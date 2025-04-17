part of 'cat_bloc.dart';

abstract class CatEvent extends Equatable {
  const CatEvent();

  @override
  List<Object> get props => [];
}

class LoadCatEvent extends CatEvent {}

class LikeCatEvent extends CatEvent {
  final BuildContext context;

  const LikeCatEvent(this.context);

  @override
  List<Object> get props => [context];
}

class DislikeCatEvent extends CatEvent {}
