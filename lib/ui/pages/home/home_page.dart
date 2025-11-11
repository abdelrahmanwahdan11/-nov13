import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import '../../../controllers/feed_controller.dart';
import '../../../core/i18n/app_localizations.dart';
import '../../../core/utils/controller_scope.dart';
import '../../../models/audio_item.dart';
import '../../widgets/genius_scaffold.dart';
import '../../widgets/image_to_top_overlay.dart';
import '../../widgets/skeleton_card.dart';
import '../../widgets/tilt_3d_card.dart';
import '../../widgets/waveform_stub.dart';

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
            _DiscoverPlaceholder(title: l10n.translate('discover')),
            _DiscoverPlaceholder(title: l10n.translate('record')),
            _DiscoverPlaceholder(title: l10n.translate('library')),
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
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(64),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: l10n.translate('search'),
                        prefixIcon: const Icon(Icons.search),
                      ),
                    ),
                  ),
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
