import 'package:flutter/material.dart';

import '../../../controllers/insights_controller.dart';
import '../../../controllers/settings_controller.dart';
import '../../../controllers/theme_controller.dart';
import '../../../core/i18n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/controller_scope.dart';
import '../../../data/dummy_data.dart';
import '../../../models/achievement.dart';
import '../../../ui/widgets/genius_app_bar.dart';
import '../../../ui/widgets/genius_scaffold.dart';
import '../../../ui/widgets/pill_buttons.dart';
import '../../../ui/widgets/skeleton_card.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = ControllerScope.of(context).auth;
    final user = auth.user ?? DummyData.user;
    final l10n = context.l10n;
    final colors = Theme.of(context).brightness == Brightness.dark
        ? geniusTheme.dark
        : geniusTheme.light;
    final themeController = ControllerScope.of(context).theme;
    final settingsController = ControllerScope.of(context).settings;

    return GeniusScaffold(
      appBar: GeniusAppBar(
        title: l10n.translate('profile'),
        actions: [
          IconButton(
            tooltip: l10n.translate('insights'),
            icon: const Icon(Icons.auto_graph_rounded),
            onPressed: () => Navigator.of(context).pushNamed('/insights'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(user.avatarUrl),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name, style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 4),
                    Text(
                      user.bio,
                      style:
                          Theme.of(context).textTheme.bodyMedium?.copyWith(color: colors.inkSecondary),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: user.stats.entries
                          .map(
                            (entry) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(pillRadius.toDouble()),
                                border: Border.all(color: colors.outline, width: geniusStrokeWidth),
                                color: colors.surface.withOpacity(0.9),
                              ),
                              child: Text('${entry.value} ${entry.key}'),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _CreatorSnapshot(colors: colors),
          const SizedBox(height: 24),
          _AchievementsHighlights(colors: colors),
          const SizedBox(height: 32),
          Text(
            l10n.translate('profile_personalize'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _ThemeLanguageControls(
            colors: colors,
            themeController: themeController,
            settingsController: settingsController,
          ),
          const SizedBox(height: 32),
          Text(
            l10n.translate('profile_creator_tools'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              SizedBox(
                width: 220,
                child: FilledPillButton(
                  label: l10n.translate('insights_open'),
                  onPressed: () => Navigator.of(context).pushNamed('/insights'),
                ),
              ),
              SizedBox(
                width: 220,
                child: OutlinedPillButton(
                  label: l10n.translate('drafts'),
                  onPressed: () => Navigator.of(context).pushNamed('/drafts'),
                ),
              ),
              SizedBox(
                width: 220,
                child: OutlinedPillButton(
                  label: l10n.translate('downloads'),
                  onPressed: () => Navigator.of(context).pushNamed('/downloads'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(l10n.translate('profile_playlists'), style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          ...List.generate(4, (index) => _PlaylistTile(index: index, colors: colors)),
        ],
      ),
    );
  }
}

class _CreatorSnapshot extends StatelessWidget {
  const _CreatorSnapshot({required this.colors});

  final GeniusColors colors;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ControllerScope.of(context).insights,
      builder: (context, _) {
        final InsightsController insights = ControllerScope.of(context).insights;
        final state = insights.state;
        final theme = Theme.of(context);

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radiusLg),
            border: Border.all(color: colors.outline, width: geniusStrokeWidth),
            color: colors.surface.withOpacity(0.9),
          ),
          child: state.isLoading
              ? Row(
                  children: const [
                    Expanded(child: LinearProgressIndicator()),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.translate('insights_glance'),
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.primaryMetric.title,
                            style: theme.textTheme.headlineSmall,
                          ),
                          Text(
                            '${state.primaryMetric.value}',
                            style: theme.textTheme.displaySmall,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            context.l10n.translate('profile_prompt_insights'),
                            style:
                                theme.textTheme.bodyMedium?.copyWith(color: colors.inkSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        FilledPillButton(
                          label: context.l10n.translate('insights_open'),
                          onPressed: () => Navigator.of(context).pushNamed('/insights'),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          context.l10n
                              .translate('insights_last_updated')
                              .replaceFirst('{time}', _formatTime(state.updatedAt)),
                          style: theme.textTheme.labelSmall?.copyWith(color: colors.inkSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    final difference = DateTime.now().difference(time);
    if (difference.inMinutes < 1) {
      return 'just now';
    }
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours}h';
    }
    return '${difference.inDays}d';
  }
}

class _ThemeLanguageControls extends StatelessWidget {
  const _ThemeLanguageControls({
    required this.colors,
    required this.themeController,
    required this.settingsController,
  });

  final GeniusColors colors;
  final ThemeController themeController;
  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final List<Color> paletteOptions = <Color>[
      themeController.primaryColor,
      const Color(0xFFFF6584),
      const Color(0xFF4DD0E1),
      const Color(0xFFA3E635),
      const Color(0xFF7C4DFF),
    ];
    return AnimatedBuilder(
      animation: Listenable.merge([themeController, settingsController]),
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radiusLg),
            border: Border.all(color: colors.outline, width: geniusStrokeWidth),
            color: colors.surface.withOpacity(0.92),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.translate('profile_dark_mode'),
                    style: theme.textTheme.titleMedium,
                  ),
                  Switch.adaptive(
                    value: themeController.isDark,
                    onChanged: themeController.toggleDarkMode,
                    activeColor: theme.colorScheme.primary,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                l10n.translate('profile_primary_pick'),
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: paletteOptions.map((color) {
                  final bool selected = themeController.primaryColor.value == color.value;
                  return GestureDetector(
                    onTap: () => themeController.setPrimary(color),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected ? theme.colorScheme.onPrimary : colors.outline,
                          width: selected ? 3 : geniusStrokeWidth,
                        ),
                      ),
                      child: selected
                          ? Icon(Icons.check, color: theme.colorScheme.onPrimary)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.translate('profile_language'),
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children: [
                  _LanguageChip(
                    label: l10n.translate('profile_language_en'),
                    selected: settingsController.state.languageCode == 'en',
                    onSelected: () => settingsController.setLanguage('en'),
                  ),
                  _LanguageChip(
                    label: l10n.translate('profile_language_ar'),
                    selected: settingsController.state.languageCode == 'ar',
                    onSelected: () => settingsController.setLanguage('ar'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LanguageChip extends StatelessWidget {
  const _LanguageChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.geniusPalette;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: selected ? Theme.of(context).colorScheme.onPrimary : palette.ink,
          ),
      selectedColor: Theme.of(context).colorScheme.primary,
      backgroundColor: palette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        side: BorderSide(color: selected ? Theme.of(context).colorScheme.primary : palette.outline, width: geniusStrokeWidth),
      ),
    );
  }
}

class _AchievementsHighlights extends StatelessWidget {
  const _AchievementsHighlights({required this.colors});

  final GeniusColors colors;

  @override
  Widget build(BuildContext context) {
    final achievements = ControllerScope.of(context).achievements;
    final l10n = context.l10n;
    return AnimatedBuilder(
      animation: achievements,
      builder: (context, _) {
        final state = achievements.state;
        if (state.isLoading && state.achievements.isEmpty) {
          return const SkeletonCard(height: 200);
        }
        final recent = state.recentlyUnlocked.take(3).toList();
        final pinned = state.pinned.take(3).toList();
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(radiusLg),
            border: Border.all(color: colors.outline, width: geniusStrokeWidth),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.translate('achievements'),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pushNamed('/achievements'),
                    style: TextButton.styleFrom(foregroundColor: colors.ink),
                    child: Text(l10n.translate('view_all')),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                l10n.translate('achievements_title'),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: colors.inkSecondary),
              ),
              if (recent.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  l10n.translate('achievements_recent'),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 16,
                  runSpacing: 14,
                  children: recent
                      .map((achievement) => _ProfileAchievementBadge(
                            achievement: achievement,
                            colors: colors,
                          ))
                      .toList(),
                ),
              ]
              else ...[
                const SizedBox(height: 16),
                Text(
                  l10n.translate('achievements_empty_recent'),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: colors.inkSecondary),
                ),
              ],
              if (pinned.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  l10n.translate('achievements_pinned'),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 16,
                  runSpacing: 14,
                  children: pinned
                      .map((achievement) => _ProfileAchievementBadge(
                            achievement: achievement,
                            colors: colors,
                            compact: true,
                          ))
                      .toList(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ProfileAchievementBadge extends StatelessWidget {
  const _ProfileAchievementBadge({
    required this.achievement,
    required this.colors,
    this.compact = false,
  });

  final Achievement achievement;
  final GeniusColors colors;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final Color iconColor = achievement.isUnlocked
        ? theme.colorScheme.primary
        : colors.ink;
    final double width = compact ? 190 : 220;
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(radiusMd),
          border: Border.all(color: colors.outline, width: geniusStrokeWidth),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(achievement.icon, color: iconColor, size: 24),
            const SizedBox(height: 12),
            Text(
              achievement.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 6),
            Text(
              achievement.description,
              maxLines: compact ? 2 : 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.inkSecondary,
                height: 1.35,
              ),
            ),
            if (achievement.highlight != null) ...[
              const SizedBox(height: 8),
              Text(
                achievement.highlight!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(color: colors.inkSecondary),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              achievement.isUnlocked
                  ? l10n.translate('achievements_unlocked')
                  : '${achievement.progress}/${achievement.target}',
              style: theme.textTheme.labelLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaylistTile extends StatelessWidget {
  const _PlaylistTile({required this.index, required this.colors});

  final int index;
  final GeniusColors colors;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface.withOpacity(0.85),
        borderRadius: BorderRadius.circular(radiusMd),
        border: Border.all(color: colors.outline, width: geniusStrokeWidth),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radiusSm),
              border: Border.all(color: colors.outline, width: geniusStrokeWidth),
            ),
            child: const Icon(Icons.queue_music_rounded),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Playlist ${index + 1}', style: theme.textTheme.titleMedium),
                Text(
                  'Curated sound journeys',
                  style: theme.textTheme.bodySmall?.copyWith(color: colors.inkSecondary),
                ),
              ],
            ),
          ),
          FilledPillButton(
            label: context.l10n.translate('play'),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
