import 'package:flutter/material.dart';
import 'package:mathwizard/splashscreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'ComicSans', // A playful font (add to pubspec.yaml)
      ),
      home: const SplashScreen(),
    );
  }
}
