import 'package:flutter_test/flutter_test.dart';

import 'package:voxa/controllers/community_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('ensureLoaded hydrates events and spotlight', () async {
    final controller = CommunityController();
    await controller.ensureLoaded();

    expect(controller.state.loading, isFalse);
    expect(controller.state.events, isNotEmpty);
    expect(controller.state.spotlight.length, lessThanOrEqualTo(4));

    controller.dispose();
  });

  test('filters respect live toggle and category selections', () async {
    final controller = CommunityController();
    await controller.ensureLoaded();
    controller.toggleLiveOnly();
    await Future<void>.delayed(const Duration(milliseconds: 650));

    expect(controller.state.liveOnly, isTrue);
    expect(controller.state.events.every((event) => event.isLive), isTrue);

    controller.selectCategory('Challenges');
    await Future<void>.delayed(const Duration(milliseconds: 650));

    expect(controller.state.category, 'Challenges');
    expect(controller.state.events.every((event) => event.category == 'Challenges'), isTrue);

    controller.dispose();
  });

  test('bookmark toggles persist in state', () async {
    final controller = CommunityController();
    await controller.ensureLoaded();
    final id = controller.state.events.first.id;

    controller.toggleBookmark(id);
    expect(controller.state.bookmarked.contains(id), isTrue);

    controller.toggleBookmark(id);
    expect(controller.state.bookmarked.contains(id), isFalse);

    controller.dispose();
  });
}
