//lib/pages/login_page.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_page.dart';
import '../services/navigation_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Theme(
      // 🛡️ THEME AISLADO (NO LE AFECTA chill/agresivo)
      data: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF7F7F7),
        primaryColor: const Color(0xFF6EC6CA),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF6EC6CA),
          secondary: Color(0xFFF8A5C2),
          surface: Colors.white,
          background: Color(0xFFF7F7F7),
          onPrimary: Colors.white,
          onSurface: Colors.black,
          onBackground: Colors.black,
        ),
      ),

      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7), // 🔒 fijo
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // Título estilo planner
                const Text(
                  "Bienvenido Compa",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6EC6CA),
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Inicia sesión para continuar",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),

                const SizedBox(height: 40),

                // EMAIL
                _buildLabel("Email"),
                const SizedBox(height: 8),
                _buildInputField(
                  controller: emailController,
                  hint: "correo@email.com",
                  icon: Icons.email_outlined,
                ),

                const SizedBox(height: 20),

                // PASSWORD
                _buildLabel("Password"),
                const SizedBox(height: 8),
                _buildPasswordField(),

                const SizedBox(height: 40),

                // BOTÓN LOGIN
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (isLoading) return;

                            setState(() {
                              isLoading = true;
                            });

                            try {
                              String email = emailController.text.trim();
                              String password = passwordController.text;

                              final auth = AuthService();

                              final userData = await auth.login(
                                email: email,
                                password: password,
                              );

                              if (userData == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Error al iniciar sesión"),
                                  ),
                                );
                                return;
                              }

                              NavigationService.removeAll(
                                context,
                                const HomePage(),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Ocurrió un error inesperado"),
                                ),
                              );
                            } finally {
                              if (mounted) {
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF8A5C2),
                      foregroundColor: Colors.white, // 🔒 fijo
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Entrar",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // DECORACIÓN estilo planner
                Center(
                  child: Container(
                    width: 60,
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB8E0D2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return const Text(
      "Email",
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF888888),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      enabled: !isLoading,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Color(0xFF6EC6CA)),
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF6EC6CA), width: 2),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: passwordController,
      obscureText: !isPasswordVisible,
      enabled: !isLoading,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF6EC6CA)),
        hintText: "********",
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        suffixIcon: IconButton(
          icon: Icon(
            isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: isLoading
              ? null
              : () {
                  setState(() {
                    isPasswordVisible = !isPasswordVisible;
                  });
                },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFF8A5C2), width: 2),
        ),
      ),
    );
  }
}
