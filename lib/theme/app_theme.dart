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
        primary: Color(0xFFB197FC), // Turquesa (FAB, AppBar)
        secondary: Color(0xFFF586A9), // Azul secundario
        // 🌸 Nuevo: Rosado (tu header y bullets)
        tertiary: Color(0xFF3DAAD8),

        // 🧱 Superficies
        surface: Colors.white, // Cards
        background: Color(0xFFF7F7F7), // Fondo general
        error: Color(0xFFFF6B6B),

        // 🖊️ Texto
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onTertiary: Colors.white,
        onSurface: Colors.black,
        onBackground: Colors.black,
        onError: Colors.white,

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

      // 🎨 Fondo general (negro real como tu UI)
      scaffoldBackgroundColor: const Color(0xFF141414),

      // 🎯 Color principal (azul tipo iconos del menú)
      primaryColor: const Color(0xFF3052F4),

      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF5EC1A2), // Azul moderno (iconos)
        secondary: Color(0xFFC871FF), // Naranja suave (CTA tipo "Pro")
        tertiary: Color(0xFFFFD12E), // Verde leve (badges / éxito)
        // 🧱 Superficies (cards tipo gris oscuro elegante)
        surface: Color(0xFF2C3034),
        background: Color(0xFF0B0B0B),
        error: Color(0xFFFF4D4D),

        // 🖊️ Texto
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onTertiary: Colors.white,
        onSurface: Color(0xFFEAEAEA),
        onBackground: Color(0xFFEAEAEA),
        onError: Colors.white,

        // 🌫️ Bordes y separadores suaves
        outline: Color(0xFF919193),
        shadow: Colors.black,
      ),

      // 🧾 Cards (igual que la imagen)
      cardColor: const Color(0xFF1C1C1E),

      // ✍️ Texto global
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Color(0xFFEAEAEA)),
      ),

      // 📌 AppBar (oscura, elegante)
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0B0B0B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      // 🔘 FAB (azul consistente)
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF3052F4),
        foregroundColor: Colors.white,
      ),

      // 📏 Divider (líneas sutiles)
      dividerColor: Color(0xFF919193),

      // 🧊 Sombras
      shadowColor: Colors.black,
    );
  }
}
