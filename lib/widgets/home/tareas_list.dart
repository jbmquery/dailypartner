//lib/widgets/tareas/tareas_list.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'tareas_list_dialog.dart';

class TareasListWidget extends StatelessWidget {
  const TareasListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // 🔥 NUEVO

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
            color: theme.cardColor, // 🔥 dinámico
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary, // 🔥 dinámico
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Tus tareas de hoy",
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary, // 🔥 dinámico
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // ➕ BOTÓN AGREGAR
                    GestureDetector(
                      onTap: () async {
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

                        await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => TareasListDialog(
                            taskDoc: null,
                            dailyRef: dailyRef,
                          ),
                        );
                      },
                      child: Icon(
                        Icons.add,
                        color: theme.colorScheme.onPrimary, // 🔥 dinámico
                      ),
                    ),
                  ],
                ),
              ),

              docs.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: Text(
                          "No hay tareas hoy 👀",
                          style: TextStyle(
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: docs.length,
                      padding: const EdgeInsets.all(8),
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
                                  activeColor:
                                      theme.colorScheme.primary, // 🔥 dinámico
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
                                        ? theme
                                              .colorScheme
                                              .tertiary // 🔥 dinámico
                                        : theme
                                              .colorScheme
                                              .primary, // 🔥 dinámico
                                    shape: BoxShape.circle,
                                  ),
                                ),

                                Expanded(
                                  child: Text(
                                    titulo,
                                    style: TextStyle(
                                      color: theme
                                          .textTheme
                                          .bodyMedium
                                          ?.color, // 🔥 dinámico
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
                                      style: TextStyle(
                                        color: theme
                                            .colorScheme
                                            .outline, // 🔥 dinámico
                                      ),
                                    ),
                                  )
                                else
                                  Icon(
                                    Icons.access_time,
                                    size: 18,
                                    color: theme
                                        .colorScheme
                                        .outline, // 🔥 dinámico
                                  ),

                                // ✏️ EDITAR
                                IconButton(
                                  icon: Icon(
                                    Icons.edit_outlined,
                                    size: 18,
                                    color: theme
                                        .colorScheme
                                        .primary, // 🔥 dinámico
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

                            Divider(
                              color: theme.dividerColor, // 🔥 dinámico
                            ),
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
