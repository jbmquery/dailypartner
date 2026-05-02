//lib/pages/tareas_page.dart
import 'package:flutter/material.dart';
import '../widgets/app_navbar.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/tareas/tareas_dialog.dart';
import 'resumen_page.dart';
import '../widgets/tareas/tareas_repetitivas.dart';
import '../widgets/tareas/tareas_inconclusas.dart';
import '../widgets/home/home_calendar.dart';

class TareasPage extends StatefulWidget {
  const TareasPage({super.key});

  @override
  State<TareasPage> createState() => _TareasPageState();
}

class _TareasPageState extends State<TareasPage> {
  bool _showFab = true;

  List<Map<String, dynamic>> tasks = [];

  void openDialog({Map<String, dynamic>? task, int? index}) async {
    setState(() {
      _showFab = false;
    });

    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => TareasDialog(task: task),
    );

    setState(() {
      _showFab = true;
    });

    if (result != null) {
      setState(() {
        if (result["delete"] == true && index != null) {
          tasks.removeAt(index);
        } else if (index != null) {
          tasks[index] = result;
        } else {
          tasks.add(result);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // 🔥 clave

    return Scaffold(
      drawer: const AppSidebar(),
      backgroundColor: theme.scaffoldBackgroundColor, // 🔥 dinámico
      resizeToAvoidBottomInset: false,

      floatingActionButton: _showFab
          ? Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FloatingActionButton(
                onPressed: () => openDialog(),
                backgroundColor: theme.colorScheme.primary, // 🔥 dinámico
                child: Icon(Icons.add, color: theme.colorScheme.onPrimary),
              ),
            )
          : null,

      body: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SafeArea(
          child: Column(
            children: [
              const AppNavbar(),
              const SizedBox(height: 20),

              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        // 🔘 BOTÓN SIGUIENTE
                        HomeCalendarBar(
                          onNext: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ResumenPage(tareasTemporales: tasks),
                              ),
                            );
                          },
                        ),

                        // 📦 CARD
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface, // 🔥 dinámico
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: theme.shadowColor.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // HEADER
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      theme.colorScheme.tertiary, // 🔥 dinámico
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(18),
                                  ),
                                ),
                                child: Text(
                                  "Las tareas del día son:",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onTertiary,
                                  ),
                                ),
                              ),

                              // LISTA
                              tasks.isEmpty
                                  ? Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(20),
                                      child: Center(
                                        child: Text(
                                          "Presiona + para agregar una tarea ✨",
                                          style: TextStyle(
                                            color: theme
                                                .colorScheme
                                                .onBackground
                                                .withOpacity(
                                                  0.6,
                                                ), // 🔥 dinámico
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    )
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      padding: const EdgeInsets.all(16),
                                      itemCount: tasks.length,
                                      itemBuilder: (context, i) {
                                        final t = tasks[i];

                                        return Column(
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  width: 10,
                                                  height: 10,
                                                  margin: const EdgeInsets.only(
                                                    right: 10,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: theme
                                                        .colorScheme
                                                        .tertiary, // 🔥 dinámico
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    t["titulo"] ?? "",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: theme
                                                          .colorScheme
                                                          .onSurface,
                                                    ),
                                                  ),
                                                ),
                                                if (t["hora"] != null)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                        ),
                                                    child: Text(
                                                      t["hora"],
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: theme
                                                            .colorScheme
                                                            .outline,
                                                      ),
                                                    ),
                                                  )
                                                else
                                                  Icon(
                                                    Icons.access_time,
                                                    size: 18,
                                                    color: theme
                                                        .colorScheme
                                                        .outline,
                                                  ),
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.edit_outlined,
                                                    size: 18,
                                                    color: theme
                                                        .colorScheme
                                                        .onSurface,
                                                  ),
                                                  padding: EdgeInsets.zero,
                                                  constraints:
                                                      const BoxConstraints(),
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                  onPressed: () => openDialog(
                                                    task: t,
                                                    index: i,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Divider(
                                              height: 1,
                                              color: theme.colorScheme.outline
                                                  .withOpacity(0.3),
                                            ),
                                            const SizedBox(height: 8),
                                          ],
                                        );
                                      },
                                    ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 💖 TAREAS REPETITIVAS
                        const TareasRepetitivasWidget(),

                        const SizedBox(height: 20),

                        // 💔 TAREAS INCONCLUSAS
                        const TareasInconclusasWidget(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
