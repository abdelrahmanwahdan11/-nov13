import 'package:flutter/foundation.dart';

@immutable
class OnboardingGuide {
  const OnboardingGuide({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imageUrl,
    required this.focusAreas,
    this.actions = const <String>[],
  });

  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String imageUrl;
  final List<String> focusAreas;
  final List<String> actions;
}
