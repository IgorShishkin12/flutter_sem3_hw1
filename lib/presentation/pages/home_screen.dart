// presentation/pages/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/cat_bloc.dart';
import '../widgets/cat_image.dart';
import '../widgets/likes_counter.dart';
import '../widgets/swipe_detector.dart';
import 'cat_detail_screen.dart';
import 'liked_cats_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<CatBloc, CatState>(
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
                  return Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: SwipeDetector(
                            onSwipeLeft:
                                () => context.read<CatBloc>().add(
                                  DislikeCatEvent(),
                                ),
                            onSwipeRight:
                                () => context.read<CatBloc>().add(
                                  LikeCatEvent(context),
                                ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          CatDetailScreen(cat: state.cat),
                                ),
                              );
                            },
                            child: CatImage(cat: state.cat),
                          ),
                        ),
                      ),
                      Text('Breed: ${state.cat.breedName}'),
                    ],
                  );
                }

                return const Center(child: Text('Unexpected state'));
              },
            ),
          ),
          const LikesCounter(),
        ],
      ),
    );
  }
}
