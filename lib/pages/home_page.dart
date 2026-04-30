//lib/pages/home_page.dart
import 'package:flutter/material.dart';
import '../widgets/app_navbar.dart';
import '../widgets/app_sidebar.dart';
import '../services/auth_service.dart';
import '../widgets/home/miniquestions.dart';
import 'tareas_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'repetitivas_page.dart';
import '../widgets/home/tareas_list.dart';

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
                                color: const Color.fromARGB(255, 128, 235, 198),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RepetitivasPage(),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 5),
                              _actionButton(
                                icon: Icons.play_arrow,
                                label: "Iniciamos",
                                color: const Color(0xFFF8A5C2),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const TareasPage(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      const MiniQuestions(),

                      const SizedBox(height: 20),

                      // 📋 TAREAS PENDIENTES
                      _pendingTasksCard(),
                      const SizedBox(height: 20),

                      const TareasListWidget(),

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

Widget _pendingTasksCard() {
  final user = FirebaseAuth.instance.currentUser!;
  final now = DateTime.now();
  String todayId = "${user.uid}_${now.year}-${now.month}-${now.day}";

  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('daily')
        .where("uid", isEqualTo: user.uid)
        .snapshots(),
    builder: (context, dailySnapshot) {
      if (!dailySnapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }

      final dailyDocs = dailySnapshot.data!.docs;

      // 🔥 excluir HOY
      final pastDays = dailyDocs.where((doc) => doc.id != todayId).toList();

      if (pastDays.isEmpty) {
        return _emptyCard();
      }

      // 🔥 aquí viene la magia: múltiples streams
      return StreamBuilder<List<DocumentSnapshot>>(
        stream: _streamPendingTasksFromPast(pastDays),
        builder: (context, taskSnapshot) {
          if (!taskSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final pendientes = taskSnapshot.data!;

          if (pendientes.isEmpty) {
            return _emptyCard();
          }

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
                    "Tareas que no hiciste",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: pendientes.map((doc) {
                      return Column(
                        children: [
                          _taskItemFirestore(doc),
                          const SizedBox(height: 10),
                          _notebookLine(),
                          const SizedBox(height: 10),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Widget _taskItemFirestore(DocumentSnapshot doc) {
  final data = doc.data() as Map<String, dynamic>;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        data["titulo"] ?? "",
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),

      const SizedBox(height: 8),

      Row(
        children: [
          _miniButton(
            Icons.check,
            "YALA",
            Colors.green,
            onTap: () {
              doc.reference.update({"estado": "completado"});
            },
          ),

          const SizedBox(width: 6),

          _miniButton(
            Icons.close,
            "YA FUE",
            Colors.red,
            onTap: () {
              doc.reference.update({"estado": "cancelado"});
            },
          ),

          const SizedBox(width: 6),

          _miniButton(
            Icons.refresh,
            "HOY LO HAGO",
            Colors.orange,
            onTap: () async {
              await moveTaskToToday(doc);
            },
          ),
        ],
      ),
    ],
  );
}

Widget _notebookLine() {
  return Container(
    width: double.infinity,
    height: 1,
    color: Colors.grey.withOpacity(0.5),
  );
}

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
    ),
  );
}

Future<DocumentReference> getDailyRef() async {
  final user = FirebaseAuth.instance.currentUser!;
  final now = DateTime.now();

  String fecha = "${now.year}-${now.month}-${now.day}";
  String docId = "${user.uid}_$fecha";

  return FirebaseFirestore.instance.collection('daily').doc(docId);
}

Future<void> moveTaskToToday(DocumentSnapshot oldTask) async {
  final user = FirebaseAuth.instance.currentUser!;
  final now = DateTime.now();

  String fecha = "${now.year}-${now.month}-${now.day}";
  String todayId = "${user.uid}_$fecha";

  final todayRef = FirebaseFirestore.instance.collection('daily').doc(todayId);

  final todayDoc = await todayRef.get();

  // 🔥 si no existe el daily de hoy, lo crea
  if (!todayDoc.exists) {
    await todayRef.set({
      "uid": user.uid,
      "fecha_creacion": FieldValue.serverTimestamp(),
    });
  }

  final data = oldTask.data() as Map<String, dynamic>;

  // 🚀 copiar tarea al día de hoy
  await todayRef.collection('tareas').add({
    "titulo": data["titulo"],
    "estado": "pendiente",
    "recordatorio": data["recordatorio"] ?? false,
    "hora_recordatorio": data["hora_recordatorio"],
    "completo": false,
    "actualizacion": FieldValue.serverTimestamp(),
  });

  // 🏷 marcar tarea antigua como traspasada
  await oldTask.reference.update({
    "estado": "traspaso",
    "actualizacion": FieldValue.serverTimestamp(),
  });
}

Widget _emptyCard() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
    ),
    child: const Center(child: Text("🎉 No tienes tareas pendientes")),
  );
}

Stream<List<DocumentSnapshot>> _streamPendingTasksFromPast(
  List<QueryDocumentSnapshot> dailyDocs,
) async* {
  final user = FirebaseAuth.instance.currentUser!;

  // 🧠 1. TRAER REPETITIVAS (SOLO UNA VEZ)
  final repetitivasSnapshot = await FirebaseFirestore.instance
      .collection('tareas_repetitivas')
      .where("uid", isEqualTo: user.uid)
      .get();

  // 🚀 PRO: titulo + hora
  final repetitivasKeys = repetitivasSnapshot.docs.map((doc) {
    final data = doc.data();
    final titulo = (data["titulo"] ?? "").toString().trim().toLowerCase();
    final hora = (data["hora_recordatorio"] ?? "")
        .toString()
        .trim()
        .toLowerCase();

    return "$titulo|$hora";
  }).toSet();

  // 🔁 LOOP STREAM
  await for (var _ in Stream.periodic(const Duration(milliseconds: 500))) {
    List<DocumentSnapshot> pendientes = [];

    for (var daily in dailyDocs) {
      final snapshot = await daily.reference.collection('tareas').get();

      for (var tarea in snapshot.docs) {
        final data = tarea.data() as Map<String, dynamic>;

        final titulo = (data["titulo"] ?? "").toString().trim().toLowerCase();
        final hora = (data["hora_recordatorio"] ?? "")
            .toString()
            .trim()
            .toLowerCase();

        final key = "$titulo|$hora";

        if (data["estado"] == "pendiente") {
          // 🧠 2. SI EXISTE EN REPETITIVAS → CANCELAR
          if (repetitivasKeys.contains(key)) {
            await tarea.reference.update({
              "estado": "cancelado",
              "actualizacion": FieldValue.serverTimestamp(),
            });
          } else {
            // ✅ SOLO LOS LIMPIOS
            pendientes.add(tarea);
          }
        }
      }
    }

    yield pendientes;
  }
}
