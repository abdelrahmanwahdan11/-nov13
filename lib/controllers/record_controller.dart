import 'package:flutter/material.dart';

import '../models/recording_clip.dart';

class RecordState {
  RecordState({
    required this.isRecording,
    required this.isPaused,
    required this.micLevel,
    required this.elapsed,
    required this.waveform,
    required this.clips,
  });

  final bool isRecording;
  final bool isPaused;
  final double micLevel;
  final Duration elapsed;
  final List<double> waveform;
  final List<RecordingClip> clips;

  RecordState copyWith({
    bool? isRecording,
    bool? isPaused,
    double? micLevel,
    Duration? elapsed,
    List<double>? waveform,
    List<RecordingClip>? clips,
  }) {
    return RecordState(
      isRecording: isRecording ?? this.isRecording,
      isPaused: isPaused ?? this.isPaused,
      micLevel: micLevel ?? this.micLevel,
      elapsed: elapsed ?? this.elapsed,
      waveform: waveform ?? this.waveform,
      clips: clips ?? this.clips,
    );
  }
}

class RecordController extends ValueNotifier<RecordState> {
  RecordController()
      : super(
          RecordState(
            isRecording: false,
            isPaused: false,
            micLevel: 0.1,
            elapsed: Duration.zero,
            waveform: const <double>[],
            clips: const <RecordingClip>[],
          ),
        );

  void startRecording() {
    value = RecordState(
      isRecording: true,
      isPaused: false,
      micLevel: 0.1,
      elapsed: Duration.zero,
      waveform: <double>[],
      clips: value.clips,
    );
  }

  void pauseRecording() {
    if (!value.isRecording) {
      return;
    }
    value = value.copyWith(isRecording: false, isPaused: true);
  }

  void resumeRecording() {
    if (!value.isPaused) {
      return;
    }
    value = value.copyWith(isRecording: true, isPaused: false);
  }

  RecordingClip? stopRecording({bool save = true}) {
    final bool hadProgress = value.elapsed > Duration.zero && value.waveform.isNotEmpty;
    RecordingClip? clip;
    if (save && hadProgress) {
      final String id = DateTime.now().millisecondsSinceEpoch.toString();
      clip = RecordingClip(
        id: id,
        duration: value.elapsed,
        waveform: List<double>.unmodifiable(value.waveform),
        createdAt: DateTime.now(),
        filePath: 'local_clip_$id.aac',
      );
    }
    final List<RecordingClip> updated = List<RecordingClip>.from(value.clips);
    if (clip != null) {
      updated.insert(0, clip);
    }
    value = RecordState(
      isRecording: false,
      isPaused: false,
      micLevel: value.micLevel,
      elapsed: Duration.zero,
      waveform: const <double>[],
      clips: List<RecordingClip>.unmodifiable(updated),
    );
    return clip;
  }

  void cancelRecording() {
    value = value.copyWith(
      isRecording: false,
      isPaused: false,
      elapsed: Duration.zero,
      waveform: const <double>[],
    );
  }

  void registerSample(double level, Duration delta) {
    final double clamped = level.clamp(0.0, 1.0);
    if (value.isRecording) {
      final List<double> waveform = List<double>.from(value.waveform)..add(clamped);
      if (waveform.length > 180) {
        waveform.removeAt(0);
      }
      value = value.copyWith(
        micLevel: clamped,
        elapsed: value.elapsed + delta,
        waveform: waveform,
      );
    } else {
      value = value.copyWith(micLevel: clamped);
    }
  }

  void removeClip(String id) {
    final List<RecordingClip> updated = value.clips.where((clip) => clip.id != id).toList();
    value = value.copyWith(clips: List<RecordingClip>.unmodifiable(updated));
  }
}
