import 'package:flutter/material.dart';

import '../../../controllers/settings_controller.dart';
import '../../../controllers/theme_controller.dart';
import '../../../core/utils/controller_scope.dart';
import '../../widgets/genius_scaffold.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = ControllerScope.of(context).settings;
    final theme = ControllerScope.of(context).theme;
    return GeniusScaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: AnimatedBuilder(
        animation: Listenable.merge([settings, theme]),
        builder: (context, _) {
          final state = settings.state;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SwitchListTile(
                value: theme.isDark,
                onChanged: theme.toggleDarkMode,
                title: const Text('Dark Mode'),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                children: [
                  for (final color in [Colors.amber, Colors.deepOrange, Colors.teal, Colors.pink])
                    GestureDetector(
                      onTap: () => theme.setPrimary(color),
                      child: CircleAvatar(
                        backgroundColor: color,
                        radius: 20,
                        child: theme.primaryColor == color
                            ? const Icon(Icons.check, color: Colors.black)
                            : null,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                value: state.languageCode,
                decoration: const InputDecoration(labelText: 'Language'),
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'ar', child: Text('العربية')),
                ],
                onChanged: (value) => settings.setLanguage(value ?? 'en'),
              ),
              SwitchListTile(
                value: state.notifications,
                onChanged: settings.setNotifications,
                title: const Text('Notifications'),
              ),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Privacy'),
                  CheckboxListTile(
                    value: state.privacyFlags['searchable'] ?? true,
                    onChanged: (value) => settings.togglePrivacy('searchable', value ?? true),
                    title: const Text('Appear in search'),
                  ),
                  CheckboxListTile(
                    value: state.privacyFlags['share_stats'] ?? false,
                    onChanged: (value) => settings.togglePrivacy('share_stats', value ?? false),
                    title: const Text('Share stats publicly'),
                  ),
                  CheckboxListTile(
                    value: state.privacyFlags['allow_messages'] ?? true,
                    onChanged: (value) => settings.togglePrivacy('allow_messages', value ?? true),
                    title: const Text('Allow messages'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: state.audioQuality,
                decoration: const InputDecoration(labelText: 'Audio Quality (kbps)'),
                items: const [
                  DropdownMenuItem(value: 64, child: Text('64 kbps')),
                  DropdownMenuItem(value: 96, child: Text('96 kbps')),
                  DropdownMenuItem(value: 128, child: Text('128 kbps')),
                ],
                onChanged: (value) => settings.setAudioQuality(value ?? 96),
              ),
            ],
          );
        },
      ),
    );
  }
}
