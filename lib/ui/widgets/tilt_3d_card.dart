import 'dart:math';

import 'package:flutter/material.dart';

class Tilt3DCard extends StatefulWidget {
  const Tilt3DCard({super.key, required this.child, this.height = 200});

  final Widget child;
  final double height;

  @override
  State<Tilt3DCard> createState() => _Tilt3DCardState();
}

class _Tilt3DCardState extends State<Tilt3DCard> {
  double _dx = 0;
  double _dy = 0;

  void _update(Offset offset) {
    setState(() {
      _dx = (offset.dx - 0.5) * 0.3;
      _dy = (offset.dy - 0.5) * -0.3;
    });
  }

  void _reset() {
    setState(() {
      _dx = 0;
      _dy = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerHover: (event) {
        final box = context.findRenderObject() as RenderBox?;
        if (box != null) {
          final local = box.globalToLocal(event.position);
          _update(Offset(local.dx / box.size.width, local.dy / box.size.height));
        }
      },
      onPointerDown: (event) {
        final box = context.findRenderObject() as RenderBox?;
        if (box != null) {
          final local = box.globalToLocal(event.position);
          _update(Offset(local.dx / box.size.width, local.dy / box.size.height));
        }
      },
      onPointerUp: (_) => _reset(),
      onPointerCancel: (_) => _reset(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: widget.height,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(_dy)
          ..rotateY(_dx),
        child: widget.child,
      ),
    );
  }
}
