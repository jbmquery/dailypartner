//lib/pages/tareas_page.dart
import 'package:flutter/material.dart';
import '../widgets/app_navbar.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/tareas/tareas_dialog.dart';

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
    return Scaffold(
      drawer: const AppSidebar(),
      backgroundColor: const Color(0xFFF7F7F7),
      resizeToAvoidBottomInset: false,

      floatingActionButton: _showFab
          ? Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FloatingActionButton(
                onPressed: () => openDialog(),
                backgroundColor: const Color(0xFF6EC6CA),
                child: const Icon(Icons.add, color: Colors.white),
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
                        GestureDetector(
                          onTap: () {
                            // luego lo usamos
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            margin: const EdgeInsets.only(bottom: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6EC6CA),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Center(
                              child: Text(
                                "Siguiente",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // 📦 CARD
                        Container(
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
                              // HEADER
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF6EC6CA),
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(18),
                                  ),
                                ),
                                child: const Text(
                                  "Las tareas del día son:",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),

                              // LISTA
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: const EdgeInsets.all(16),
                                itemCount: tasks.length,
                                itemBuilder: (context, i) {
                                  final t = tasks[i];

                                  return Column(
                                    children: [
                                      Row(
                                        children: [
                                          // 🔴 PUNTO
                                          Container(
                                            width: 10,
                                            height: 10,
                                            margin: const EdgeInsets.only(
                                              right: 10,
                                            ),
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF6EC6CA),
                                              shape: BoxShape.circle,
                                            ),
                                          ),

                                          Expanded(
                                            child: Text(
                                              t["titulo"] ?? "",
                                              style: const TextStyle(
                                                fontSize: 14,
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
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            )
                                          else
                                            const Icon(
                                              Icons.access_time,
                                              size: 18,
                                              color: Colors.grey,
                                            ),

                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit_outlined,
                                              size: 20,
                                            ),
                                            onPressed: () =>
                                                openDialog(task: t, index: i),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 10),
                                      const Divider(),
                                      const SizedBox(height: 10),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
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
