import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/liked_cats_bloc.dart';

class FilterWidget extends StatelessWidget {
  const FilterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<LikedCatsBloc>();
    final breeds = bloc.likedCats.map((cat) => cat.breedName).toSet().toList();

    return PopupMenuButton<String>(
      onSelected: (breed) {
        bloc.add(FilterLikedCats(breed == 'All' ? null : breed));
      },
      itemBuilder:
          (context) => [
            const PopupMenuItem(value: 'All', child: Text('All Breeds')),
            ...breeds.map(
              (breed) => PopupMenuItem(value: breed, child: Text(breed)),
            ),
          ],
      child: const Icon(Icons.filter_list),
    );
  }
}
