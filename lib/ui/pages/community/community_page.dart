import 'package:flutter/material.dart';

import '../../../controllers/community_controller.dart';
import '../../../core/i18n/app_localizations.dart';
import '../../../core/utils/controller_scope.dart';
import '../../widgets/community_event_card.dart';
import '../../widgets/genius_app_bar.dart';
import '../../widgets/genius_scaffold.dart';
import '../../widgets/pill_buttons.dart';
import '../../widgets/skeleton_card.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return GeniusScaffold(
      appBar: GeniusAppBar(
        title: l10n.translate('community_title'),
        actions: [
          IconButton(
            tooltip: l10n.translate('community_live_toggle'),
            icon: const Icon(Icons.bolt_outlined),
            onPressed: ControllerScope.of(context).community.toggleLiveOnly,
          ),
        ],
      ),
      body: const CommunityView(),
    );
  }
}

class CommunityView extends StatefulWidget {
  const CommunityView({super.key, this.inline = false});

  final bool inline;

  @override
  State<CommunityView> createState() => _CommunityViewState();
}

class _CommunityViewState extends State<CommunityView> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  void _onScroll() {
    final community = ControllerScope.of(context).community;
    if (_controller.position.pixels >
        _controller.position.maxScrollExtent - 160) {
      community.loadMore();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final community = ControllerScope.of(context).community;
    final l10n = context.l10n;
    return AnimatedBuilder(
      animation: community,
      builder: (context, _) {
        final CommunityState state = community.state;
        return RefreshIndicator(
          onRefresh: () => community.refresh(),
          edgeOffset: widget.inline ? 48 : 0,
          child: CustomScrollView(
            controller: _controller,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, widget.inline ? 20 : 4, 20, 20),
                  child: _HeroBanner(l10n: l10n),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _Filters(state: state, controller: community, l10n: l10n),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 320,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: state.loading
                        ? ListView.separated(
                            scrollDirection: Axis.horizontal,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: 3,
                            separatorBuilder: (_, __) => const SizedBox(width: 16),
                            itemBuilder: (_, __) => const SizedBox(
                              width: 260,
                              child: SkeletonCard(),
                            ),
                          )
                        : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            itemCount: state.spotlight.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 16),
                            itemBuilder: (context, index) {
                              final event = state.spotlight[index];
                              return SizedBox(
                                width: 280,
                                child: CommunityEventCard(
                                  event: event,
                                  bookmarked: state.bookmarked.contains(event.id),
                                  onBookmark: () => community.toggleBookmark(event.id),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ),
              if (!state.loading)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      l10n.translate('community_upcoming_title'),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ),
              if (!state.loading)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  sliver: SliverList.separated(
                    separatorBuilder: (_, __) => const SizedBox(height: 20),
                    itemCount: state.events.length,
                    itemBuilder: (context, index) {
                      final event = state.events[index];
                      return CommunityEventCard(
                        event: event,
                        compact: true,
                        bookmarked: state.bookmarked.contains(event.id),
                        onBookmark: () => community.toggleBookmark(event.id),
                      );
                    },
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  sliver: SliverList.separated(
                    separatorBuilder: (_, __) => const SizedBox(height: 20),
                    itemCount: 4,
                    itemBuilder: (_, __) => const SkeletonCard(),
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.translate('community_updated').replaceFirst(
                              '{time}',
                              _timeAgo(state.lastUpdated, l10n),
                            ),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(height: 16),
                      FilledPillButton(
                        label: l10n.translate('community_host_cta'),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _timeAgo(DateTime date, AppLocalizations l10n) {
    final lang = l10n.locale.languageCode;
    if (date.millisecondsSinceEpoch == 0) {
      return l10n.translate('community_moments_ago');
    }
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) {
      return l10n.translate('community_moments_ago');
    }
    if (diff.inMinutes < 60) {
      final value = diff.inMinutes;
      return lang == 'ar' ? 'منذ ${value} د' : '${value}m ago';
    }
    if (diff.inHours < 24) {
      final value = diff.inHours;
      return lang == 'ar' ? 'منذ ${value} س' : '${value}h ago';
    }
    final value = diff.inDays;
    return lang == 'ar' ? 'منذ ${value} يوم' : '${value}d ago';
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.primary.withOpacity(0.9),
            scheme.primary.withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: scheme.onPrimary, width: 1.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.translate('community_host_caption'),
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: scheme.onPrimary),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledPillButton(
                label: l10n.translate('community_host_cta'),
                onPressed: () {},
              ),
              OutlinedPillButton(
                label: l10n.translate('community_browse_catalog'),
                onPressed: () => Navigator.of(context).pushNamed('/catalog'),
                icon: const Icon(Icons.auto_awesome_motion_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({
    required this.state,
    required this.controller,
    required this.l10n,
  });

  final CommunityState state;
  final CommunityController controller;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final categories = <String>[
      l10n.translate('community_filter_all'),
      l10n.translate('community_filter_challenges'),
      l10n.translate('community_filter_studios'),
      l10n.translate('community_filter_meetups'),
    ];
    final mapping = {
      l10n.translate('community_filter_all'): 'All',
      l10n.translate('community_filter_challenges'): 'Challenges',
      l10n.translate('community_filter_studios'): 'Studios',
      l10n.translate('community_filter_meetups'): 'Meetups',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              for (final category in categories)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _FilterChip(
                    label: category,
                    selected: state.category == mapping[category],
                    onTap: () => controller.selectCategory(mapping[category]!),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: controller.toggleLiveOnly,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
                width: 1.6,
              ),
              color: state.liveOnly
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.12)
                  : Theme.of(context).colorScheme.surface.withOpacity(0.7),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  state.liveOnly ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(l10n.translate('community_live_toggle')),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: scheme.outline, width: 1.6),
          color: selected ? scheme.primary.withOpacity(0.15) : scheme.surface.withOpacity(0.7),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: selected ? scheme.onPrimary : scheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}
