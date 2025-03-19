import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/main_image_rotation.dart';

import 'cat_detail_screen.dart';
import 'cat_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final GlobalKey _imageKey = GlobalKey();
  late MainImageRotation mainRotation = MainImageRotation(_imageKey);

  @override
  void initState() {
    // mainRotation = MainImageRotation(_imageKey);
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      mainRotation.addRotation(
        details.primaryDelta! / 300,
        shouldNotify: false,
      );
    });
    mainRotation.tryUpdate();
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    _controller.animateTo(
      0,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
    if (details.primaryVelocity! < 0) {
      Provider.of<CatProvider>(context, listen: false).dislikeCat();
    } else if (details.primaryVelocity! > 0) {
      Provider.of<CatProvider>(context, listen: false).likeCat();
    }
    mainRotation.reset();
  }

  @override
  Widget build(BuildContext context) {
    final catProvider = Provider.of<CatProvider>(context);

    if (catProvider.currentCat == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Cat App')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Cat App')),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            CatDetailScreen(cat: catProvider.currentCat!),
                  ),
                );
              },
              onHorizontalDragUpdate: _onHorizontalDragUpdate,
              onHorizontalDragEnd: _onHorizontalDragEnd,
              child: Center(
                key: _imageKey,
                child: ListenableBuilder(
                  listenable: mainRotation,
                  builder: (BuildContext ctx, Widget? widget) {
                    return Transform.translate(
                      offset: Offset(mainRotation.dx, mainRotation.dy),
                      child: Transform.rotate(
                        angle: mainRotation.angle,
                        alignment: Alignment.bottomCenter,
                        child: catProvider.currentCat!.image,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Text('Breed: ${catProvider.currentCat!.breedName}'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              DislikeIcon(catProvider: catProvider),
              Text('Likes: ${catProvider.likes}'),
              LikeIcon(catProvider: catProvider),
            ],
          ),
        ],
      ),
    );
  }
}

class DislikeIcon extends StatelessWidget {
  const DislikeIcon({
    super.key,
    required this.catProvider,
  });

  final CatProvider catProvider;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.thumb_down),
      color: Colors.grey,
      onPressed: () {
        catProvider.dislikeCat();
      },
    );
  }
}

class LikeIcon extends StatelessWidget {
  const LikeIcon({
    super.key,
    required this.catProvider,
  });

  final CatProvider catProvider;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.thumb_up),
      color: Colors.red,
      onPressed: () {
        catProvider.likeCat();
      },
    );
  }
}
