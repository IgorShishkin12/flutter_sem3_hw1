import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/liked_cats_bloc.dart';
import '../widgets/cat_card.dart';
import '../widgets/filter_widget.dart';

class LikedCatsScreen extends StatelessWidget {
  const LikedCatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liked Cats'),
        actions: [FilterWidget()],
      ),
      body: BlocBuilder<LikedCatsBloc, LikedCatsState>(
        builder: (context, state) {
          if (state is LikedCatsInitial) {
            return const Center(child: Text('No liked cats yet'));
          }

          final cats = (state as LikedCatsUpdated).cats;
          if (cats.isEmpty) {
            return const Center(child: Text('No cats match the filter'));
          }

          return ListView.builder(
            itemCount: cats.length,
            itemBuilder: (context, index) {
              final cat = cats[index];
              return Dismissible(
                key: Key(cat.id),
                background: Container(color: Colors.red),
                onDismissed: (direction) {
                  context.read<LikedCatsBloc>().add(RemoveLikedCat(cat.id));
                },
                child: CatCard(cat: cat),
              );
            },
          );
        },
      ),
    );
  }
}
