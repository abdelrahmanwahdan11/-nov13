import 'package:flutter/material.dart';

class PlayerState {
  PlayerState({
    required this.isPlaying,
    required this.position,
    required this.duration,
    required this.speed,
    required this.isLiked,
    required this.isSaved,
  });

  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final double speed;
  final bool isLiked;
  final bool isSaved;

  PlayerState copyWith({
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    double? speed,
    bool? isLiked,
    bool? isSaved,
  }) {
    return PlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      speed: speed ?? this.speed,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
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
          ),
        );

  void togglePlay() {
    value = value.copyWith(isPlaying: !value.isPlaying);
  }

  void seekBy(Duration delta) {
    final newPosition = value.position + delta;
    value = value.copyWith(
      position: newPosition.clamp(Duration.zero, value.duration),
    );
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
}
