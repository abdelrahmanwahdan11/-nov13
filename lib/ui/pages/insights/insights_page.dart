import 'package:flutter/material.dart';

import '../../../controllers/insights_controller.dart';
import '../../../core/i18n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/controller_scope.dart';
import '../../../models/audio_item.dart';
import '../../../models/insight_metric.dart';
import '../../../ui/widgets/genius_app_bar.dart';
import '../../../ui/widgets/genius_scaffold.dart';
import '../../../ui/widgets/insight_cards.dart';

class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key});

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  InsightsController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = ControllerScope.of(context).insights;
    if (_controller == controller) return;
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
    final controller = _controller!;
    final state = controller.state;
    final l10n = context.l10n;
    final colors = Theme.of(context).brightness == Brightness.dark
        ? geniusTheme.dark
        : geniusTheme.light;

    return GeniusScaffold(
      appBar: GeniusAppBar(
        title: l10n.translate('insights'),
        actions: [
          IconButton(
            tooltip: l10n.translate('refresh'),
            icon: const Icon(Icons.refresh_rounded),
            onPressed: state.isRefreshing || state.isLoading
                ? null
                : () => controller.refresh(),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: state.isLoading
            ? const _InsightsSkeleton()
            : RefreshIndicator(
                onRefresh: controller.refresh,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
                  children: [
                    Text(
                      l10n.translate('insights_overview'),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    _RangeSelector(
                      range: state.range,
                      colors: colors,
                      onRangeSelected: controller.changeRange,
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: state.metrics
                          .map(
                            (metric) => SizedBox(
                              width: MediaQuery.of(context).size.width <= 600
                                  ? double.infinity
                                  : (MediaQuery.of(context).size.width - 80) / 2,
                              child: InsightMetricCard(metric: metric, colors: colors),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 32),
                    _AudienceBreakdown(segments: state.segments, colors: colors),
                    const SizedBox(height: 32),
                    _HighlightsSection(highlights: state.highlights, colors: colors),
                    const SizedBox(height: 32),
                    _TrendingAudioList(items: state.trending, colors: colors),
                    const SizedBox(height: 12),
                    Text(
                      l10n.translate('insights_last_updated')
                          .replaceFirst('{time}', _formatTime(state.updatedAt)),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: colors.inkSecondary),
                    ),
                  ],
                ),
              ),
      ),
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

class _RangeSelector extends StatelessWidget {
  const _RangeSelector({
    required this.range,
    required this.colors,
    required this.onRangeSelected,
  });

  final InsightRange range;
  final GeniusColors colors;
  final ValueChanged<InsightRange> onRangeSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Wrap(
      spacing: 12,
      children: InsightRange.values
          .map(
            (option) => ChoiceChip(
              label: Text(
                l10n.translate('insights_range_${option.name}'),
                style: theme.textTheme.labelLarge,
              ),
              selected: range == option,
              onSelected: (_) => onRangeSelected(option),
              selectedColor: theme.colorScheme.primary.withOpacity(0.2),
              backgroundColor: colors.surface,
              labelStyle: theme.textTheme.labelLarge?.copyWith(
                color: range == option ? theme.colorScheme.primary : colors.ink,
              ),
              shape: StadiumBorder(
                side: BorderSide(color: colors.outline, width: geniusStrokeWidth),
              ),
              showCheckmark: false,
            ),
          )
          .toList(),
    );
  }
}

class _AudienceBreakdown extends StatelessWidget {
  const _AudienceBreakdown({required this.segments, required this.colors});

  final List<AudienceSegment> segments;
  final GeniusColors colors;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.translate('insights_audience'),
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Column(
          children: segments
              .map(
                (segment) => Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colors.surface.withOpacity(0.9),
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
                              segment.label,
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                          Text('${(segment.percentage * 100).round()}%'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(radiusMd),
                        child: LinearProgressIndicator(
                          value: segment.percentage.clamp(0.0, 1.0),
                          minHeight: 10,
                          backgroundColor: colors.surface,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        segment.highlight,
                        style: theme.textTheme.bodySmall?.copyWith(color: colors.inkSecondary),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _HighlightsSection extends StatelessWidget {
  const _HighlightsSection({required this.highlights, required this.colors});

  final List<InsightHighlight> highlights;
  final GeniusColors colors;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.translate('insights_moments'),
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: highlights
              .map(
                (highlight) => Container(
                  width: MediaQuery.of(context).size.width <= 600
                      ? double.infinity
                      : (MediaQuery.of(context).size.width - 80) / 2,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    border: Border.all(color: colors.outline, width: geniusStrokeWidth),
                    borderRadius: BorderRadius.circular(radiusLg),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(radiusMd),
                          border: Border.all(color: colors.outline, width: geniusStrokeWidth),
                        ),
                        child: Icon(highlight.icon, color: Theme.of(context).colorScheme.primary),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(highlight.title, style: theme.textTheme.titleMedium),
                            const SizedBox(height: 8),
                            Text(
                              highlight.caption,
                              style:
                                  theme.textTheme.bodySmall?.copyWith(color: colors.inkSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _TrendingAudioList extends StatelessWidget {
  const _TrendingAudioList({required this.items, required this.colors});

  final List<AudioItem> items;
  final GeniusColors colors;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.translate('insights_trending'),
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Column(
          children: items
              .map(
                (item) => Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.surface.withOpacity(0.92),
                    border: Border.all(color: colors.outline, width: geniusStrokeWidth),
                    borderRadius: BorderRadius.circular(radiusMd),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(radiusSm),
                        child: Image.network(
                          item.imageUrl,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.title, style: theme.textTheme.titleMedium),
                            Text(
                              '${item.creator} • ${(item.durationSec / 60).toStringAsFixed(0)}m',
                              style: theme.textTheme.bodySmall?.copyWith(color: colors.inkSecondary),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${item.plays}'),
                          Text(
                            context.l10n.translate('plays'),
                            style: theme.textTheme.labelSmall?.copyWith(color: colors.inkSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _InsightsSkeleton extends StatelessWidget {
  const _InsightsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: const [
        InsightSkeletonCard(),
        SizedBox(height: 16),
        InsightSkeletonCard(),
        SizedBox(height: 16),
        InsightSkeletonCard(),
      ],
    );
  }
}
