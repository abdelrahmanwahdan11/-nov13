import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/insight_metric.dart';

class InsightMetricCard extends StatelessWidget {
  const InsightMetricCard({
    super.key,
    required this.metric,
    required this.colors,
  });

  final InsightMetric metric;
  final GeniusColors colors;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deltaColor = metric.isPositive
        ? theme.colorScheme.primary
        : Colors.redAccent.shade200;
    final icon = metric.isPositive ? Icons.arrow_outward_rounded : Icons.south_west_rounded;
    final unitSuffix = metric.unit?.isNotEmpty == true ? metric.unit : '';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface.withOpacity(theme.brightness == Brightness.dark ? 0.82 : 0.95),
        borderRadius: BorderRadius.circular(radiusLg),
        border: Border.all(color: colors.outline, width: geniusStrokeWidth),
        boxShadow: [
          BoxShadow(
            color: colors.outline.withOpacity(0.05),
            offset: const Offset(0, 8),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(metric.title, style: theme.textTheme.titleMedium),
          if (metric.subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              metric.subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(color: colors.inkSecondary),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${metric.value}${unitSuffix.isNotEmpty ? unitSuffix : ''}',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: deltaColor.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(pillRadius.toDouble()),
                  border: Border.all(color: colors.outline, width: geniusStrokeWidth / 2),
                ),
                child: Row(
                  children: [
                    Icon(icon, size: 16, color: deltaColor),
                    const SizedBox(width: 4),
                    Text(
                      '${metric.deltaPercentage.toStringAsFixed(1)}%',
                      style: theme.textTheme.labelMedium?.copyWith(color: deltaColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 52,
            child: CustomPaint(
              painter: _SparklinePainter(
                values: metric.timeline,
                color: theme.colorScheme.primary,
                accent: colors.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InsightSkeletonCard extends StatelessWidget {
  const InsightSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.dark
        ? geniusTheme.dark
        : geniusTheme.light;
    return Container(
      height: 148,
      decoration: BoxDecoration(
        color: colors.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(radiusLg),
        border: Border.all(color: colors.outline, width: geniusStrokeWidth),
      ),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.values,
    required this.color,
    required this.accent,
  });

  final List<double> values;
  final Color color;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final minValue = values.reduce(min);
    final maxValue = values.reduce(max);
    final range = max(1e-3, maxValue - minValue);

    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = i / (values.length - 1) * size.width;
      final normalized = (values[i] - minValue) / range;
      final y = size.height - normalized * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final areaPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..color = accent.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    canvas.drawPath(areaPath, fillPaint);

    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.color != color ||
        oldDelegate.accent != accent;
  }
}
