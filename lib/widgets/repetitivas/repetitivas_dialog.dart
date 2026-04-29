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
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🔘 HANDLE (detalle pro)
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // 🧠 TITULO
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.task == null ? "Nueva tarea" : "Editar tarea",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 14),

          // ✍️ INPUT ESTILO CARD
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

          // ⏰ SELECTOR DE HORA BONITO
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
            ],
          ),

          const SizedBox(height: 20),

          // 🔘 BOTONES BONITOS
          Row(
            children: [
              // ELIMINAR
              if (widget.task != null)
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

              if (widget.task != null) const SizedBox(width: 10),

              // GUARDAR (principal)
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
    );
  }
}
