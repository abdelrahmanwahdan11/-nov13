import 'package:flutter/material.dart';

import '../../models/community_event.dart';

class CommunityEventCard extends StatelessWidget {
  const CommunityEventCard({
    super.key,
    required this.event,
    required this.bookmarked,
    required this.onBookmark,
    this.compact = false,
  });

  final CommunityEvent event;
  final bool bookmarked;
  final VoidCallback onBookmark;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.colorScheme.surface;
    final outline = theme.colorScheme.outline;
    final textTheme = theme.textTheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(compact ? 20 : 28),
        border: Border.all(color: outline, width: 1.8),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.05),
            offset: const Offset(0, 12),
            blurRadius: 28,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Artwork(event: event),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title, style: textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(
                  event.subtitle,
                  style: textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                  maxLines: compact ? 2 : 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: outline.withOpacity(0.08),
                      child: Text(event.host.substring(0, 1)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(event.host, style: textTheme.bodyMedium),
                          Text(
                            _timeLabel(event),
                            style: textTheme.labelSmall?.copyWith(color: theme.hintColor),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: onBookmark,
                      icon: Icon(
                        bookmarked ? Icons.bookmark : Icons.bookmark_outline,
                        color: bookmarked ? theme.colorScheme.primary : outline,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _TagChip(label: event.category),
                    ...event.tags.take(compact ? 2 : 4).map(_TagChip.new),
                    _TagChip(label: '${event.attending}/${event.maxSlots}'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _timeLabel(CommunityEvent event) {
    final now = DateTime.now();
    if (event.isLive) {
      final minutes = event.duration.inMinutes;
      return 'Live • ${minutes}m session';
    }
    if (event.startTime.isAfter(now)) {
      final diff = event.startTime.difference(now);
      if (diff.inHours >= 24) {
        return 'Starts in ${diff.inDays}d';
      }
      if (diff.inHours >= 1) {
        return 'Starts in ${diff.inHours}h';
      }
      return 'Starts in ${diff.inMinutes}m';
    }
    return 'Replay available';
  }
}

class _Artwork extends StatelessWidget {
  const _Artwork({required this.event});

  final CommunityEvent event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final badgeColor = event.badgeColor(brightness);
    return SizedBox(
      height: 180,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(event.coverUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.15),
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            top: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.black.withOpacity(0.2), width: 1.2),
              ),
              child: Text(
                event.isLive ? 'LIVE' : 'UP NEXT',
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: Colors.white, letterSpacing: 1.1),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.white, letterSpacing: -0.3),
                ),
                const SizedBox(height: 8),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: event.isLive ? 1 : 0.65,
                  child: LinearProgressIndicator(
                    value: event.isLive ? event.progress : 1,
                    minHeight: 4,
                    backgroundColor: Colors.white.withOpacity(0.25),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.colorScheme.outline, width: 1.4),
        color: theme.colorScheme.surface.withOpacity(0.7),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium,
      ),
    );
  }
}
