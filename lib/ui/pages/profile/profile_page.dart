import 'package:flutter/material.dart';

import '../../../controllers/auth_controller.dart';
import '../../../core/utils/controller_scope.dart';
import '../../../data/dummy_data.dart';
import '../../widgets/genius_scaffold.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = ControllerScope.of(context).auth;
    final user = auth.user ?? DummyData.user;
    return GeniusScaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundImage: NetworkImage(user.avatarUrl),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name, style: Theme.of(context).textTheme.titleLarge),
                    Text(user.bio),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              children: user.stats.entries
                  .map(
                    (e) => Chip(
                      label: Text('${e.key}: ${e.value}'),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
            const Text('Playlists'),
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.queue_music),
                    title: Text('Playlist ${index + 1}'),
                    subtitle: const Text('Curated stories'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
