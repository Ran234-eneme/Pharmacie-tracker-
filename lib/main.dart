import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const PharmacieTrackerApp());
}

class PharmacieTrackerApp extends StatelessWidget {
  const PharmacieTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pharmacie Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.green,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: false),
      ),
      home: const HomeScreen(),
    );
  }
}
