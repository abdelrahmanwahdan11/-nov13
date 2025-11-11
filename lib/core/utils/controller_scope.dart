import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/compare_controller.dart';
import '../../controllers/edit_controller.dart';
import '../../controllers/feed_controller.dart';
import '../../controllers/player_controller.dart';
import '../../controllers/publish_controller.dart';
import '../../controllers/record_controller.dart';
import '../../controllers/search_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../controllers/theme_controller.dart';

class ControllerScope extends InheritedWidget {
  const ControllerScope({
    super.key,
    required this.theme,
    required this.auth,
    required this.feed,
    required this.player,
    required this.record,
    required this.edit,
    required this.publish,
    required this.search,
    required this.compare,
    required this.settings,
    required super.child,
  });

  final ThemeController theme;
  final AuthController auth;
  final FeedController feed;
  final PlayerController player;
  final RecordController record;
  final EditController edit;
  final PublishController publish;
  final SearchController search;
  final CompareController compare;
  final SettingsController settings;

  static ControllerScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ControllerScope>();
    assert(scope != null, 'ControllerScope not found');
    return scope!;
  }

  @override
  bool updateShouldNotify(ControllerScope oldWidget) {
    return theme != oldWidget.theme ||
        auth != oldWidget.auth ||
        feed != oldWidget.feed ||
        player != oldWidget.player ||
        record != oldWidget.record ||
        edit != oldWidget.edit ||
        publish != oldWidget.publish ||
        search != oldWidget.search ||
        compare != oldWidget.compare ||
        settings != oldWidget.settings;
  }
}
