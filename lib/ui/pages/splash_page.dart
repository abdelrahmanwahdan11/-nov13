import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final prefs = await SharedPreferences.getInstance();
    final firstRun = prefs.getBool('firstRun') ?? true;
    if (firstRun) {
      await prefs.setBool('firstRun', false);
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/onboarding');
    } else {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/auth/signin');
    }
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
