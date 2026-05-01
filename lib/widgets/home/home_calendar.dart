//lib/widgets/home/home_calendar.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeCalendarBar extends StatelessWidget {
  final VoidCallback onNext;

  const HomeCalendarBar({super.key, required this.onNext});

  String getTodayText() {
    final now = DateTime.now();

    final diaSemana = DateFormat('EEEE', 'es').format(now);
    final fecha = DateFormat('d \'de\' MMMM yyyy', 'es').format(now);

    final diaCapitalizado = diaSemana[0].toUpperCase() + diaSemana.substring(1);

    return "$diaCapitalizado\n$fecha";
  }

  void openCalendar(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: theme.cardColor, // 🔥 dinámico
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: CalendarDatePicker(
              initialDate: DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
              onDateChanged: (date) {
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary, // 🔥 dinámico
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // 📅 ICONO CALENDARIO
          GestureDetector(
            onTap: () => openCalendar(context),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.calendar_month,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),

          const SizedBox(width: 10),

          // 📆 TEXTO FECHA
          Expanded(
            child: Text(
              getTodayText(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                height: 1.2,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // 🚀 BOTÓN SIGUIENTE
          GestureDetector(
            onTap: onNext,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: theme.cardColor, // 🔥 dinámico
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "Siguiente",
                style: TextStyle(
                  color: theme.colorScheme.primary, // 🔥 dinámico
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
