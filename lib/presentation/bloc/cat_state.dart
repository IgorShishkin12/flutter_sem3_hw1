part of 'cat_bloc.dart';

abstract class CatState extends Equatable {
  const CatState();

  @override
  List<Object> get props => [];
}

class CatInitial extends CatState {}

class CatLoading extends CatState {}

class CatLoaded extends CatState {
  final Cat cat;
  const CatLoaded(this.cat);

  @override
  List<Object> get props => [cat];
}

class CatError extends CatState {
  final String message;
  const CatError(this.message);

  @override
  List<Object> get props => [message];
}