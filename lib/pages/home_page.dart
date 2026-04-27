//lib/pages/home_page.dart
import 'package:flutter/material.dart';
import '../widgets/app_navbar.dart';
import '../widgets/app_sidebar.dart';
import '../services/auth_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppSidebar(),
      backgroundColor: const Color(0xFFF7F7F7),

      body: SafeArea(
        child: Column(
          children: [
            const AppNavbar(),

            const SizedBox(height: 20),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _card(title: "Ventas del día", value: "S/ 0.00"),
                    const SizedBox(height: 12),
                    _card(title: "Pedidos", value: "0"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card({required String title, required String value}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6EC6CA),
            ),
          ),
        ],
      ),
    );
  }
}
