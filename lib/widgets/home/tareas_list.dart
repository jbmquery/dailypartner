//lib/widgets/tareas/tareas_list.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'tareas_list_dialog.dart';

class TareasListWidget extends StatelessWidget {
  const TareasListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final now = DateTime.now();

    String todayId = "${user.uid}_${now.year}-${now.month}-${now.day}";

    final tareasRef = FirebaseFirestore.instance
        .collection('daily')
        .doc(todayId)
        .collection('tareas');

    return StreamBuilder<QuerySnapshot>(
      stream: tareasRef.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        // 🔥 ORDEN: alta primero
        docs.sort((a, b) {
          final aImp = (a["importancia"] ?? "normal") == "alta" ? 0 : 1;
          final bImp = (b["importancia"] ?? "normal") == "alta" ? 0 : 1;
          return aImp.compareTo(bImp);
        });

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFF6EC6CA),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                ),
                child: const Text(
                  "Tus tareas de hoy",
                  style: TextStyle(color: Colors.white),
                ),
              ),

              docs.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: Text("No hay tareas hoy 👀")),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: docs.length,
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, i) {
                        final doc = docs[i];
                        final data = doc.data() as Map<String, dynamic>;

                        final titulo = data["titulo"] ?? "";
                        final hora = data["hora_recordatorio"];
                        final estado = data["estado"] ?? "pendiente";

                        final isDone = estado == "completado";

                        return Column(
                          children: [
                            Row(
                              children: [
                                // ✅ CHECK
                                Checkbox(
                                  value: isDone,
                                  onChanged: (val) {
                                    doc.reference.update({
                                      "estado": val!
                                          ? "completado"
                                          : "pendiente",
                                    });
                                  },
                                ),

                                // 🔴 PUNTO
                                Container(
                                  width: 10,
                                  height: 10,
                                  margin: const EdgeInsets.only(right: 10),
                                  decoration: BoxDecoration(
                                    color: data["importancia"] == "alta"
                                        ? Colors.orange
                                        : const Color(0xFF6EC6CA),
                                    shape: BoxShape.circle,
                                  ),
                                ),

                                Expanded(
                                  child: Text(
                                    titulo,
                                    style: TextStyle(
                                      decoration: isDone
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                ),

                                if (hora != null)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Text(
                                      hora,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )
                                else
                                  const Icon(Icons.access_time, size: 18),

                                // ✏️ EDITAR
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (_) =>
                                          TareasListDialog(taskDoc: doc),
                                    );
                                  },
                                ),
                              ],
                            ),

                            const Divider(),
                          ],
                        );
                      },
                    ),
            ],
          ),
        );
      },
    );
  }
}
