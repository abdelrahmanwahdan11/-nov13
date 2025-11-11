import 'package:flutter/material.dart';

class SkeletonCard extends StatefulWidget {
  const SkeletonCard({super.key, this.height = 160});

  final double height;

  @override
  State<SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<SkeletonCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final opacity = 0.3 + (_controller.value * 0.5);
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: colors.surfaceVariant.withOpacity(opacity),
            borderRadius: BorderRadius.circular(24),
          ),
        );
      },
    );
  }
}
