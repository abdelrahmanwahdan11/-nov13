import 'package:flutter_test/flutter_test.dart';

import 'package:voxa/controllers/search_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('initial search seeds onboarding guides', () async {
    final controller = SearchController();
    await Future<void>.delayed(const Duration(milliseconds: 400));

    expect(controller.state.guideMatches, isNotEmpty);

    controller.dispose();
  });

  test('query surfaces matching onboarding guide', () async {
    final controller = SearchController();
    await controller.updateQuery('publish');

    expect(controller.state.guideMatches.any((guide) => guide.id == 'publish'), isTrue);

    controller.dispose();
  });
}
