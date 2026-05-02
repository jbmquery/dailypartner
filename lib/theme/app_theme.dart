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

      // 🎨 Fondo general (negro real como tu UI)
      scaffoldBackgroundColor: const Color(0xFF0B0B0B),

      // 🎯 Color principal (azul tipo iconos del menú)
      primaryColor: const Color(0xFF3D7BFF),

      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF3D7BFF), // Azul moderno (iconos)
        secondary: Color(0xFFFF8C42), // Naranja suave (CTA tipo "Pro")
        tertiary: Color(0xFF4CAF50), // Verde leve (badges / éxito)
        // 🧱 Superficies (cards tipo gris oscuro elegante)
        surface: Color(0xFF1C1C1E),
        background: Color(0xFF0B0B0B),

        // 🖊️ Texto
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onTertiary: Colors.white,
        onSurface: Color(0xFFEAEAEA),
        onBackground: Color(0xFFEAEAEA),

        // 🌫️ Bordes y separadores suaves
        outline: Color(0xFF2C2C2E),
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
        backgroundColor: Color(0xFF3D7BFF),
        foregroundColor: Colors.white,
      ),

      // 📏 Divider (líneas sutiles)
      dividerColor: Color(0xFF2C2C2E),

      // 🧊 Sombras
      shadowColor: Colors.black,
    );
  }
}
