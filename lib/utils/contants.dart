import 'package:flutter/material.dart';
import 'package:heavenhunt/screens/explore_screen.dart';

class Constants {
  static List<Widget> HomeScreenPages = [
    ExploreScreen(),
    const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Messages',
          ),
        ],
      ),
    ),
  ];
}
