import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../widgets/glass_bottom_navbar.dart';

class OrderSuccessScreen extends StatefulWidget {
  const OrderSuccessScreen({super.key});

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scale = Tween(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _opacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();

    /// AUTO REDIRECT AFTER 2 SECONDS
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.dashboard,
            (route) => false,
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

    return Scaffold(
      backgroundColor: const Color(0xFF0F1218),

      bottomNavigationBar: GlassBottomNavbar(
        currentIndex: 0,
        onTap: (index) {

          if (index == 0) return;

          if (index == 1) {
            Navigator.pushReplacementNamed(context, AppRoutes.products);
          }

          if (index == 2) {
            Navigator.pushReplacementNamed(context, AppRoutes.orderDraft);
          }

          if (index == 3) {
            Navigator.pushReplacementNamed(context, AppRoutes.profile);
          }

        },
      ),

      body: Center(
        child: FadeTransition(
          opacity: _opacity,

          child: ScaleTransition(
            scale: _scale,

            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 36,
                vertical: 42,
              ),

              margin: const EdgeInsets.symmetric(horizontal: 24),

              decoration: BoxDecoration(
                color: const Color(0xFF161A22),

                borderRadius: BorderRadius.circular(22),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 30,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,

                children: [

                  /// SUCCESS ICON
                  Container(
                    width: 86,
                    height: 86,

                    decoration: BoxDecoration(
                      shape: BoxShape.circle,

                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF2E6CF6),
                          Color(0xFF5B8CFF)
                        ],
                      ),

                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2E6CF6)
                              .withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),

                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 46,
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    "Order Placed!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Your order has been placed successfully.\nRedirecting to dashboard...",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFA1A6B3),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 26),

                  /// BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 46,

                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.dashboard,
                              (route) => false,
                        );
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E6CF6),

                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(12),
                        ),
                      ),

                      child: const Text(
                        "Go to Dashboard",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}