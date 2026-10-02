import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/notifications_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationsProvider>().fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationsProvider>();
    final notifications = provider.notifications;
    final isLoading = provider.status == NotificationsStatus.loading;

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: isLoading && notifications.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('No notifications.'),
                      if (provider.errorMessage != null)
                        Text('Error: ${provider.errorMessage}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.read<NotificationsProvider>().fetchNotifications(),
                        child: const Text('Refresh'),
                      )
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final note = notifications[index];
                    return ListTile(
                      title: Text(note.title, style: TextStyle(fontWeight: note.isRead ? FontWeight.normal : FontWeight.bold)),
                      subtitle: Text(note.body),
                      trailing: !note.isRead
                          ? const CircleAvatar(radius: 4, backgroundColor: Colors.red)
                          : null,
                      onTap: () {
                        if (!note.isRead) {
                          context.read<NotificationsProvider>().markAsRead(note.id);
                        }
                      },
                    );
                  },
                ),
    );
  }
}
