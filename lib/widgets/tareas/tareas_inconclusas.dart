import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TareasInconclusasWidget extends StatelessWidget {
  const TareasInconclusasWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final now = DateTime.now();

    String todayId = "${user.uid}_${now.year}-${now.month}-${now.day}";

    final dailyRef = FirebaseFirestore.instance
        .collection('daily')
        .doc(todayId);

    return StreamBuilder<DocumentSnapshot>(
      stream: dailyRef.snapshots(),
      builder: (context, dailySnapshot) {
        if (!dailySnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final dailyDoc = dailySnapshot.data!;

        return StreamBuilder<QuerySnapshot>(
          stream: dailyRef.collection('tareas').snapshots(),
          builder: (context, tareasSnapshot) {
            if (!tareasSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final tareas = tareasSnapshot.data!.docs;

            // 🧠 si el doc no existe → lista vacía
            final pendientes = !dailyDoc.exists
                ? []
                : tareas.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data["estado"] == "pendiente";
                  }).toList();

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
                      color: Color.fromRGBO(244, 151, 149, 1),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(18),
                      ),
                    ),
                    child: const Text(
                      "Tareas pendientes",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // 🔥 MISMO PATRÓN QUE YA USAS
                  pendientes.isEmpty
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          child: const Center(
                            child: Text(
                              "Excelente, estamos al día 🎉",
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
                          itemCount: pendientes.length,
                          itemBuilder: (context, i) {
                            final data =
                                pendientes[i].data() as Map<String, dynamic>;

                            final titulo = data["titulo"] ?? "";
                            final hora = data["hora_recordatorio"];

                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      margin: const EdgeInsets.only(right: 10),
                                      decoration: const BoxDecoration(
                                        color: Color.fromRGBO(244, 151, 149, 1),
                                        shape: BoxShape.circle,
                                      ),
                                    ),

                                    Expanded(
                                      child: Text(
                                        titulo,
                                        style: const TextStyle(fontSize: 14),
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
            );
          },
        );
      },
    );
  }
}
