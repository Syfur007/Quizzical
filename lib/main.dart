import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(TriviaQuizApp());
}

class TriviaQuizApp extends StatelessWidget {
  const TriviaQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trivia Quest',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
