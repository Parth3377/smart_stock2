// ════════════════════════════════════════════════════════════════════
//  lib/screens/settings/notifications_screen.dart
// ════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {

  @override
  void initState() {
    super.initState();
    // Mark all read when opening
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().markAllRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<NotificationProvider>();
    final notifications = prov.notifications;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1218),
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFF161A22),
        elevation: 0,
        actions: [
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: () => prov.clearNotifications(),
              child: const Text('Clear all',
                  style: TextStyle(color: Colors.red, fontSize: 13)),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? _emptyState()
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (ctx, i) => _NotifCard(notif: notifications[i]),
      ),
    );
  }

  Widget _emptyState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.notifications_none,
            size: 80, color: Colors.white.withOpacity(0.15)),
        const SizedBox(height: 16),
        const Text('No notifications yet',
            style: TextStyle(color: Colors.white54, fontSize: 16)),
        const SizedBox(height: 8),
        const Text('Order updates and alerts will appear here',
            style: TextStyle(color: Colors.white38, fontSize: 13)),
      ],
    ),
  );
}

class _NotifCard extends StatelessWidget {
  final AppNotification notif;
  const _NotifCard({required this.notif});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: notif.isRead
          ? const Color(0xFF161A22)
          : const Color(0xFF1C2333),
      borderRadius: BorderRadius.circular(14),
      border: notif.isRead
          ? null
          : Border.all(color: notif.color.withOpacity(0.3)),
    ),
    child: Row(children: [

      // Icon circle
      Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: notif.color.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(notif.icon, color: notif.color, size: 20),
      ),

      const SizedBox(width: 12),

      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(
              child: Text(notif.title,
                  style: const TextStyle(color: Colors.white,
                      fontWeight: FontWeight.w600, fontSize: 14),
                  overflow: TextOverflow.ellipsis),
            ),
            if (!notif.isRead)
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(color: notif.color,
                    shape: BoxShape.circle),
              ),
          ]),
          const SizedBox(height: 4),
          Text(notif.body,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
              maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          Text(notif.timeAgo,
              style: const TextStyle(color: Colors.white38, fontSize: 11)),
        ]),
      ),
    ]),
  );
}



// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../providers/notification_provider.dart';
//
// class NotificationsScreen extends StatelessWidget {
//   const NotificationsScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//
//     final notificationProvider =
//     Provider.of<NotificationProvider>(context);
//
//     final notifications = notificationProvider.notifications;
//
//     return Scaffold(
//       backgroundColor: const Color(0xFF0F1218),
//
//       appBar: AppBar(
//         title: const Text("Notifications"),
//         backgroundColor: const Color(0xFF161A22),
//         elevation: 0,
//
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.delete_outline),
//             onPressed: () {
//               notificationProvider.clearNotifications();
//             },
//           )
//         ],
//       ),
//
//       body: notifications.isEmpty
//           ? const Center(
//         child: Text(
//           "No notifications yet",
//           style: TextStyle(color: Colors.white70),
//         ),
//       )
//           : ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: notifications.length,
//         itemBuilder: (context, index) {
//
//           final note = notifications[index];
//
//           return Container(
//             margin: const EdgeInsets.only(bottom: 12),
//             padding: const EdgeInsets.all(16),
//
//             decoration: BoxDecoration(
//               color: const Color(0xFF161A22),
//               borderRadius: BorderRadius.circular(16),
//             ),
//
//             child: Row(
//               children: [
//
//                 const Icon(
//                   Icons.notifications,
//                   color: Color(0xFF2E6CF6),
//                 ),
//
//                 const SizedBox(width: 12),
//
//                 Expanded(
//                   child: Text(
//                     note,
//                     style: const TextStyle(color: Colors.white),
//                   ),
//                 )
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }