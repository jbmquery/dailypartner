//lib/services/navigation_service.dart
import 'package:flutter/material.dart';

class NavigationService {
  // 👉 Navegar con slide
  static Future slideTo(BuildContext context, Widget page) {
    return Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          final tween = Tween(begin: const Offset(1, 0), end: Offset.zero)
              .animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              );

          return SlideTransition(position: tween, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  // 👉 Reemplazar pantalla (ej: login → home)
  static Future replace(BuildContext context, Widget page) {
    return Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  // 👉 Ir y borrar historial (logout)
  static Future removeAll(BuildContext context, Widget page) {
    return Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => page),
      (route) => false,
    );
  }
}
