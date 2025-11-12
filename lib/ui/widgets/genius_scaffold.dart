import 'package:flutter/material.dart';

import '../../controllers/theme_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/controller_scope.dart';

class GeniusScaffold extends StatelessWidget {
  const GeniusScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = ControllerScope.of(context).theme;
    final bool dark = themeController.isDark;
    return GradientBackground(
      dark: dark,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: appBar,
          body: body,
          bottomNavigationBar: bottomNavigationBar,
          floatingActionButton: floatingActionButton,
        ),
      ),
    );
  }
}
