import 'package:flutter/material.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool obscure = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  /// 🔐 LOGIN → DASHBOARD
  Future<void> loginUser() async {
    setState(() => loading = true);

    await Future.delayed(const Duration(seconds: 1));

    setState(() => loading = false);

    if (!mounted) return;

    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  Future<void> googleLogin() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Google login coming soon")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0B0E14),
              Color(0xFF101626),
              Color(0xFF0B0E14),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Image.asset("assets/logo.png", height: 80),
                const SizedBox(height: 28),

                /// MAIN CARD
                Container(
                  width: size.width > 600 ? 420 : size.width * 0.92,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161A22),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 35,
                        offset: const Offset(0, 25),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Welcome Back",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Login to manage your orders & inventory",
                        style:
                        TextStyle(color: Color(0xFFA1A6B3), fontSize: 13),
                      ),
                      const SizedBox(height: 24),

                      _inputField("Email Address", emailController),
                      const SizedBox(height: 16),

                      _inputField("Password", passwordController,
                          isPassword: true),
                      const SizedBox(height: 24),

                      /// SIGN IN BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: loading ? null : loginUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E6CF6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: loading
                              ? const CircularProgressIndicator(
                              color: Colors.white)
                              : const Text("Sign In"),
                        ),
                      ),

                      const SizedBox(height: 22),

                      Row(
                        children: const [
                          Expanded(child: Divider(color: Color(0xFF2A2F3A))),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child:
                            Text("OR", style: TextStyle(color: Color(0xFFA1A6B3))),
                          ),
                          Expanded(child: Divider(color: Color(0xFF2A2F3A))),
                        ],
                      ),

                      const SizedBox(height: 18),

                      /// GOOGLE BUTTON
                      GestureDetector(
                        onTap: googleLogin,
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border:
                            Border.all(color: const Color(0xFF2A2F3A)),
                          ),
                          child: const Center(
                            child: Text(
                              "Continue with Google",
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      /// NAVIGATE TO REGISTER
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "New here? Create an account",
                          style: TextStyle(color: Color(0xFFA1A6B3)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField(String label, TextEditingController controller,
      {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword && obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFFA1A6B3)),
        filled: true,
        fillColor: const Color(0xFF0F1218),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: const Color(0xFFA1A6B3),
          ),
          onPressed: () => setState(() => obscure = !obscure),
        )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
