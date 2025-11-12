import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../models/notification_item.dart';

enum NotificationFilter { all, interactions, follows, system }

class NotificationsState {
  const NotificationsState({
    required this.items,
    required this.filter,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMore,
    required this.totalUnread,
  });

  factory NotificationsState.initial() {
    return const NotificationsState(
      items: <NotificationItem>[],
      filter: NotificationFilter.all,
      isLoading: false,
      isLoadingMore: false,
      hasMore: true,
      totalUnread: 0,
    );
  }

  final List<NotificationItem> items;
  final NotificationFilter filter;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int totalUnread;

  int get filteredUnread => items.where((item) => !item.isRead).length;

  NotificationsState copyWith({
    List<NotificationItem>? items,
    NotificationFilter? filter,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? totalUnread,
  }) {
    return NotificationsState(
      items: items ?? this.items,
      filter: filter ?? this.filter,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      totalUnread: totalUnread ?? this.totalUnread,
    );
  }
}

class NotificationsController extends ChangeNotifier {
  NotificationsController();

  final List<NotificationItem> _allItems = <NotificationItem>[];
  NotificationsState _state = NotificationsState.initial();
  int _page = 0;
  bool _initialized = false;

  NotificationsState get state => _state;

  Future<void> ensureLoaded() async {
    if (_initialized) return;
    _initialized = true;
    await refresh();
  }

  Future<void> refresh() async {
    if (_state.isLoading) return;
    _state = _state.copyWith(isLoading: true);
    notifyListeners();
    _page = 0;
    final items = await _simulateFetch(page: _page);
    _allItems
      ..clear()
      ..addAll(items);
    _applyFilter();
    _state = _state.copyWith(
      isLoading: false,
      hasMore: _canLoadMore(_page),
      totalUnread: _calculateTotalUnread(),
    );
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_state.isLoadingMore || !_state.hasMore) {
      return;
    }
    _state = _state.copyWith(isLoadingMore: true);
    notifyListeners();
    _page += 1;
    final more = await _simulateFetch(page: _page);
    _allItems.addAll(more);
    _applyFilter();
    _state = _state.copyWith(
      isLoadingMore: false,
      hasMore: _canLoadMore(_page),
      totalUnread: _calculateTotalUnread(),
    );
    notifyListeners();
  }

  void changeFilter(NotificationFilter filter) {
    if (filter == _state.filter) return;
    _state = _state.copyWith(filter: filter);
    _applyFilter();
    notifyListeners();
  }

  void markRead(String id) {
    final index = _allItems.indexWhere((item) => item.id == id);
    if (index == -1) return;
    _allItems[index] = _allItems[index].copyWith(isRead: true);
    _applyFilter();
    notifyListeners();
  }

  void markAllRead() {
    for (var i = 0; i < _allItems.length; i++) {
      _allItems[i] = _allItems[i].copyWith(isRead: true);
    }
    _applyFilter();
    notifyListeners();
  }

  void toggleMute(String id) {
    final index = _allItems.indexWhere((item) => item.id == id);
    if (index == -1) return;
    final current = _allItems[index];
    _allItems[index] = current.copyWith(isMuted: !current.isMuted);
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    Iterable<NotificationItem> filtered = _allItems;
    switch (_state.filter) {
      case NotificationFilter.interactions:
        filtered = _allItems.where((item) =>
            item.kind == NotificationKind.like ||
            item.kind == NotificationKind.comment ||
            item.kind == NotificationKind.mention);
        break;
      case NotificationFilter.follows:
        filtered = _allItems.where((item) => item.kind == NotificationKind.follow);
        break;
      case NotificationFilter.system:
        filtered = _allItems.where((item) => item.kind == NotificationKind.system);
        break;
      case NotificationFilter.all:
        break;
    }
    _state = _state.copyWith(
      items: filtered.toList(growable: false),
      totalUnread: _calculateTotalUnread(),
    );
  }

  Future<List<NotificationItem>> _simulateFetch({required int page}) async {
    final random = Random(page + 37);
    await Future<void>.delayed(Duration(milliseconds: 600 + random.nextInt(300)));
    final pageSize = 8;
    final start = page * pageSize;
    return List<NotificationItem>.generate(pageSize, (index) {
      final audio = DummyData.audioItems[(start + index) % DummyData.audioItems.length];
      final kind = NotificationKind.values[(start + index) % NotificationKind.values.length];
      final baseId = 'notification_${page}_${index}';
      final timestamp = DateTime.now().subtract(Duration(minutes: (start + index) * 9));
      switch (kind) {
        case NotificationKind.like:
          return NotificationItem(
            id: baseId,
            kind: kind,
            title: '${audio.creator} liked your story',
            message: '“${audio.title}” just received fresh love.',
            timestamp: timestamp,
            avatarUrl: audio.imageUrl,
          );
        case NotificationKind.follow:
          return NotificationItem(
            id: baseId,
            kind: kind,
            title: '${audio.creator} started following you',
            message: 'Say hi back and share your latest session.',
            timestamp: timestamp,
            avatarUrl: audio.imageUrl,
          );
        case NotificationKind.mention:
          return NotificationItem(
            id: baseId,
            kind: kind,
            title: '${audio.creator} mentioned you',
            message: 'You were tagged in a behind-the-scenes drop.',
            timestamp: timestamp,
            avatarUrl: audio.imageUrl,
          );
        case NotificationKind.comment:
          return NotificationItem(
            id: baseId,
            kind: kind,
            title: 'New comment on ${audio.title}',
            message: '“Loved the build-up!” — ${audio.creator}',
            timestamp: timestamp,
            avatarUrl: audio.imageUrl,
          );
        case NotificationKind.system:
          return NotificationItem(
            id: baseId,
            kind: kind,
            title: 'System spotlight',
            message: 'Your mix ranked in top discoveries this week.',
            timestamp: timestamp,
          );
      }
    });
  }

  bool _canLoadMore(int page) {
    return page < 2;
  }

  int _calculateTotalUnread() {
    return _allItems.where((item) => !item.isRead).length;
  }
}
