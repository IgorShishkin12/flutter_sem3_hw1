import 'dart:math';

import 'package:flutter/cupertino.dart';

class MainImageRotation with ChangeNotifier {
  double angle = 0.0;
  late double _x;
  late double _y;
  late double xDefault;
  late double yDefault;
  late double xTmp;
  late double yTmp;
  late GlobalKey _key;
  RenderBox? targetRenderBox;

  MainImageRotation(GlobalKey key) {
    _key = key;
    _x = xTmp = xDefault = 0.0;
    _y = yTmp = yDefault = 0.0;
    tryUpdate();
  }

  void tryUpdate() {
    if (targetRenderBox != null) {
      return;
    }
    if (_key.currentContext?.findRenderObject() != null) {
      targetRenderBox = _key.currentContext?.findRenderObject() as RenderBox;
    } else {
      return;
    }

    final position = targetRenderBox!.localToGlobal(Offset.zero);
    _x = xTmp = xDefault = -position.dx;
    _y = yTmp = yDefault = -position.dy;
  }

  void addRotation(double diffRotation, {bool shouldNotify = true}) {
    angle += diffRotation;
    xTmp = _x * cos(diffRotation) - _y * sin(diffRotation);
    yTmp = _x * (sin(diffRotation)) + _y * cos(diffRotation);
    _x = xTmp;
    _y = yTmp;
    if (shouldNotify) {
      notifyListeners();
    }
  }

  // double get x {
  //   _x = xTmp;
  //   return _x;
  // }
  //
  // double get y {
  //   _y = yTmp;
  //   return _y;
  // }

  double get dx {
    // print(_x-xDefault);
    return _x - xDefault;
  }

  double get dy {
    return _y - yDefault;
  }

  void reset({bool shouldNotify = true}) {
    angle = 0.0;
    _x = xTmp = xDefault;
    _y = yTmp = yDefault;
    if (shouldNotify) {
      notifyListeners();
    }
  }
}
