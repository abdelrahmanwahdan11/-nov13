import 'package:flutter/material.dart';

import '../../../core/i18n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/controller_scope.dart';
import '../../../data/dummy_data.dart';
import '../../../models/onboarding_guide.dart';
import '../../widgets/genius_app_bar.dart';
import '../../widgets/genius_scaffold.dart';
import '../../widgets/onboarding_guide_card.dart';

class OnboardingGuidesPage extends StatefulWidget {
  const OnboardingGuidesPage({super.key, this.focusId});

  final String? focusId;

  @override
  State<OnboardingGuidesPage> createState() => _OnboardingGuidesPageState();
}

class _OnboardingGuidesPageState extends State<OnboardingGuidesPage> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _jumpToFocusedGuide();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final themeController = ControllerScope.of(context).theme;
    final GeniusPalette palette = themeController.isDark ? geniusTheme.dark : geniusTheme.light;
    final List<OnboardingGuide> guides = DummyData.onboardingGuides;
    final int focusIndex = widget.focusId == null
        ? -1
        : guides.indexWhere((guide) => guide.id == widget.focusId);

    return GeniusScaffold(
      appBar: GeniusAppBar(title: l10n.translate('onboarding_guides_title')),
      body: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        itemBuilder: (context, index) {
          final OnboardingGuide guide = guides[index];
          final bool highlight = index == focusIndex;
          return OnboardingGuideCard(
            guide: guide,
            palette: palette,
            highlight: highlight,
            onPrimaryAction: guide.actions.isEmpty
                ? null
                : () => _handlePrimaryAction(context, guide),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 20),
        itemCount: guides.length,
      ),
    );
  }

  void _handlePrimaryAction(BuildContext context, OnboardingGuide guide) {
    switch (guide.id) {
      case 'record':
        Navigator.of(context).pushNamed('/record');
        break;
      case 'publish':
        Navigator.of(context).pushNamed('/publish');
        break;
      default:
        Navigator.of(context).pushNamed('/editor');
        break;
    }
  }

  void _jumpToFocusedGuide() {
    if (!mounted || widget.focusId == null) {
      return;
    }
    final List<OnboardingGuide> guides = DummyData.onboardingGuides;
    final int index = guides.indexWhere((guide) => guide.id == widget.focusId);
    if (index <= 0) {
      return;
    }
    _scrollController.animateTo(
      index * 420.0,
      duration: const Duration(milliseconds: 480),
      curve: Curves.easeInOut,
    );
  }
}
