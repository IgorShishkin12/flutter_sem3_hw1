// presentation/bloc/cat_bloc.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/cat.dart';
import '../../domain/usecases/get_cat.dart';
import 'liked_cats_bloc.dart';

part 'cat_event.dart';

part 'cat_state.dart';

class CatBloc extends Bloc<CatEvent, CatState> {
  final GetCatUseCase getCatUseCase;
  List<Cat> cats = [];
  int likes = 0;

  CatBloc(this.getCatUseCase) : super(CatInitial()) {
    on<LoadCatEvent>(_onLoadCat);
    on<LikeCatEvent>(_onLikeCat);
    on<DislikeCatEvent>(_onDislikeCat);

    // Load initial cats
    for (int i = 0; i < 20; i++) {
      add(LoadCatEvent());
    }
  }

  Future<void> _onLoadCat(LoadCatEvent event, Emitter<CatState> emit) async {
    emit(CatLoading());
    try {
      final cat = await getCatUseCase.execute();
      cats.insert(0, cat);
      emit(CatLoaded(cats.first));
    } catch (e) {
      emit(CatError(e.toString()));
    }
  }

  void _onLikeCat(LikeCatEvent event, Emitter<CatState> emit) {
    likes++;
    final likedCat = cats.first.copyWith();
    event.context.read<LikedCatsBloc>().add(AddLikedCat(likedCat));
    add(LoadCatEvent());
  }

  void _onDislikeCat(DislikeCatEvent event, Emitter<CatState> emit) {
    add(LoadCatEvent());
  }
}
