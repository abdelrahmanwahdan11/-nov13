import 'package:flutter/material.dart';

import '../../widgets/genius_scaffold.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = List.generate(
      12,
      (index) => index.isEven ? 'New like on your track' : 'New follower joined',
    );
    return GeniusScaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future<void>.delayed(const Duration(milliseconds: 400));
        },
        child: ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final text = notifications[index];
            return ListTile(
              leading: const Icon(Icons.notifications_active_outlined),
              title: Text(text),
              subtitle: Text('2h ago'),
            );
          },
        ),
      ),
    );
  }
}
