//lib/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData chill() {
    return ThemeData(
      brightness: Brightness.light,

      // 🎨 Fondo general
      scaffoldBackgroundColor: const Color(0xFFF7F7F7),

      // 🎯 Color principal
      primaryColor: const Color(0xFF6EC6CA),

      colorScheme: const ColorScheme.light(
        primary: Color(0xFF6EC6CA), // Turquesa (FAB, AppBar)
        secondary: Color(0xFF3DAAD8), // Azul secundario
        // 🌸 Nuevo: Rosado (tu header y bullets)
        tertiary: Color.fromRGBO(245, 134, 169, 1),

        // 🧱 Superficies
        surface: Colors.white, // Cards
        background: Color(0xFFF7F7F7), // Fondo general
        // 🖊️ Texto
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onTertiary: Colors.white,
        onSurface: Colors.black,
        onBackground: Colors.black,

        // 🌫️ Detalles suaves (sombras/dividers)
        outline: Colors.grey,
        shadow: Colors.black,
      ),

      // 🧾 Cards
      cardColor: Colors.white,

      // ✍️ Texto global
      textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.black)),

      // 📌 AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF6EC6CA),
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      // 🔘 FAB
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF6EC6CA),
        foregroundColor: Colors.white,
      ),

      // 📏 Divider
      dividerColor: Colors.grey,

      // 🧊 Sombras suaves
      shadowColor: Colors.black,
    );
  }

  static ThemeData agresivo() {
    return ThemeData(
      brightness: Brightness.dark,

      // 🎨 Fondo general (oscuro profundo)
      scaffoldBackgroundColor: const Color(0xFF0F1720),

      // 🎯 Color principal (verde militar moderno)
      primaryColor: const Color(0xFF4CAF50),

      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF4CAF50), // Verde táctico
        secondary: Color(0xFF00E5FF), // Cyan neón (toque gamer)
        // ⚡ Acento fuerte
        tertiary: Color(0xFFFF3B3B), // Rojo alerta
        // 🧱 Superficies
        surface: Color(0xFF1A1F24), // Cards oscuras
        background: Color(0xFF0F1720), // Fondo base
        // 🖊️ Texto
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onTertiary: Colors.white,
        onSurface: Colors.white,
        onBackground: Colors.white,

        // 🌫️ Detalles
        outline: Color(0xFF3A3F44), // Bordes gris oscuro
        shadow: Colors.black,
      ),

      // 🧾 Cards
      cardColor: const Color(0xFF1A1F24),

      // ✍️ Texto global
      textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white)),

      // 📌 AppBar (modo comando)
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF4CAF50),
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      // 🔘 FAB (botón acción rápida)
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF00E5FF),
        foregroundColor: Colors.black,
      ),

      // 📏 Divider
      dividerColor: Color(0xFF3A3F44),

      // 🧊 Sombras
      shadowColor: Colors.black,
    );
  }
}
