import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../models/audio_item.dart';

class SearchController extends ChangeNotifier {
  SearchController()
      : _query = '',
        _filters = const {},
        _results = DummyData.audioItems;

  String _query;
  Map<String, dynamic> _filters;
  List<AudioItem> _results;

  String get query => _query;
  Map<String, dynamic> get filters => _filters;
  List<AudioItem> get results => _results;

  void updateQuery(String query) {
    _query = query;
    _apply();
  }

  void updateFilters(Map<String, dynamic> filters) {
    _filters = filters;
    _apply();
  }

  void _apply() {
    _results = DummyData.audioItems.where((item) {
      final text = '${item.title} ${item.creator} ${item.mood} ${item.tags.join(' ')}'.toLowerCase();
      final matchesQuery = text.contains(_query.toLowerCase());
      if (!matchesQuery) return false;
      final mood = _filters['mood'] as String?;
      if (mood != null && mood.isNotEmpty && item.mood != mood) return false;
      return true;
    }).toList();
    notifyListeners();
  }
}
