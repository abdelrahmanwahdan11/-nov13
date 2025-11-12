import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../models/achievement.dart';

class AchievementsState {
  const AchievementsState({
    required this.currentStreak,
    required this.longestStreak,
    required this.dailyGoalMinutes,
    required this.dailyProgressMinutes,
    required this.xp,
    required this.level,
    required this.nextMilestoneXp,
    required this.achievements,
    required this.recentlyUnlocked,
    required this.isLoading,
    required this.isRefreshing,
    required this.lastUpdated,
  });

  factory AchievementsState.initial() {
    return AchievementsState(
      currentStreak: 0,
      longestStreak: 0,
      dailyGoalMinutes: 45,
      dailyProgressMinutes: 0,
      xp: 0,
      level: 1,
      nextMilestoneXp: 600,
      achievements: const <Achievement>[],
      recentlyUnlocked: const <Achievement>[],
      isLoading: true,
      isRefreshing: false,
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  final int currentStreak;
  final int longestStreak;
  final int dailyGoalMinutes;
  final int dailyProgressMinutes;
  final int xp;
  final int level;
  final int nextMilestoneXp;
  final List<Achievement> achievements;
  final List<Achievement> recentlyUnlocked;
  final bool isLoading;
  final bool isRefreshing;
  final DateTime lastUpdated;

  double get dailyCompletion =>
      dailyGoalMinutes == 0 ? 0 : (dailyProgressMinutes / dailyGoalMinutes).clamp(0.0, 1.0);

  int get xpToNext => (nextMilestoneXp - xp).clamp(0, nextMilestoneXp);

  List<Achievement> get pinned => achievements.where((a) => a.isPinned).toList();

  AchievementsState copyWith({
    int? currentStreak,
    int? longestStreak,
    int? dailyGoalMinutes,
    int? dailyProgressMinutes,
    int? xp,
    int? level,
    int? nextMilestoneXp,
    List<Achievement>? achievements,
    List<Achievement>? recentlyUnlocked,
    bool? isLoading,
    bool? isRefreshing,
    DateTime? lastUpdated,
  }) {
    return AchievementsState(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      dailyProgressMinutes: dailyProgressMinutes ?? this.dailyProgressMinutes,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      nextMilestoneXp: nextMilestoneXp ?? this.nextMilestoneXp,
      achievements: achievements ?? this.achievements,
      recentlyUnlocked: recentlyUnlocked ?? this.recentlyUnlocked,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class AchievementsController extends ChangeNotifier {
  AchievementsController()
      : _achievements = DummyData.achievements.map((achievement) => achievement).toList();

  AchievementsState _state = AchievementsState.initial();
  final List<Achievement> _achievements;
  final Random _random = Random();
  bool _initialized = false;
  Timer? _ticker;

  int _currentStreak = 4;
  int _longestStreak = 9;
  int _dailyGoalMinutes = 48;
  int _dailyProgressMinutes = 18;
  int _labsCompleted = 3;
  int _dropsPublished = 11;
  int _collabMoments = 2;

  AchievementsState get state => _state;

  Future<void> ensureLoaded() async {
    if (_initialized) return;
    _initialized = true;
    _state = _state.copyWith(isLoading: true);
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _rebuildState();
    _startTicker();
  }

  Future<void> refresh() async {
    if (_state.isRefreshing) return;
    _state = _state.copyWith(isRefreshing: true);
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 420));
    _advanceProgress(boosted: true);
  }

  void completeDailyChallenge() {
    _advanceProgress(boosted: true, streakOnly: true);
  }

  void togglePin(String id) {
    final index = _achievements.indexWhere((achievement) => achievement.id == id);
    if (index == -1) return;
    final current = _achievements[index];
    _achievements[index] = current.copyWith(isPinned: !current.isPinned);
    _rebuildState(notify: true, updateTimestamp: false);
  }

  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 26), (_) {
      _advanceProgress();
    });
  }

  void _advanceProgress({bool boosted = false, bool streakOnly = false}) {
    final increment = boosted ? 14 + _random.nextInt(8) : 6 + _random.nextInt(6);
    _dailyProgressMinutes =
        (_dailyProgressMinutes + increment).clamp(0, _dailyGoalMinutes);

    if (_dailyProgressMinutes >= _dailyGoalMinutes) {
      _currentStreak += 1;
      if (_currentStreak > _longestStreak) {
        _longestStreak = _currentStreak;
      }
      if (!streakOnly) {
        _labsCompleted += 1 + _random.nextInt(2);
        if (_random.nextBool()) {
          _dropsPublished += 1;
        }
        if (_random.nextInt(3) == 0) {
          _collabMoments += 1;
        }
      }
      _dailyGoalMinutes = 42 + _random.nextInt(18);
      _dailyProgressMinutes = 6 + _random.nextInt(10);
    } else if (!streakOnly) {
      if (_random.nextBool()) {
        _labsCompleted += 1;
      }
      if (_random.nextInt(4) == 0) {
        _collabMoments += 1;
      }
      if (_random.nextInt(5) == 0) {
        _dropsPublished += 1;
      }
    }

    _labsCompleted = _labsCompleted.clamp(0, 40);
    _dropsPublished = _dropsPublished.clamp(0, 40);
    _collabMoments = _collabMoments.clamp(0, 40);

    _rebuildState();
  }

  void _rebuildState({bool notify = true, bool updateTimestamp = true}) {
    for (var i = 0; i < _achievements.length; i++) {
      final achievement = _achievements[i];
      _achievements[i] = _resolveAchievement(achievement);
    }

    final unlocked = _achievements.where((achievement) => achievement.isUnlocked).toList();
    final xp = unlocked.fold<int>(0, (total, achievement) => total + achievement.xp);
    final level = xp ~/ 600 + 1;
    final nextMilestoneXp = (level) * 600;
    final recent = unlocked
        .where((achievement) => achievement.unlockedAt != null)
        .toList()
      ..sort((a, b) => b.unlockedAt!.compareTo(a.unlockedAt!));

    _state = _state.copyWith(
      currentStreak: _currentStreak,
      longestStreak: _longestStreak,
      dailyGoalMinutes: _dailyGoalMinutes,
      dailyProgressMinutes: _dailyProgressMinutes,
      xp: xp,
      level: level,
      nextMilestoneXp: nextMilestoneXp,
      achievements: List<Achievement>.unmodifiable(_achievements),
      recentlyUnlocked: List<Achievement>.unmodifiable(recent.take(3)),
      isLoading: false,
      isRefreshing: false,
      lastUpdated: updateTimestamp ? DateTime.now() : _state.lastUpdated,
    );

    if (notify) {
      notifyListeners();
    }
  }

  Achievement _resolveAchievement(Achievement achievement) {
    var progress = achievement.progress;
    var isUnlocked = achievement.isUnlocked;
    var unlockedAt = achievement.unlockedAt;

    switch (achievement.id) {
      case 'streak_3':
      case 'streak_7':
      case 'streak_30':
        progress = min(_currentStreak, achievement.target);
        break;
      case 'labs_5':
      case 'labs_15':
        progress = min(_labsCompleted, achievement.target);
        break;
      case 'drops_12':
      case 'drops_30':
        progress = min(_dropsPublished, achievement.target);
        break;
      case 'collab_6':
        progress = min(_collabMoments, achievement.target);
        break;
      default:
        if (!achievement.isUnlocked && achievement.target > 0) {
          final bump = _random.nextInt(2);
          if (bump > 0) {
            progress = (progress + bump).clamp(0, achievement.target);
          }
        }
    }

    if (!isUnlocked && achievement.target > 0 && progress >= achievement.target) {
      isUnlocked = true;
      unlockedAt = DateTime.now().subtract(Duration(minutes: _random.nextInt(90)));
    }

    return achievement.copyWith(
      progress: progress,
      isUnlocked: isUnlocked,
      unlockedAt: unlockedAt ?? achievement.unlockedAt,
    );
  }
}
