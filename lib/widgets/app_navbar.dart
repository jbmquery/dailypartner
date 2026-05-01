//lib/widgets/app_navbar.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../pages/login_page.dart';
import '../services/navigation_service.dart';

class AppNavbar extends StatelessWidget {
  const AppNavbar({super.key});

  Future<String> obtenerNombre() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection("usuarios")
        .doc(uid)
        .get();

    return doc.data()?["nombres"] ?? "Usuario";
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();

    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onPrimary = theme.colorScheme.onPrimary;

    return FutureBuilder(
      future: obtenerNombre(),
      builder: (context, snapshot) {
        final nombre = snapshot.data ?? "Usuario";

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: primary,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ☰ menú
              Builder(
                builder: (context) => GestureDetector(
                  onTap: () => Scaffold.of(context).openDrawer(),
                  child: _iconBox(
                    icon: Icons.menu,
                    bgColor: onPrimary.withOpacity(0.15),
                    iconColor: onPrimary,
                  ),
                ),
              ),

              Text(
                "Daily Partner",
                style: TextStyle(
                  color: onPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              PopupMenuButton<String>(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: theme.colorScheme.surface, // 🔥 mejor que cardColor
                onSelected: (value) async {
                  if (value == "logout") {
                    await auth.logout();
                    NavigationService.removeAll(context, const LoginPage());
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    enabled: false,
                    child: Text(
                      "Hola, $nombre",
                      style: TextStyle(
                        color:
                            theme.colorScheme.onSurface, // 🔥 dinámico correcto
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: "logout",
                    child: Text(
                      "Cerrar sesión",
                      style: TextStyle(color: theme.colorScheme.onSurface),
                    ),
                  ),
                ],
                child: _iconBox(
                  icon: Icons.account_circle,
                  bgColor: onPrimary.withOpacity(0.15),
                  iconColor: onPrimary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _iconBox({
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: iconColor),
    );
  }
}
