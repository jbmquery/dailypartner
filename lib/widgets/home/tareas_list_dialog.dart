//lib/widgets/home/tareas_list_dialog.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TareasListDialog extends StatefulWidget {
  final DocumentSnapshot? taskDoc; // 👈 ahora puede ser null
  final DocumentReference? dailyRef; // 👈 para crear

  const TareasListDialog({super.key, this.taskDoc, this.dailyRef});

  @override
  State<TareasListDialog> createState() => _TareasListDialogState();
}

class _TareasListDialogState extends State<TareasListDialog> {
  final TextEditingController controller = TextEditingController();

  String? time;
  String importancia = "normal";

  bool get isEditing => widget.taskDoc != null;

  @override
  void initState() {
    super.initState();

    if (isEditing) {
      final data = widget.taskDoc!.data() as Map<String, dynamic>;
      controller.text = data["titulo"] ?? "";
      time = data["hora_recordatorio"];
      importancia = data["importancia"] ?? "normal";
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
    if (controller.text.trim().isEmpty) return;

    final data = {
      "titulo": controller.text,
      "hora_recordatorio": time,
      "importancia": importancia,
      "estado": "pendiente",
      "actualizacion": FieldValue.serverTimestamp(),
    };

    if (isEditing) {
      await widget.taskDoc!.reference.update(data);
    } else {
      await widget.dailyRef!.collection('tareas').add(data);
    }

    Navigator.pop(context);
  }

  Future<void> delete() async {
    if (isEditing) {
      await widget.taskDoc!.reference.delete();
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
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
            // HANDLE
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            // TITULO
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                isEditing ? "Editar tarea" : "Nueva tarea",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 14),

            // INPUT
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: "¿Qué tienes que hacer?",
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ⏰ + ⭐ MISMA FILA
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: pickTime,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6EC6CA).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 18,
                            color: Color(0xFF6EC6CA),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            time ?? "Agregar hora",
                            style: const TextStyle(
                              color: Color(0xFF6EC6CA),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButton<String>(
                      value: importancia,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(
                          value: "normal",
                          child: Text("Normal"),
                        ),
                        DropdownMenuItem(value: "alta", child: Text("Alta 🔥")),
                      ],
                      onChanged: (val) {
                        setState(() {
                          importancia = val!;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // BOTONES
            Row(
              children: [
                if (isEditing)
                  Expanded(
                    child: GestureDetector(
                      onTap: delete,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            "Eliminar",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                if (isEditing) const SizedBox(width: 10),

                Expanded(
                  child: GestureDetector(
                    onTap: save,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6EC6CA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          "Guardar",
                          style: TextStyle(
                            color: Colors.white,
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
