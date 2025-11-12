import 'dart:math';

import 'package:flutter/material.dart';

class WaveformStub extends StatefulWidget {
  const WaveformStub({super.key, this.height = 48, this.waveform, this.animate = true});

  final double height;
  final List<double>? waveform;
  final bool animate;

  @override
  State<WaveformStub> createState() => _WaveformStubState();
}

class _WaveformStubState extends State<WaveformStub> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant WaveformStub oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.animate && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int barCount = 36;
    return SizedBox(
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final List<double> data = _resolveData(barCount);
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List<Widget>.generate(barCount, (index) {
              final double value = data[index];
              return Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOutCubic,
                    height: widget.height * (0.2 + value * 0.8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.35 + value * 0.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  List<double> _resolveData(int count) {
    final List<double>? waveform = widget.waveform;
    if (waveform != null && waveform.isNotEmpty) {
      if (waveform.length == count) {
        return waveform.map((e) => e.clamp(0.0, 1.0)).toList();
      }
      final List<double> scaled = <double>[];
      for (int i = 0; i < count; i++) {
        final double position = i / count * waveform.length;
        final int lower = position.floor().clamp(0, waveform.length - 1);
        final int upper = position.ceil().clamp(0, waveform.length - 1);
        final double t = position - lower;
        final double value = waveform[lower] * (1 - t) + waveform[upper] * t;
        scaled.add(value.clamp(0.0, 1.0));
      }
      return scaled;
    }

    final Random random = Random((_controller.value * 1000).round());
    return List<double>.generate(count, (index) => random.nextDouble());
  }
}
