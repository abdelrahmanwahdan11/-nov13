import 'package:flutter_test/flutter_test.dart';

import 'package:voxa/controllers/achievements_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('ensureLoaded hydrates achievements', () async {
    final controller = AchievementsController();

    await controller.ensureLoaded();

    expect(controller.state.achievements, isNotEmpty);
    expect(controller.state.isLoading, isFalse);
    expect(controller.state.level, greaterThanOrEqualTo(1));

    controller.dispose();
  });

  test('completeDailyChallenge advances streak', () async {
    final controller = AchievementsController();
    await controller.ensureLoaded();
    final initialStreak = controller.state.currentStreak;

    controller.completeDailyChallenge();
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(controller.state.currentStreak, greaterThanOrEqualTo(initialStreak));
    controller.dispose();
  });

  test('togglePin toggles pinned goals', () async {
    final controller = AchievementsController();
    await controller.ensureLoaded();
    final achievement = controller.state.achievements.first;
    final initialPinned = achievement.isPinned;

    controller.togglePin(achievement.id);

    expect(controller.state.achievements.first.isPinned, isNot(initialPinned));

    controller.togglePin(achievement.id);
    expect(controller.state.achievements.first.isPinned, equals(initialPinned));

    controller.dispose();
  });
}
