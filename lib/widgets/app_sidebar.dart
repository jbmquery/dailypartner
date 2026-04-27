//lib/widgets/app_sidebar.dart
import 'package:flutter/material.dart';
import '../services/navigation_service.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFFF7F7F7),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
              decoration: const BoxDecoration(
                color: Color(0xFF6EC6CA),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.dashboard, color: Colors.white, size: 40),
                  SizedBox(height: 10),
                  Text(
                    "Daily Partner",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Panel principal",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _menuItem(
              context,
              icon: Icons.history,
              title: "Historial",
              onTap: () {
                // luego conectas
              },
            ),

            _menuItem(
              context,
              icon: Icons.bar_chart,
              title: "Estadísticas",
              onTap: () {
                // luego conectas
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF6EC6CA)),
        title: Text(title),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        onTap: onTap,
      ),
    );
  }
}
