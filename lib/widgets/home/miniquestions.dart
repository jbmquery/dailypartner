//lib/widgets/home/miniquestions.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/streak_service.dart';

class MiniQuestions extends StatefulWidget {
  const MiniQuestions({super.key});

  @override
  State<MiniQuestions> createState() => _MiniQuestionsState();
}

class _MiniQuestionsState extends State<MiniQuestions> {
  final PageController _controller = PageController();

  int currentPage = 0;
  int waterSelected = 0;
  int moodSelected = -1;
  int productivitySelected = -1;
  int energySelected = -1;
  int stressSelected = -1;
  int weatherSelected = -1;

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

  Future<void> saveMiniQuestions() async {
    final dailyRef = await getOrCreateDaily();

    await dailyRef.collection('minipreguntas').doc('resumen').set({
      "vasos": waterSelected,
      "modo": moodSelected,
      "productividad": productivitySelected,
      "energia": energySelected,
      "estres": stressSelected,
      "tiempo": weatherSelected,
    }, SetOptions(merge: true));
  }

  Future<void> loadMiniQuestions() async {
    final dailyRef = await getOrCreateDaily();
    final doc = await dailyRef.collection('minipreguntas').doc('resumen').get();

    if (doc.exists) {
      final data = doc.data()!;

      setState(() {
        waterSelected = data["vasos"] ?? 0;
        moodSelected = data["modo"] ?? -1;
        productivitySelected = data["productividad"] ?? -1;
        energySelected = data["energia"] ?? -1;
        stressSelected = data["estres"] ?? -1;
        weatherSelected = data["tiempo"] ?? -1;
      });
    }
  }

  void nextPage() {
    if (currentPage < 5) {
      currentPage++;
      _controller.animateToPage(
        currentPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    loadMiniQuestions();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      child: PageView(
        controller: _controller,
        physics: const BouncingScrollPhysics(),
        children: [
          _waterQuestion(),
          _moodQuestion(),
          _productivityQuestion(),
          _energyQuestion(),
          _stressQuestion(),
          _weatherQuestion(),
        ],
      ),
    );
  }

  Widget _waterQuestion() {
    final theme = Theme.of(context);

    return _card(
      title: "¿Cuántos vasos de agua vas tomado?",
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(8, (index) {
          bool isActive = index < waterSelected;

          return GestureDetector(
            onTap: () async {
              setState(() {
                waterSelected = index + 1;
              });

              await saveMiniQuestions();
              await StreakService.updateStreak();

              Future.delayed(const Duration(milliseconds: 300), nextPage);
            },
            child: Column(
              children: [
                Icon(
                  isActive ? Icons.local_drink : Icons.local_drink_outlined,
                  color: isActive
                      ? theme.primaryColor
                      : theme.colorScheme.outline, // 🔥 dinámico
                  size: 40,
                ),
                const SizedBox(height: 4),
                Text(
                  "${index + 1}",
                  style: TextStyle(
                    color: theme.colorScheme.onSurface, // 🔥 dinámico
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _moodQuestion() {
    final theme = Theme.of(context);

    final moods = [
      {"icon": "😄", "label": "Muy feliz"},
      {"icon": "🙂", "label": "Feliz"},
      {"icon": "😐", "label": "Normal"},
      {"icon": "🙁", "label": "Triste"},
      {"icon": "😣", "label": "Muy triste"},
    ];

    return _card(
      title: "Estoy modo...",
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(moods.length, (index) {
          bool isSelected = moodSelected == index;

          return GestureDetector(
            onTap: () async {
              setState(() {
                moodSelected = index;
              });

              await saveMiniQuestions();
              nextPage();
            },
            child: Column(
              children: [
                Text(
                  moods[index]["icon"] as String,
                  style: TextStyle(fontSize: isSelected ? 45 : 40),
                ),
                const SizedBox(height: 4),
                Text(
                  moods[index]["label"] as String,
                  style: TextStyle(
                    fontSize: 10,
                    color: isSelected
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.outline, // 🔥 dinámico
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _card({required String title, required Widget child}) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface, // 🔥 dinámico correcto
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.05), // 🔥 dinámico
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface, // 🔥 dinámico
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _productivityQuestion() {
    final theme = Theme.of(context);

    return _card(
      title: "¿Qué tan productivo me siento?",
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              bool active = index < productivitySelected;

              return GestureDetector(
                onTap: () async {
                  setState(() {
                    productivitySelected = index + 1;
                  });

                  await saveMiniQuestions();

                  Future.delayed(const Duration(milliseconds: 300), nextPage);
                },
                child: Icon(
                  active ? Icons.star : Icons.star_border,
                  color:
                      theme.colorScheme.tertiary, // 🔥 dinámico (antes amber)
                  size: 60,
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Quiero mi cama 😴",
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                "Tamos ready 😎🤙🏻",
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _energyQuestion() {
    final theme = Theme.of(context);

    final levels = [10, 25, 50, 75, 90, 100];

    Color getColor(int value) {
      if (value <= 25) return theme.colorScheme.tertiary;
      if (value <= 50) return theme.colorScheme.secondary;
      if (value <= 75) return theme.colorScheme.primary;
      return theme.colorScheme.primary;
    }

    return _card(
      title: "Mi nivel de energía",
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(levels.length, (index) {
          bool selected = energySelected == index;

          return GestureDetector(
            onTap: () async {
              setState(() {
                energySelected = index;
              });

              await saveMiniQuestions();

              Future.delayed(const Duration(milliseconds: 300), nextPage);
            },
            child: Column(
              children: [
                Icon(
                  Icons.battery_full,
                  size: selected ? 55 : 50,
                  color: getColor(levels[index]),
                ),
                Text(
                  "${levels[index]}%",
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _stressQuestion() {
    final theme = Theme.of(context);

    final stressLevels = [
      {"emoji": "😌", "label": "Relax"},
      {"emoji": "🙂", "label": "Leve"},
      {"emoji": "😐", "label": "Normal"},
      {"emoji": "😣", "label": "Alto"},
      {"emoji": "🤯", "label": "Exploto"},
    ];

    return _card(
      title: "Nivel de estrés",
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(stressLevels.length, (index) {
          bool selected = stressSelected == index;

          return GestureDetector(
            onTap: () async {
              setState(() {
                stressSelected = index;
              });

              await saveMiniQuestions();

              Future.delayed(const Duration(milliseconds: 300), nextPage);
            },
            child: Column(
              children: [
                Text(
                  stressLevels[index]["emoji"]!,
                  style: TextStyle(fontSize: selected ? 45 : 40),
                ),
                Text(
                  stressLevels[index]["label"]!,
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.colorScheme.onSurface, // 🔥 dinámico
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _weatherQuestion() {
    final theme = Theme.of(context);

    final weather = [
      {"icon": Icons.wb_sunny, "label": "Soleado"},
      {"icon": Icons.cloud, "label": "Nublado"},
      {"icon": Icons.grain, "label": "Lluvia"},
      {"icon": Icons.ac_unit, "label": "Frío"},
      {"icon": Icons.thunderstorm, "label": "Tormenta"},
    ];

    return _card(
      title: "¿Cómo está el clima?",
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(weather.length, (index) {
          bool selected = weatherSelected == index;

          return GestureDetector(
            onTap: () async {
              setState(() {
                weatherSelected = index;
              });

              await saveMiniQuestions();
            },
            child: Column(
              children: [
                Icon(
                  weather[index]["icon"] as IconData,
                  size: selected ? 34 : 28,
                  color: selected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline, // 🔥 dinámico
                ),
                Text(
                  weather[index]["label"] as String,
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
