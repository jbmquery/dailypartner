//lib/widgets/home/miniquestions.dart
import 'package:flutter/material.dart';
import '../widgets/app_navbar.dart';
import '../widgets/app_sidebar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/repetitivas/repetitivas_dialog.dart';

class RepetitivasPage extends StatefulWidget {
  const RepetitivasPage({super.key});

  @override
  State<RepetitivasPage> createState() => _RepetitivasPageState();
}

class _RepetitivasPageState extends State<RepetitivasPage> {
  final user = FirebaseAuth.instance.currentUser!;
  bool _showFab = true;
  List<Map<String, dynamic>> tasks = [];

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('tareas_repetitivas')
        .where("uid", isEqualTo: user.uid)
        .get();

    setState(() {
      tasks = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          "id": doc.id,
          "titulo": data["titulo"],
          "hora": data["hora_recordatorio"],
        };
      }).toList();
    });
  }

  void openDialog({Map<String, dynamic>? task}) async {
    setState(() {
      _showFab = false; // 👈 ocultar FAB
    });

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RepetitivasDialog(task: task),
    );

    setState(() {
      _showFab = true; // 👈 mostrar FAB otra vez
    });

    loadTasks(); // refrescar
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppSidebar(),
      backgroundColor: const Color(0xFFF7F7F7),

      // FAB FIJO
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

      body: SafeArea(
        child: Column(
          children: [
            const AppNavbar(),
            const SizedBox(height: 20),

            // 🔥 SCROLL GENERAL (clave)
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),

                  child: Container(
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
                            color: Color.fromARGB(255, 244, 151, 149),
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(18),
                            ),
                          ),
                          child: const Text(
                            "Tareas repetitivas",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        // LISTA (se adapta al contenido)
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
                                    Expanded(
                                      child: Text(
                                        t["titulo"] ?? "",
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),

                                    // ⏰ hora
                                    if (t["hora"] != null)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
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

                                    // ✏️ editar
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        size: 20,
                                      ),
                                      onPressed: () => openDialog(task: t),
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
