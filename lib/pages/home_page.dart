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
import '../widgets/home/home_racha.dart';

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
    final theme = Theme.of(context);

    return Scaffold(
      drawer: const AppSidebar(),
      backgroundColor: theme.scaffoldBackgroundColor,

      body: StreamBuilder(
        stream: DailyStatusService.stream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary, // 🔥 dinámico
              ),
            );
          }

          final doc = snapshot.data!;
          final data = doc.data() as Map<String, dynamic>?;

          if (data == null) {
            return Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            );
          }

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
                              const HomeRacha(),

                              Row(
                                children: [
                                  _actionButton(
                                    context: context,
                                    icon: Icons.repeat,
                                    label: "Repetitivas",
                                    bgColor:
                                        theme.colorScheme.secondary, // 🔥 azul
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
                                    context: context,
                                    icon: Icons.play_arrow,
                                    label: "Iniciamos",
                                    enabled: botonActivo,
                                    bgColor:
                                        theme.colorScheme.primary, // 🔥 azul
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

Widget _actionButton({
  required BuildContext context,
  required IconData icon,
  required String label,
  required Color bgColor, // 🔥 NUEVO
  VoidCallback? onTap,
  bool enabled = true,
}) {
  final theme = Theme.of(context);

  final backgroundColor = enabled ? bgColor : theme.disabledColor;

  final textColor = theme.colorScheme.onPrimary;

  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    ),
  );
}
