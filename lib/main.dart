// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';

// 🔥 NUEVO
import 'services/theme_service.dart';
import 'theme/app_theme.dart';
import 'services/daily_status_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MiApp());
}

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      stream: ThemeService.modoStream(),
      builder: (context, snapshot) {
        final modo = snapshot.data ?? "chill";

        final theme = modo == "agresivo"
            ? AppTheme.agresivo()
            : AppTheme.chill();

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Daily Partner',
          theme: theme,

          // 👇 MANTENEMOS TU FLUJO DE AUTH
          home: const AuthWrapper(),
        );
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();

    // 🔥 ESCUCHAMOS CAMBIOS DE USUARIO
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        DailyStatusService.initDay();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // ⏳ Cargando
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 🔐 Usuario logueado
        if (snapshot.hasData) {
          return const HomePage();
        }

        // 🚪 No logueado
        return const LoginPage();
      },
    );
  }
}
