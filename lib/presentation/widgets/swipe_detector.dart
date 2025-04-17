// presentation/widgets/swipe_detector.dart
import 'package:flutter/material.dart';
import 'dart:math';

class SwipeDetector extends StatefulWidget {
  final Widget child;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;
  final VoidCallback onTap;

  const SwipeDetector({
    super.key,
    required this.child,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    required this.onTap,
  });

  @override
  State<SwipeDetector> createState() => _SwipeDetectorState();
}

class _SwipeDetectorState extends State<SwipeDetector>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _dragPosition = 0.0;
  double _rotationAngle = 0.0;
  final double _swipeThreshold = 100.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragPosition += details.primaryDelta!;
      _rotationAngle = (_dragPosition / 20) * (pi / 180);
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_dragPosition.abs() > _swipeThreshold) {
      if (_dragPosition > 0) {
        widget.onSwipeRight();
      } else {
        widget.onSwipeLeft();
      }
    }

    _controller.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );

    setState(() {
      _dragPosition = 0.0;
      _rotationAngle = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      onTap: widget.onTap,
      child: Transform.translate(
        offset: Offset(_dragPosition, 0),
        child: Transform.rotate(
          angle: _rotationAngle,
          alignment: Alignment.center,
          child: widget.child,
        ),
      ),
    );
  }
}
