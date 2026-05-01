//lib/pages/home_page.dart
import 'package:flutter/material.dart';
import '../widgets/app_navbar.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/home/miniquestions.dart';
import 'tareas_page.dart';
import 'repetitivas_page.dart';
import '../widgets/home/tareas_list.dart';
import '../widgets/home/tareas_pendientes.dart';
import '../services/daily_status_service.dart';
import '../services/streak_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    DailyStatusService.initDay();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppSidebar(),
      backgroundColor: const Color(0xFFF7F7F7),

      body: StreamBuilder(
        stream: DailyStatusService.stream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final pendientesResueltos = data["pendientesResueltos"] ?? false;
          final resumenCompletado = data["resumenCompletado"] ?? false;

          final mostrarPendientes = !pendientesResueltos;
          final mostrarLista = resumenCompletado;
          final botonActivo = pendientesResueltos && !resumenCompletado;

          return SafeArea(
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
                                    color: const Color.fromRGBO(
                                      215,
                                      150,
                                      192,
                                      1,
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const RepetitivasPage(),
                                        ),
                                      );
                                    },
                                  ),

                                  const SizedBox(width: 5),

                                  _actionButton(
                                    icon: Icons.play_arrow,
                                    label: "Iniciamos",
                                    color: botonActivo
                                        ? const Color.fromRGBO(245, 134, 169, 1)
                                        : Colors.grey,
                                    onTap: botonActivo
                                        ? () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    const TareasPage(),
                                              ),
                                            );
                                          }
                                        : null,
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),
                          const MiniQuestions(),
                          const SizedBox(height: 20),

                          // 👇 SOLO UNO SE MUESTRA SEGÚN ESTADO
                          if (mostrarPendientes) ...[
                            const TareasPendientesWidget(),
                            const SizedBox(height: 20),
                          ],

                          if (mostrarLista) ...[
                            const TareasListWidget(),
                            const SizedBox(height: 20),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

Widget _streakWidget() {
  return StreamBuilder<DocumentSnapshot>(
    stream: StreakService.stream(),
    builder: (context, snapshot) {
      if (!snapshot.hasData || !snapshot.data!.exists) {
        return _streakUI(0);
      }

      final data = snapshot.data!.data() as Map<String, dynamic>;
      final streak = data["currentStreak"] ?? 0;

      return _streakUI(streak);
    },
  );
}

Widget _streakUI(int streak) {
  Color color;

  if (streak <= 10) {
    color = Colors.orange;
  } else if (streak <= 30) {
    color = Colors.blue;
  } else if (streak <= 100) {
    color = Colors.green;
  } else if (streak <= 365) {
    color = Colors.purple;
  } else {
    color = Colors.amber;
  }

  // 🔥 tamaño dinámico según racha
  double size = 18;
  if (streak > 10) size = 22;
  if (streak > 30) size = 26;
  if (streak > 100) size = 30;
  if (streak > 365) size = 34;

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      children: [
        FireIcon(size: size, color: color), // 👈 NUEVO
        const SizedBox(width: 6),
        Text(
          "$streak días",
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
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

class FireIcon extends StatefulWidget {
  final double size;
  final Color color;

  const FireIcon({super.key, required this.size, required this.color});

  @override
  State<FireIcon> createState() => _FireIconState();
}

class _FireIconState extends State<FireIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> scale;
  late Animation<double> rotation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    scale = Tween<double>(
      begin: 1.0,
      end: 1.25,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    rotation = Tween<double>(
      begin: -0.08,
      end: 0.08,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: rotation.value,
          child: Transform.scale(
            scale: scale.value,
            child: Icon(
              Icons.local_fire_department,
              color: widget.color,
              size: widget.size,
            ),
          ),
        );
      },
    );
  }
}
