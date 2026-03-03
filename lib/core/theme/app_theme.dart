import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryBrand = Color(0xFFFF5500); 
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primaryBrand,
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primaryBrand,
        unselectedItemColor: Colors.grey,
      ),
      // Add your Google Fonts or custom font families here
    );
  }
}