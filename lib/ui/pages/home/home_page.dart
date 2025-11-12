import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import '../../../controllers/feed_controller.dart';
import '../../../controllers/notifications_controller.dart';
import '../../../core/utils/controller_scope.dart';
import '../../../core/i18n/app_localizations.dart';
import '../../../data/dummy_data.dart';
import '../../../models/audio_item.dart';
import '../../widgets/genius_scaffold.dart';
import '../../widgets/genius_input.dart';
import '../../widgets/image_to_top_overlay.dart';
import '../../widgets/pill_buttons.dart';
import '../../widgets/skeleton_card.dart';
import '../../widgets/community_event_card.dart';
import '../../widgets/tilt_3d_card.dart';
import '../../widgets/waveform_stub.dart';
import '../../../controllers/insights_controller.dart';
import '../community/community_page.dart';
import '../../../core/theme/app_theme.dart';

const String _searchHeroTag = 'home_search_bar';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >
        _scrollController.position.maxScrollExtent - 200) {
      ControllerScope.of(context).feed.loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feed = ControllerScope.of(context).feed;
    final l10n = context.l10n;
    return GeniusScaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: IndexedStack(
          key: ValueKey(_currentIndex),
          index: _currentIndex,
          children: [
            _FeedTab(feed: feed, controller: _scrollController),
            const CommunityView(inline: true),
            _DiscoverPlaceholder(title: l10n.translate('record')),
            const _LibraryTab(),
            _DiscoverPlaceholder(title: l10n.translate('profile')),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (value) => setState(() => _currentIndex = value),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), label: 'Discover'),
          BottomNavigationBarItem(icon: Icon(Icons.mic_none), label: 'Record'),
          BottomNavigationBarItem(icon: Icon(Icons.library_music_outlined), label: 'Library'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

class _FeedTab extends StatefulWidget {
  const _FeedTab({required this.feed, required this.controller});

  final FeedController feed;
  final ScrollController controller;

  @override
  State<_FeedTab> createState() => _FeedTabState();
}

class _FeedTabState extends State<_FeedTab> {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final search = ControllerScope.of(context).search;
    return RefreshIndicator(
      onRefresh: () => widget.feed.refresh(),
      child: StreamBuilder<FeedState>(
        stream: widget.feed.stream,
        builder: (context, snapshot) {
          final state = snapshot.data ?? widget.feed.state;
          final items = state.items;
          return CustomScrollView(
            controller: widget.controller,
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Text('Voxa', style: Theme.of(context).textTheme.headlineSmall),
                actions: [
                  AnimatedBuilder(
                    animation: ControllerScope.of(context).notifications,
                    builder: (context, _) {
                      final NotificationsController notifications =
                          ControllerScope.of(context).notifications;
                      final unread = notifications.state.totalUnread;
                      return IconButton(
                        tooltip: l10n.translate('notifications_title'),
                        onPressed: () => Navigator.of(context).pushNamed('/notifications'),
                        icon: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Icon(Icons.notifications_none_rounded),
                            if (unread > 0)
                              Positioned(
                                right: -2,
                                top: -4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    unread > 9 ? '9+' : '$unread',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(color: Theme.of(context).colorScheme.surface),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(64),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Hero(
                      tag: _searchHeroTag,
                      child: Material(
                        color: Colors.transparent,
                        child: GeniusInput(
                          key: const ValueKey('home_search_input'),
                          hintText: l10n.translate('search_hint'),
                          readOnly: true,
                          suffix: const Icon(Icons.search),
                          onTap: () => Navigator.of(context).pushNamed('/search'),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: const _QuickActionsRow(),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  child: AnimatedBuilder(
                    animation: search,
                    builder: (context, _) {
                      final suggestions = search.state.suggestions.take(6).toList();
                      return _TrendingSearchChips(
                        suggestions: suggestions,
                        onSelected: (value) {
                          search.applySuggestion(value);
                          Navigator.of(context).pushNamed('/search');
                        },
                      );
                    },
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: _CreatorInsightsRibbon(),
                ),
              ),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: _CommunitySpotlightPreview(),
                ),
              ),
              if (items.isEmpty && state.isLoading)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => const Padding(
                      padding: EdgeInsets.all(16),
                      child: SkeletonCard(),
                    ),
                    childCount: 6,
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= items.length) {
                        return state.hasMore
                            ? const Padding(
                                padding: EdgeInsets.all(16),
                                child: SkeletonCard(),
                              )
                            : const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: _FeedCard(item: items[index]),
                      );
                    },
                    childCount: state.hasMore ? items.length + 1 : items.length,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _FeedCard extends StatelessWidget {
  const _FeedCard({required this.item});

  final AudioItem item;

  @override
  Widget build(BuildContext context) {
    return PageTransitionSwitcher(
      duration: const Duration(milliseconds: 450),
      transitionBuilder: (child, animation, secondaryAnimation) {
        return FadeThroughTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
      child: Tilt3DCard(
        child: Card(
          key: ValueKey(item.id),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          elevation: 0,
          color: Theme.of(context).colorScheme.surface.withOpacity(0.85),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ImageToTopOverlay(
                  preview: Image.network(
                    item.imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  details: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(item.title, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text('${item.creator} • ${item.mood}'),
                      const SizedBox(height: 8),
                      Text('Plays: ${item.plays}'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(item.title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text('${item.creator} • ${item.mood} • ${item.durationSec ~/ 60}m'),
                const SizedBox(height: 16),
                const WaveformStub(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    IconButton(onPressed: () {}, icon: const Icon(Icons.play_arrow)),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border)),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.bookmark_border)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow();

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).brightness == Brightness.dark
        ? geniusTheme.dark
        : geniusTheme.light;
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.translate('home_quick_actions'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _QuickActionChip(
              label: l10n.translate('home_quick_record'),
              icon: Icons.mic_none_rounded,
              palette: palette,
              onTap: () => Navigator.of(context).pushNamed('/record'),
            ),
            _QuickActionChip(
              label: l10n.translate('home_quick_publish'),
              icon: Icons.upload_rounded,
              palette: palette,
              onTap: () => Navigator.of(context).pushNamed('/publish'),
            ),
            _QuickActionChip(
              label: l10n.translate('home_quick_catalog'),
              icon: Icons.view_module_rounded,
              palette: palette,
              onTap: () => Navigator.of(context).pushNamed('/catalog'),
            ),
            _QuickActionChip(
              label: l10n.translate('home_quick_settings'),
              icon: Icons.tune_rounded,
              palette: palette,
              onTap: () => Navigator.of(context).pushNamed('/settings'),
            ),
          ],
        ),
      ],
    );
  }
}

class _TrendingSearchChips extends StatelessWidget {
  const _TrendingSearchChips({required this.suggestions, required this.onSelected});

  final List<String> suggestions;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) {
      return const SizedBox(height: 0);
    }
    final palette = Theme.of(context).brightness == Brightness.dark
        ? geniusTheme.dark
        : geniusTheme.light;
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.translate('home_search_chips'),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: suggestions
              .map(
                (label) => _SuggestionChip(
                  label: label,
                  palette: palette,
                  onTap: () => onSelected(label),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    required this.label,
    required this.icon,
    required this.palette,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final GeniusPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(pillRadius.toDouble()),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(pillRadius.toDouble()),
          border: Border.all(color: palette.outline, width: geniusStrokeWidth),
          color: palette.surface.withOpacity(0.9),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: palette.ink),
            const SizedBox(width: 12),
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: palette.ink, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({
    required this.label,
    required this.palette,
    required this.onTap,
  });

  final String label;
  final GeniusPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(pillRadius.toDouble()),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(pillRadius.toDouble()),
          border: Border.all(color: palette.outline, width: geniusStrokeWidth),
          color: palette.surface.withOpacity(0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: palette.inkSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreatorInsightsRibbon extends StatelessWidget {
  const _CreatorInsightsRibbon();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.dark
        ? geniusTheme.dark
        : geniusTheme.light;
    return AnimatedBuilder(
      animation: ControllerScope.of(context).insights,
      builder: (context, _) {
        final InsightsController controller = ControllerScope.of(context).insights;
        final state = controller.state;
        return GestureDetector(
          onTap: () => Navigator.of(context).pushNamed('/insights'),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radiusLg),
              border: Border.all(color: colors.outline, width: geniusStrokeWidth),
              color: colors.surface.withOpacity(0.85),
            ),
            child: state.isLoading
                ? Row(
                    children: [
                      const CircularProgressIndicator(strokeWidth: 2),
                      const SizedBox(width: 12),
                      Text(context.l10n.translate('loading')),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.l10n.translate('insights_glance'),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(color: colors.inkSecondary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              state.primaryMetric.title,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              '${state.primaryMetric.value}',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.auto_graph_rounded,
                        size: 32,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class _CommunitySpotlightPreview extends StatelessWidget {
  const _CommunitySpotlightPreview();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final community = ControllerScope.of(context).community;
    return AnimatedBuilder(
      animation: community,
      builder: (context, _) {
        final state = community.state;
        if (state.loading && state.events.isEmpty) {
          return const SkeletonCard();
        }
        final event = state.spotlight.isNotEmpty ? state.spotlight.first : null;
        if (event == null) {
          return OutlinedPillButton(
            label: l10n.translate('community_preview_cta'),
            onPressed: () => Navigator.of(context).pushNamed('/community'),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.translate('community_preview_title'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pushNamed('/community'),
                  child: Text(l10n.translate('community_preview_cta')),
                ),
              ],
            ),
            const SizedBox(height: 12),
            CommunityEventCard(
              event: event,
              compact: true,
              bookmarked: state.bookmarked.contains(event.id),
              onBookmark: () => community.toggleBookmark(event.id),
            ),
          ],
        );
      },
    );
  }
}

class _DiscoverPlaceholder extends StatelessWidget {
  const _DiscoverPlaceholder({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(title, style: Theme.of(context).textTheme.headlineMedium),
    );
  }
}

class _LibraryTab extends StatelessWidget {
  const _LibraryTab();

  @override
  Widget build(BuildContext context) {
    final downloads = ControllerScope.of(context).downloads;
    final l10n = context.l10n;
    final drafts = DummyData.audioItems.take(3).toList();
    return AnimatedBuilder(
      animation: downloads,
      builder: (context, _) {
        final entries = downloads.entries.take(3).toList();
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(l10n.translate('recent_drafts'),
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (drafts.isEmpty)
              Text(l10n.translate('no_drafts'))
            else
              ...drafts.map(
                (item) => Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(item.imageUrl),
                    ),
                    title: Text(item.title),
                    subtitle: Text('${item.durationSec ~/ 60} min • ${item.mood}'),
                    trailing: FilledPillButton(
                      label: l10n.translate('publish'),
                      onPressed: () => Navigator.of(context).pushNamed('/publish'),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.translate('downloads'),
                    style: Theme.of(context).textTheme.titleMedium),
                TextButton(
                  onPressed: () => Navigator.of(context).pushNamed('/downloads'),
                  child: Text(l10n.translate('view_all')), 
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (entries.isEmpty)
              Text(l10n.translate('no_downloads'))
            else
              ...entries.map((entry) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(entry.imageUrl),
                    ),
                    title: Text(entry.title),
                    subtitle: entry.isCompleted
                        ? Text(l10n.translate('saved_offline'))
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LinearProgressIndicator(value: entry.progress),
                              const SizedBox(height: 4),
                              Text('${(entry.progress * 100).floor()}%'),
                            ],
                          ),
                    trailing: IconButton(
                      icon: entry.isCompleted
                          ? const Icon(Icons.check_circle_outline)
                          : const Icon(Icons.open_in_new),
                      onPressed: () =>
                          Navigator.of(context).pushNamed('/downloads'),
                    ),
                  ),
                );
              }),
            const SizedBox(height: 24),
            FilledPillButton(
              label: l10n.translate('browse_catalog'),
              onPressed: () => Navigator.of(context).pushNamed('/catalog'),
            ),
            const SizedBox(height: 12),
            OutlinedPillButton(
              label: l10n.translate('downloads'),
              icon: const Icon(Icons.download_for_offline_outlined),
              onPressed: () => Navigator.of(context).pushNamed('/downloads'),
            ),
          ],
        );
      },
    );
  }
}
