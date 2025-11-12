import 'dart:async';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  int _totalSlides = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final int total = _resolveSlides(context.l10n).length;
    if (total != _totalSlides && total > 0) {
      setState(() {
        _totalSlides = total;
        if (_index >= _totalSlides) {
          _index = _totalSlides - 1;
        }
      });
      _restartTimer();
    } else if (total <= 1) {
      _restartTimer();
    }
  }

  void _restartTimer() {
    _timer?.cancel();
    if (_totalSlides <= 1) {
      return;
    }
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || !_controller.hasClients || _totalSlides <= 1) {
        return;
      }
      final int next = (_index + 1) % _totalSlides;
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
    if (_index == value) {
      return;
    }
    setState(() {
      _index = value;
    });
    _restartTimer();
  }

  Future<void> _completeOnboarding() async {
    _timer?.cancel();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('firstRun', false);
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushReplacementNamed('/auth/signin');
  }

  void _goTo(int target) {
    if (!_controller.hasClients) {
      return;
    }
    final int safeTarget = target.clamp(0, _totalSlides - 1);
    _controller.animateToPage(
      safeTarget,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final GeniusPalette colors = Theme.of(context).brightness == Brightness.dark
        ? geniusTheme.dark
        : geniusTheme.light;
    final themeController = ControllerScope.of(context).theme;
    final List<_OnboardingSlide> slides = _resolveSlides(l10n);
    final int safeIndex = slides.isEmpty ? 0 : _index.clamp(0, slides.length - 1);
    final _OnboardingSlide active = slides.isNotEmpty
        ? slides[safeIndex]
        : const _OnboardingSlide(title: '', description: '', visual: _OnboardingVisual('', Colors.transparent));
    final bool isLast = safeIndex >= slides.length - 1 && slides.isNotEmpty;

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
                      key: ValueKey<int>(safeIndex),
                      controller: _controller,
                      onPageChanged: _onPageChanged,
                      itemCount: slides.length,
                      itemBuilder: (context, index) {
                        final _OnboardingSlide slide = slides[index];
                        return Column(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 32),
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    return Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Positioned(
                                          top: 0,
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 500),
                                            curve: Curves.easeInOut,
                                            width: constraints.maxWidth * 0.8,
                                            height: constraints.maxHeight * 0.65,
                                            decoration: BoxDecoration(
                                              color: colors.surface.withOpacity(0.85),
                                              borderRadius: BorderRadius.circular(radiusLg),
                                              border: Border.all(
                                                color: colors.outline,
                                                width: geniusStrokeWidth,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 500),
                                            padding: const EdgeInsets.all(14),
                                            decoration: BoxDecoration(
                                              color: slide.visual.accent.withOpacity(0.9),
                                              borderRadius: BorderRadius.circular(pillRadius.toDouble()),
                                              border: Border.all(
                                                color: colors.outline,
                                                width: geniusStrokeWidth,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.auto_graph, color: Colors.black87),
                                                const SizedBox(width: 12),
                                                Text(
                                                  slide.title,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelLarge
                                                      ?.copyWith(color: Colors.black87),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(radiusLg),
                                          child: AnimatedSwitcher(
                                            duration: const Duration(milliseconds: 600),
                                            child: Image.network(
                                              slide.visual.image,
                                              key: ValueKey<String>(slide.visual.image),
                                              width: constraints.maxWidth * 0.78,
                                              height: constraints.maxHeight * 0.6,
                                              fit: BoxFit.cover,
                                              loadingBuilder: (context, child, progress) {
                                                if (progress == null) {
                                                  return child;
                                                }
                                                return Container(
                                                  width: constraints.maxWidth * 0.78,
                                                  height: constraints.maxHeight * 0.6,
                                                  alignment: Alignment.center,
                                                  child: CircularProgressIndicator(
                                                    value: progress.expectedTotalBytes != null
                                                        ? progress.cumulativeBytesLoaded /
                                                            progress.expectedTotalBytes!
                                                        : null,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                            Text(
                              slide.title,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: colors.ink,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              slide.description,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(color: colors.inkSecondary),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _OnboardingIndicators(
                  activeIndex: safeIndex,
                  total: slides.length,
                  accent: active.visual.accent,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedPillButton(
                        label: l10n.translate('onboarding_prev'),
                        onPressed: safeIndex == 0 ? null : () => _goTo(safeIndex - 1),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedPillButton(
                        label: isLast
                            ? l10n.translate('onboarding_done')
                            : l10n.translate('onboarding_next'),
                        onPressed: () => isLast ? _completeOnboarding() : _goTo(safeIndex + 1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FilledPillButton(
                  label: l10n.translate('onboarding_skip'),
                  onPressed: _completeOnboarding,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<_OnboardingSlide> _resolveSlides(AppLocalizations l10n) {
    final List<Map<String, String>> raw = l10n.listOfMaps('onboarding_slides');
    if (raw.isEmpty) {
      return const <_OnboardingSlide>[
        _OnboardingSlide(
          title: '',
          description: '',
          visual: _OnboardingVisual('', Colors.transparent),
        ),
      ];
    }
    return List<_OnboardingSlide>.generate(raw.length, (int index) {
      final Map<String, String> item = raw[index];
      final _OnboardingVisual visual = _onboardingVisuals[index % _onboardingVisuals.length];
      return _OnboardingSlide(
        title: item['title'] ?? '',
        description: item['description'] ?? '',
        visual: visual,
      );
    });
  }
}

class _OnboardingIndicators extends StatelessWidget {
  const _OnboardingIndicators({
    required this.activeIndex,
    required this.total,
    required this.accent,
  });

  final int activeIndex;
  final int total;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final GeniusPalette colors = Theme.of(context).brightness == Brightness.dark
        ? geniusTheme.dark
        : geniusTheme.light;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(total, (int i) {
        final bool selected = i == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: selected ? 22 : 10,
          height: 10,
          decoration: BoxDecoration(
            color: selected ? accent : colors.ink.withOpacity(0.25),
            borderRadius: BorderRadius.circular(pillRadius.toDouble()),
            border: Border.all(color: colors.outline, width: geniusStrokeWidth),
          ),
        );
      }),
    );
  }
}

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.title,
    required this.description,
    required this.visual,
  });

  final String title;
  final String description;
  final _OnboardingVisual visual;
}

class _OnboardingVisual {
  const _OnboardingVisual(this.image, this.accent);

  final String image;
  final Color accent;
}

const List<_OnboardingVisual> _onboardingVisuals = <_OnboardingVisual>[
  _OnboardingVisual(
    'https://images.unsplash.com/photo-1511379938547-c1f69419868d',
    Color(0xFFFFE563),
  ),
  _OnboardingVisual(
    'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4',
    Color(0xFFFFD84D),
  ),
  _OnboardingVisual(
    'https://images.unsplash.com/photo-1470225620780-dba8ba36b745',
    Color(0xFFFFC860),
  ),
];
