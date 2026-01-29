import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final List<NotificationItem> _notifications = [
    NotificationItem(
      title: "Attendance Updated",
      message: "Employee Santosh checked in at 9:05 AM.",
      time: DateTime.now().subtract(const Duration(minutes: 10)),
      isRead: false,
    ),
    NotificationItem(
      title: "Password Changed",
      message: "Your account password was changed successfully.",
      time: DateTime.now().subtract(const Duration(hours: 3)),
      isRead: true,
    ),
    NotificationItem(
      title: "System Update",
      message: "New app version available. Please update.",
      time: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
  ];

  void _markAllAsRead() {
    setState(() {
      for (var item in _notifications) {
        item.isRead = true;
      }
    });
  }

  String _formatTime(DateTime time) {
    final difference = DateTime.now().difference(time);

    if (difference.inMinutes < 60) {
      return "${difference.inMinutes} min ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} hrs ago";
    } else {
      return "${difference.inDays} days ago";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        centerTitle: true,
        actions: [
          if (_notifications.any((e) => !e.isRead))
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text("Mark all"),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? _emptyState()
          : ListView.separated(
              itemCount: _notifications.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = _notifications[index];
                return _notificationTile(item);
              },
            ),
    );
  }

  Widget _notificationTile(NotificationItem item) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor:
            item.isRead ? Colors.grey.shade300 : Colors.blue.shade100,
        child: Icon(
          Icons.notifications,
          color: item.isRead ? Colors.grey : Colors.blue,
        ),
      ),
      title: Text(
        item.title,
        style: TextStyle(
          fontWeight: item.isRead ? FontWeight.normal : FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(item.message),
          const SizedBox(height: 6),
          Text(
            _formatTime(item.time),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
      onTap: () {
        setState(() => item.isRead = true);
        // TODO: Navigate based on notification type
      },
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "No Notifications",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              "You’re all caught up. New notifications will appear here.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationItem {
  final String title;
  final String message;
  final DateTime time;
  bool isRead;

  NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    this.isRead = false,
  });
}
