//lib/pages/home_page.dart
import 'package:flutter/material.dart';
import '../widgets/app_navbar.dart';
import '../widgets/app_sidebar.dart';
import '../services/auth_service.dart';

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

            const SizedBox(height: 20),

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
                                color: const Color(0xFFB8E0D2),
                              ),
                              const SizedBox(width: 5),
                              _actionButton(
                                icon: Icons.play_arrow,
                                label: "Iniciamos",
                                color: const Color(0xFFF8A5C2),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // 📋 TAREAS PENDIENTES
                      _pendingTasksCard(),

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

  Widget _card({required String title, required String value}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6EC6CA),
            ),
          ),
        ],
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
}) {
  return Container(
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
  );
}

Widget _pendingTasksCard() {
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🎀 HEADER CON COLOR
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: const BoxDecoration(
            color: Color(0xFFEDB2B1),
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          ),
          child: const Text(
            "Tareas pendientes de ayer",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),

        // 📦 CONTENIDO
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _taskItem("Lavar ropa"),
              const SizedBox(height: 10),
              _taskItem("Ordenar cuarto"),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _taskItem(String title) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFF7F7F7),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),

        const SizedBox(height: 8),

        Row(
          children: [
            _miniButton(Icons.check, "YALA", Colors.green),
            const SizedBox(width: 6),
            _miniButton(Icons.close, "YA FUE", Colors.red),
            const SizedBox(width: 6),
            _miniButton(Icons.refresh, "HOY LO HAGO", Colors.orange),
          ],
        ),
      ],
    ),
  );
}

Widget _miniButton(IconData? icon, String label, Color color, {String? emoji}) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 👇 ICONO o EMOJI
          if (emoji != null)
            Text(emoji, style: const TextStyle(fontSize: 18))
          else if (icon != null)
            Icon(icon, size: 18, color: color),

          const SizedBox(height: 4),

          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    ),
  );
}
