import 'package:flutter_test/flutter_test.dart';

import 'package:voxa/controllers/insights_controller.dart';
import 'package:voxa/models/insight_metric.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('ensureLoaded populates metrics', () async {
    final controller = InsightsController();
    await controller.ensureLoaded();

    expect(controller.state.metrics, isNotEmpty);
    expect(controller.state.isLoading, isFalse);
    expect(controller.state.primaryMetric.timeline, isNotEmpty);

    controller.dispose();
  });

  test('changeRange updates the sample count', () async {
    final controller = InsightsController();
    await controller.ensureLoaded();
    final initialCount = controller.state.primaryMetric.timeline.length;

    controller.changeRange(InsightRange.month);
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(controller.state.range, InsightRange.month);
    expect(controller.state.primaryMetric.timeline.length, isNot(initialCount));
    expect(controller.state.primaryMetric.timeline.length,
        equals(InsightRange.month.sampleCount));

    controller.dispose();
  });
}
