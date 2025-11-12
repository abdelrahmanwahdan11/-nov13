import 'dart:math';

import 'package:flutter/material.dart';

class WaveformStub extends StatefulWidget {
  const WaveformStub({super.key, this.height = 48});

  final double height;

  @override
  State<WaveformStub> createState() => _WaveformStubState();
}

class _WaveformStubState extends State<WaveformStub> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final random = Random(_controller.value.hashCode);
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(20, (index) {
            final scale = random.nextDouble();
            return Expanded(
              child: FractionallySizedBox(
                heightFactor: 0.2 + scale * 0.8,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4 + scale * 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
