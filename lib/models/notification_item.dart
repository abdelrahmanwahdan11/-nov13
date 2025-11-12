import 'package:flutter/foundation.dart';

enum NotificationKind { like, follow, mention, comment, system }

@immutable
class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.kind,
    required this.title,
    required this.message,
    required this.timestamp,
    this.avatarUrl,
    this.isRead = false,
    this.isMuted = false,
  });

  final String id;
  final NotificationKind kind;
  final String title;
  final String message;
  final DateTime timestamp;
  final String? avatarUrl;
  final bool isRead;
  final bool isMuted;

  NotificationItem copyWith({
    bool? isRead,
    bool? isMuted,
  }) {
    return NotificationItem(
      id: id,
      kind: kind,
      title: title,
      message: message,
      timestamp: timestamp,
      avatarUrl: avatarUrl,
      isRead: isRead ?? this.isRead,
      isMuted: isMuted ?? this.isMuted,
    );
  }
}
