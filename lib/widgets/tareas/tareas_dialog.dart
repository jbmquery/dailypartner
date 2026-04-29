//lib/widgets/tareas/tareas_dialog.dart
import 'package:flutter/material.dart';

class TareasDialog extends StatefulWidget {
  final Map<String, dynamic>? task;

  const TareasDialog({super.key, this.task});

  @override
  State<TareasDialog> createState() => _TareasDialogState();
}

class _TareasDialogState extends State<TareasDialog> {
  final TextEditingController controller = TextEditingController();

  String? time;

  @override
  void initState() {
    super.initState();

    if (widget.task != null) {
      controller.text = widget.task!["titulo"] ?? "";
      time = widget.task!["hora"];
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

  void save() {
    Navigator.pop(context, {"titulo": controller.text, "hora": time});
  }

  void delete() {
    Navigator.pop(context, {"delete": true});
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

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.task == null ? "Nueva tarea" : "Editar tarea",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: controller,
                autofocus: true,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  hintText: "¿Qué tienes que hacer?",
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 14),

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
                          style: const TextStyle(color: Color(0xFF6EC6CA)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [
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
