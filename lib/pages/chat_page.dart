// lib/pages/chat_page.dart
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
    messages.add({"text": "¿Qué vas a hacer hoy?", "isUser": false});
  }

  // 🔥 DAILY
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

  // 📝 GUARDAR
  Future<void> saveTaskToDaily(String text, TimeOfDay? time) async {
    final dailyRef = await getOrCreateDaily();

    await dailyRef.collection('tareas').add({
      "titulo": text,
      "importancia": "normal",
      "recordatorio": time != null,
      "hora_recordatorio": time != null ? time.format(context) : null,
      "estado": "pendiente",
      "actualizacion": FieldValue.serverTimestamp(),
    });
  }

  // 💬 LÓGICA CHAT
  void sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      messages.add({"text": text, "isUser": true});
    });

    controller.clear();

    await Future.delayed(const Duration(milliseconds: 400));

    if (waitingTask) {
      tasks.add({"task": text, "time": selectedTime});
      await saveTaskToDaily(text, selectedTime);

      selectedTime = null;
      showTimeSelector = false;

      setState(() {
        messages.add({"text": "¿Otra tarea?", "isUser": false});
        waitingTask = false;
        askAnother = true;
      });
    } else if (askAnother) {
      if (text.toLowerCase() == "si") {
        setState(() {
          messages.add({"text": "Dale, dime la siguiente", "isUser": false});
          waitingTask = true;
          askAnother = false;
        });
      } else {
        showSummary();
      }
    }
  }

  void showSummary() {
    String resumen = "📋 HOY TIENES:\n\n";

    for (var t in tasks) {
      resumen += t["time"] != null
          ? "• ${t["task"]} (${t["time"]!.format(context)})\n"
          : "• ${t["task"]}\n";
    }

    setState(() {
      messages.add({"text": resumen, "isUser": false});
      messages.add({"text": "🔥 Dale con todo hoy.", "isUser": false});
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

  // 🎨 BURBUJA ESTILO NOTEBOOK
  Widget bubble(Map msg) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: msg["isUser"] ? const Color(0xFFF8A5C2) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Text(
        msg["text"],
        style: TextStyle(color: msg["isUser"] ? Colors.white : Colors.black87),
      ),
    );
  }

  // 📓 LINEA DE CUADERNO
  Widget notebookLine() {
    return Container(
      height: 1,
      color: Colors.grey.withOpacity(0.3),
      margin: const EdgeInsets.symmetric(vertical: 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0),

      appBar: AppBar(
        title: const Text("DAILY PLANNER"),
        backgroundColor: const Color(0xFF6EC6CA),
        elevation: 0,
      ),

      body: Column(
        children: [
          // 📋 ESTILO HOJA
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return Column(
                    crossAxisAlignment: messages[index]["isUser"]
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [bubble(messages[index]), notebookLine()],
                  );
                },
              ),
            ),
          ),

          // ⌨️ INPUT
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: Colors.white),
            child: Column(
              children: [
                if (waitingTask)
                  Row(
                    children: [
                      const Icon(Icons.alarm, size: 18),
                      const SizedBox(width: 6),
                      const Text("Recordatorio"),
                      const Spacer(),
                      Switch(
                        value: showTimeSelector,
                        onChanged: (v) {
                          setState(() {
                            showTimeSelector = v;
                          });
                        },
                      ),
                      if (showTimeSelector)
                        TextButton(
                          onPressed: pickTime,
                          child: Text(
                            selectedTime != null
                                ? selectedTime!.format(context)
                                : "Hora",
                          ),
                        ),
                    ],
                  ),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          hintText: askAnother ? "Sí / No" : "Escribe tarea...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onSubmitted: sendMessage,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () => sendMessage(controller.text),
                      color: const Color(0xFF6EC6CA),
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
