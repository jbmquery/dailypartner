import 'package:flutter/material.dart';
import '../widgets/app_navbar.dart';
import '../widgets/app_sidebar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RepetitivasPage extends StatefulWidget {
  const RepetitivasPage({super.key});

  @override
  State<RepetitivasPage> createState() => _RepetitivasPageState();
}

class _RepetitivasPageState extends State<RepetitivasPage> {
  final user = FirebaseAuth.instance.currentUser!;
  final FocusNode _focusNode = FocusNode();

  List<Map<String, dynamic>> tasks = [];

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    for (var t in tasks) {
      t["controller"]?.dispose();
    }
    super.dispose();
  }

  // 🔥 CARGAR DESDE FIRESTORE
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
          "time": data["hora_recordatorio"],
          "editing": false,
          "controller": TextEditingController(text: data["titulo"]),
        };
      }).toList();
    });
  }

  // ➕ AGREGAR NUEVA TAREA
  void addTask() {
    setState(() {
      tasks.add({
        "id": null,
        "time": null,
        "editing": true,
        "controller": TextEditingController(),
      });
    });

    // ⚡ foco suave
    Future.delayed(const Duration(milliseconds: 50), () {
      _focusNode.requestFocus();
    });
  }

  // 💾 GUARDAR
  Future<void> saveTask(int index) async {
    var t = tasks[index];

    final data = {
      "uid": user.uid,
      "titulo": t["controller"].text,
      "estado": "pendiente",
      "recordatorio": t["time"] != null,
      "hora_recordatorio": t["time"],
      "importancia": "normal",
      "actualizacion": FieldValue.serverTimestamp(),
    };

    if (t["id"] == null) {
      final doc = await FirebaseFirestore.instance
          .collection('tareas_repetitivas')
          .add(data);
      t["id"] = doc.id;
    } else {
      await FirebaseFirestore.instance
          .collection('tareas_repetitivas')
          .doc(t["id"])
          .update(data);
    }

    setState(() {
      t["editing"] = false;
    });

    FocusScope.of(context).unfocus();
  }

  // 🗑 ELIMINAR
  Future<void> deleteTask(int index) async {
    var t = tasks[index];

    if (t["id"] != null) {
      await FirebaseFirestore.instance
          .collection('tareas_repetitivas')
          .doc(t["id"])
          .delete();
    }

    t["controller"].dispose();

    setState(() {
      tasks.removeAt(index);
    });
  }

  // ⏰ PICK TIME
  Future<void> pickTime(int index) async {
    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        tasks[index]["time"] = time.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppSidebar(),
      backgroundColor: const Color(0xFFF7F7F7),
      resizeToAvoidBottomInset: true,

      floatingActionButton: FloatingActionButton(
        onPressed: addTask,
        backgroundColor: const Color(0xFF6EC6CA),
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              const AppNavbar(),
              const SizedBox(height: 20),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // HEADER
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 128, 235, 198),
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

                      // LISTA
                      Expanded(
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(18),
                            ),
                          ),
                          child: ListView.separated(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            padding: const EdgeInsets.all(12),
                            itemCount: tasks.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),

                            itemBuilder: (context, i) {
                              var t = tasks[i];

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: t["controller"],
                                            focusNode: t["editing"]
                                                ? _focusNode
                                                : null,
                                            enabled: t["editing"],
                                            enableSuggestions: false,
                                            autocorrect: false,
                                            decoration: const InputDecoration(
                                              hintText: "Escribe tarea",
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        ),

                                        t["time"] == null
                                            ? IconButton(
                                                icon: const Icon(
                                                  Icons.access_time,
                                                  size: 20,
                                                  color: Colors.grey,
                                                ),
                                                onPressed: t["editing"]
                                                    ? () => pickTime(i)
                                                    : null,
                                              )
                                            : GestureDetector(
                                                onTap: t["editing"]
                                                    ? () => pickTime(i)
                                                    : null,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                      ),
                                                  child: Text(
                                                    t["time"],
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ),
                                              ),

                                        if (!t["editing"])
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit_outlined,
                                              size: 20,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                t["editing"] = true;
                                              });

                                              Future.delayed(
                                                const Duration(
                                                  milliseconds: 50,
                                                ),
                                                () {
                                                  _focusNode.requestFocus();
                                                },
                                              );
                                            },
                                          ),
                                      ],
                                    ),

                                    if (t["editing"])
                                      Row(
                                        children: [
                                          _miniButton(
                                            Icons.check,
                                            "LISTO",
                                            Colors.green,
                                            onTap: () => saveTask(i),
                                          ),
                                          const SizedBox(width: 6),
                                          _miniButton(
                                            Icons.delete_outline,
                                            "ELIMINAR",
                                            Colors.red,
                                            onTap: () => deleteTask(i),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
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

// 🔘 BOTÓN MINI
Widget _miniButton(
  IconData? icon,
  String label,
  Color color, {
  String? emoji,
  VoidCallback? onTap,
}) {
  return Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (emoji != null)
              Text(emoji, style: const TextStyle(fontSize: 18))
            else if (icon != null)
              Icon(icon, size: 18, color: color),

            const SizedBox(height: 4),

            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
