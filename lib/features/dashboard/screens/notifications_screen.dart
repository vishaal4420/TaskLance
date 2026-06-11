import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/empty_error_states.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, String>> _notifications = [
    {'id': '1', 'title': 'Invoice Paid', 'body': 'Your invoice #INV-001 has been paid.', 'time': '2m ago', 'type': 'payment'},
    {'id': '2', 'title': 'New Message', 'body': 'Alex Rivera sent you a message.', 'time': '1h ago', 'type': 'message'},
    {'id': '3', 'title': 'Task Assigned', 'body': 'You were assigned to "Design System".', 'time': '3h ago', 'type': 'task'},
  ];

  void _markAllRead() {
    setState(() {
      _notifications.clear();
    });
  }

  void _dismissNotification(String id) {
    setState(() {
      _notifications.removeWhere((n) => n['id'] == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_notifications.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notifications')),
        body: const EmptyState(
          title: 'All caught up!',
          subtitle: 'You have no new notifications.',
          icon: Icons.notifications_none,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: _markAllRead,
            tooltip: 'Mark all read',
          ),
        ],
      ),
      body: ListView.separated(
        itemCount: _notifications.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final n = _notifications[i];
          final type = n['type']!;
          final iconData = type == 'payment' ? Icons.attach_money : type == 'message' ? Icons.message : Icons.check_circle;
          final color = type == 'payment' ? AppColors.secondary : type == 'message' ? AppColors.primary : AppColors.warning;

          return Dismissible(
            key: Key(n['id']!),
            direction: DismissDirection.endToStart,
            onDismissed: (_) => _dismissNotification(n['id']!),
            background: Container(
              color: AppColors.error,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.1),
                child: Icon(iconData, color: color, size: 20),
              ),
              title: Text(n['title']!, style: AppTextStyles.titleSmall),
              subtitle: Text(n['body']!, style: AppTextStyles.bodySmall.copyWith(color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
              trailing: Text(n['time']!, style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
              onTap: () => _dismissNotification(n['id']!),
            ),
          );
        },
      ),
    );
  }
}
