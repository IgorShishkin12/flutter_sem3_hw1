// presentation/widgets/swipeable_cat_card.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/cat.dart';

class SwipeableCatCard extends StatefulWidget {
  final Cat cat;
  final VoidCallback onLike;
  final VoidCallback onDislike;
  final VoidCallback onTap;

  const SwipeableCatCard({
    super.key,
    required this.cat,
    required this.onLike,
    required this.onDislike,
    required this.onTap,
  });

  @override
  State<SwipeableCatCard> createState() => _SwipeableCatCardState();
}

class _SwipeableCatCardState extends State<SwipeableCatCard>
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
        widget.onLike();
      } else {
        widget.onDislike();
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
          child: CachedNetworkImage(
            imageUrl: widget.cat.imageUrl,
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
