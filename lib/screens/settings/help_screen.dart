import 'package:flutter/material.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fade = Tween<double>(begin: 0, end: 1).animate(_controller);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        title: Text("Help & Support"),
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
      ),

      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,

          child: ListView(
            padding: const EdgeInsets.all(16),

            children: [

              /// ================= SUPPORT HEADER =================

              Container(
                padding: const EdgeInsets.all(22),

                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E6CF6), Color(0xFF4B8BFF)],
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),

                child: Row(
                  children: [

                    Icon(Icons.support_agent,
                        size: 42,
                        color: Colors.white),

                    SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Text(
                            "SmartStock Support",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),

                          SizedBox(height: 4),

                          Text(
                            "We're here to help you manage orders, inventory and payments smoothly.",
                            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 28),

              /// ================= QUICK HELP =================

              Text(
                "Quick Help",
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              _helpCard(
                icon: Icons.shopping_cart,
                title: "How to place an order?",
                desc:
                "Browse products → Add to cart → Checkout → Complete payment.",
              ),

              _helpCard(
                icon: Icons.payment,
                title: "Payment options",
                desc:
                "You can pay using Card, UPI or other secure payment methods.",
              ),

              _helpCard(
                icon: Icons.inventory,
                title: "Inventory tracking",
                desc:
                "SmartStock automatically tracks stock levels after every order.",
              ),

              const SizedBox(height: 28),

              /// ================= CONTACT SUPPORT =================

              Text(
                "Contact Support",
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              _contactCard(
                icon: Icons.email,
                title: "Email Support",
                subtitle: "admin@smartstock.com",
              ),

              _contactCard(
                icon: Icons.phone,
                title: "Call Support",
                subtitle: "+91 93288 25315",
              ),

              _contactCard(
                icon: Icons.chat,
                title: "Live Chat",
                subtitle: "Available 9 AM – 6 PM",
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// ================= HELP CARD =================

  Widget _helpCard({
    required IconData icon,
    required String title,
    required String desc,
  }) {

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
            child: Icon(icon, color: Color(0xFF2E6CF6)),
          ),

          SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  desc,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
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

  /// ================= CONTACT CARD =================

  Widget _contactCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
      ),

      child: Row(
        children: [

          Icon(icon, color: Color(0xFF2E6CF6)),

          SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  subtitle,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                )
              ],
            ),
          ),

          Icon(Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(context).textTheme.bodySmall?.color),
        ],
      ),
    );
  }
}


// import 'package:flutter/material.dart';
//
// class HelpScreen extends StatefulWidget {
//   const HelpScreen({super.key});
//
//   @override
//   State<HelpScreen> createState() => _HelpScreenState();
// }
//
// class _HelpScreenState extends State<HelpScreen>
//     with SingleTickerProviderStateMixin {
//
//   late AnimationController _controller;
//   late Animation<double> _fade;
//   late Animation<Offset> _slide;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 700),
//     );
//
//     _fade = Tween<double>(begin: 0, end: 1).animate(_controller);
//
//     _slide = Tween<Offset>(
//       begin: const Offset(0, 0.2),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
//
//     _controller.forward();
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Scaffold(
//       backgroundColor: const Color(0xFF0F1218),
//
//       appBar: AppBar(
//         title: const Text("Help & Support"),
//         backgroundColor: const Color(0xFF161A22),
//         elevation: 0,
//       ),
//
//       body: FadeTransition(
//         opacity: _fade,
//         child: SlideTransition(
//           position: _slide,
//
//           child: ListView(
//             padding: const EdgeInsets.all(16),
//
//             children: [
//
//               /// ================= SUPPORT HEADER =================
//
//               Container(
//                 padding: const EdgeInsets.all(22),
//
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                     colors: [Color(0xFF2E6CF6), Color(0xFF4B8BFF)],
//                   ),
//                   borderRadius: BorderRadius.circular(22),
//                 ),
//
//                 child: const Row(
//                   children: [
//
//                     Icon(Icons.support_agent,
//                         size: 42,
//                         color: Colors.white),
//
//                     SizedBox(width: 16),
//
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//
//                           Text(
//                             "SmartStock Support",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 18,
//                             ),
//                           ),
//
//                           SizedBox(height: 4),
//
//                           Text(
//                             "We're here to help you manage orders, inventory and payments smoothly.",
//                             style: TextStyle(color: Colors.white70),
//                           ),
//                         ],
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//
//               const SizedBox(height: 28),
//
//               /// ================= QUICK HELP =================
//
//               const Text(
//                 "Quick Help",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//
//               const SizedBox(height: 16),
//
//               _helpCard(
//                 icon: Icons.shopping_cart,
//                 title: "How to place an order?",
//                 desc:
//                 "Browse products → Add to cart → Checkout → Complete payment.",
//               ),
//
//               _helpCard(
//                 icon: Icons.payment,
//                 title: "Payment options",
//                 desc:
//                 "You can pay using Card, UPI or other secure payment methods.",
//               ),
//
//               _helpCard(
//                 icon: Icons.inventory,
//                 title: "Inventory tracking",
//                 desc:
//                 "SmartStock automatically tracks stock levels after every order.",
//               ),
//
//               const SizedBox(height: 28),
//
//               /// ================= CONTACT SUPPORT =================
//
//               const Text(
//                 "Contact Support",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//
//               const SizedBox(height: 16),
//
//               _contactCard(
//                 icon: Icons.email,
//                 title: "Email Support",
//                 subtitle: "support@smartstock.com",
//               ),
//
//               _contactCard(
//                 icon: Icons.phone,
//                 title: "Call Support",
//                 subtitle: "+91 98765 43210",
//               ),
//
//               _contactCard(
//                 icon: Icons.chat,
//                 title: "Live Chat",
//                 subtitle: "Available 9 AM – 6 PM",
//               ),
//
//               const SizedBox(height: 24),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   /// ================= HELP CARD =================
//
//   Widget _helpCard({
//     required IconData icon,
//     required String title,
//     required String desc,
//   }) {
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(16),
//
//       decoration: BoxDecoration(
//         color: const Color(0xFF161A22),
//         borderRadius: BorderRadius.circular(18),
//       ),
//
//       child: Row(
//         children: [
//
//           Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: const Color(0xFF2E6CF6).withValues(alpha: 0.15),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(icon, color: const Color(0xFF2E6CF6)),
//           ),
//
//           const SizedBox(width: 14),
//
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//
//                 const SizedBox(height: 4),
//
//                 Text(
//                   desc,
//                   style: const TextStyle(
//                     color: Color(0xFFA1A6B3),
//                     fontSize: 13,
//                   ),
//                 )
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }
//
//   /// ================= CONTACT CARD =================
//
//   Widget _contactCard({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//   }) {
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(16),
//
//       decoration: BoxDecoration(
//         color: const Color(0xFF161A22),
//         borderRadius: BorderRadius.circular(18),
//       ),
//
//       child: Row(
//         children: [
//
//           Icon(icon, color: const Color(0xFF2E6CF6)),
//
//           const SizedBox(width: 12),
//
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//
//                 Text(
//                   subtitle,
//                   style: const TextStyle(
//                     color: Color(0xFFA1A6B3),
//                   ),
//                 )
//               ],
//             ),
//           ),
//
//           const Icon(Icons.arrow_forward_ios,
//               size: 16,
//               color: Colors.white54),
//         ],
//       ),
//     );
//   }
// }