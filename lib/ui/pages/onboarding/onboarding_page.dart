import 'dart:async';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../controllers/theme_controller.dart';
import '../../../core/i18n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/controller_scope.dart';
import '../../../core/utils/transparent_image.dart';
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
  bool _hasCompleted = false;

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
    _timer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (!mounted || !_controller.hasClients || _totalSlides <= 1) {
        return;
      }
      if (_index >= _totalSlides - 1) {
        _timer?.cancel();
        await Future<void>.delayed(const Duration(milliseconds: 400));
        if (mounted) {
          _completeOnboarding();
        }
        return;
      }
      final int next = (_index + 1).clamp(0, _totalSlides - 1);
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
    if (_hasCompleted) {
      return;
    }
    _hasCompleted = true;
    _timer?.cancel();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('firstRun', false);
    await prefs.setBool('onboardingComplete', true);
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double horizontalPadding = constraints.maxWidth > 720 ? 48 : 24;
              final double verticalPadding = constraints.maxHeight > 740 ? 32 : 20;
              final double sectionSpacing = constraints.maxHeight > 640 ? 28 : 20;

              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          PageView.builder(
                            controller: _controller,
                            onPageChanged: _onPageChanged,
                            physics: const BouncingScrollPhysics(),
                            itemCount: slides.length,
                            itemBuilder: (context, index) {
                              final _OnboardingSlide slide = slides[index];
                              return _OnboardingVisualCard(
                                slide: slide,
                                isActive: index == safeIndex,
                              );
                            },
                          ),
                          Positioned(
                            bottom: constraints.maxHeight > 640 ? 32 : 24,
                            left: 0,
                            right: 0,
                            child: _OnboardingIndicators(
                              activeIndex: safeIndex,
                              total: slides.length,
                              accent: active.visual.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: sectionSpacing),
                    PageTransitionSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder: (child, animation, secondaryAnimation) {
                        return SharedAxisTransition(
                          animation: animation,
                          secondaryAnimation: secondaryAnimation,
                          transitionType: SharedAxisTransitionType.vertical,
                          child: child,
                        );
                      },
                      child: Column(
                        key: ValueKey<int>(safeIndex),
                        children: [
                          Text(
                            active.title,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            active.description,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  height: 1.5,
                                ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: sectionSpacing),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedPillButton(
                            label: l10n.translate('onboarding_prev'),
                            onPressed: safeIndex == 0 ? null : () => _goTo(safeIndex - 1),
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedPillButton(
                            label: isLast
                                ? l10n.translate('onboarding_done')
                                : l10n.translate('onboarding_next'),
                            onPressed: () =>
                                isLast ? _completeOnboarding() : _goTo(safeIndex + 1),
                            icon: Icon(
                              isLast
                                  ? Icons.check_rounded
                                  : Icons.arrow_forward_ios_rounded,
                              size: 16,
                            ),
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
              );
            },
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
    final List<Map<String, String>> capped = raw.take(3).toList();
    return List<_OnboardingSlide>.generate(capped.length, (int index) {
      final Map<String, String> item = capped[index];
      final _OnboardingVisual visual = _onboardingVisuals[index % _onboardingVisuals.length];
      return _OnboardingSlide(
        title: item['title'] ?? '',
        description: item['description'] ?? '',
        visual: visual,
      );
    });
  }
}


class _OnboardingVisualCard extends StatelessWidget {
  const _OnboardingVisualCard({
    required this.slide,
    required this.isActive,
  });

  final _OnboardingSlide slide;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final GeniusPalette colors = Theme.of(context).brightness == Brightness.dark
        ? geniusTheme.dark
        : geniusTheme.light;
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool wide = constraints.maxWidth > 520;
        final double maxWidth = wide ? 560 : constraints.maxWidth;
        final double aspectRatio = wide ? 3 / 2 : 4 / 5;
        final double haloSize = wide ? maxWidth * 0.45 : maxWidth * 0.6;
        return Center(
          child: AnimatedScale(
            scale: isActive ? 1 : 0.94,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutBack,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 450),
              opacity: isActive ? 1 : 0.7,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: maxWidth,
                  maxHeight: constraints.maxHeight,
                ),
                child: AspectRatio(
                  aspectRatio: aspectRatio,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(radiusLg),
                      border: Border.all(color: colors.outline, width: geniusStrokeWidth),
                      color: colors.surface.withOpacity(0.9),
                    ),
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeOutCubic,
                            width: haloSize,
                            height: haloSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: slide.visual.accent.withOpacity(0.35),
                              boxShadow: [
                                BoxShadow(
                                  color: slide.visual.accent.withOpacity(0.3),
                                  blurRadius: 120,
                                  spreadRadius: 12,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: Padding(
                            padding: EdgeInsets.all(wide ? 32 : 20),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(radiusLg - 8),
                              child: slide.visual.image.isEmpty
                                  ? Container(color: colors.surface.withOpacity(0.6))
                                  : FadeInImage.memoryNetwork(
                                      placeholder: transparentImage,
                                      image: slide.visual.image,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: wide ? 32 : 20,
                          right: wide ? 32 : 20,
                          bottom: wide ? 28 : 20,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 450),
                            curve: Curves.easeOutCubic,
                            padding: EdgeInsets.symmetric(
                              horizontal: wide ? 24 : 18,
                              vertical: wide ? 18 : 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.55),
                              borderRadius: BorderRadius.circular(radiusMd),
                              border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.2),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 4,
                                  height: wide ? 40 : 32,
                                  decoration: BoxDecoration(
                                    color: slide.visual.accent,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    slide.title,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
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
