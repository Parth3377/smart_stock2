import 'package:flutter/material.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _fade = Tween<double>(begin: 0, end: 1).animate(_controller);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
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

      appBar: AppBar(
        title: const Text("About SmartStock"),
        backgroundColor: const Color(0xFF161A22),
        elevation: 0,
      ),

      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,

          child: ListView(
            padding: const EdgeInsets.all(16),

            children: [

              /// ================= APP HEADER =================

              Container(
                padding: const EdgeInsets.all(24),

                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E6CF6), Color(0xFF4B8BFF)],
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),

                child: const Column(
                  children: [

                    Icon(
                      Icons.app_shortcut_rounded,
                      size: 60,
                      color: Colors.white,
                    ),

                    SizedBox(height: 12),

                    Text(
                      "SmartStock",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 4),

                    Text(
                      "B2B Order & Inventory System",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              /// ================= APP INFO =================

              _infoCard(
                icon: Icons.info,
                title: "Application Version",
                subtitle: "Version 1.0.0",
              ),

              _infoCard(
                icon: Icons.developer_mode,
                title: "Developed By",
                subtitle: "SmartStock Development Team",
              ),

              _infoCard(
                icon: Icons.storage,
                title: "Technology Stack",
                subtitle: "Flutter • Firebase",
              ),

              const SizedBox(height: 28),

              /// ================= DESCRIPTION =================

              Container(
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: const Color(0xFF161A22),
                  borderRadius: BorderRadius.circular(18),
                ),

                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      "About SmartStock",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    SizedBox(height: 10),

                    Text(
                      "SmartStock is a modern B2B inventory and order management "
                          "platform designed for businesses to efficiently manage "
                          "products, orders, payments and customer data.\n\n"
                          "Our goal is to provide a simple, fast and powerful "
                          "solution for managing industrial inventory operations.",
                      style: TextStyle(
                        color: Color(0xFFA1A6B3),
                        height: 1.4,
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 24),

              /// ================= COPYRIGHT =================

              const Center(
                child: Text(
                  "© 2026 SmartStock Inc.",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// ================= INFO CARD =================

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: const Color(0xFF161A22),
        borderRadius: BorderRadius.circular(18),
      ),

      child: Row(
        children: [

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF2E6CF6).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF2E6CF6)),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFFA1A6B3),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}