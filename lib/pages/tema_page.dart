import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/app_navbar.dart';
import '../widgets/app_sidebar.dart';

class TemaPage extends StatefulWidget {
  const TemaPage({super.key});

  @override
  State<TemaPage> createState() => _TemaPageState();
}

class _TemaPageState extends State<TemaPage> {
  final user = FirebaseAuth.instance.currentUser!;
  String modo = "chill"; // default

  @override
  void initState() {
    super.initState();
    loadModo();
  }

  Future<void> loadModo() async {
    final doc = await FirebaseFirestore.instance
        .collection("usuarios")
        .doc(user.uid)
        .get();

    if (doc.exists) {
      setState(() {
        modo = doc.data()?["modo"] ?? "chill";
      });
    }
  }

  Future<void> setModo(String nuevoModo) async {
    await FirebaseFirestore.instance.collection("usuarios").doc(user.uid).set({
      "modo": nuevoModo,
    }, SetOptions(merge: true));

    setState(() {
      modo = nuevoModo;
    });
  }

  Widget modoCard({
    required String title,
    required String subtitle,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    final selected = modo == value;

    return GestureDetector(
      onTap: () => setModo(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? color : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? color : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? Colors.white : color, size: 30),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: selected
                          ? Colors.white.withOpacity(0.8)
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            if (selected) const Icon(Icons.check, color: Colors.white),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppSidebar(),
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Column(
          children: [
            const AppNavbar(),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    modoCard(
                      title: "Modo Chill 🌿",
                      subtitle: "Relajado, claro, suave",
                      value: "chill",
                      color: const Color(0xFF6EC6CA),
                      icon: Icons.wb_sunny,
                    ),

                    modoCard(
                      title: "Modo Agresivo 🔥",
                      subtitle: "Oscuro, intenso, enfocado",
                      value: "agresivo",
                      color: Colors.deepPurple,
                      icon: Icons.nightlight_round,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
