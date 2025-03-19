import 'package:flutter/material.dart';
import 'cat_model.dart';

class CatDetailScreen extends StatelessWidget {
  final Cat cat;

  const CatDetailScreen({super.key, required this.cat});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(cat.breedName)),
      body: Column(
        children: [
          Image.network(cat.imageUrl),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(cat.description),
          ),
        ],
      ),
    );
  }
}
