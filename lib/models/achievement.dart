import 'package:flutter/material.dart';

class Achievement {
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.progress,
    required this.target,
    required this.xp,
    required this.isUnlocked,
    required this.unlockedAt,
    required this.isPinned,
    this.highlight,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int progress;
  final int target;
  final int xp;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final bool isPinned;
  final String? highlight;

  double get completion => target == 0 ? 1 : (progress / target).clamp(0.0, 1.0);

  Achievement copyWith({
    int? progress,
    bool? isUnlocked,
    DateTime? unlockedAt,
    bool? isPinned,
  }) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      icon: icon,
      progress: progress ?? this.progress,
      target: target,
      xp: xp,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      isPinned: isPinned ?? this.isPinned,
      highlight: highlight,
    );
  }
}
