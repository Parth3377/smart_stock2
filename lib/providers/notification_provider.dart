// ════════════════════════════════════════════════════════════════════
//  lib/providers/notification_provider.dart
//
//  In-app notification store — saves to Firestore in background.
//  Used by dashboard bell and profile notifications screen.
// ════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final String type;     // order_placed | cart_add | confirmed | low_stock | etc.
  final String? orderId;
  final DateTime time;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.orderId,
    required this.time,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() => {
    'id':      id,
    'title':   title,
    'body':    body,
    'type':    type,
    'orderId': orderId ?? '',
    'time':    FieldValue.serverTimestamp(),
    'isRead':  isRead,
  };

  IconData get icon {
    switch (type) {
      case 'order_placed':   return Icons.shopping_bag_outlined;
      case 'order_confirmed':return Icons.check_circle_outline;
      case 'order_delivered':return Icons.local_shipping_outlined;
      case 'cart_add':       return Icons.add_shopping_cart_outlined;
      case 'location_set':   return Icons.location_on_outlined;
      case 'low_stock':      return Icons.warning_amber_outlined;
      case 'stock_transfer': return Icons.swap_horiz_rounded;
      default:               return Icons.notifications_outlined;
    }
  }

  Color get color {
    switch (type) {
      case 'order_placed':   return const Color(0xFF2E6CF6);
      case 'order_confirmed':return Colors.green;
      case 'order_delivered':return Colors.teal;
      case 'cart_add':       return Colors.orange;
      case 'location_set':   return Colors.purple;
      case 'low_stock':      return Colors.red;
      case 'stock_transfer': return Colors.indigo;
      default:               return Colors.blueGrey;
    }
  }

  String get timeAgo {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1)  return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24)   return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class NotificationProvider extends ChangeNotifier {

  final List<AppNotification> _notifications = [];

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  bool get hasUnread  => unreadCount > 0;

  // Legacy getter kept for backward compatibility
  List<String> get notificationStrings =>
      _notifications.map((n) => n.body).toList();

  // ── ADD NOTIFICATION ───────────────────────────────────────────────
  void addNotification({
    required String title,
    required String body,
    required String type,
    String? orderId,
  }) {
    final notif = AppNotification(
      id:      DateTime.now().millisecondsSinceEpoch.toString(),
      title:   title,
      body:    body,
      type:    type,
      orderId: orderId,
      time:    DateTime.now(),
    );

    _notifications.insert(0, notif);
    notifyListeners();

    // Save to Firestore in background
    _saveToFirestore(notif).catchError((_) {});
  }

  Future<void> _saveToFirestore(AppNotification n) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .doc(n.id)
        .set(n.toMap());
  }

  // ── LOAD FROM FIRESTORE ────────────────────────────────────────────
  Future<void> loadFromFirestore() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final snap = await FirebaseFirestore.instance
          .collection('users').doc(uid)
          .collection('notifications')
          .orderBy('time', descending: true)
          .limit(50)
          .get();

      _notifications.clear();
      for (final doc in snap.docs) {
        final d = doc.data();
        _notifications.add(AppNotification(
          id:      d['id']      as String? ?? doc.id,
          title:   d['title']   as String? ?? '',
          body:    d['body']    as String? ?? '',
          type:    d['type']    as String? ?? 'general',
          orderId: d['orderId'] as String?,
          time:    (d['time'] as Timestamp?)?.toDate() ?? DateTime.now(),
          isRead:  d['isRead']  as bool? ?? false,
        ));
      }
      notifyListeners();
    } catch (_) {}
  }

  // ── MARK ALL READ ──────────────────────────────────────────────────
  void markAllRead() {
    for (final n in _notifications) { n.isRead = true; }
    notifyListeners();
  }

  // ── CLEAR ──────────────────────────────────────────────────────────
  void clearNotifications() {
    _notifications.clear();
    notifyListeners();

    // Clear from Firestore in background
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    FirebaseFirestore.instance
        .collection('users').doc(uid)
        .collection('notifications')
        .get()
        .then((snap) {
      for (final doc in snap.docs) { doc.reference.delete(); }
    }).catchError((_) {});
  }
}