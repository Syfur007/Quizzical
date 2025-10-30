import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(Quizzical());
}

class Quizzical extends StatelessWidget {
  const Quizzical({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quizzical Adventure',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: Colors.grey.shade50,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
