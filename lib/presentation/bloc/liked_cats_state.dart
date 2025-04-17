part of 'liked_cats_bloc.dart';

abstract class LikedCatsState extends Equatable {
  const LikedCatsState();

  @override
  List<Object> get props => [];
}

class LikedCatsInitial extends LikedCatsState {}

class LikedCatsUpdated extends LikedCatsState {
  final List<Cat> cats;
  const LikedCatsUpdated(this.cats);

  @override
  List<Object> get props => [cats];
}