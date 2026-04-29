import 'package:flutter/material.dart';

Future<String?> showEliminarRepetitivaDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔘 HANDLE (consistencia con tus modals)
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // 🧠 TITULO
              const Text(
                "¿Eliminar esta tarea?",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              // ✍️ SUBTEXTO (detalle fino UX)
              const Text(
                "Puedes quitarla solo por hoy o eliminarla para siempre",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),

              const SizedBox(height: 20),

              // 🔘 BOTONES
              Row(
                children: [
                  // 🟠 SOLO HOY
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context, "hoy");
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6EC6CA).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            "Solo por hoy",
                            style: TextStyle(
                              color: Color(0xFF6EC6CA),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // 🔴 PARA SIEMPRE
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context, "siempre");
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            "Para siempre",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
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
    },
  );
}
