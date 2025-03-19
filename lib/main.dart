import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cat_provider.dart';
import 'home_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(create: (context) => CatProvider(), child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Cat App', home: HomeScreen());
  }
}
