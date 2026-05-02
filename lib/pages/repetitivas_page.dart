//lib/pages/repetitivas_page.dart
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
      _showFab = false;
    });

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => RepetitivasDialog(task: task),
    );

    setState(() {
      _showFab = true;
    });

    loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      drawer: const AppSidebar(),
      backgroundColor: theme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false,

      floatingActionButton: _showFab
          ? Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FloatingActionButton(
                onPressed: () => openDialog(),
                backgroundColor: theme.colorScheme.secondary,
                foregroundColor: theme.colorScheme.onPrimary,
                child: const Icon(Icons.add),
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

                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
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
                              color: theme.colorScheme.secondary,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(18),
                              ),
                            ),
                            child: Text(
                              "Tareas repetitivas",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSecondary,
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
                                      "Presiona + para agregar tarea✨",
                                      style: TextStyle(
                                        color: theme.colorScheme.onBackground
                                            .withOpacity(0.6), // 🔥 dinámico
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                )
                              : ListView.builder(
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
                                              width: 12,
                                              height: 12,
                                              margin: const EdgeInsets.only(
                                                right: 10,
                                              ),
                                              decoration: BoxDecoration(
                                                color:
                                                    theme.colorScheme.secondary,
                                                shape: BoxShape.circle,
                                              ),
                                            ),

                                            // 📄 TEXTO
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

                                            // ⏰ HORA
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
                                                color:
                                                    theme.colorScheme.outline,
                                              ),

                                            // ✏️ EDITAR
                                            IconButton(
                                              icon: Icon(
                                                Icons.edit_outlined,
                                                size: 18,
                                                color:
                                                    theme.colorScheme.onSurface,
                                              ),
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                              visualDensity:
                                                  VisualDensity.compact,
                                              onPressed: () =>
                                                  openDialog(task: t),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 8),
                                        Divider(
                                          height: 1,
                                          color: theme.dividerColor,
                                        ),
                                        const SizedBox(height: 8),
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
      ),
    );
  }
}
