import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/theme/app_theme.dart';

class SocialPillRow extends StatelessWidget {
  const SocialPillRow({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.dark
        ? geniusTheme.dark
        : geniusTheme.light;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 12,
      children: [
        _SocialButton(label: 'Facebook', icon: IconlyLight.user, color: colors.outline),
        _SocialButton(label: 'Twitter', icon: IconlyLight.activity, color: colors.outline),
        _SocialButton(label: 'Google', icon: Icons.mail_outline, color: colors.outline),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.label, required this.icon, required this.color});

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, color: color),
      label: Text(label, style: TextStyle(color: color)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        side: BorderSide(color: color, width: geniusStrokeWidth),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(pillRadius.toDouble()),
        ),
      ),
    );
  }
}
