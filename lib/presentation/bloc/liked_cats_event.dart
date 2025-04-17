part of 'liked_cats_bloc.dart';

abstract class LikedCatsEvent extends Equatable {
  const LikedCatsEvent();

  @override
  List<Object> get props => [];
}

class AddLikedCat extends LikedCatsEvent {
  final Cat cat;
  const AddLikedCat(this.cat);

  @override
  List<Object> get props => [cat];
}

class RemoveLikedCat extends LikedCatsEvent {
  final int index;
  const RemoveLikedCat(this.index);

  @override
  List<Object> get props => [index];
}

class FilterLikedCats extends LikedCatsEvent {
  final String? breed;
  const FilterLikedCats(this.breed);

  @override
  List<Object> get props => [breed ?? ''];
}