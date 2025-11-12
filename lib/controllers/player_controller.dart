import 'dart:async';

import 'package:flutter/material.dart';

import '../models/audio_item.dart';
import '../models/recording_clip.dart';

class PlayerState {
  PlayerState({
    required this.isPlaying,
    required this.position,
    required this.duration,
    required this.speed,
    required this.isLiked,
    required this.isSaved,
    this.trackId,
    this.trackTitle,
    this.isLocal = false,
    this.waveform = const <double>[],
  });

  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final double speed;
  final bool isLiked;
  final bool isSaved;
  final String? trackId;
  final String? trackTitle;
  final bool isLocal;
  final List<double> waveform;

  PlayerState copyWith({
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    double? speed,
    bool? isLiked,
    bool? isSaved,
    String? trackId,
    String? trackTitle,
    bool? isLocal,
    List<double>? waveform,
  }) {
    return PlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      speed: speed ?? this.speed,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      trackId: trackId ?? this.trackId,
      trackTitle: trackTitle ?? this.trackTitle,
      isLocal: isLocal ?? this.isLocal,
      waveform: waveform ?? this.waveform,
    );
  }
}

class PlayerController extends ValueNotifier<PlayerState> {
  PlayerController()
      : super(
          PlayerState(
            isPlaying: false,
            position: Duration.zero,
            duration: const Duration(minutes: 5),
            speed: 1,
            isLiked: false,
            isSaved: false,
            waveform: const <double>[],
          ),
        );

  Timer? _ticker;

  void togglePlay() {
    final bool next = !value.isPlaying;
    value = value.copyWith(isPlaying: next);
    if (next) {
      _startTicker();
    } else {
      _stopTicker();
    }
  }

  void seekBy(Duration delta) {
    seekTo(value.position + delta);
  }

  void changeSpeed(double speed) {
    value = value.copyWith(speed: speed);
  }

  void toggleLike() {
    value = value.copyWith(isLiked: !value.isLiked);
  }

  void toggleSave() {
    value = value.copyWith(isSaved: !value.isSaved);
  }

  void seekTo(Duration position) {
    final Duration safe = _clampDuration(position, Duration.zero, value.duration);
    value = value.copyWith(position: safe);
  }

  void playAudioItem(AudioItem item) {
    _loadTrack(
      id: item.id,
      title: item.title,
      duration: Duration(seconds: item.durationSec),
      waveform: item.waveform,
      isLocal: false,
    );
  }

  void playRecording(RecordingClip clip) {
    _loadTrack(
      id: clip.id,
      title: 'Recording ${clip.friendlyLabel}',
      duration: clip.duration,
      waveform: clip.waveform,
      isLocal: true,
    );
  }

  void _loadTrack({
    required String id,
    required String title,
    required Duration duration,
    required List<double> waveform,
    required bool isLocal,
  }) {
    _stopTicker();
    value = value.copyWith(
      trackId: id,
      trackTitle: title,
      duration: duration,
      position: Duration.zero,
      waveform: waveform,
      isLocal: isLocal,
      isPlaying: true,
    );
    _startTicker();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (!value.isPlaying) {
        return;
      }
      final int deltaMillis = (250 * value.speed).round();
      final Duration next = value.position + Duration(milliseconds: deltaMillis);
      if (next >= value.duration) {
        value = value.copyWith(position: value.duration, isPlaying: false);
        _stopTicker();
      } else {
        value = value.copyWith(position: next);
      }
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  Duration _clampDuration(Duration value, Duration min, Duration max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  @override
  void dispose() {
    _stopTicker();
    super.dispose();
  }
}
