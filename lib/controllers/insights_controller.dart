import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../models/audio_item.dart';
import '../models/insight_metric.dart';

class InsightsState {
  const InsightsState({
    required this.metrics,
    required this.range,
    required this.segments,
    required this.highlights,
    required this.trending,
    required this.updatedAt,
    required this.isLoading,
    required this.isRefreshing,
  });

  factory InsightsState.initial() {
    return InsightsState(
      metrics: const <InsightMetric>[],
      range: InsightRange.week,
      segments: const <AudienceSegment>[],
      highlights: const <InsightHighlight>[],
      trending: const <AudioItem>[],
      updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
      isLoading: true,
      isRefreshing: false,
    );
  }

  final List<InsightMetric> metrics;
  final InsightRange range;
  final List<AudienceSegment> segments;
  final List<InsightHighlight> highlights;
  final List<AudioItem> trending;
  final DateTime updatedAt;
  final bool isLoading;
  final bool isRefreshing;

  InsightMetric get primaryMetric => metrics.isNotEmpty ? metrics.first : _emptyMetric;

  InsightMetric get _emptyMetric => InsightMetric(
        id: 'empty',
        title: 'Plays',
        value: 0,
        delta: 0,
        timeline: const [0],
      );

  InsightsState copyWith({
    List<InsightMetric>? metrics,
    InsightRange? range,
    List<AudienceSegment>? segments,
    List<InsightHighlight>? highlights,
    List<AudioItem>? trending,
    DateTime? updatedAt,
    bool? isLoading,
    bool? isRefreshing,
  }) {
    return InsightsState(
      metrics: metrics ?? this.metrics,
      range: range ?? this.range,
      segments: segments ?? this.segments,
      highlights: highlights ?? this.highlights,
      trending: trending ?? this.trending,
      updatedAt: updatedAt ?? this.updatedAt,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

class InsightsController extends ChangeNotifier {
  InsightsController();

  InsightsState _state = InsightsState.initial();
  Timer? _ticker;
  bool _initialized = false;

  InsightsState get state => _state;

  Future<void> ensureLoaded() async {
    if (_initialized) return;
    _initialized = true;
    await _loadSnapshot(initial: true);
    _startTicker();
  }

  Future<void> refresh() async {
    if (_state.isRefreshing) return;
    _state = _state.copyWith(isRefreshing: true);
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 650));
    await _loadSnapshot(initial: false);
  }

  void changeRange(InsightRange range) {
    if (range == _state.range) return;
    _state = _state.copyWith(range: range, isLoading: true);
    notifyListeners();
    _loadSnapshot(initial: false);
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 18), (_) {
      _loadSnapshot(initial: false, quiet: true);
    });
  }

  Future<void> _loadSnapshot({required bool initial, bool quiet = false}) async {
    if (!quiet && initial) {
      _state = _state.copyWith(isLoading: true);
      notifyListeners();
    }
    final snapshot = _generateSnapshot(_state.range);
    _state = _state.copyWith(
      metrics: snapshot.metrics,
      segments: snapshot.segments,
      highlights: snapshot.highlights,
      trending: snapshot.trending,
      updatedAt: DateTime.now(),
      isLoading: false,
      isRefreshing: false,
    );
    notifyListeners();
  }

  _InsightsSnapshot _generateSnapshot(InsightRange range) {
    final items = DummyData.audioItems;
    final random = Random(DateTime.now().millisecondsSinceEpoch ^ range.index);
    final totalPlays = items.fold<int>(0, (sum, item) => sum + item.plays);
    final totalLikes = items.fold<int>(0, (sum, item) => sum + item.likes);
    final avgListenMinutes =
        items.fold<double>(0, (sum, item) => sum + item.durationSec / 60) / items.length;

    final metrics = <InsightMetric>[
      InsightMetric(
        id: 'plays',
        title: 'Total Plays',
        subtitle: 'Across published shows',
        unit: '',
        value: totalPlays + random.nextInt(800),
        delta: _generateDelta(random),
        timeline: _buildTimeline(random, range, base: totalPlays.toDouble()),
      ),
      InsightMetric(
        id: 'listeners',
        title: 'New Listeners',
        subtitle: 'First-time audience',
        unit: '',
        value: 400 + random.nextInt(150),
        delta: _generateDelta(random),
        timeline: _buildTimeline(random, range, base: avgListenMinutes * 120),
      ),
      InsightMetric(
        id: 'completion',
        title: 'Avg Completion',
        subtitle: 'Percent finishing episodes',
        unit: '%',
        value: 62 + random.nextInt(25),
        delta: _generateDelta(random) / 2,
        timeline: _buildTimeline(random, range, base: 58 + random.nextInt(5))
            .map((v) => v.clamp(40, 100).toDouble())
            .toList(),
      ),
      InsightMetric(
        id: 'saves',
        title: 'Saves',
        subtitle: 'Listeners bookmarking',
        unit: '',
        value: totalLikes ~/ 3 + random.nextInt(180),
        delta: _generateDelta(random),
        timeline: _buildTimeline(random, range, base: totalLikes / 3),
      ),
    ];

    final segments = <AudienceSegment>[
      AudienceSegment(
        label: 'Night Owls',
        percentage: 0.38 + random.nextDouble() * 0.1,
        highlight: 'Most active after 10pm',
      ),
      AudienceSegment(
        label: 'Focus Sprinters',
        percentage: 0.28 + random.nextDouble() * 0.08,
        highlight: 'Listen during work blocks',
      ),
      AudienceSegment(
        label: 'Commute Club',
        percentage: 0.18 + random.nextDouble() * 0.05,
        highlight: 'Prefer 20-30 min edits',
      ),
    ];

    final highlights = <InsightHighlight>[
      InsightHighlight(
        title: 'Episode ${random.nextInt(items.length) + 1} trending',
        caption: 'Waveforms shared 2.4x more this ${range.analyticsSeed}',
        icon: Icons.bolt_rounded,
      ),
      const InsightHighlight(
        title: 'Retention spike',
        caption: 'New listeners stayed +12 mins longer',
        icon: Icons.auto_graph_rounded,
      ),
      const InsightHighlight(
        title: 'Community love',
        caption: '120 shoutouts from loyal fans',
        icon: Icons.favorite_outline,
      ),
    ];

    final trending = items.take(3).toList();

    return _InsightsSnapshot(
      metrics: metrics,
      segments: segments,
      highlights: highlights,
      trending: trending,
    );
  }

  List<double> _buildTimeline(Random random, InsightRange range, {required double base}) {
    final samples = range.sampleCount;
    return List<double>.generate(samples, (index) {
      final variance = 0.75 + random.nextDouble() * 0.45;
      return base / samples * variance;
    });
  }

  double _generateDelta(Random random) {
    final value = (random.nextDouble() * 0.22) - 0.05;
    return double.parse(value.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

class _InsightsSnapshot {
  const _InsightsSnapshot({
    required this.metrics,
    required this.segments,
    required this.highlights,
    required this.trending,
  });

  final List<InsightMetric> metrics;
  final List<AudienceSegment> segments;
  final List<InsightHighlight> highlights;
  final List<AudioItem> trending;
}
