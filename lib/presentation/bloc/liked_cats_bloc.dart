import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/cat.dart';

part 'liked_cats_event.dart';

part 'liked_cats_state.dart';

class LikedCatsBloc extends Bloc<LikedCatsEvent, LikedCatsState> {
  List<Cat> likedCats = [];
  String? filterBreed;

  LikedCatsBloc() : super(LikedCatsInitial()) {
    on<AddLikedCat>(_onAddLikedCat);
    on<RemoveLikedCat>(_onRemoveLikedCat);
    on<FilterLikedCats>(_onFilterLikedCats);
  }

  void _onAddLikedCat(AddLikedCat event, Emitter<LikedCatsState> emit) {
    likedCats.add(event.cat);
    emit(LikedCatsUpdated(List.from(likedCats)));
  }

  void _onRemoveLikedCat(RemoveLikedCat event, Emitter<LikedCatsState> emit) {
    likedCats.removeAt(event.index);
    emit(LikedCatsUpdated(List.from(likedCats)));
  }

  void _onFilterLikedCats(FilterLikedCats event, Emitter<LikedCatsState> emit) {
    filterBreed = event.breed;
    final filtered =
        filterBreed == null
            ? likedCats
            : likedCats.where((cat) => cat.breedName == filterBreed).toList();
    emit(LikedCatsUpdated(filtered));
  }
}
