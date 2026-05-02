//lib/widgets/repetitivas/repetitivas_dialog.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RepetitivasDialog extends StatefulWidget {
  final Map<String, dynamic>? task;

  const RepetitivasDialog({super.key, this.task});

  @override
  State<RepetitivasDialog> createState() => _RepetitivasDialogState();
}

class _RepetitivasDialogState extends State<RepetitivasDialog> {
  final user = FirebaseAuth.instance.currentUser!;
  final TextEditingController controller = TextEditingController();

  String? time;

  @override
  void initState() {
    super.initState();

    if (widget.task != null) {
      controller.text = widget.task!["titulo"] ?? "";
      time = widget.task!["hora_recordatorio"];
    }
  }

  Future<void> pickTime() async {
    TimeOfDay? t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (t != null) {
      setState(() {
        time = t.format(context);
      });
    }
  }

  Future<void> save() async {
    final data = {
      "uid": user.uid,
      "titulo": controller.text,
      "estado": "pendiente",
      "recordatorio": time != null,
      "hora_recordatorio": time,
      "importancia": "normal",
      "actualizacion": FieldValue.serverTimestamp(),
    };

    if (widget.task == null) {
      await FirebaseFirestore.instance
          .collection('tareas_repetitivas')
          .add(data);
    } else {
      await FirebaseFirestore.instance
          .collection('tareas_repetitivas')
          .doc(widget.task!["id"])
          .update(data);
    }

    Navigator.pop(context);
  }

  Future<void> delete() async {
    if (widget.task != null) {
      await FirebaseFirestore.instance
          .collection('tareas_repetitivas')
          .doc(widget.task!["id"])
          .delete();
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface, // 🔥 dinámico
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🔘 HANDLE
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            // 🧠 TITULO
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.task == null ? "Nueva tarea" : "Editar tarea",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ✍️ INPUT
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: controller,
                autofocus: true,
                textInputAction: TextInputAction.done,
                enableSuggestions: false,
                autocorrect: false,
                style: TextStyle(color: theme.colorScheme.onBackground),
                decoration: InputDecoration(
                  hintText: "¿Qué tienes que hacer?",
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onBackground.withOpacity(0.5),
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ⏰ HORA
            Row(
              children: [
                GestureDetector(
                  onTap: pickTime,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 18,
                          color: theme.colorScheme.secondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          time ?? "Agregar hora",
                          style: TextStyle(
                            color: theme.colorScheme.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 🔘 BOTONES
            Row(
              children: [
                if (widget.task != null)
                  Expanded(
                    child: GestureDetector(
                      onTap: delete,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            "Eliminar",
                            style: TextStyle(
                              color: theme.colorScheme.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                if (widget.task != null) const SizedBox(width: 10),

                Expanded(
                  child: GestureDetector(
                    onTap: save,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          "Guardar",
                          style: TextStyle(
                            color: theme.colorScheme.onSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
