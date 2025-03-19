import 'package:flutter/material.dart';

class Cat {
  final String id;
  final String imageUrl;
  final String breedName;
  final String description;
  Image? image;

  Cat({
    required this.id,
    required this.imageUrl,
    required this.breedName,
    required this.description,
    this.image,
  });

  factory Cat.fromJson(Map<String, dynamic> json) {
    final breeds = json['breeds'] as List<dynamic>?;
    final breed = breeds != null && breeds.isNotEmpty ? breeds[0] : null;
    return Cat(
      id: json['id'],
      imageUrl: json['url'],
      breedName: breed?['name'] ?? 'Unknown Breed',
      description: breed?['description'] ?? 'No description available',
    );
  }
}
