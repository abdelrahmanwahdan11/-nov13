import 'dart:async';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import '../../../controllers/theme_controller.dart';
import '../../../core/i18n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/controller_scope.dart';
import '../../widgets/pill_buttons.dart';

class OnboardingStoryPage extends StatefulWidget {
  const OnboardingStoryPage({super.key});

  @override
  State<OnboardingStoryPage> createState() => _OnboardingStoryPageState();
}

class _OnboardingStoryPageState extends State<OnboardingStoryPage> {
  late final PageController _controller;
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      final next = (_index + 1) % context.l10n.list('onboarding').length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onPageChanged(int value) {
    setState(() {
      _index = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).brightness == Brightness.dark
        ? geniusTheme.dark
        : geniusTheme.light;
    final themeController = ControllerScope.of(context).theme;
    return GradientBackground(
      dark: themeController.isDark,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Expanded(
                  child: PageTransitionSwitcher(
                    duration: const Duration(milliseconds: 600),
                    transitionBuilder: (child, animation, secondaryAnimation) {
                      return SharedAxisTransition(
                        animation: animation,
                        secondaryAnimation: secondaryAnimation,
                        transitionType: SharedAxisTransitionType.horizontal,
                        child: child,
                      );
                    },
                    child: PageView.builder(
                      key: ValueKey(_index),
                      controller: _controller,
                      onPageChanged: _onPageChanged,
                      itemCount: l10n.list('onboarding').length,
                      itemBuilder: (context, index) {
                        final text = l10n.list('onboarding')[index];
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.graphic_eq, size: 120, color: colors.ink),
                            const SizedBox(height: 32),
                            Text(
                              text,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: colors.ink,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(l10n.list('onboarding').length, (i) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: i == _index ? 16 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == _index ? colors.ink : colors.ink.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedPillButton(
                        label: 'Prev',
                        onPressed: () {
                          final prev = (_index - 1) < 0
                              ? l10n.list('onboarding').length - 1
                              : _index - 1;
                          _controller.animateToPage(
                            prev,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedPillButton(
                        label: 'Next',
                        onPressed: () {
                          final next = (_index + 1) % l10n.list('onboarding').length;
                          _controller.animateToPage(
                            next,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FilledPillButton(
                  label: 'Skip',
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/auth/signin');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
