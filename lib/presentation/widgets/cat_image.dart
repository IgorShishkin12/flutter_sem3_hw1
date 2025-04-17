// presentation/widgets/cat_image.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/cat.dart';

class CatImage extends StatelessWidget {
  final Cat cat;

  const CatImage({super.key, required this.cat});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: cat.imageUrl,
      placeholder: (context, url) => const CircularProgressIndicator(),
      errorWidget: (context, url, error) => const Icon(Icons.error),
      fit: BoxFit.cover,
    );
  }
}
