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
  List<Map<String, dynamic>> tasks = [];

  @override
  void initState() {
    super.initState();
    loadTasks();
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
          "task": data["titulo"],
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
        "task": "",
        "time": null,
        "editing": true,
        "controller": TextEditingController(),
      });
    });
  }

  // 💾 GUARDAR EN FIRESTORE
  Future<void> saveTask(int index) async {
    var t = tasks[index];
    final data = {
      "uid": user.uid,
      "titulo": t["controller"].text,
      "estado": "pendiente",
      "recordatorio": t["time"] != null,
      "hora_recordatorio": t["time"],
      "importancia": "normal", // Por defecto normal
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
      resizeToAvoidBottomInset: false,
      // 1. Botón flotante inferior derecho
      floatingActionButton: FloatingActionButton(
        onPressed: addTask,
        backgroundColor: const Color(0xFF6EC6CA),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const AppNavbar(),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // 4. Encabezado personalizado
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
                  // Contenedor blanco para la lista que conecta con el header
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(18),
                      ),
                    ),
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.6,
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(12),
                      itemCount: tasks.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, i) {
                        var t = tasks[i];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 🔹 FILA PRINCIPAL
                              Row(
                                children: [
                                  // INPUT
                                  Expanded(
                                    child: TextField(
                                      controller: t["controller"],
                                      enabled: t["editing"],
                                      style: const TextStyle(fontSize: 14),
                                      decoration: const InputDecoration(
                                        hintText: "Escribe tarea",
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),

                                  // ⏰ ICONO O HORA (SOLO UNO)
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
                                            padding: const EdgeInsets.symmetric(
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

                                  // ✏️ EDITAR
                                  if (!t["editing"])
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        color: Colors.blueGrey,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          t["editing"] = true;
                                        });
                                      },
                                    ),
                                ],
                              ),

                              // 🔻 SEGUNDA FILA (SOLO EN EDICIÓN)
                              if (t["editing"])
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.check,
                                        color: Colors.green,
                                        size: 20,
                                      ),
                                      onPressed: () => saveTask(i),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.redAccent,
                                        size: 20,
                                      ),
                                      onPressed: () => deleteTask(i),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
