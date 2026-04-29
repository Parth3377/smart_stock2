// ════════════════════════════════════════════════════════════════════
//  lib/providers/admin_notification_provider.dart
//
//  Streams 'admin_notifications' Firestore collection in real-time.
//  Drives the bell badge count and the notification dropdown panel
//  in the Admin Shell top bar.
// ════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ── Notification model ────────────────────────────────────────────
class AdminNotif {
  final String   id, type, title, body, screen;
  final DateTime time;
  bool           isRead;

  AdminNotif({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.screen,
    required this.time,
    this.isRead = false,
  });

  IconData get icon {
    switch (type) {
      case 'purchase_arrived': return Icons.inventory_2_rounded;
      case 'new_sale':         return Icons.shopping_cart_rounded;
      case 'supplier_added':   return Icons.business_rounded;
      case 'stock_transfer':   return Icons.swap_horiz_rounded;
      case 'low_stock':        return Icons.warning_amber_rounded;
      case 'out_of_stock':     return Icons.cancel_rounded;
      default:                 return Icons.notifications_rounded;
    }
  }

  Color get color {
    switch (type) {
      case 'purchase_arrived': return const Color(0xFF22C55E);  // green
      case 'new_sale':         return const Color(0xFF2E6CF6);  // blue
      case 'supplier_added':   return const Color(0xFF845EF7);  // purple
      case 'stock_transfer':   return const Color(0xFF0EA5E9);  // cyan
      case 'low_stock':        return const Color(0xFFF97316);  // orange
      case 'out_of_stock':     return const Color(0xFFEF4444);  // red
      default:                 return const Color(0xFF6B7280);  // grey
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

// ── Provider ──────────────────────────────────────────────────────
class AdminNotificationProvider extends ChangeNotifier {
  final List<AdminNotif> _notifs      = [];
  StreamSubscription?    _sub;

  List<AdminNotif> get all         => _notifs;
  int              get unreadCount => _notifs.where((n) => !n.isRead).length;
  bool             get hasUnread   => unreadCount > 0;

  // Call this once in AdminShell.initState()
  void startListening() {
    _sub?.cancel();
    _sub = FirebaseFirestore.instance
        .collection('admin_notifications')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .listen(
          (snap) {
        _notifs.clear();
        for (final doc in snap.docs) {
          final d = doc.data();
          _notifs.add(AdminNotif(
            id:     doc.id,
            type:   d['type']   as String? ?? 'general',
            title:  d['title']  as String? ?? '',
            body:   d['body']   as String? ?? '',
            screen: d['screen'] as String? ?? 'dashboard',
            time:   (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            isRead: d['isRead'] as bool? ?? false,
          ));
        }
        notifyListeners();
      },
      onError: (_) {/* silently ignore */},
    );
  }

  // Mark individual notification as read
  Future<void> markRead(String id) async {
    final i = _notifs.indexWhere((n) => n.id == id);
    if (i != -1) { _notifs[i].isRead = true; notifyListeners(); }
    FirebaseFirestore.instance
        .collection('admin_notifications')
        .doc(id)
        .update({'isRead': true})
        .catchError((_) {});
  }

  // Mark all notifications as read
  Future<void> markAllRead() async {
    for (final n in _notifs) { n.isRead = true; }
    notifyListeners();
    // Batch update Firestore
    final batch = FirebaseFirestore.instance.batch();
    for (final n in _notifs) {
      batch.update(
        FirebaseFirestore.instance.collection('admin_notifications').doc(n.id),
        {'isRead': true},
      );
    }
    batch.commit().catchError((_) {});
  }

  @override
  void dispose() { _sub?.cancel(); super.dispose(); }
}