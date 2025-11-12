import 'package:flutter/material.dart';

class InsightMetric {
  InsightMetric({
    required this.id,
    required this.title,
    required this.value,
    required this.delta,
    required this.timeline,
    this.subtitle,
    this.unit,
  }) : assert(timeline.isNotEmpty, 'timeline cannot be empty');

  final String id;
  final String title;
  final int value;
  final double delta;
  final List<double> timeline;
  final String? subtitle;
  final String? unit;

  bool get isPositive => delta >= 0;

  double get deltaPercentage => delta * 100;

  double get maxTimelineValue => timeline.reduce((a, b) => a > b ? a : b);
}

class AudienceSegment {
  const AudienceSegment({
    required this.label,
    required this.percentage,
    required this.highlight,
  });

  final String label;
  final double percentage;
  final String highlight;
}

class InsightHighlight {
  const InsightHighlight({
    required this.title,
    required this.caption,
    required this.icon,
  });

  final String title;
  final String caption;
  final IconData icon;
}

enum InsightRange { week, month, quarter }

extension InsightRangeX on InsightRange {
  int get sampleCount {
    switch (this) {
      case InsightRange.week:
        return 7;
      case InsightRange.month:
        return 30;
      case InsightRange.quarter:
        return 12;
    }
  }

  String get analyticsSeed {
    switch (this) {
      case InsightRange.week:
        return 'week';
      case InsightRange.month:
        return 'month';
      case InsightRange.quarter:
        return 'quarter';
    }
  }
}
