import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/audio_item.dart';

class DownloadEntry {
  DownloadEntry({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.durationSec,
    required this.progress,
    required this.isCompleted,
    required this.isPaused,
    required this.queuedAt,
    this.completedAt,
  });

  final String id;
  final String title;
  final String imageUrl;
  final int durationSec;
  final double progress;
  final bool isCompleted;
  final bool isPaused;
  final DateTime queuedAt;
  final DateTime? completedAt;

  DownloadEntry copyWith({
    double? progress,
    bool? isCompleted,
    bool? isPaused,
    DateTime? queuedAt,
    DateTime? completedAt,
  }) {
    return DownloadEntry(
      id: id,
      title: title,
      imageUrl: imageUrl,
      durationSec: durationSec,
      progress: progress ?? this.progress,
      isCompleted: isCompleted ?? this.isCompleted,
      isPaused: isPaused ?? this.isPaused,
      queuedAt: queuedAt ?? this.queuedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'duration': durationSec,
      'progress': progress,
      'completed': isCompleted,
      'paused': isPaused,
      'queuedAt': queuedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory DownloadEntry.fromJson(Map<String, dynamic> json) {
    return DownloadEntry(
      id: json['id'] as String,
      title: json['title'] as String,
      imageUrl: json['imageUrl'] as String,
      durationSec: json['duration'] as int,
      progress: (json['progress'] as num).toDouble(),
      isCompleted: json['completed'] as bool,
      isPaused: json['paused'] as bool,
      queuedAt: DateTime.parse(json['queuedAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }
}

class DownloadsController extends ChangeNotifier {
  DownloadsController._(Map<String, DownloadEntry> entries)
      : _entries = entries;

  static const _prefsKey = 'downloads';

  final Map<String, DownloadEntry> _entries;
  final Map<String, Timer> _timers = {};
  bool _hydrated = false;

  List<DownloadEntry> get entries {
    final list = _entries.values.toList();
    list.sort((a, b) => b.queuedAt.compareTo(a.queuedAt));
    return list;
  }

  List<DownloadEntry> get completed =>
      entries.where((entry) => entry.isCompleted).toList();
  List<DownloadEntry> get inProgress =>
      entries.where((entry) => !entry.isCompleted).toList();

  DownloadEntry? entryFor(String id) => _entries[id];

  static Future<DownloadsController> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_prefsKey) ?? const <String>[];
    final entries = <String, DownloadEntry>{};
    for (final raw in stored) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        final entry = DownloadEntry.fromJson(map);
        entries[entry.id] = entry;
      } catch (_) {
        // ignore malformed entry
      }
    }
    final controller = DownloadsController._(entries);
    controller._hydrateTimers();
    controller._hydrated = true;
    return controller;
  }

  void startDownload(AudioItem item) {
    final existing = _entries[item.id];
    if (existing != null && existing.isCompleted) {
      return;
    }

    final entry = DownloadEntry(
      id: item.id,
      title: item.title,
      imageUrl: item.imageUrl,
      durationSec: item.durationSec,
      progress: existing?.progress ?? 0.0,
      isCompleted: false,
      isPaused: false,
      queuedAt: existing?.queuedAt ?? DateTime.now(),
    );

    _entries[item.id] = entry;
    _startTimer(item.id);
    notifyListeners();
    _persist();
  }

  void pause(String id) {
    final entry = _entries[id];
    if (entry == null || entry.isPaused || entry.isCompleted) return;
    _entries[id] = entry.copyWith(isPaused: true);
    notifyListeners();
    _persist();
  }

  void resume(String id) {
    final entry = _entries[id];
    if (entry == null || !entry.isPaused || entry.isCompleted) return;
    _entries[id] = entry.copyWith(isPaused: false);
    notifyListeners();
    _startTimer(id);
    _persist();
  }

  void remove(String id) {
    _entries.remove(id);
    _timers.remove(id)?.cancel();
    notifyListeners();
    _persist();
  }

  Future<void> clearCompleted() async {
    _entries.removeWhere((key, value) => value.isCompleted);
    await _persist();
    notifyListeners();
  }

  void _startTimer(String id) {
    _timers[id]?.cancel();
    _timers[id] = Timer.periodic(const Duration(milliseconds: 350), (timer) {
      final entry = _entries[id];
      if (entry == null) {
        timer.cancel();
        _timers.remove(id);
        return;
      }
      if (entry.isCompleted) {
        timer.cancel();
        _timers.remove(id);
        return;
      }
      if (entry.isPaused) {
        return;
      }
      final nextProgress = (entry.progress + 0.08).clamp(0.0, 1.0);
      if (nextProgress >= 0.999) {
        _entries[id] = entry.copyWith(
          progress: 1.0,
          isCompleted: true,
          completedAt: DateTime.now(),
        );
        timer.cancel();
        _timers.remove(id);
      } else {
        _entries[id] = entry.copyWith(progress: nextProgress);
      }
      notifyListeners();
      _persist();
    });
  }

  void _hydrateTimers() {
    for (final entry in _entries.values) {
      if (!entry.isCompleted && !entry.isPaused) {
        _startTimer(entry.id);
      }
    }
  }

  Future<void> simulateSync() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!_hydrated) return;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = _entries.values.map((entry) => jsonEncode(entry.toJson())).toList();
    await prefs.setStringList(_prefsKey, encoded);
  }

  @override
  void dispose() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    super.dispose();
  }
}
