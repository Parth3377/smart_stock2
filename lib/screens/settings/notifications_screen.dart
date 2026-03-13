import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/notification_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final notificationProvider =
    Provider.of<NotificationProvider>(context);

    final notifications = notificationProvider.notifications;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1218),

      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: const Color(0xFF161A22),
        elevation: 0,

        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              notificationProvider.clearNotifications();
            },
          )
        ],
      ),

      body: notifications.isEmpty
          ? const Center(
        child: Text(
          "No notifications yet",
          style: TextStyle(color: Colors.white70),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {

          final note = notifications[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),

            decoration: BoxDecoration(
              color: const Color(0xFF161A22),
              borderRadius: BorderRadius.circular(16),
            ),

            child: Row(
              children: [

                const Icon(
                  Icons.notifications,
                  color: Color(0xFF2E6CF6),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    note,
                    style: const TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}