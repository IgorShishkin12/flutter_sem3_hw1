// lib/presentation/pages/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

import '../bloc/cat_bloc.dart';
import '../widgets/cat_image.dart';
import '../widgets/likes_counter.dart';
import '../widgets/swipe_detector.dart';
import 'cat_detail_screen.dart';
import 'liked_cats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _checkInitialConnectivity();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> _checkInitialConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    _updateConnectionStatus(connectivityResult);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    bool currentlyOffline = result == ConnectivityResult.none;
    if (_isOffline != currentlyOffline) {
      setState(() {
        _isOffline = currentlyOffline;
      });
      _showNetworkStatusSnackbar(currentlyOffline);
      if (!currentlyOffline && context.read<CatBloc>().state is CatError) {
        // If connection is restored and there was an error, try reloading.
        context.read<CatBloc>().add(LoadCatEvent());
      }
    }
  }

  void _showNetworkStatusSnackbar(bool isOffline) {
    if (!mounted) return; // Check if the widget is still in the tree
    final snackBar = SnackBar(
      content: Text(
        isOffline ? 'You are offline. Displaying cached cats.' : 'Back online.',
      ),
      duration: Duration(seconds: isOffline ? 5 : 2),
      backgroundColor: isOffline ? Colors.orange : Colors.green,
    );
    ScaffoldMessenger.of(
      context,
    ).removeCurrentSnackBar(); // Remove previous snackbar
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Cat App'),
            if (_isOffline)
              const Icon(Icons.signal_wifi_off, color: Colors.orange, size: 20),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LikedCatsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<CatBloc, CatState>(
              listener: (context, state) {
                if (state is CatError) {
                  if (!_isOffline) {
                    showDialog(
                      context: context,
                      builder:
                          (ctx) => AlertDialog(
                            title: const Text('Error'),
                            content: Text(state.message),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                    );
                  }
                }
              },
              builder: (context, state) {
                if (state is CatLoading || state is CatInitial) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is CatLoaded) {
                  return Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: SwipeDetector(
                            onSwipeLeft:
                                () => context.read<CatBloc>().add(
                                  DislikeCatEvent(),
                                ),
                            onSwipeRight:
                                () => context.read<CatBloc>().add(
                                  LikeCatEvent(context),
                                ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          CatDetailScreen(cat: state.cat),
                                ),
                              );
                            },
                            child: CatImage(cat: state.cat),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Breed: ${state.cat.breedName}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  );
                }
                if (state is CatError) {
                  // If there's an error and we have previously loaded cats, show them
                  final catBloc = context.read<CatBloc>();
                  if (catBloc.cats.isNotEmpty) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isOffline)
                          const Text(
                            "You are offline. Showing last loaded cat.",
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 16,
                            ),
                          ),
                        if (!_isOffline)
                          Text(
                            "Error: ${state.message}. Showing last loaded cat.",
                            style: TextStyle(color: Colors.red, fontSize: 16),
                          ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: Center(
                            child: SwipeDetector(
                              onSwipeLeft: () => catBloc.add(DislikeCatEvent()),
                              onSwipeRight:
                                  () => catBloc.add(LikeCatEvent(context)),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => CatDetailScreen(
                                          cat: catBloc.cats.first,
                                        ),
                                  ),
                                );
                              },
                              child: CatImage(cat: catBloc.cats.first),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Breed: ${catBloc.cats.first.breedName}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    );
                  }
                  return Center(
                    child: Text(
                      'Error: ${state.message}. Please check your connection and try again.',
                    ),
                  );
                }

                return const Center(
                  child: Text('Unexpected state. Please restart the app.'),
                );
              },
            ),
          ),
          const LikesCounter(),
        ],
      ),
    );
  }
}
