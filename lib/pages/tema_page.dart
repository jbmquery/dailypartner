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
    required BuildContext context,
    required String title,
    required String subtitle,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final selected = modo == value;

    return GestureDetector(
      onTap: () => setModo(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? color : theme.colorScheme.surface, // 🔥 dinámico
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? color
                : theme.colorScheme.outline.withOpacity(0.3), // 🔥 dinámico
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
            Icon(
              icon,
              color: selected ? theme.colorScheme.onPrimary : color,
              size: 30,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: selected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: selected
                          ? theme.colorScheme.onPrimary.withOpacity(0.8)
                          : theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (selected) Icon(Icons.check, color: theme.colorScheme.onPrimary),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      drawer: const AppSidebar(),
      backgroundColor: theme.scaffoldBackgroundColor, // 🔥 dinámico
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
                      context: context,
                      title: "Modo Chill 🌿",
                      subtitle: "Fluye con tu día. Tu paz es lo primero.",
                      value: "chill",
                      color: theme.colorScheme.primary, // 🔥 dinámico
                      icon: Icons.wb_sunny,
                    ),

                    modoCard(
                      context: context,
                      title: "Modo Agresivo 🔥",
                      subtitle:
                          "¿Vas a llorar o vas a cumplir? El reloj no se detiene para los flojos.",
                      value: "agresivo",
                      color: theme.colorScheme.primary, // 🔥 dinámico
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
