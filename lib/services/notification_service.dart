// ════════════════════════════════════════════════════════════════════
//  lib/services/notification_service.dart
//
//  Firebase Cloud Messaging — Client & Admin push notifications.
//  Also stores notifications in Firestore "notifications" collection.
// ════════════════════════════════════════════════════════════════════

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

/// Background message handler — must be top-level function.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background FCM: ${message.messageId}');
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _fcm = FirebaseMessaging.instance;
  final _db = FirebaseFirestore.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  // ════════════════════════════════════════════════════════════════════
  //  INITIALISE (call once in main() after Firebase.initializeApp())
  // ════════════════════════════════════════════════════════════════════
  Future<void> init() async {
    // Background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request permission (iOS/Android 13+)
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Local notifications channel (Android)
    const androidChannel = AndroidNotificationChannel(
      'smartstock_channel',
      'SmartStock Notifications',
      description: 'Order and inventory notifications',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    // Init local notifications plugin
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _localNotifications.initialize(initSettings);

    // Save FCM token when user is logged in
    await _saveTokenToFirestore();

    // Listen for token refresh
    _fcm.onTokenRefresh.listen(_updateToken);

    // Foreground message listener → show local notification
    FirebaseMessaging.onMessage.listen((message) {
      _showLocalNotification(message);
      _saveNotificationToFirestore(message);
    });
  }

  // ════════════════════════════════════════════════════════════════════
  //  TOKEN MANAGEMENT
  // ════════════════════════════════════════════════════════════════════
  Future<void> _saveTokenToFirestore() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final token = await _fcm.getToken();
    if (token == null) return;
    await _db.collection('users').doc(uid).update({'fcmToken': token});
  }

  Future<void> _updateToken(String token) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _db.collection('users').doc(uid).update({'fcmToken': token});
  }

  // ════════════════════════════════════════════════════════════════════
  //  SEND NOTIFICATIONS (via Firestore — Cloud Function delivers FCM)
  //  Since we cannot call FCM HTTP API directly from client code,
  //  we write to a "notifications_queue" collection. A Cloud Function
  //  triggers on that write and sends the actual FCM message.
  // ════════════════════════════════════════════════════════════════════

  /// Order status notification to client
  Future<void> sendOrderNotification({
    required String userId,
    required String orderId,
    required String status,
  }) async {
    String title;
    String body;

    switch (status) {
      case 'Confirmed':
        title = 'Order Confirmed ✅';
        body = 'Your order #${orderId.substring(0, 6)} has been confirmed.';
        break;
      case 'Shipped':
        title = 'Order Shipped 🚚';
        body = 'Your order is on the way!';
        break;
      case 'Delivered':
        title = 'Order Delivered 🎉';
        body = 'Your order has been delivered. Thank you!';
        break;
      case 'Cancelled':
        title = 'Order Cancelled';
        body = 'Your order #${orderId.substring(0, 6)} was cancelled.';
        break;
      default:
        title = 'Order Update';
        body = 'Order status: $status';
    }

    await _queueNotification(
      toUserId: userId,
      title: title,
      body: body,
      data: {'orderId': orderId, 'type': 'order_update', 'status': status},
    );
  }

  /// New order notification to admin
  Future<void> sendAdminNewOrderNotification({
    required String orderId,
    required String customerName,
    required double amount,
  }) async {
    await _queueNotification(
      toUserId: 'admin',  // Cloud Function resolves admin FCM token
      title: 'New Order Received 🛒',
      body: '$customerName placed an order of ₹${amount.toStringAsFixed(0)}',
      data: {'orderId': orderId, 'type': 'new_order'},
    );
  }

  /// Low stock alert to admin
  Future<void> sendLowStockAlert({
    required String productName,
    required int currentStock,
  }) async {
    await _queueNotification(
      toUserId: 'admin',
      title: 'Low Stock Alert ⚠️',
      body: '"$productName" has only $currentStock units remaining.',
      data: {'type': 'low_stock', 'product': productName},
    );
  }

  Future<void> _queueNotification({
    required String toUserId,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    // Write to notifications collection (for in-app notification list)
    final notifRef = _db.collection('notifications').doc();
    await notifRef.set({
      'id': notifRef.id,
      'toUserId': toUserId,
      'title': title,
      'body': body,
      'data': data,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Also write to queue for Cloud Function to send FCM push
    await _db.collection('notifications_queue').add({
      'toUserId': toUserId,
      'title': title,
      'body': body,
      'data': data,
      'processed': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ════════════════════════════════════════════════════════════════════
  //  LOCAL NOTIFICATION (foreground)
  // ════════════════════════════════════════════════════════════════════
  void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'smartstock_channel',
          'SmartStock Notifications',
          channelDescription: 'Order and inventory notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  //  SAVE INCOMING NOTIFICATION TO FIRESTORE (for notification list)
  // ════════════════════════════════════════════════════════════════════
  Future<void> _saveNotificationToFirestore(RemoteMessage message) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await _db.collection('notifications').add({
      'toUserId': uid,
      'title': message.notification?.title ?? '',
      'body': message.notification?.body ?? '',
      'data': message.data,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ── STREAM: Notifications for current user ─────────────────────────
  Stream<List<Map<String, dynamic>>> streamMyNotifications() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _db
        .collection('notifications')
        .where('toUserId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((s) => s.docs
            .map((d) => {'id': d.id, ...d.data()})
            .toList());
  }

  // ── MARK AS READ ────────────────────────────────────────────────────
  Future<void> markAsRead(String notificationId) async {
    await _db
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  // ── MARK ALL READ ───────────────────────────────────────────────────
  Future<void> markAllRead() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final batch = _db.batch();
    final snap = await _db
        .collection('notifications')
        .where('toUserId', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .get();

    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }
}
