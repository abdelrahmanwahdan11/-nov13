import 'package:flutter/material.dart';

import '../../../core/i18n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/controller_scope.dart';
import '../../widgets/genius_app_bar.dart';
import '../../widgets/genius_scaffold.dart';
import '../../widgets/pill_buttons.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = ControllerScope.of(context).settings;
    final theme = ControllerScope.of(context).theme;
    final auth = ControllerScope.of(context).auth;
    final l10n = context.l10n;

    return GeniusScaffold(
      appBar: GeniusAppBar(title: l10n.translate('settings')),
      body: AnimatedBuilder(
        animation: Listenable.merge([settings, theme, auth]),
        builder: (context, _) {
          final settingsState = settings.state;
          final palette = context.geniusPalette;
          final themeController = theme;
          final authController = auth;
          final user = authController.user;
          final isGuest = authController.isGuest;
          final colorOptions = <Color>[
            const Color(0xFFFFB703),
            const Color(0xFFFF6F61),
            const Color(0xFF00BFA5),
            const Color(0xFF7C4DFF),
            const Color(0xFF2196F3),
          ];

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
            children: [
              _SettingSection(
                title: l10n.translate('settings_account_section'),
                palette: palette,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: palette.accent,
                          backgroundImage:
                              user != null ? NetworkImage(user.avatarUrl) : null,
                          child: user == null
                              ? Icon(Icons.person_outline, color: palette.ink)
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isGuest
                                    ? l10n.translate('settings_account_guest')
                                    : '${l10n.translate('settings_account_signed_in')} ${user?.name ?? ''}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                isGuest
                                    ? l10n.translate('settings_account_guest_hint')
                                    : (user?.bio ?? ''),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: palette.inkSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        FilledPillButton(
                          label: isGuest
                              ? l10n.translate('settings_account_sign_in')
                              : l10n.translate('settings_account_manage'),
                          onPressed: () {
                            if (isGuest) {
                              Navigator.of(context).pushNamed('/auth/signin');
                            } else {
                              Navigator.of(context).pushNamed('/profile');
                            }
                          },
                        ),
                        OutlinedPillButton(
                          label: isGuest
                              ? l10n.translate('settings_account_create')
                              : l10n.translate('settings_account_sign_out'),
                          onPressed: () {
                            if (isGuest) {
                              Navigator.of(context).pushNamed('/auth/signup');
                            } else {
                              authController.signOut();
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _SettingSection(
                title: l10n.translate('settings_theme_section'),
                palette: palette,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.translate('settings_theme_mode'),
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _SelectablePill(
                          label: l10n.translate('settings_theme_light'),
                          selected: !themeController.isDark,
                          onTap: () => themeController.toggleDarkMode(false),
                        ),
                        _SelectablePill(
                          label: l10n.translate('settings_theme_dark'),
                          selected: themeController.isDark,
                          onTap: () => themeController.toggleDarkMode(true),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.translate('settings_primary_color'),
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 16,
                      children: [
                        for (final color in colorOptions)
                          _ColorChoice(
                            color: color,
                            selected: themeController.primaryColor.value == color.value,
                            onTap: () => themeController.setPrimary(color),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.translate('settings_primary_color_hint'),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: palette.inkSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _SettingSection(
                title: l10n.translate('settings_experience_section'),
                palette: palette,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.translate('settings_language'),
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _SelectablePill(
                          label: l10n.translate('settings_language_en'),
                          selected: settingsState.languageCode == 'en',
                          onTap: () => settings.setLanguage('en'),
                        ),
                        _SelectablePill(
                          label: l10n.translate('settings_language_ar'),
                          selected: settingsState.languageCode == 'ar',
                          onTap: () => settings.setLanguage('ar'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _SettingToggle(
                      label: l10n.translate('settings_notifications'),
                      value: settingsState.notifications,
                      onChanged: settings.setNotifications,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.translate('settings_audio_quality'),
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        for (final quality in const [64, 96, 128])
                          _SelectablePill(
                            label:
                                '$quality ${l10n.translate('settings_audio_quality_unit')}',
                            selected: settingsState.audioQuality == quality,
                            onTap: () => settings.setAudioQuality(quality),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _SettingSection(
                title: l10n.translate('settings_privacy_section'),
                palette: palette,
                child: Column(
                  children: [
                    _SettingToggle(
                      label: l10n.translate('settings_privacy_searchable'),
                      value: settingsState.privacyFlags['searchable'] ?? true,
                      onChanged: (value) =>
                          settings.togglePrivacy('searchable', value),
                    ),
                    const SizedBox(height: 16),
                    _SettingToggle(
                      label: l10n.translate('settings_privacy_share_stats'),
                      value: settingsState.privacyFlags['share_stats'] ?? false,
                      onChanged: (value) =>
                          settings.togglePrivacy('share_stats', value),
                    ),
                    const SizedBox(height: 16),
                    _SettingToggle(
                      label: l10n.translate('settings_privacy_allow_messages'),
                      value: settingsState.privacyFlags['allow_messages'] ?? true,
                      onChanged: (value) =>
                          settings.togglePrivacy('allow_messages', value),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SettingSection extends StatelessWidget {
  const _SettingSection({
    required this.title,
    required this.child,
    required this.palette,
  });

  final String title;
  final Widget child;
  final GeniusPalette palette;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style:
              Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.85),
            borderRadius: BorderRadius.circular(geniusRadiusLarge),
            border: Border.all(color: palette.outline, width: geniusStrokeWidth),
          ),
          child: child,
        ),
      ],
    );
  }
}

class _SelectablePill extends StatelessWidget {
  const _SelectablePill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.geniusPalette;
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(geniusPillRadius),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(geniusPillRadius),
            border: Border.all(
              color: selected ? colorScheme.primary : palette.outline,
              width: geniusStrokeWidth,
            ),
            color: selected
                ? colorScheme.primary.withOpacity(0.18)
                : Colors.transparent,
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: selected ? colorScheme.primary : palette.ink,
                ),
          ),
        ),
      ),
    );
  }
}

class _ColorChoice extends StatelessWidget {
  const _ColorChoice({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.geniusPalette;
    final borderColor = selected ? Theme.of(context).colorScheme.primary : palette.outline;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: geniusStrokeWidth),
        ),
        child: CircleAvatar(
          radius: 22,
          backgroundColor: color,
          child: selected
              ? Icon(
                  Icons.check,
                  color: Colors.black.withOpacity(0.8),
                )
              : null,
        ),
      ),
    );
  }
}

class _SettingToggle extends StatelessWidget {
  const _SettingToggle({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.geniusPalette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(geniusRadiusMedium),
        border: Border.all(color: palette.outline, width: geniusStrokeWidth),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
