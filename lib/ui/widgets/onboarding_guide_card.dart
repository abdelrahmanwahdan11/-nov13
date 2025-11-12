import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/transparent_image.dart';
import '../../models/onboarding_guide.dart';
import 'pill_buttons.dart';

class OnboardingGuideCard extends StatelessWidget {
  const OnboardingGuideCard({
    super.key,
    required this.guide,
    required this.palette,
    this.highlight = false,
    this.onPrimaryAction,
  });

  final OnboardingGuide guide;
  final GeniusPalette palette;
  final bool highlight;
  final VoidCallback? onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    final Color borderColor = highlight ? palette.accent : palette.outline;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(geniusRadiusLarge),
        border: Border.all(color: borderColor, width: geniusStrokeWidth),
        boxShadow: highlight
            ? [
                BoxShadow(
                  color: palette.accent.withOpacity(0.25),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(geniusRadiusLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  FadeInImage.memoryNetwork(
                    placeholder: transparentImage,
                    image: guide.imageUrl,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.black.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          guide.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          guide.subtitle,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    guide.description,
                    style: TextStyle(
                      color: palette.inkSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: guide.focusAreas
                        .map(
                          (area) => Chip(
                            label: Text(area.toUpperCase()),
                            backgroundColor: palette.surface,
                            side: BorderSide(color: palette.outline, width: geniusStrokeWidth),
                            shape: const StadiumBorder(),
                            labelStyle: TextStyle(
                              color: palette.ink,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  if (onPrimaryAction != null && guide.actions.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    FilledPillButton(
                      label: guide.actions.first,
                      onPressed: onPrimaryAction!,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
