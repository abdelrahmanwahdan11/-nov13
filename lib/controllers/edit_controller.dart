import 'package:flutter/material.dart';

class EditState {
  EditState({
    required this.trimStart,
    required this.trimEnd,
    required this.normalize,
    required this.denoise,
    required this.speed,
    required this.pitch,
  });

  final double trimStart;
  final double trimEnd;
  final bool normalize;
  final bool denoise;
  final double speed;
  final double pitch;

  EditState copyWith({
    double? trimStart,
    double? trimEnd,
    bool? normalize,
    bool? denoise,
    double? speed,
    double? pitch,
  }) {
    return EditState(
      trimStart: trimStart ?? this.trimStart,
      trimEnd: trimEnd ?? this.trimEnd,
      normalize: normalize ?? this.normalize,
      denoise: denoise ?? this.denoise,
      speed: speed ?? this.speed,
      pitch: pitch ?? this.pitch,
    );
  }
}

class EditController extends ValueNotifier<EditState> {
  EditController()
      : super(
          EditState(
            trimStart: 0,
            trimEnd: 1,
            normalize: false,
            denoise: false,
            speed: 1,
            pitch: 0,
          ),
        );

  void setTrim(double start, double end) {
    value = value.copyWith(trimStart: start, trimEnd: end);
  }

  void toggleNormalize(bool normalize) {
    value = value.copyWith(normalize: normalize);
  }

  void toggleDenoise(bool denoise) {
    value = value.copyWith(denoise: denoise);
  }

  void setSpeed(double speed) {
    value = value.copyWith(speed: speed);
  }

  void setPitch(double pitch) {
    value = value.copyWith(pitch: pitch);
  }
}
