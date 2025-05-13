import 'dart:convert';

// import 'dart:nativewrappers/_internal/vm/lib/internal_patch.dart';
import 'dart:developer';

// import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/cat.dart';

part 'liked_cats_event.dart';

part 'liked_cats_state.dart';

class LikedCatsBloc extends Bloc<LikedCatsEvent, LikedCatsState> {
  List<Cat> likedCats = [];
  String? filterBreed;
  static const String _likedCatsKey = 'liked_cats_ids';

  LikedCatsBloc() : super(LikedCatsInitial()) {
    on<LoadLikedCats>(_onLoadLikedCats);
    on<AddLikedCat>(_onAddLikedCat);
    on<RemoveLikedCat>(_onRemoveLikedCat);
    on<FilterLikedCats>(_onFilterLikedCats);

    add(LoadLikedCats());
  }

  Future<void> _saveLikedCats() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> likedCatsJson =
        likedCats.map((cat) => jsonEncode(cat.toJson())).toList();
    await prefs.setStringList(_likedCatsKey, likedCatsJson);
    log("cats saved to memory");
  }

  Future<void> _onLoadLikedCats(
    LoadLikedCats event,
    Emitter<LikedCatsState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final likedCatIds = prefs.getStringList(_likedCatsKey);

    if (likedCatIds != null) {
      final likedCatsJson = likedCatIds;
      try {
        likedCats =
            likedCatsJson
                .map((catString) => Cat.fromJsonStore(jsonDecode(catString)))
                .toList();
      } catch (e) {
        log("error during unpickling cats");
        likedCats = [];
      }
    }
    emit(LikedCatsUpdated(List.from(likedCats)));
  }

  void _onAddLikedCat(AddLikedCat event, Emitter<LikedCatsState> emit) {
    if (!likedCats.any((cat) => cat.id == event.cat.id)) {
      // Avoid duplicates
      likedCats.add(event.cat);
      emit(LikedCatsUpdated(List.from(likedCats)));
      _saveLikedCats(); // Save after adding
    }
  }

  void _onRemoveLikedCat(RemoveLikedCat event, Emitter<LikedCatsState> emit) {
    likedCats.removeWhere(
      (cat) => cat.id == event.catId,
    );
    emit(LikedCatsUpdated(List.from(likedCats)));
    _saveLikedCats();
  }

  void _onFilterLikedCats(FilterLikedCats event, Emitter<LikedCatsState> emit) {
    filterBreed = event.breed;
    final filtered =
        filterBreed == null ||
                filterBreed ==
                    'All'
            ? List.from(likedCats)
            : likedCats.where((cat) => cat.breedName == filterBreed).toList();
    emit(LikedCatsUpdated(filtered as List<Cat>));
  }
}
