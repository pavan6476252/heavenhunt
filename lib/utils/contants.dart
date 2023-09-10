import 'package:flutter/material.dart';
import 'package:heavenhunt/screens/explore_screen.dart';
import 'package:rive/rive.dart';

class Constants {
  static List<Widget> HomeScreenPages = [
    ExploreScreen(),
    RiveAnimation.asset('assets/ani404.riv')
  ];
}
