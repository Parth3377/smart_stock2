import 'dart:async';
import 'package:flutter/material.dart';
import '../auth/login_screen.dart';
import '../../widgets/loading_indicator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _bounce;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _bounce = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.repeat(reverse: true);

    /// Navigate after 3 seconds
    Timer(const Duration(seconds: 3), () {

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );

    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0E14),

      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0B0E14),
              Color(0xFF101626),
              Color(0xFF0B0E14),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            /// BOUNCING LOGO
            AnimatedBuilder(
              animation: _bounce,
              builder: (context, child) {

                return Transform.scale(
                  scale: _bounce.value,
                  child: child,
                );
              },

              child: Image.asset(
                "assets/logo.png",

                /// BIG CLEAR LOGO
                width: size.width * 0.40,
              ),
            ),

            const SizedBox(height: 50),

            /// LOADING DOTS
            const LoadingIndicator(),

          ],
        ),
      ),
    );
  }
}