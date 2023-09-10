import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class LoadingAnimation extends StatelessWidget {
  const LoadingAnimation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: RiveAnimation.asset(
        fit: BoxFit.cover,
        'assets/loading.riv',
      ),
    );
  }
}
