import 'package:flutter/material.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen>
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
        title: const Text("Privacy Policy"),
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

              /// ================= HEADER =================

              Container(
                padding: const EdgeInsets.all(22),

                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E6CF6), Color(0xFF4B8BFF)],
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),

                child: const Row(
                  children: [

                    Icon(
                      Icons.privacy_tip,
                      size: 40,
                      color: Colors.white,
                    ),

                    SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Text(
                            "Your Privacy Matters",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),

                          SizedBox(height: 4),

                          Text(
                            "SmartStock is committed to protecting your data and ensuring transparency.",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 28),

              /// ================= POLICY SECTIONS =================

              _policySection(
                "Information We Collect",
                "SmartStock collects information such as account details, "
                    "order history, product data and usage activity to improve "
                    "our services and provide efficient inventory management.",
              ),

              _policySection(
                "How We Use Your Data",
                "Your data is used to process orders, manage inventory, "
                    "improve system performance and provide personalized "
                    "business insights.",
              ),

              _policySection(
                "Data Security",
                "We use industry-standard encryption and security "
                    "protocols to protect your information from unauthorized "
                    "access, misuse or disclosure.",
              ),

              _policySection(
                "Third-Party Services",
                "SmartStock may integrate with trusted third-party "
                    "services such as payment gateways and cloud storage "
                    "providers to enhance system capabilities.",
              ),

              _policySection(
                "User Rights",
                "Users have the right to access, update or request "
                    "removal of their personal information stored in the "
                    "SmartStock platform.",
              ),

              const SizedBox(height: 20),

              /// ================= FOOTER =================

              const Center(
                child: Text(
                  "Last updated: February 2026",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// ================= POLICY CARD =================

  Widget _policySection(String title, String description) {

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: const Color(0xFF161A22),
        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            description,
            style: const TextStyle(
              color: Color(0xFFA1A6B3),
              height: 1.4,
            ),
          )
        ],
      ),
    );
  }
}