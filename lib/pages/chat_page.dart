import 'package:flutter/material.dart';

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

  void sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      messages.add({"text": text, "isUser": true});
    });

    controller.clear();

    await Future.delayed(const Duration(milliseconds: 500));

    if (waitingTask) {
      tasks.add({"task": text, "time": selectedTime});

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
