import 'dart:async';

import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../models/audio_item.dart';

const _pageSize = 8;

class SearchState {
  const SearchState({
    this.query = '',
    this.filters = const <String, dynamic>{},
    this.matches = const <AudioItem>[],
    this.visible = const <AudioItem>[],
    this.history = const <String>[],
    this.suggestions = const <String>[],
    this.isLoading = false,
    this.isPaginating = false,
    this.hasMore = false,
    this.page = 1,
  });

  final String query;
  final Map<String, dynamic> filters;
  final List<AudioItem> matches;
  final List<AudioItem> visible;
  final List<String> history;
  final List<String> suggestions;
  final bool isLoading;
  final bool isPaginating;
  final bool hasMore;
  final int page;

  SearchState copyWith({
    String? query,
    Map<String, dynamic>? filters,
    List<AudioItem>? matches,
    List<AudioItem>? visible,
    List<String>? history,
    List<String>? suggestions,
    bool? isLoading,
    bool? isPaginating,
    bool? hasMore,
    int? page,
  }) {
    return SearchState(
      query: query ?? this.query,
      filters: filters ?? this.filters,
      matches: matches ?? this.matches,
      visible: visible ?? this.visible,
      history: history ?? this.history,
      suggestions: suggestions ?? this.suggestions,
      isLoading: isLoading ?? this.isLoading,
      isPaginating: isPaginating ?? this.isPaginating,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
    );
  }

  static SearchState initial(List<String> suggestions) {
    return SearchState(
      suggestions: suggestions,
      history: const <String>[],
      hasMore: false,
      isLoading: false,
      matches: const <AudioItem>[],
      visible: const <AudioItem>[],
      filters: const <String, dynamic>{},
      query: '',
      page: 1,
    );
  }
}

class SearchController extends ChangeNotifier {
  SearchController()
      : _state = SearchState.initial(_buildSuggestions()),
        _searchToken = 0 {
    unawaited(updateQuery(''));
  }

  SearchState _state;
  int _searchToken;
  bool _disposed = false;

  SearchState get state => _state;

  List<String> get availableMoods => _availableMoods;

  List<String> get durationOptions => const <String>['short', 'medium', 'long'];

  List<String> get sortOptions => const <String>['recent', 'popular', 'duration'];

  static final List<String> _availableMoods =
      DummyData.audioItems.map((item) => item.mood).toSet().toList()..sort();

  static List<String> _buildSuggestions() {
    final Set<String> base = <String>{};
    for (final AudioItem item in DummyData.audioItems) {
      base.add(item.mood);
      base.addAll(item.tags);
      base.add(item.creator);
    }
    return base.take(10).toList();
  }

  Future<void> updateQuery(String query) async {
    final int token = ++_searchToken;
    _emit(_state.copyWith(query: query, isLoading: true, page: 1, hasMore: false));
    await _performSearch(token: token, saveHistory: query.trim().isNotEmpty);
  }

  Future<void> updateFilters(Map<String, dynamic> filters) async {
    final Map<String, dynamic> cleaned = Map<String, dynamic>.from(filters)
      ..removeWhere((key, value) => value == null || (value is String && value.isEmpty));
    final int token = ++_searchToken;
    _emit(_state.copyWith(filters: cleaned, isLoading: true, page: 1, hasMore: false));
    await _performSearch(token: token, saveHistory: _state.query.trim().isNotEmpty);
  }

  Future<void> refresh() async {
    final int token = ++_searchToken;
    _emit(_state.copyWith(isLoading: true, page: 1));
    await _performSearch(token: token, saveHistory: false);
  }

  Future<void> loadMore() async {
    if (!_state.hasMore || _state.isPaginating) {
      return;
    }
    final int token = _searchToken;
    _emit(_state.copyWith(isPaginating: true));
    await Future<void>.delayed(const Duration(milliseconds: 420));
    if (_disposed || token != _searchToken) {
      return;
    }
    final int nextPage = _state.page + 1;
    final List<AudioItem> visible =
        _state.matches.take(nextPage * _pageSize).toList(growable: false);
    _emit(
      _state.copyWith(
        page: nextPage,
        visible: visible,
        isPaginating: false,
        hasMore: visible.length < _state.matches.length,
      ),
    );
  }

  void applySuggestion(String suggestion) {
    updateQuery(suggestion);
  }

  void useHistory(String value) {
    updateQuery(value);
  }

  void clearHistory() {
    _emit(_state.copyWith(history: <String>[]));
  }

  void removeHistoryEntry(String entry) {
    final List<String> history =
        _state.history.where((element) => element != entry).toList();
    _emit(_state.copyWith(history: history));
  }

  void removeFilter(String key) {
    if (_state.filters.containsKey(key)) {
      final Map<String, dynamic> next = Map<String, dynamic>.from(_state.filters)
        ..remove(key);
      updateFilters(next);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> _performSearch({required int token, required bool saveHistory}) async {
    await Future<void>.delayed(const Duration(milliseconds: 320));
    if (_disposed || token != _searchToken) {
      return;
    }
    final List<AudioItem> matches = _filterMatches();
    final List<AudioItem> visible = matches.take(_pageSize).toList(growable: false);
    final List<String> history = saveHistory ? _updateHistory(_state.query) : _state.history;
    _emit(
      _state.copyWith(
        matches: matches,
        visible: visible,
        history: history,
        page: 1,
        isLoading: false,
        isPaginating: false,
        hasMore: visible.length < matches.length,
      ),
    );
  }

  List<AudioItem> _filterMatches() {
    final String query = _state.query.trim().toLowerCase();
    final String? mood = _state.filters['mood'] as String?;
    final String? duration = _state.filters['duration'] as String?;
    final String? sort = _state.filters['sort'] as String?;

    final Iterable<AudioItem> filtered = DummyData.audioItems.where((AudioItem item) {
      final String haystack =
          '${item.title} ${item.creator} ${item.mood} ${item.tags.join(' ')}'.toLowerCase();
      final bool matchesQuery = query.isEmpty || haystack.contains(query);
      if (!matchesQuery) {
        return false;
      }
      if (mood != null && mood.isNotEmpty && item.mood != mood) {
        return false;
      }
      if (duration != null && duration.isNotEmpty) {
        final int seconds = item.durationSec;
        if (duration == 'short' && seconds > 240) {
          return false;
        }
        if (duration == 'medium' && (seconds <= 240 || seconds > 420)) {
          return false;
        }
        if (duration == 'long' && seconds <= 420) {
          return false;
        }
      }
      return true;
    });

    final List<AudioItem> matches = filtered.toList();
    switch (sort) {
      case 'popular':
        matches.sort((AudioItem a, AudioItem b) => b.plays.compareTo(a.plays));
        break;
      case 'duration':
        matches.sort((AudioItem a, AudioItem b) => b.durationSec.compareTo(a.durationSec));
        break;
      default:
        matches.sort((AudioItem a, AudioItem b) => b.createdAt.compareTo(a.createdAt));
        break;
    }
    return matches;
  }

  List<String> _updateHistory(String query) {
    final String trimmed = query.trim();
    if (trimmed.isEmpty) {
      return _state.history;
    }
    final List<String> history = <String>[trimmed, ..._state.history.where((item) => item != trimmed)];
    return history.take(6).toList(growable: false);
  }

  void _emit(SearchState value) {
    if (_disposed) {
      return;
    }
    _state = value;
    notifyListeners();
  }
}
