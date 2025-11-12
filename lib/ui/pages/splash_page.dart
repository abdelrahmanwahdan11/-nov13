import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/auth_controller.dart';
import '../../core/theme/app_theme.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    final bool hasSeenOnboarding = prefs.getBool('onboardingComplete') ?? false;
    final bool setupComplete = prefs.getBool(AuthController.setupCompleteKey) ?? false;
    if (!mounted) return;
    if (!hasSeenOnboarding) {
      Navigator.of(context).pushReplacementNamed('/onboarding');
      return;
    }
    if (!setupComplete) {
      Navigator.of(context).pushReplacementNamed('/auth/signin');
      return;
    }
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.dark
        ? geniusTheme.dark
        : geniusTheme.light;
    return GradientBackground(
      dark: Theme.of(context).brightness == Brightness.dark,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Text(
            'Voxa',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: colors.ink,
            ),
          ),
        ),
      ),
    );
  }
}
