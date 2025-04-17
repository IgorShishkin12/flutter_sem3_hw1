// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled/presentation/bloc/cat_bloc.dart';
import 'package:untitled/presentation/bloc/liked_cats_bloc.dart';
import 'di/injector.dart';
import 'presentation/pages/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDependencies();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<CatBloc>()),
        BlocProvider(create: (context) => getIt<LikedCatsBloc>()),
      ],
      child: MaterialApp(
        title: 'Cat App',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: HomeScreen(),
      ),
    );
  }
}
