import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../bloc/cat_bloc.dart';
import 'cat_detail_screen.dart';
import 'liked_cats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
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
        // Swiped right - like
        context.read<CatBloc>().add(LikeCatEvent(context));
      } else {
        // Swiped left - dislike
        context.read<CatBloc>().add(DislikeCatEvent());
      }
    }

    // Reset position
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cat App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LikedCatsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<CatBloc, CatState>(
        listener: (context, state) {
          if (state is CatError) {
            showDialog(
              context: context,
              builder:
                  (ctx) => AlertDialog(
                    title: const Text('Error'),
                    content: Text(state.message),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
            );
          }
        },
        builder: (context, state) {
          if (state is CatLoading || state is CatInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CatLoaded) {
            final cat = state.cat;
            return Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onHorizontalDragUpdate: _onHorizontalDragUpdate,
                    onHorizontalDragEnd: _onHorizontalDragEnd,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CatDetailScreen(cat: cat),
                        ),
                      );
                    },
                    child: Center(
                      child: Transform.translate(
                        offset: Offset(_dragPosition, 0),
                        child: Transform.rotate(
                          angle: _rotationAngle,
                          alignment: Alignment.center,
                          child: CachedNetworkImage(
                            imageUrl: cat.imageUrl,
                            placeholder:
                                (context, url) =>
                                    const CircularProgressIndicator(),
                            errorWidget:
                                (context, url, error) =>
                                    const Icon(Icons.error),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Text('Breed: ${cat.breedName}'),
                BlocBuilder<CatBloc, CatState>(
                  builder: (context, state) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.thumb_down),
                          color: Colors.grey,
                          onPressed: () {
                            context.read<CatBloc>().add(DislikeCatEvent());
                          },
                        ),
                        Text('Likes: ${context.read<CatBloc>().likes}'),
                        IconButton(
                          icon: const Icon(Icons.thumb_up),
                          color: Colors.red,
                          onPressed: () {
                            context.read<CatBloc>().add(LikeCatEvent(context));
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            );
          }

          return const Center(child: Text('Unexpected state'));
        },
      ),
    );
  }
}
