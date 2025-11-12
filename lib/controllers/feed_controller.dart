import 'dart:async';

import '../data/dummy_data.dart';
import '../models/audio_item.dart';

class FeedState {
  FeedState({
    required this.items,
    required this.isLoading,
    required this.hasMore,
    required this.page,
  });

  final List<AudioItem> items;
  final bool isLoading;
  final bool hasMore;
  final int page;

  FeedState copyWith({
    List<AudioItem>? items,
    bool? isLoading,
    bool? hasMore,
    int? page,
  }) {
    return FeedState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
    );
  }
}

class FeedController {
  FeedController()
      : _state = FeedState(
          items: const [],
          isLoading: false,
          hasMore: true,
          page: 0,
        ) {
    _controller = StreamController<FeedState>.broadcast();
    _controller.add(_state);
  }

  late final StreamController<FeedState> _controller;
  FeedState _state;

  Stream<FeedState> get stream => _controller.stream;
  FeedState get state => _state;

  Future<void> refresh() async {
    _update(_state.copyWith(isLoading: true, page: 0));
    await Future<void>.delayed(const Duration(milliseconds: 800));
    final slice = DummyData.audioItems.take(10).toList();
    _update(
      FeedState(
        items: slice,
        isLoading: false,
        hasMore: DummyData.audioItems.length > slice.length,
        page: 1,
      ),
    );
  }

  Future<void> loadMore() async {
    if (_state.isLoading || !_state.hasMore) return;
    _update(_state.copyWith(isLoading: true));
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final end = (_state.page * 10) + 10;
    final safeEnd = end.clamp(0, DummyData.audioItems.length).toInt();
    final newItems = DummyData.audioItems.sublist(0, safeEnd).toList();
    _update(
      FeedState(
        items: newItems,
        isLoading: false,
        hasMore: newItems.length < DummyData.audioItems.length,
        page: _state.page + 1,
      ),
    );
  }

  void _update(FeedState state) {
    _state = state;
    _controller.add(state);
  }

  void dispose() {
    _controller.close();
  }
}
