import 'package:flutter/material.dart';

class RecordState {
  RecordState({
    required this.isRecording,
    required this.micLevel,
    this.tempFilePath,
  });

  final bool isRecording;
  final double micLevel;
  final String? tempFilePath;

  RecordState copyWith({
    bool? isRecording,
    double? micLevel,
    String? tempFilePath,
  }) {
    return RecordState(
      isRecording: isRecording ?? this.isRecording,
      micLevel: micLevel ?? this.micLevel,
      tempFilePath: tempFilePath ?? this.tempFilePath,
    );
  }
}

class RecordController extends ValueNotifier<RecordState> {
  RecordController()
      : super(RecordState(isRecording: false, micLevel: 0.1, tempFilePath: null));

  void toggleRecording() {
    value = value.copyWith(isRecording: !value.isRecording);
  }

  void updateMicLevel(double level) {
    value = value.copyWith(micLevel: level.clamp(0.0, 1.0));
  }

  void stopWithFile(String path) {
    value = value.copyWith(isRecording: false, tempFilePath: path);
  }
}
