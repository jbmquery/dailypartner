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

    return FutureBuilder(
      future: obtenerNombre(),
      builder: (context, snapshot) {
        final nombre = snapshot.data ?? "Usuario";

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: const BoxDecoration(
            color: Color(0xFF6EC6CA), // celeste
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ☰ botón menú
              Builder(
                builder: (context) => GestureDetector(
                  onTap: () => Scaffold.of(context).openDrawer(),
                  child: _iconBox(Icons.menu),
                ),
              ),

              const Text(
                "Daily Partner",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              PopupMenuButton<String>(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                onSelected: (value) async {
                  if (value == "logout") {
                    await auth.logout();

                    NavigationService.removeAll(context, const LoginPage());
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(enabled: false, child: Text("Hola, $nombre")),
                  const PopupMenuItem(
                    value: "logout",
                    child: Text("Cerrar sesión"),
                  ),
                ],
                child: _iconBox(Icons.account_circle),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _iconBox(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: Colors.white),
    );
  }
}
