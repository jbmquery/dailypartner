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
          backgroundColor: theme.colorScheme.surface, // 🔥 dinámico correcto
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

    final primary = theme.colorScheme.primary;
    final onPrimary = theme.colorScheme.onPrimary;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: primary,
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
                color: onPrimary.withOpacity(0.2), // 🔥 dinámico
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.calendar_month,
                color: onPrimary, // 🔥 dinámico
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
                color: onPrimary, // 🔥 dinámico
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
                color: theme.colorScheme.surface, // 🔥 dinámico correcto
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "Siguiente",
                style: TextStyle(
                  color: primary, // 🔥 dinámico
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
