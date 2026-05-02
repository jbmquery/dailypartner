//lib/pages/resumen_page.dart
import 'package:flutter/material.dart';
import '../widgets/app_navbar.dart';
import '../widgets/app_sidebar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/daily_status_service.dart';
import 'home_page.dart';

class ResumenPage extends StatefulWidget {
  final List<Map<String, dynamic>> tareasTemporales;

  const ResumenPage({super.key, required this.tareasTemporales});

  @override
  State<ResumenPage> createState() => _ResumenPageState();
}

class _ResumenPageState extends State<ResumenPage> {
  final user = FirebaseAuth.instance.currentUser!;
  bool isSaving = false;
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

          if (skipKeys.contains(key)) return null;

          return {
            "titulo": titulo,
            "hora": hora,
            "source": "repetitiva",
            "checked": false,
          };
        })
        .whereType<Map<String, dynamic>>()
        .toList();

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
    final theme = Theme.of(context);

    switch (source) {
      case "daily":
        return theme.colorScheme.secondary;
      case "repetitiva":
        return theme.colorScheme.tertiary;
      case "temp":
        return theme.colorScheme.primary;
      default:
        return theme.colorScheme.outline;
    }
  }

  Future<void> saveAll() async {
    if (isSaving) return;

    setState(() {
      isSaving = true;
    });

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
        await dailyRef.collection('tareas').doc(task["id"]).update({
          "importancia": importancia,
          "actualizacion": FieldValue.serverTimestamp(),
        });
      } else {
        await dailyRef.collection('tareas').add({
          "titulo": task["titulo"],
          "estado": "pendiente",
          "hora_recordatorio": task["hora"],
          "importancia": importancia,
          "actualizacion": FieldValue.serverTimestamp(),
        });
      }
    }

    await DailyStatusService.setResumenCompletado();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      drawer: const AppSidebar(),
      backgroundColor: theme.scaffoldBackgroundColor,

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
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.onPrimary
                                      .withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  "Atrás",
                                  style: TextStyle(
                                    color: theme.colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),

                            GestureDetector(
                              onTap: isSaving ? null : saveAll,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.onPrimary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: isSaving
                                    ? SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: theme.colorScheme.primary,
                                        ),
                                      )
                                    : Text(
                                        "Guardar",
                                        style: TextStyle(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 📦 CARD
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: theme.shadowColor.withOpacity(0.03),
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
                                color: theme.colorScheme.secondary,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(18),
                                ),
                              ),
                              child: Text(
                                "Las prioridades del día son:",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSecondary,
                                ),
                              ),
                            ),

                            allTasks.isEmpty
                                ? Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(20),
                                    child: Center(
                                      child: Text(
                                        "No hay tareas para hoy 💤\nAgrega algunas antes de continuar",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: theme.colorScheme.outline,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    padding: const EdgeInsets.all(16),
                                    itemCount: allTasks.length,
                                    itemBuilder: (context, i) {
                                      final t = allTasks[i];

                                      return Column(
                                        children: [
                                          Row(
                                            children: [
                                              Checkbox(
                                                value: t["checked"],
                                                activeColor:
                                                    theme.colorScheme.secondary,
                                                onChanged: (val) {
                                                  setState(() {
                                                    t["checked"] = val;
                                                  });
                                                },
                                              ),

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
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: theme
                                                        .colorScheme
                                                        .onSurface,
                                                  ),
                                                ),
                                              ),

                                              if (t["hora"] != null)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                      ),
                                                  child: Text(
                                                    t["hora"],
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: theme
                                                          .colorScheme
                                                          .outline,
                                                    ),
                                                  ),
                                                )
                                              else
                                                Icon(
                                                  Icons.access_time,
                                                  size: 18,
                                                  color:
                                                      theme.colorScheme.outline,
                                                ),
                                            ],
                                          ),

                                          const SizedBox(height: 8),
                                          Divider(
                                            height: 1,
                                            color: theme.dividerColor,
                                          ),
                                          const SizedBox(height: 8),
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
