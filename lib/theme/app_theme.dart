//lib/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData chill() {
    return ThemeData(
      brightness: Brightness.light,

      scaffoldBackgroundColor: const Color(0xFFF7F7F7),

      primaryColor: const Color(0xFF6EC6CA),

      colorScheme: const ColorScheme.light(
        primary: Color(0xFF6EC6CA),
        secondary: Color(0xFF3DAAD8),
      ),

      cardColor: Colors.white,

      textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.black)),

      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF6EC6CA),
        foregroundColor: Colors.white,
      ),
    );
  }

  static ThemeData agresivo() {
    return ThemeData(
      brightness: Brightness.dark,

      scaffoldBackgroundColor: const Color(0xFF121212),

      primaryColor: Colors.deepPurple,

      colorScheme: const ColorScheme.dark(
        primary: Colors.deepPurple,
        secondary: Colors.purpleAccent,
      ),

      cardColor: const Color(0xFF1E1E1E),

      textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white)),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
    );
  }
}
