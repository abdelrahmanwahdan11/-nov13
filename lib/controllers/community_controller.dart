import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/dummy_data.dart';
import '../models/community_event.dart';

class CommunityState {
  const CommunityState({
    required this.spotlight,
    required this.events,
    required this.bookmarked,
    required this.loading,
    required this.page,
    required this.liveOnly,
    required this.category,
    required this.refreshing,
    required this.lastUpdated,
  });

  factory CommunityState.initial() {
    return CommunityState(
      spotlight: const [],
      events: const [],
      bookmarked: const {},
      loading: true,
      page: 1,
      liveOnly: false,
      category: 'All',
      refreshing: false,
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  final List<CommunityEvent> spotlight;
  final List<CommunityEvent> events;
  final Set<String> bookmarked;
  final bool loading;
  final int page;
  final bool liveOnly;
  final String category;
  final bool refreshing;
  final DateTime lastUpdated;

  CommunityState copyWith({
    List<CommunityEvent>? spotlight,
    List<CommunityEvent>? events,
    Set<String>? bookmarked,
    bool? loading,
    int? page,
    bool? liveOnly,
    String? category,
    bool? refreshing,
    DateTime? lastUpdated,
  }) {
    return CommunityState(
      spotlight: spotlight ?? this.spotlight,
      events: events ?? this.events,
      bookmarked: bookmarked ?? this.bookmarked,
      loading: loading ?? this.loading,
      page: page ?? this.page,
      liveOnly: liveOnly ?? this.liveOnly,
      category: category ?? this.category,
      refreshing: refreshing ?? this.refreshing,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class CommunityController extends ChangeNotifier {
  CommunityController();

  CommunityState _state = CommunityState.initial();
  Timer? _ticker;

  CommunityState get state => _state;

  Future<void> ensureLoaded() async {
    if (!_state.loading) return;
    await refresh();
    _startTicker();
  }

  Future<void> refresh({bool soft = false}) async {
    _state = _state.copyWith(
      refreshing: true,
      loading: !soft && _state.events.isEmpty,
    );
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final events = _filter(DummyData.communityEvents.take(_state.page * 6).toList());
    _state = _state.copyWith(
      events: events,
      spotlight: events.take(4).toList(),
      loading: false,
      refreshing: false,
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_state.loading || _state.refreshing) return;
    final nextPage = _state.page + 1;
    if (nextPage > 3) return;
    _state = _state.copyWith(page: nextPage, refreshing: true);
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final events = _filter(DummyData.communityEvents.take(nextPage * 6).toList());
    _state = _state.copyWith(events: events, refreshing: false);
    notifyListeners();
  }

  void toggleLiveOnly() {
    _state = _state.copyWith(liveOnly: !_state.liveOnly, page: 1);
    notifyListeners();
    refresh(soft: true);
  }

  void selectCategory(String category) {
    if (_state.category == category) return;
    _state = _state.copyWith(category: category, page: 1);
    notifyListeners();
    refresh(soft: true);
  }

  void toggleBookmark(String id) {
    final updated = Set<String>.from(_state.bookmarked);
    if (!updated.add(id)) {
      updated.remove(id);
    }
    _state = _state.copyWith(bookmarked: updated);
    notifyListeners();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
      final spotlight = _state.spotlight
          .map((event) => event.copyWith(isLive: event.isLive))
          .toList(growable: false);
      _state = _state.copyWith(spotlight: spotlight);
      notifyListeners();
    });
  }

  List<CommunityEvent> _filter(List<CommunityEvent> source) {
    return source.where((event) {
      final matchesLive = !_state.liveOnly || event.isLive;
      final matchesCategory = _state.category == 'All' || event.category == _state.category;
      return matchesLive && matchesCategory;
    }).toList();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
