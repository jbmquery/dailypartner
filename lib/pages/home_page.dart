//lib/pages/home_page.dart
import 'package:flutter/material.dart';
import '../widgets/app_navbar.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/home/miniquestions.dart';
import 'tareas_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'repetitivas_page.dart';
import '../widgets/home/tareas_list.dart';
import '../widgets/home/tareas_pendientes.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔥 FILA SUPERIOR
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _streakWidget(),

                          Row(
                            children: [
                              _actionButton(
                                icon: Icons.repeat,
                                label: "Repetitivas",
                                color: const Color.fromARGB(255, 128, 235, 198),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RepetitivasPage(),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 5),
                              _actionButton(
                                icon: Icons.play_arrow,
                                label: "Iniciamos",
                                color: const Color(0xFFF8A5C2),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const TareasPage(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      const MiniQuestions(),

                      const SizedBox(height: 20),

                      // 📋 TAREAS PENDIENTES
                      const TareasPendientesWidget(),

                      const SizedBox(height: 20),

                      const TareasListWidget(),

                      const SizedBox(height: 20),

                      // 👇 puedes dejar tus cards si quieres
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _streakWidget() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.orange.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
    ),
    child: const Row(
      children: [
        Icon(Icons.local_fire_department, color: Colors.orange),
        SizedBox(width: 6),
        Text(
          "5 días", // 👈 luego lo haces dinámico
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
        ),
      ],
    ),
  );
}

Widget _actionButton({
  required IconData icon,
  required String label,
  required Color color,
  VoidCallback? onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}

Future<DocumentReference> getDailyRef() async {
  final user = FirebaseAuth.instance.currentUser!;
  final now = DateTime.now();

  String fecha = "${now.year}-${now.month}-${now.day}";
  String docId = "${user.uid}_$fecha";

  return FirebaseFirestore.instance.collection('daily').doc(docId);
}
