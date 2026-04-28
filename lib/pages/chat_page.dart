//lib/pages/chat_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController controller = TextEditingController();

  List<Map<String, dynamic>> messages = [];

  List<Map<String, dynamic>> tasks = [];

  bool waitingTask = true;
  bool askAnother = false;
  bool showTimeSelector = false;

  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();

    messages.add({"text": "¿Qué vas a hacer el día de hoy?", "isUser": false});
  }

  // 🔥 CREA OBTIENE EL DAILY DEL DÍA
  Future<DocumentReference> getOrCreateDaily() async {
    final user = FirebaseAuth.instance.currentUser!;
    final now = DateTime.now();

    String fecha = "${now.year}-${now.month}-${now.day}";
    String docId = "${user.uid}_$fecha";

    final ref = FirebaseFirestore.instance.collection('daily').doc(docId);

    final doc = await ref.get();

    if (!doc.exists) {
      await ref.set({
        "uid": user.uid,
        "fecha_creacion": FieldValue.serverTimestamp(),
      });
    }

    return ref;
  }

  // 📝 GUARDAR TAREA
  Future<void> saveTaskToDaily(String text, TimeOfDay? time) async {
    final dailyRef = await getOrCreateDaily();

    await dailyRef.collection('tareas').add({
      "titulo": text,
      "estado": "normal",
      "recordatorio": time != null,
      "hora_recordatorio": time != null ? time.format(context) : null,
      "completo": false,
      "actualizacion": FieldValue.serverTimestamp(),
    });
  }

  // 📊 GUARDAR MINI PREGUNTAS
  Future<void> saveMiniQuestions({
    required int vasos,
    required String modo,
    required String productividad,
    required double energia,
    required String estres,
    required String tiempo,
  }) async {
    final dailyRef = await getOrCreateDaily();

    await dailyRef.collection('minipreguntas').doc('resumen').set({
      "vasos": vasos,
      "modo": modo,
      "productividad": productividad,
      "energia": energia,
      "estres": estres,
      "tiempo": tiempo,
    });
  }

  void sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      messages.add({"text": text, "isUser": true});
    });

    controller.clear();

    await Future.delayed(const Duration(milliseconds: 500));

    if (waitingTask) {
      tasks.add({"task": text, "time": selectedTime});
      await saveTaskToDaily(text, selectedTime);

      selectedTime = null;
      showTimeSelector = false;

      setState(() {
        messages.add({"text": "¿Tienes otra tarea?", "isUser": false});
        waitingTask = false;
        askAnother = true;
      });
    } else if (askAnother) {
      if (text.toLowerCase() == "si") {
        setState(() {
          messages.add({
            "text": "Perfecto, dime la siguiente tarea",
            "isUser": false,
          });
          waitingTask = true;
          askAnother = false;
        });
      } else {
        showSummary();
      }
    }
  }

  void showSummary() {
    String resumen = "🧾 Tus tareas del día:\n\n";

    for (var t in tasks) {
      if (t["time"] != null) {
        resumen += "• ${t["task"]} a las ${t["time"]!.format(context)}\n";
      } else {
        resumen += "• ${t["task"]}\n";
      }
    }

    setState(() {
      messages.add({"text": resumen, "isUser": false});
      messages.add({
        "text": "🔥 Listo, a romperla hoy. ¡Vamos!",
        "isUser": false,
      });
    });

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
    });
  }

  void pickTime() async {
    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        selectedTime = time;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),

      appBar: AppBar(
        title: const Text("Plan del día"),
        backgroundColor: const Color(0xFF6EC6CA),
      ),

      body: Column(
        children: [
          // 💬 CHAT
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];

                return Align(
                  alignment: msg["isUser"]
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: msg["isUser"]
                          ? const Color(0xFFF8A5C2)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg["text"],
                      style: TextStyle(
                        color: msg["isUser"] ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ⌨️ INPUT + OPCIONES
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.white,
            child: Column(
              children: [
                if (waitingTask)
                  Row(
                    children: [
                      Checkbox(
                        value: showTimeSelector,
                        onChanged: (value) {
                          setState(() {
                            showTimeSelector = value!;
                          });
                        },
                      ),
                      const Text("¿Recordatorio?"),

                      if (showTimeSelector)
                        IconButton(
                          icon: const Icon(Icons.access_time),
                          onPressed: pickTime,
                        ),

                      if (selectedTime != null)
                        Text(selectedTime!.format(context)),
                    ],
                  ),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          hintText: askAnother
                              ? "Responde: Si / No"
                              : "Escribe tu tarea...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    IconButton(
                      icon: const Icon(Icons.send),
                      color: const Color(0xFF6EC6CA),
                      onPressed: () => sendMessage(controller.text),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
