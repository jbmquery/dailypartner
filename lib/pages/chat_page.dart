// lib/pages/chat_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController controller = TextEditingController();

  bool isTyping = false;
  bool finished = false;

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

  Future<void> saveAllTasks() async {
    final dailyRef = await getOrCreateDaily();

    for (var t in tasks) {
      await dailyRef.collection('tareas').add({
        "titulo": t["task"],
        "importancia": t["important"] ? "alta" : "normal",
        "recordatorio": t["time"] != null,
        "hora_recordatorio": t["time"] ?? null,
        "estado": "pendiente",
        "completo": false,
        "actualizacion": FieldValue.serverTimestamp(),
      });
    }

    Navigator.pop(context);
  }

  // 🌐 LLAMADA A OPENROUTER
  Future<String> askAI(String prompt) async {
    const apiKey =
        "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";

    try {
      final response = await http.post(
        Uri.parse("https://openrouter.ai/api/v1/chat/completions"),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
          "HTTP-Referer": "https://tuapp.com",
          "X-Title": "Daily Partner",
        },
        body: jsonEncode({
          "model": "nvidia/nemotron-3-nano-omni-30b-a3b-reasoning:free",
          "messages": [
            {
              "role": "system",
              "content": """
Eres un asistente de productividad.

REGLAS:
- SOLO hablas de tareas diarias
- NO respondes preguntas fuera de productividad
- Redirige al usuario si se desvía
- Respuestas cortas
""",
            },
            {"role": "user", "content": prompt},
          ],
        }),
      );

      final data = jsonDecode(response.body);

      // 🧨 DEBUG (IMPORTANTE)
      print("RESPONSE OPENROUTER:");
      print(data);

      // ❌ SI VIENE ERROR
      if (data["error"] != null) {
        return "⚠️ Error IA: ${data["error"]["message"]}";
      }

      // ❌ SI NO VIENE choices
      if (data["choices"] == null) {
        return "⚠️ La IA no respondió correctamente.";
      }

      return data["choices"][0]["message"]["content"] ?? "⚠️ Respuesta vacía";
    } catch (e) {
      return "⚠️ Error de conexión con IA";
    }
  }

  // 📊 CONTEXTO DEL USUARIO (FIRESTORE)
  Future<Map<String, dynamic>> getUserContext() async {
    final user = FirebaseAuth.instance.currentUser!;
    final now = DateTime.now();

    String fecha = "${now.year}-${now.month}-${now.day}";
    String docId = "${user.uid}_$fecha";

    final dailyRef = FirebaseFirestore.instance.collection('daily').doc(docId);

    final tareasSnap = await dailyRef.collection('tareas').get();
    final miniSnap = await dailyRef
        .collection('minipreguntas')
        .doc('resumen')
        .get();

    final repetidasSnap = await FirebaseFirestore.instance
        .collection('tareasrepetidas')
        .where("uid", isEqualTo: user.uid)
        .get();

    return {
      "tareas": tareasSnap.docs.map((d) => d["titulo"]).toList(),
      "mini": miniSnap.data() ?? {},
      "repetidas": repetidasSnap.docs.map((d) => d["titulo"]).toList(),
    };
  }

  // 🧠 CONSTRUIR PROMPT
  Future<String> buildPrompt(String userMessage) async {
    final ctx = await getUserContext();

    return """
Extrae tareas del siguiente mensaje.

Mensaje:
"$userMessage"

Reglas:
- Devuelve SOLO JSON
- Formato:
[
  {"task": "texto", "time": "HH:mm o null"}
]

Ejemplo:
[
  {"task": "Lavar uniforme", "time": null},
  {"task": "Ir a casa de Juan", "time": "15:00"}
]

No expliques nada.

Respuesta:
""";
  }

  // 💬 LÓGICA CHAT
  void sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // 🛑 DETECTAR FINALIZAR POR TEXTO
    if (text.toLowerCase().contains("finalizar") ||
        text.toLowerCase().contains("listo")) {
      setState(() {
        finished = true;
      });

      // 🔥 Agregar mensaje tipo sistema
      Future.delayed(const Duration(milliseconds: 300), () {
        setState(() {
          messages.add({
            "text": "📋 Revisa tus tareas antes de guardar 👇",
            "isUser": false,
          });
        });
      });

      return;
    }

    // 💬 MENSAJE NORMAL
    setState(() {
      messages.add({"text": text, "isUser": true});
      isTyping = true;
    });

    controller.clear();

    // 🧠 IA
    String prompt = await buildPrompt(text);
    String aiResponse = await askAI(prompt);

    processAIResponse(aiResponse);

    setState(() {
      isTyping = false;
      messages.add({
        "text":
            "✅ Tareas detectadas. Sigue escribiendo o presiona FINALIZAR 👇",
        "isUser": false,
      });
    });
  }

  void processAIResponse(String response) {
    try {
      final List data = jsonDecode(response);

      for (var item in data) {
        String task = item["task"];
        String? time = item["time"];

        bool exists = tasks.any(
          (t) => t["task"].toLowerCase() == task.toLowerCase(),
        );

        if (!exists) {
          tasks.add({"task": task, "time": time, "important": false});
        }
      }

      setState(() {});
    } catch (e) {
      print("Error parseando IA: $e");
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
                itemCount: messages.length + (isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (isTyping && index == messages.length) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("✍️ escribiendo..."),
                    );
                  }
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
          // 📋 TABLA DE TAREAS TEMPORALES
          // 🔘 BOTÓN FINALIZAR
          if (tasks.isNotEmpty && !finished)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                onPressed: () {
                  setState(() {
                    finished = true;
                    messages.add({
                      "text": "📋 Revisa tus tareas antes de guardar",
                      "isUser": false,
                    });
                  });
                },
                child: const Text("FINALIZAR"),
              ),
            ),

          if (tasks.isNotEmpty && finished)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    "📋 Tus tareas",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  ...tasks.asMap().entries.map((entry) {
                    int i = entry.key;
                    var t = entry.value;

                    return Row(
                      children: [
                        Checkbox(
                          value: t["important"] ?? false,
                          onChanged: (v) {
                            setState(() {
                              t["important"] = v ?? false;
                            });
                          },
                        ),

                        Expanded(child: Text(t["task"])),

                        Text(t["time"] ?? ""),

                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            controller.text = t["task"];
                          },
                        ),

                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              tasks.removeAt(i);
                            });
                          },
                        ),
                      ],
                    );
                  }),

                  const SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: saveAllTasks,
                    child: const Text("GUARDAR"),
                  ),
                ],
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
                                : "Escoge la Hora",
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
                      onPressed: finished
                          ? null
                          : () => sendMessage(controller.text),
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
