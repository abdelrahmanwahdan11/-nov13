import 'package:flutter/material.dart';

class PasswordStrengthMeter extends StatelessWidget {
  const PasswordStrengthMeter({super.key, required this.score});

  final int score; // 0-3

  Color _color(BuildContext context, int index) {
    final colors = [Colors.red, Colors.orange, Colors.amber, Colors.green];
    if (index <= score) {
      return colors[index].withOpacity(0.9);
    }
    return colors[index].withOpacity(0.3);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(4, (index) {
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: EdgeInsets.only(right: index == 3 ? 0 : 8),
            height: 6,
            decoration: BoxDecoration(
              color: _color(context, index),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }
}

int computePasswordScore(String value) {
  int score = 0;
  if (value.length >= 6) score++;
  if (RegExp(r'[A-Z]').hasMatch(value)) score++;
  if (RegExp(r'[0-9]').hasMatch(value)) score++;
  if (RegExp(r'[^A-Za-z0-9]').hasMatch(value)) score++;
  return score.clamp(0, 3);
}

String passwordLabel(int score) {
  switch (score) {
    case 0:
      return 'Very Weak';
    case 1:
      return 'Weak';
    case 2:
      return 'Medium';
    default:
      return 'Strong';
  }
}
