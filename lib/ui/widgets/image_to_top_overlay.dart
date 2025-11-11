import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

class ImageToTopOverlay extends StatefulWidget {
  const ImageToTopOverlay({super.key, required this.preview, required this.details});

  final Widget preview;
  final Widget details;

  @override
  State<ImageToTopOverlay> createState() => _ImageToTopOverlayState();
}

class _ImageToTopOverlayState extends State<ImageToTopOverlay> {
  bool _expanded = false;
  bool _flipped = false;

  void _toggle() {
    setState(() {
      if (!_expanded) {
        _expanded = true;
      } else if (!_flipped) {
        _flipped = true;
      } else {
        _expanded = false;
        _flipped = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: PageTransitionSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation, secondaryAnimation) {
          return FadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          );
        },
        child: _expanded
            ? AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: _flipped
                    ? Container(
                        key: const ValueKey('details'),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          color: Theme.of(context).colorScheme.surface.withOpacity(0.95),
                        ),
                        padding: const EdgeInsets.all(24),
                        child: widget.details,
                      )
                    : ClipRRect(
                        key: const ValueKey('preview'),
                        borderRadius: BorderRadius.circular(32),
                        child: widget.preview,
                      ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: widget.preview,
              ),
      ),
    );
  }
}
