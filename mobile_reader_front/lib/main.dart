import 'package:flutter/material.dart';
import 'package:mobile_reader_front/views/navigation_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'K Reader',
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color.fromARGB(255, 24, 24, 24),
        scaffoldBackgroundColor: const Color.fromARGB(255, 24, 24, 24),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: Colors.amber[800],
          unselectedItemColor: Colors.grey,
        ),
      ),
      home: const NavigationScreen(),
    );
  }
}
