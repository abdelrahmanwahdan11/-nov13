import 'package:flutter/material.dart';

import '../models/audio_item.dart';

class CompareState {
  CompareState({
    required this.first,
    required this.second,
  });

  final AudioItem? first;
  final AudioItem? second;

  CompareState copyWith({AudioItem? first, AudioItem? second}) {
    return CompareState(
      first: first ?? this.first,
      second: second ?? this.second,
    );
  }
}

class CompareController extends ValueNotifier<CompareState> {
  CompareController() : super(CompareState(first: null, second: null));

  void setFirst(AudioItem? item) {
    value = value.copyWith(first: item);
  }

  void setSecond(AudioItem? item) {
    value = value.copyWith(second: item);
  }
}
