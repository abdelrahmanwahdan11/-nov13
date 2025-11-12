import 'package:flutter/material.dart';

import '../../../controllers/achievements_controller.dart';
import '../../../core/i18n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/controller_scope.dart';
import '../../../models/achievement.dart';
import '../../widgets/genius_app_bar.dart';
import '../../widgets/genius_scaffold.dart';
import '../../widgets/pill_buttons.dart';
import '../../widgets/skeleton_card.dart';

class AchievementsPage extends StatefulWidget {
  const AchievementsPage({super.key});

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  AchievementsController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = ControllerScope.of(context).achievements;
    if (identical(_controller, controller)) return;
    _controller?.removeListener(_onChanged);
    _controller = controller..addListener(_onChanged);
    controller.ensureLoaded();
  }

  @override
  void dispose() {
    _controller?.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) {
      return const SizedBox.shrink();
    }
    final state = controller.state;
    final l10n = context.l10n;
    final colors = Theme.of(context).brightness == Brightness.dark
        ? geniusTheme.dark
        : geniusTheme.light;

    return GeniusScaffold(
      appBar: GeniusAppBar(
        title: l10n.translate('achievements'),
        actions: [
          IconButton(
            tooltip: l10n.translate('refresh'),
            icon: const Icon(Icons.refresh_rounded),
            onPressed: state.isLoading || state.isRefreshing
                ? null
                : () => controller.refresh(),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 320),
        child: state.isLoading
            ? const _AchievementsSkeleton()
            : RefreshIndicator(
                onRefresh: controller.refresh,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
                  children: [
                    _StreakOverviewCard(
                      state: state,
                      colors: colors,
                      onCompleteDaily: state.dailyCompletion >= 1
                          ? null
                          : controller.completeDailyChallenge,
                    ),
                    const SizedBox(height: 24),
                    if (state.pinned.isNotEmpty) ...[
                      Text(
                        l10n.translate('achievements_pinned'),
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      _PinnedGoalsRow(
                        achievements: state.pinned,
                        colors: colors,
                        onTogglePin: controller.togglePin,
                        l10n: l10n,
                      ),
                      const SizedBox(height: 24),
                    ],
                    Text(
                      l10n.translate('achievements_recent'),
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    if (state.recentlyUnlocked.isEmpty)
                      Text(
                        l10n.translate('achievements_empty_recent'),
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: colors.inkSecondary),
                      )
                    else
                      ...state.recentlyUnlocked.map(
                        (achievement) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _AchievementTile(
                            achievement: achievement,
                            colors: colors,
                            l10n: l10n,
                            onTogglePin: controller.togglePin,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.translate('achievements_all'),
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    ...state.achievements.map(
                      (achievement) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _AchievementTile(
                          achievement: achievement,
                          colors: colors,
                          l10n: l10n,
                          onTogglePin: controller.togglePin,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n
                          .translate('achievements_last_updated')
                          .replaceFirst('{time}', _formatRelative(state.lastUpdated)),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: colors.inkSecondary),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      l10n.translate('achievements_unlock_more'),
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: colors.inkSecondary),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  String _formatRelative(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) {
      return 'just now';
    }
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours}h';
    }
    return '${diff.inDays}d';
  }
}

class _StreakOverviewCard extends StatelessWidget {
  const _StreakOverviewCard({
    required this.state,
    required this.colors,
    required this.onCompleteDaily,
  });

  final AchievementsState state;
  final GeniusColors colors;
  final VoidCallback? onCompleteDaily;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final xpLabel = l10n
        .translate('achievements_xp_label')
        .replaceFirst('{xp}', state.xp.toString())
        .replaceFirst('{level}', state.level.toString());
    final xpToNext = l10n
        .translate('achievements_xp_to_next')
        .replaceFirst('{xp}', state.xpToNext.toString());
    final streakText = l10n
        .translate('achievements_streak_current')
        .replaceFirst('{days}', state.currentStreak.toString());
    final bestText = l10n
        .translate('achievements_streak_best')
        .replaceFirst('{days}', state.longestStreak.toString());
    final dailyText = l10n
        .translate('achievements_daily_minutes')
        .replaceFirst('{minutes}', state.dailyGoalMinutes.toString());

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
          Text(
            l10n.translate('achievements_title'),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            xpLabel,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: colors.inkSecondary),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _StreakBadge(label: streakText, icon: Icons.local_fire_department_outlined, colors: colors),
              _StreakBadge(label: bestText, icon: Icons.auto_awesome, colors: colors),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            l10n.translate('achievements_daily_focus'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            dailyText,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: colors.inkSecondary),
          ),
          const SizedBox(height: 12),
          _ProgressBar(
            value: state.dailyCompletion,
            colors: colors,
            highlightColor: scheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            xpToNext,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: colors.inkSecondary),
          ),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedPillButton(
              label: l10n.translate('achievements_daily_action'),
              onPressed: onCompleteDaily,
              icon: const Icon(Icons.flash_on_rounded, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  const _StreakBadge({
    required this.label,
    required this.icon,
    required this.colors,
  });

  final String label;
  final IconData icon;
  final GeniusColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(radiusMd),
        border: Border.all(color: colors.outline, width: geniusStrokeWidth),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: colors.ink),
          const SizedBox(width: 10),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.value,
    required this.colors,
    required this.highlightColor,
  });

  final double value;
  final GeniusColors colors;
  final Color highlightColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 16,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth * value.clamp(0, 1);
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radiusMd),
              border: Border.all(color: colors.outline, width: geniusStrokeWidth),
            ),
            child: Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 360),
                  curve: Curves.easeOut,
                  width: width,
                  decoration: BoxDecoration(
                    color: highlightColor,
                    borderRadius: BorderRadius.circular(radiusMd),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PinnedGoalsRow extends StatelessWidget {
  const _PinnedGoalsRow({
    required this.achievements,
    required this.colors,
    required this.onTogglePin,
    required this.l10n,
  });

  final List<Achievement> achievements;
  final GeniusColors colors;
  final void Function(String id) onTogglePin;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final achievement = achievements[index];
          return SizedBox(
            width: 220,
            child: _AchievementTile(
              achievement: achievement,
              colors: colors,
              l10n: l10n,
              onTogglePin: onTogglePin,
              compact: true,
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemCount: achievements.length,
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({
    required this.achievement,
    required this.colors,
    required this.l10n,
    required this.onTogglePin,
    this.compact = false,
  });

  final Achievement achievement;
  final GeniusColors colors;
  final AppLocalizations l10n;
  final void Function(String id) onTogglePin;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool unlocked = achievement.isUnlocked;
    final bool pinned = achievement.isPinned;
    final iconColor = unlocked ? theme.colorScheme.primary : colors.ink;
    final xpLabel = '${achievement.xp} XP';

    return Container(
      padding: EdgeInsets.fromLTRB(20, 18, 20, compact ? 18 : 22),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(radiusLg),
        border: Border.all(color: colors.outline, width: geniusStrokeWidth),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(radiusMd),
                  border: Border.all(color: colors.outline, width: geniusStrokeWidth),
                ),
                child: Icon(achievement.icon, color: iconColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      achievement.title,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      achievement.description,
                      maxLines: compact ? 2 : 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.inkSecondary,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      xpLabel,
                      style: theme.textTheme.labelLarge,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: pinned
                    ? l10n.translate('achievements_unpin')
                    : l10n.translate('achievements_pin'),
                onPressed: () => onTogglePin(achievement.id),
                icon: Icon(
                  pinned ? Icons.push_pin : Icons.push_pin_outlined,
                  color: colors.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (achievement.highlight != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                achievement.highlight!,
                style: theme.textTheme.bodySmall?.copyWith(color: colors.inkSecondary),
              ),
            ),
          if (!unlocked)
            _ProgressBar(
              value: achievement.completion,
              colors: colors,
              highlightColor: theme.colorScheme.primary,
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.16),
                borderRadius: BorderRadius.circular(radiusMd),
                border: Border.all(color: colors.outline, width: geniusStrokeWidth),
              ),
              child: Text(
                l10n.translate('achievements_unlocked'),
                style: theme.textTheme.labelLarge,
              ),
            ),
        ],
      ),
    );
  }
}

class _AchievementsSkeleton extends StatelessWidget {
  const _AchievementsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
      children: const [
        SkeletonCard(height: 220),
        SizedBox(height: 20),
        SkeletonCard(height: 160),
        SizedBox(height: 20),
        SkeletonCard(height: 160),
        SizedBox(height: 20),
        SkeletonCard(height: 160),
      ],
    );
  }
}
