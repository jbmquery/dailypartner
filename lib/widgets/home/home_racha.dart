//lib/widgets/home/home_racha.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/streak_service.dart';

class HomeRacha extends StatelessWidget {
  const HomeRacha({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: StreakService.stream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return _rachaUI(context, 0);
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final streak = data["currentStreak"] ?? 0;

        return _rachaUI(context, streak);
      },
    );
  }
}

// 🎨 UI DE LA RACHA
Widget _rachaUI(BuildContext context, int streak) {
  final theme = Theme.of(context);

  Color baseColor;

  if (streak <= 10) {
    baseColor = Colors.orange;
  } else if (streak <= 30) {
    baseColor = Colors.blue;
  } else if (streak <= 100) {
    baseColor = Colors.green;
  } else if (streak <= 365) {
    baseColor = Colors.purple;
  } else {
    baseColor = Colors.amber;
  }

  // 🔥 mezcla con el tema
  final color = Color.lerp(theme.colorScheme.primary, baseColor, 0.6)!;

  double size = 18;
  if (streak > 10) size = 22;
  if (streak > 30) size = 26;
  if (streak > 100) size = 30;
  if (streak > 365) size = 34;

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12), // 🔥 dinámico
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      children: [
        FireIcon(size: size, color: color),
        const SizedBox(width: 6),
        Text(
          "$streak días",
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
      ],
    ),
  );
}

// 🔥 ICONO ANIMADO
class FireIcon extends StatefulWidget {
  final double size;
  final Color color;

  const FireIcon({super.key, required this.size, required this.color});

  @override
  State<FireIcon> createState() => _FireIconState();
}

class _FireIconState extends State<FireIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> scale;
  late Animation<double> rotation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    scale = Tween<double>(
      begin: 1.0,
      end: 1.25,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    rotation = Tween<double>(
      begin: -0.08,
      end: 0.08,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: rotation.value,
          child: Transform.scale(
            scale: scale.value,
            child: Icon(
              Icons.local_fire_department,
              color: widget.color,
              size: widget.size,
            ),
          ),
        );
      },
    );
  }
}
