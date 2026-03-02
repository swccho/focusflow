import 'package:flutter/material.dart';

/// Simple home screen. No feature logic yet.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'FocusFlow',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
      ),
    );
  }
}
