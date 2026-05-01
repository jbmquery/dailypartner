//lib/widgets/home/tareas_pendientes.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/daily_status_service.dart';

class TareasPendientesWidget extends StatelessWidget {
  const TareasPendientesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
        final pastDays = dailyDocs.where((doc) => doc.id != todayId).toList();

        if (pastDays.isEmpty) {
          return _emptyCard(context);
        }

        return StreamBuilder<List<DocumentSnapshot>>(
          stream: _streamPendingTasksFromPast(pastDays),
          builder: (context, taskSnapshot) {
            if (!taskSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final pendientes = taskSnapshot.data!;

            if (pendientes.isEmpty) {
              DailyStatusService.setPendientesResueltos();
              return _emptyCard(context);
            }

            return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.08), // 🔥 dinámico
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary, // 🔥 dinámico
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(18),
                      ),
                    ),
                    child: Text(
                      "Tareas que no hiciste",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSecondary, // 🔥 dinámico
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: pendientes.map((doc) {
                        return Column(
                          children: [
                            _taskItemFirestore(context, doc),
                            const SizedBox(height: 10),
                            _notebookLine(context),
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
}

Widget _taskItemFirestore(BuildContext context, DocumentSnapshot doc) {
  final theme = Theme.of(context);
  final data = doc.data() as Map<String, dynamic>;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        data["titulo"] ?? "",
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onBackground, // 🔥 más consistente
        ),
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          _miniButton(
            context,
            Icons.check,
            "YALA",
            Colors.green,
            onTap: () {
              doc.reference.update({"estado": "completado"});
            },
          ),
          const SizedBox(width: 6),
          _miniButton(
            context,
            Icons.close,
            "YA FUE",
            Colors.red,
            onTap: () {
              doc.reference.update({"estado": "cancelado"});
            },
          ),
          const SizedBox(width: 6),
          _miniButton(
            context,
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

Widget _miniButton(
  BuildContext context,
  IconData? icon,
  String label,
  Color color, {
  VoidCallback? onTap,
}) {
  final theme = Theme.of(context);

  return Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
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

Widget _notebookLine(BuildContext context) {
  final theme = Theme.of(context);

  return Container(
    width: double.infinity,
    height: 1,
    color: theme.dividerColor.withOpacity(0.5),
  );
}

Widget _emptyCard(BuildContext context) {
  final theme = Theme.of(context);

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Center(
      child: Text(
        "🎉 No tienes tareas pendientes",
        style: TextStyle(
          color: theme.colorScheme.onBackground, // 🔥 consistente
        ),
      ),
    ),
  );
}

Future<void> moveTaskToToday(DocumentSnapshot oldTask) async {
  final user = FirebaseAuth.instance.currentUser!;
  final now = DateTime.now();

  String fecha = "${now.year}-${now.month}-${now.day}";
  String todayId = "${user.uid}_$fecha";

  final todayRef = FirebaseFirestore.instance.collection('daily').doc(todayId);

  final todayDoc = await todayRef.get();

  if (!todayDoc.exists) {
    await todayRef.set({
      "uid": user.uid,
      "fecha_creacion": FieldValue.serverTimestamp(),
    });
  }

  final data = oldTask.data() as Map<String, dynamic>;

  await todayRef.collection('tareas').add({
    "titulo": data["titulo"],
    "estado": "pendiente",
    "recordatorio": data["recordatorio"] ?? false,
    "hora_recordatorio": data["hora_recordatorio"],
    "completo": false,
    "actualizacion": FieldValue.serverTimestamp(),
  });

  await oldTask.reference.update({
    "estado": "traspaso",
    "actualizacion": FieldValue.serverTimestamp(),
  });
}

Stream<List<DocumentSnapshot>> _streamPendingTasksFromPast(
  List<QueryDocumentSnapshot> dailyDocs,
) async* {
  final user = FirebaseAuth.instance.currentUser!;

  final repetitivasSnapshot = await FirebaseFirestore.instance
      .collection('tareas_repetitivas')
      .where("uid", isEqualTo: user.uid)
      .get();

  final repetitivasKeys = repetitivasSnapshot.docs.map((doc) {
    final data = doc.data();
    final titulo = (data["titulo"] ?? "").toString().trim().toLowerCase();
    final hora = (data["hora_recordatorio"] ?? "")
        .toString()
        .trim()
        .toLowerCase();

    return "$titulo|$hora";
  }).toSet();

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
          if (repetitivasKeys.contains(key)) {
            await tarea.reference.update({
              "estado": "cancelado",
              "actualizacion": FieldValue.serverTimestamp(),
            });
          } else {
            pendientes.add(tarea);
          }
        }
      }
    }

    yield pendientes;
  }
}
