// domain/entities/cat.dart
import 'package:cached_network_image/cached_network_image.dart';

class Cat {
  final String id;
  final String imageUrl;
  final String breedName;
  final String description;
  final DateTime likedDate;
  CachedNetworkImage? image;

  Cat({
    required this.id,
    required this.imageUrl,
    required this.breedName,
    required this.description,
    required this.likedDate,
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
      likedDate: DateTime.now(),
    );
  }

  Cat copyWith({
    String? id,
    String? imageUrl,
    String? breedName,
    String? description,
    DateTime? likedDate,
    CachedNetworkImage? image,
  }) {
    return Cat(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      breedName: breedName ?? this.breedName,
      description: description ?? this.description,
      likedDate: likedDate ?? this.likedDate,
      image: image ?? this.image,
    );
  }
}