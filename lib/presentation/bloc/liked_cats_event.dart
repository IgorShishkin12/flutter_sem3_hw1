part of 'liked_cats_bloc.dart';

abstract class LikedCatsEvent extends Equatable {
  const LikedCatsEvent();

  @override
  List<Object> get props => [];
}

class LoadLikedCats extends LikedCatsEvent {}

class AddLikedCat extends LikedCatsEvent {
  final Cat cat;

  const AddLikedCat(this.cat);

  @override
  List<Object> get props => [cat];
}

class RemoveLikedCat extends LikedCatsEvent {
  final String catId;

  const RemoveLikedCat(this.catId);

  @override
  List<Object> get props => [catId];
}

class FilterLikedCats extends LikedCatsEvent {
  final String? breed;

  const FilterLikedCats(this.breed);

  @override
  List<Object> get props => [breed ?? ''];
}
