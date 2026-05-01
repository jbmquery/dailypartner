//lib/widgets/tareas/tareas_repetitivas.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'tareas_repetitivas_dialog.dart';

class TareasRepetitivasWidget extends StatelessWidget {
  const TareasRepetitivasWidget({super.key});

  @override
  Widget build(BuildContext context) {
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

        // 🔥 SEGUNDO STREAM (skip de hoy)
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

            // 🧠 construir set de tareas "saltadas"
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
                      color: Color.fromRGBO(215, 150, 192, 1),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(18),
                      ),
                    ),
                    child: const Text(
                      "Tus tareas repetitivas",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // 🔥 AQUÍ ESTÁ LA MAGIA
                  tareas.isEmpty
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          child: const Center(
                            child: Text(
                              "No hay tareas repetitivas 👀",
                              style: TextStyle(
                                color: Colors.grey,
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
                                            ? Colors.grey
                                            : const Color.fromRGBO(
                                                215,
                                                150,
                                                192,
                                                1,
                                              ),
                                        shape: BoxShape.circle,
                                      ),
                                    ),

                                    Expanded(
                                      child: Text(
                                        titulo,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isSkipped
                                              ? Colors.grey
                                              : Colors.black,
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
                                            color: Colors.grey,
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
                                        color: Colors.grey,
                                      ),

                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        size: 18,
                                        color: Colors.grey,
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
                                const Divider(height: 1),
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
