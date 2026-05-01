//lib/widgets/app_sidebar.dart
import 'package:daily_partner/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:daily_partner/pages/tema_page.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: Container(
        color: theme.scaffoldBackgroundColor, // 🔥 dinámico
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary, // 🔥 dinámico
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.dashboard, color: Colors.white, size: 40),
                  const SizedBox(height: 10),
                  const Text(
                    "Daily Partner",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Panel principal",
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _menuItem(
              context,
              icon: Icons.home_outlined,
              title: "Inicio",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HomePage()),
                );
              },
            ),

            _menuItem(
              context,
              icon: Icons.history,
              title: "Historial",
              onTap: () {},
            ),

            _menuItem(
              context,
              icon: Icons.bar_chart,
              title: "Estadísticas",
              onTap: () {},
            ),

            _menuItem(
              context,
              icon: Icons.mode_night_outlined,
              title: "Temas",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TemaPage()),
                );
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
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: Icon(
          icon,
          color: theme.colorScheme.primary, // 🔥 dinámico
        ),
        title: Text(
          title,
          style: TextStyle(
            color: theme.textTheme.bodyMedium?.color, // 🔥 dinámico
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        onTap: onTap,
      ),
    );
  }
}
