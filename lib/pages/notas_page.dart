import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../widgets/app_navbar.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/notas/notas_dialog.dart';

class NotasPage extends StatefulWidget {
  const NotasPage({super.key});

  @override
  State<NotasPage> createState() => _NotasPageState();
}

class _NotasPageState extends State<NotasPage> {
  final user = FirebaseAuth.instance.currentUser!;

  bool _showFab = true;

  void openDialog({DocumentSnapshot? noteDoc}) async {
    setState(() {
      _showFab = false;
    });

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => NotasDialog(noteDoc: noteDoc),
    );

    if (!mounted) return;

    setState(() {
      _showFab = true;
    });
  }

  String formatDate(Timestamp? timestamp) {
    if (timestamp == null) return "";

    final date = timestamp.toDate();

    return DateFormat("d 'de' MMM • h:mm a", 'es').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      drawer: const AppSidebar(),
      backgroundColor: theme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false,

      floatingActionButton: _showFab
          ? Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FloatingActionButton(
                onPressed: () => openDialog(),
                backgroundColor: theme.colorScheme.secondary,
                foregroundColor: theme.colorScheme.onSecondary,
                child: const Icon(Icons.add),
              ),
            )
          : null,

      body: SafeArea(
        child: Column(
          children: [
            const AppNavbar(),

            const SizedBox(height: 18),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('notas')
                    .where("uid", isEqualTo: user.uid)
                    .orderBy("fecha_creacion", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  // 🔥 loading inicial
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // 🔥 error
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Error cargando notas",
                        style: TextStyle(color: theme.colorScheme.outline),
                      ),
                    );
                  }

                  // 🔥 docs seguros
                  final docs = snapshot.data?.docs ?? [];

                  // 🔥 vacío real
                  if (docs.isEmpty) {
                    return Center(
                      child: Text(
                        "Todavía no tienes notas ✨",
                        style: TextStyle(
                          color: theme.colorScheme.outline,
                          fontSize: 14,
                        ),
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                    itemCount: docs.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.88,
                        ),
                    itemBuilder: (context, index) {
                      final doc = docs[index];

                      final data = doc.data() as Map<String, dynamic>? ?? {};

                      final titulo = data["titulo"] ?? "Sin título";
                      final cuerpo = data["cuerpo"] ?? "";
                      final fecha = data["fecha_creacion"] as Timestamp?;

                      return GestureDetector(
                        onTap: () => openDialog(noteDoc: doc),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: theme.shadowColor.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                titulo.toString().trim().isEmpty
                                    ? "Sin título"
                                    : titulo,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),

                              const SizedBox(height: 10),

                              Expanded(
                                child: Text(
                                  cuerpo.toString().trim().isEmpty
                                      ? "Sin contenido"
                                      : cuerpo,
                                  maxLines: 7,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    height: 1.4,
                                    fontSize: 14,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.7),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 14),

                              Text(
                                formatDate(fecha),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
