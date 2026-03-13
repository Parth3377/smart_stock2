import 'package:flutter/material.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1218),

      appBar: AppBar(
        title: const Text("Security Center"),
        backgroundColor: const Color(0xFF161A22),
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// ================= SECURITY STATUS =================
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E6CF6), Color(0xFF4B8BFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
              ),

              child: Row(
                children: [

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.security,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),

                  const SizedBox(width: 16),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(
                          "SmartStock Security v3.2 Active",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        SizedBox(height: 4),

                        Text(
                          "Your data & orders are fully protected.",
                          style: TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 28),

            /// ================= PROTECTION MODULES =================

            const Text(
              "Protection Modules",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            _moduleCard(
              icon: Icons.lock,
              title: "Account Protection",
              desc:
              "Your account is secured with encrypted authentication and session monitoring.",
            ),

            _moduleCard(
              icon: Icons.shield,
              title: "Transaction Security",
              desc:
              "All inventory purchases are protected with secured billing and encrypted processing.",
            ),

            _moduleCard(
              icon: Icons.devices,
              title: "Device Protection",
              desc:
              "Login activity and devices are monitored continuously to prevent unauthorized access.",
            ),

            const SizedBox(height: 28),

            /// ================= SECURITY UPDATES =================

            const Text(
              "Security Updates",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            _updateCard(
              icon: Icons.check_circle,
              title: "Last Scan",
              status: "No threats found",
              color: Colors.green,
            ),

            _updateCard(
              icon: Icons.lock,
              title: "System Encryption",
              status: "Active",
              color: const Color(0xFF2E6CF6),
            ),

            _updateCard(
              icon: Icons.system_update,
              title: "Security Patch",
              status: "Updated 3 days ago",
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  /// ================= MODULE CARD =================

  Widget _moduleCard({
    required IconData icon,
    required String title,
    required String desc,
  }) {

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
              color: const Color(0xFF2E6CF6).withValues(alpha: 0.15),
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

                const SizedBox(height: 4),

                Text(
                  desc,
                  style: const TextStyle(
                    color: Color(0xFFA1A6B3),
                    fontSize: 13,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  /// ================= UPDATE CARD =================

  Widget _updateCard({
    required IconData icon,
    required String title,
    required String status,
    required Color color,
  }) {

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: const Color(0xFF161A22),
        borderRadius: BorderRadius.circular(16),
      ),

      child: Row(
        children: [

          Icon(icon, color: color),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.white),
            ),
          ),

          Text(
            status,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }
}