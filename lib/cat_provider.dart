import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'cat_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CatProvider with ChangeNotifier {
  int _likes = 0;
  List<Cat?> cats = [];

  Cat? get currentCat => (cats.isNotEmpty) ? cats[0] : null;

  int get likes => _likes;

  CatProvider() {
    for (int i = 0; i < 20; ++i) {
      fetchRandomCat(shouldRemove: false);
    }
  }

  Future<void> fetchRandomCat({shouldRemove = true}) async {
    loadCat();
    if (shouldRemove && cats.isNotEmpty) {
      cats.removeAt(0);
    }
  }

  Future<void> loadCat() async {
    Cat? tmpcat;
    final response = await http.get(
      Uri.parse('https://api.thecatapi.com/v1/images/search?has_breeds=1'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      tmpcat = Cat.fromJson(data[0]);
    } else {
      throw Exception('Failed to load cat id');
    }
    final realResponse = await http.get(
      Uri.parse('https://api.thecatapi.com/v1/images/${tmpcat.id}'),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(realResponse.body);
      tmpcat = Cat.fromJson(data);
      notifyListeners();
    } else {
      throw Exception('Failed to load full cat');
    }
    tmpcat.image = CachedNetworkImage(
      imageUrl: tmpcat.imageUrl,
      fit: BoxFit.cover,
    );

    cats.add(tmpcat);
  }

  void likeCat() {
    _likes++;
    fetchRandomCat();
  }

  void dislikeCat() {
    fetchRandomCat();
  }
}
