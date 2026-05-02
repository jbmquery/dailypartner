//lib/widgets/tareas/tareas_repetitivas.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'tareas_repetitivas_dialog.dart';

class TareasRepetitivasWidget extends StatelessWidget {
  const TareasRepetitivasWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // 🔥 NUEVO

    final user = FirebaseAuth.instance.currentUser!;
    final today = DateTime.now().toString().substring(0, 10);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tareas_repetitivas')
          .where("uid", isEqualTo: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final tareas = snapshot.data!.docs;

        return FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('tareas_repetitivas_skip')
              .where("uid", isEqualTo: user.uid)
              .where("fecha", isEqualTo: today)
              .get(),
          builder: (context, skipSnapshot) {
            if (!skipSnapshot.hasData) {
              return const SizedBox();
            }

            final skipKeys = skipSnapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final titulo = (data["titulo"] ?? "")
                  .toString()
                  .trim()
                  .toLowerCase();
              final hora = (data["hora"] ?? "").toString().trim().toLowerCase();

              return "$titulo|$hora";
            }).toSet();

            return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface, // 🔥 dinámico
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withOpacity(
                      0.05,
                    ), // 🔥 dinámico
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
                      color: theme.colorScheme.secondary, // 🔥 dinámico
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(18),
                      ),
                    ),
                    child: Text(
                      "Tus tareas repetitivas",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onTertiary, // 🔥 dinámico
                      ),
                    ),
                  ),

                  tareas.isEmpty
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          child: Center(
                            child: Text(
                              "No hay tareas repetitivas 👀",
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
                          itemCount: tareas.length,
                          itemBuilder: (context, i) {
                            final data =
                                tareas[i].data() as Map<String, dynamic>;

                            final titulo = data["titulo"] ?? "";
                            final hora = data["hora_recordatorio"];

                            final key =
                                "${titulo.toString().trim().toLowerCase()}|${(hora ?? "").toString().trim().toLowerCase()}";

                            final isSkipped = skipKeys.contains(key);

                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      margin: const EdgeInsets.only(right: 10),
                                      decoration: BoxDecoration(
                                        color: isSkipped
                                            ? theme
                                                  .colorScheme
                                                  .outline // 🔥 dinámico
                                            : theme
                                                  .colorScheme
                                                  .secondary, // 🔥 dinámico
                                        shape: BoxShape.circle,
                                      ),
                                    ),

                                    Expanded(
                                      child: Text(
                                        titulo,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isSkipped
                                              ? theme
                                                    .colorScheme
                                                    .outline // 🔥 dinámico
                                              : theme
                                                    .colorScheme
                                                    .onSurface, // 🔥 dinámico
                                          decoration: isSkipped
                                              ? TextDecoration.lineThrough
                                              : TextDecoration.none,
                                        ),
                                      ),
                                    ),

                                    if (hora != null &&
                                        hora.toString().isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        child: Text(
                                          hora,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: theme
                                                .colorScheme
                                                .outline, // 🔥 dinámico
                                            decoration: isSkipped
                                                ? TextDecoration.lineThrough
                                                : TextDecoration.none,
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

                                    IconButton(
                                      icon: Icon(
                                        Icons.delete_outline,
                                        size: 18,
                                        color: theme
                                            .colorScheme
                                            .error, // 🔥 dinámico
                                      ),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () async {
                                        final action =
                                            await showEliminarRepetitivaDialog(
                                              context,
                                            );

                                        if (action == "siempre") {
                                          await tareas[i].reference.delete();
                                        }

                                        if (action == "hoy") {
                                          await FirebaseFirestore.instance
                                              .collection(
                                                'tareas_repetitivas_skip',
                                              )
                                              .add({
                                                "uid": user.uid,
                                                "titulo": titulo,
                                                "hora": hora,
                                                "fecha": today,
                                              });
                                        }
                                      },
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 8),
                                Divider(height: 1, color: theme.dividerColor),
                                const SizedBox(height: 8),
                              ],
                            );
                          },
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
