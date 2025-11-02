import 'package:flutter/material.dart';
import 'main_navigation_screen.dart';

// HomeScreen is now just a redirect to MainNavigationScreen
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainNavigationScreen();
  }
}
