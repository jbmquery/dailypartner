//lib/widgets/tareas/tareas_list_dialog.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TareasListDialog extends StatefulWidget {
  final DocumentSnapshot taskDoc;

  const TareasListDialog({super.key, required this.taskDoc});

  @override
  State<TareasListDialog> createState() => _TareasListDialogState();
}

class _TareasListDialogState extends State<TareasListDialog> {
  final TextEditingController controller = TextEditingController();
  String? time;
  String importancia = "normal";

  @override
  void initState() {
    super.initState();

    final data = widget.taskDoc.data() as Map<String, dynamic>;

    controller.text = data["titulo"] ?? "";
    time = data["hora_recordatorio"];
    importancia = data["importancia"] ?? "normal";
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
    await widget.taskDoc.reference.update({
      "titulo": controller.text,
      "hora_recordatorio": time,
      "importancia": importancia,
      "actualizacion": FieldValue.serverTimestamp(),
    });

    Navigator.pop(context);
  }

  Future<void> delete() async {
    await widget.taskDoc.reference.delete();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, color: Colors.grey),

            const SizedBox(height: 12),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Editar tarea",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: "Editar tarea...",
                border: InputBorder.none,
              ),
            ),

            const SizedBox(height: 10),

            GestureDetector(
              onTap: pickTime,
              child: Row(
                children: [
                  const Icon(Icons.access_time),
                  const SizedBox(width: 6),
                  Text(time ?? "Agregar hora"),
                ],
              ),
            ),

            const SizedBox(height: 10),

            DropdownButton<String>(
              value: importancia,
              items: const [
                DropdownMenuItem(value: "normal", child: Text("Normal")),
                DropdownMenuItem(value: "alta", child: Text("Alta")),
              ],
              onChanged: (val) {
                setState(() {
                  importancia = val!;
                });
              },
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: delete,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      color: Colors.red.withOpacity(0.1),
                      child: const Center(child: Text("Eliminar")),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: save,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      color: const Color(0xFF6EC6CA),
                      child: const Center(
                        child: Text(
                          "Guardar",
                          style: TextStyle(color: Colors.white),
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
