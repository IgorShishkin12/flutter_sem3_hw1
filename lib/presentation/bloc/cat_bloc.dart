// presentation/bloc/cat_bloc.dart
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/cat.dart';
import '../../domain/usecases/get_cat.dart';
import 'liked_cats_bloc.dart';

part 'cat_event.dart';

part 'cat_state.dart';

class CatBloc extends Bloc<CatEvent, CatState> {
  final GetCatUseCase getCatUseCase;
  List<Cat> cats = [];
  int likes_ = 0;
  final String _cntOfLikedCatsKey = "cntOfLikedCatsKey";

  Future<void> syncLikes() async {
    final prefs = await SharedPreferences.getInstance();
    final cnt = prefs.getInt(_cntOfLikedCatsKey);
    if (cnt == null) {
      likes_ = 0;
    } else {
      likes_ = max(cnt, likes_);
    }
    prefs.setInt(_cntOfLikedCatsKey, likes_);
  }

  CatBloc(this.getCatUseCase) : super(CatInitial()) {
    on<LoadCatEvent>(_onLoadCat);
    on<LikeCatEvent>(_onLikeCat);
    on<DislikeCatEvent>(_onDislikeCat);

    // Load initial cats
    for (int i = 0; i < 20; i++) {
      add(LoadCatEvent());
    }
  }

  /*
  Future<void> _saveViewedCats() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> viewedCatsJson = cats.take(20).map((cat) => jsonEncode(cat.toJson())).toList(); // Save
    await prefs.setStringList(_viewedCatsKey, viewedCatsJson);
  }

  Future<void> _onLoadPersistedCats(LoadPersistedCatsEvent event, Emitter<CatState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final viewedCatsJson = prefs.getStringList(_viewedCatsKey);
    if (viewedCatsJson != null && viewedCatsJson.isNotEmpty) {
      cats = viewedCatsJson.map((catJson) => Cat.fromJsonStore(jsonDecode(catJson))).toList();
      if (cats.isNotEmpty) {
        emit(CatLoaded(cats.first, likes)); // Show the first persisted cat
        return; // Don't load from network if persisted cats are available
      }
    }
    add(LoadCatEvent());
  }
  */

  Future<void> _onLoadCat(LoadCatEvent event, Emitter<CatState> emit) async {
    await syncLikes();
    emit(CatLoading());
    try {
      final cat = await getCatUseCase.execute();
      if (!cats.any((existingCat) => existingCat.id == cat.id)) {
        // Avoid duplicates
        cats.insert(0, cat);
        if (cats.length > 20) {
          cats.removeLast();
        }
      }
      // cats.insert(0, cat);
      emit(CatLoaded(cats.first, likes_)); // Include likes count
    } catch (e) {
      emit(CatError("Failed to load cat: ${e.toString()}"));
    }
  }

  void _onLikeCat(LikeCatEvent event, Emitter<CatState> emit) {
    likes_++;
    final likedCat = cats.first.copyWith();
    event.context.read<LikedCatsBloc>().add(AddLikedCat(likedCat));
    emit(CatLoaded(cats.first, likes_)); // Emit with current likes count
    add(LoadCatEvent());
  }

  void _onDislikeCat(DislikeCatEvent event, Emitter<CatState> emit) {
    emit(CatLoaded(cats.first, likes_)); // Maintain likes count
    add(LoadCatEvent());
  }
}
