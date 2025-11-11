import 'dart:async';

import 'package:flutter/material.dart';

import '../../../controllers/notifications_controller.dart';
import '../../../core/i18n/app_localizations.dart';
import '../../../core/utils/controller_scope.dart';
import '../../../models/notification_item.dart';
import '../../widgets/genius_scaffold.dart';
import '../../widgets/skeleton_card.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late final ScrollController _scrollController;
  bool _didRequestInitial = false;

  NotificationsController get _controller => ControllerScope.of(context).notifications;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didRequestInitial) {
      _didRequestInitial = true;
      unawaited(_controller.ensureLoaded());
    }
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 160) {
      _controller.loadMore();
    }
  }

  Future<void> _onRefresh() {
    return _controller.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return GeniusScaffold(
      appBar: AppBar(
        title: Text(l10n.translate('notifications_title')),
        actions: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final hasUnread = _controller.state.totalUnread > 0;
              if (!hasUnread) {
                return const SizedBox.shrink();
              }
              return TextButton(
                onPressed: _controller.markAllRead,
                child: Text(l10n.translate('mark_all_read')),
              );
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final state = _controller.state;
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  sliver: SliverToBoxAdapter(
                    child: _NotificationsFilterBar(
                      filter: state.filter,
                      onFilterChanged: _controller.changeFilter,
                    ),
                  ),
                ),
                if (state.isLoading)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList.list(
                      children: List<Widget>.generate(
                        4,
                        (index) => const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: SkeletonCard(),
                        ),
                      ),
                    ),
                  )
                else if (state.items.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.notifications_none_rounded, size: 72),
                          const SizedBox(height: 16),
                          Text(
                            l10n.translate('notifications_empty_title'),
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.translate('notifications_empty_body'),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList.separated(
                      itemCount: state.items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = state.items[index];
                        return _NotificationTile(
                          item: item,
                          onMarkRead: () => _controller.markRead(item.id),
                          onToggleMute: () => _controller.toggleMute(item.id),
                          l10n: l10n,
                        );
                      },
                    ),
                  ),
                SliverToBoxAdapter(
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOut,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: state.isLoadingMore
                            ? const CircularProgressIndicator()
                            : state.hasMore
                                ? Text(
                                    l10n.translate('notifications_pull_more'),
                                    style: Theme.of(context).textTheme.bodySmall,
                                  )
                                : const SizedBox.shrink(),
                      ),
                    ),
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

class _NotificationsFilterBar extends StatelessWidget {
  const _NotificationsFilterBar({
    required this.filter,
    required this.onFilterChanged,
  });

  final NotificationFilter filter;
  final ValueChanged<NotificationFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SegmentedButton<NotificationFilter>(
      segments: <ButtonSegment<NotificationFilter>>[
        ButtonSegment(
          value: NotificationFilter.all,
          label: Text(l10n.translate('notifications_filter_all')),
          icon: const Icon(Icons.inbox_outlined),
        ),
        ButtonSegment(
          value: NotificationFilter.interactions,
          label: Text(l10n.translate('notifications_filter_interactions')),
          icon: const Icon(Icons.graphic_eq_rounded),
        ),
        ButtonSegment(
          value: NotificationFilter.follows,
          label: Text(l10n.translate('notifications_filter_follows')),
          icon: const Icon(Icons.person_add_alt_1_outlined),
        ),
        ButtonSegment(
          value: NotificationFilter.system,
          label: Text(l10n.translate('notifications_filter_system')),
          icon: const Icon(Icons.auto_awesome_outlined),
        ),
      ],
      selected: <NotificationFilter>{filter},
      onSelectionChanged: (selection) {
        onFilterChanged(selection.first);
      },
      style: ButtonStyle(
        side: MaterialStateProperty.all(
          BorderSide(color: Theme.of(context).colorScheme.onSurface, width: 1.6),
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.item,
    required this.onMarkRead,
    required this.onToggleMute,
    required this.l10n,
  });

  final NotificationItem item;
  final VoidCallback onMarkRead;
  final VoidCallback onToggleMute;
  final AppLocalizations l10n;

  IconData _resolveIcon() {
    switch (item.kind) {
      case NotificationKind.like:
        return Icons.favorite_outline;
      case NotificationKind.comment:
        return Icons.chat_bubble_outline_rounded;
      case NotificationKind.mention:
        return Icons.alternate_email_rounded;
      case NotificationKind.follow:
        return Icons.person_add_alt_1_outlined;
      case NotificationKind.system:
        return Icons.auto_awesome_outlined;
    }
  }

  Color? _resolveTint(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (item.kind) {
      case NotificationKind.like:
        return Colors.pinkAccent;
      case NotificationKind.comment:
        return scheme.primary;
      case NotificationKind.mention:
        return scheme.tertiary;
      case NotificationKind.follow:
        return scheme.secondary;
      case NotificationKind.system:
        return scheme.surfaceTint;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tint = _resolveTint(context);
    final opacity = item.isRead ? 0.6 : 1.0;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 220),
      opacity: opacity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.72),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Theme.of(context).colorScheme.onSurface, width: 1.6),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage:
                        item.avatarUrl != null ? NetworkImage(item.avatarUrl!) : null,
                    backgroundColor: tint?.withOpacity(0.12),
                    child: item.avatarUrl == null
                        ? Icon(_resolveIcon(), color: tint ?? Theme.of(context).colorScheme.onSurface)
                        : null,
                  ),
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      child: Icon(
                        _resolveIcon(),
                        size: 16,
                        color: tint ?? Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.message,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.schedule_outlined, size: 16, color: Theme.of(context).colorScheme.onSurface),
                        const SizedBox(width: 6),
                        Text(
                          _formatTimestamp(item.timestamp, context),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: item.isRead ? null : onMarkRead,
                          icon: const Icon(Icons.check_circle_outline, size: 18),
                          label: Text(l10n.translate('mark_read')),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    tooltip: item.isMuted
                        ? l10n.translate('unmute_creator')
                        : l10n.translate('mute_creator'),
                    onPressed: onToggleMute,
                    icon: Icon(
                      item.isMuted ? Icons.notifications_off_outlined : Icons.notifications_active_outlined,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp, BuildContext context) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    if (difference.inMinutes < 60) {
      return l10n.translate('minutes_ago').replaceFirst('{value}', difference.inMinutes.toString());
    }
    if (difference.inHours < 24) {
      return l10n.translate('hours_ago').replaceFirst('{value}', difference.inHours.toString());
    }
    return l10n.translate('days_ago').replaceFirst('{value}', difference.inDays.toString());
  }
}
