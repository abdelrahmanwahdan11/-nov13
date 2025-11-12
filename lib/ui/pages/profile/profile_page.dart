import 'package:flutter/material.dart';

import '../../../controllers/insights_controller.dart';
import '../../../core/i18n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/controller_scope.dart';
import '../../../data/dummy_data.dart';
import '../../../ui/widgets/genius_app_bar.dart';
import '../../../ui/widgets/genius_scaffold.dart';
import '../../../ui/widgets/pill_buttons.dart';

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
