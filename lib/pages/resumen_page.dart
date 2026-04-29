import 'package:flutter/material.dart';
import '../widgets/app_navbar.dart';
import '../widgets/app_sidebar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResumenPage extends StatefulWidget {
  final List<Map<String, dynamic>> tareasTemporales;

  const ResumenPage({super.key, required this.tareasTemporales});

  @override
  State<ResumenPage> createState() => _ResumenPageState();
}

class _ResumenPageState extends State<ResumenPage> {
  final user = FirebaseAuth.instance.currentUser!;

  List<Map<String, dynamic>> allTasks = [];

  @override
  void initState() {
    super.initState();
    loadAllTasks();
  }

  Future<void> loadAllTasks() async {
    final now = DateTime.now();
    String todayId = "${user.uid}_${now.year}-${now.month}-${now.day}";

    List<Map<String, dynamic>> temp = widget.tareasTemporales.map((t) {
      return {...t, "source": "temp", "checked": false};
    }).toList();

    // 🧠 SKIP DE HOY
    final today = DateTime.now().toString().substring(0, 10);

    final skipSnapshot = await FirebaseFirestore.instance
        .collection('tareas_repetitivas_skip')
        .where("uid", isEqualTo: user.uid)
        .where("fecha", isEqualTo: today)
        .get();

    final skipKeys = skipSnapshot.docs.map((doc) {
      final data = doc.data();
      final titulo = (data["titulo"] ?? "").toString().trim().toLowerCase();
      final hora = (data["hora"] ?? "").toString().trim().toLowerCase();

      return "$titulo|$hora";
    }).toSet();

    // 🔁 REPETITIVAS
    final repetitivasSnapshot = await FirebaseFirestore.instance
        .collection('tareas_repetitivas')
        .where("uid", isEqualTo: user.uid)
        .get();

    List<Map<String, dynamic>> repetitivas = repetitivasSnapshot.docs
        .map((doc) {
          final data = doc.data();

          final titulo = data["titulo"];
          final hora = data["hora_recordatorio"];

          final key =
              "${titulo.toString().trim().toLowerCase()}|${(hora ?? "").toString().trim().toLowerCase()}";

          // 🚫 si está en skip → no entra
          if (skipKeys.contains(key)) {
            return null;
          }

          return {
            "titulo": titulo,
            "hora": hora,
            "source": "repetitiva",
            "checked": false,
          };
        })
        .whereType<Map<String, dynamic>>()
        .toList();

    // 📅 DAILY (HOY)
    final dailyRef = FirebaseFirestore.instance
        .collection('daily')
        .doc(todayId);

    final dailyDoc = await dailyRef.get();

    List<Map<String, dynamic>> dailyTasks = [];

    if (dailyDoc.exists) {
      final tareasSnapshot = await dailyRef.collection('tareas').get();

      dailyTasks = tareasSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          "id": doc.id,
          "titulo": data["titulo"],
          "hora": data["hora_recordatorio"],
          "source": "daily",
          "checked": data["importancia"] == "alta",
        };
      }).toList();
    }

    setState(() {
      allTasks = [...dailyTasks, ...repetitivas, ...temp];
    });
  }

  Color getColor(String source) {
    switch (source) {
      case "daily":
        return Colors.orange;
      case "repetitiva":
        return Colors.pink;
      case "temp":
        return const Color(0xFF6EC6CA);
      default:
        return Colors.grey;
    }
  }

  Future<void> saveAll() async {
    final now = DateTime.now();
    String todayId = "${user.uid}_${now.year}-${now.month}-${now.day}";

    final dailyRef = FirebaseFirestore.instance
        .collection('daily')
        .doc(todayId);

    final dailyDoc = await dailyRef.get();

    if (!dailyDoc.exists) {
      await dailyRef.set({
        "uid": user.uid,
        "fecha_creacion": FieldValue.serverTimestamp(),
      });
    }

    for (var task in allTasks) {
      final importancia = task["checked"] ? "alta" : "normal";

      if (task["source"] == "daily") {
        // 🔄 actualizar
        await dailyRef.collection('tareas').doc(task["id"]).update({
          "importancia": importancia,
          "actualizacion": FieldValue.serverTimestamp(),
        });
      } else {
        // ➕ crear nueva
        await dailyRef.collection('tareas').add({
          "titulo": task["titulo"],
          "estado": "pendiente",
          "hora_recordatorio": task["hora"],
          "importancia": importancia,
          "actualizacion": FieldValue.serverTimestamp(),
        });
      }
    }

    Navigator.pop(context);
  }

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
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),

                  child: Column(
                    children: [
                      // 🔘 BOTONES
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                margin: const EdgeInsets.only(
                                  bottom: 14,
                                  right: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Center(
                                  child: Text(
                                    "Atrás",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          Expanded(
                            child: GestureDetector(
                              onTap: saveAll,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                margin: const EdgeInsets.only(
                                  bottom: 14,
                                  left: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6EC6CA),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Center(
                                  child: Text(
                                    "Guardar",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
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
                                "Resumen del día",
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
                              itemCount: allTasks.length,
                              itemBuilder: (context, i) {
                                final t = allTasks[i];

                                return Column(
                                  children: [
                                    Row(
                                      children: [
                                        // ✅ CHECKBOX
                                        Checkbox(
                                          value: t["checked"],
                                          onChanged: (val) {
                                            setState(() {
                                              t["checked"] = val;
                                            });
                                          },
                                        ),

                                        // 🔴 PUNTO SEGÚN ORIGEN
                                        Container(
                                          width: 10,
                                          height: 10,
                                          margin: const EdgeInsets.only(
                                            right: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: getColor(t["source"]),
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
    );
  }
}
