import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class DividerText extends StatelessWidget {
  const DividerText({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.dark
        ? geniusTheme.dark
        : geniusTheme.light;
    return Row(
      children: [
        Expanded(child: Divider(color: colors.outline, thickness: geniusStrokeWidth / 2)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            style: TextStyle(color: colors.inkSecondary),
          ),
        ),
        Expanded(child: Divider(color: colors.outline, thickness: geniusStrokeWidth / 2)),
      ],
    );
  }
}
