// presentation/widgets/likes_counter.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/cat_bloc.dart';

class LikesCounter extends StatelessWidget {
  const LikesCounter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CatBloc, CatState>(
      buildWhen: (previous, current) {
        // Only rebuild when likes change, not when cat changes
        return previous is CatLoaded &&
            current is CatLoaded &&
            context.read<CatBloc>().likes_ != (previous).likes;
      },
      builder: (context, state) {
        return FutureBuilder(
          future: context.read<CatBloc>().syncLikes(),
          builder: (context, state) {
            final likes = context.read<CatBloc>().likes_;
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
                Text('Likes: $likes'),
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
        );
      },
    );
  }
}
