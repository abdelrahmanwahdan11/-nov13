import 'package:flutter/material.dart';

class CommunityEvent {
  const CommunityEvent({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.host,
    required this.startTime,
    required this.duration,
    required this.tags,
    required this.coverUrl,
    required this.attending,
    required this.maxSlots,
    required this.category,
    required this.isLive,
  });

  final String id;
  final String title;
  final String subtitle;
  final String host;
  final DateTime startTime;
  final Duration duration;
  final List<String> tags;
  final String coverUrl;
  final int attending;
  final int maxSlots;
  final String category;
  final bool isLive;

  double get progress {
    if (!isLive) return 0;
    final elapsed = DateTime.now().difference(startTime).inSeconds;
    if (elapsed <= 0) return 0;
    final total = duration.inSeconds;
    if (total <= 0) return 1;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  Color badgeColor(Brightness brightness) {
    if (isLive) {
      return Colors.redAccent;
    }
    return brightness == Brightness.dark
        ? const Color(0xFF444444)
        : const Color(0xFFE5E5E5);
  }

  CommunityEvent copyWith({
    bool? isLive,
    int? attending,
  }) {
    return CommunityEvent(
      id: id,
      title: title,
      subtitle: subtitle,
      host: host,
      startTime: startTime,
      duration: duration,
      tags: tags,
      coverUrl: coverUrl,
      attending: attending ?? this.attending,
      maxSlots: maxSlots,
      category: category,
      isLive: isLive ?? this.isLive,
    );
  }
}
