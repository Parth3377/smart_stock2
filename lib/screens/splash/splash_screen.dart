import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../dashboard/admin_dashboard_screen.dart';
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

  // ── Admin emails list — same as auth_service.dart ────────────────
  static const List<String> _adminEmails = ['admin@smartstock.com'];

  @override
  void initState() {
    super.initState();

    // ── Animation (same as original) ──────────────────────────────
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

    // ── After 2 seconds → decide where to go ──────────────────────
    // Reduced from 3s to 2s — navigation itself is now instant
    Timer(const Duration(seconds: 2), _navigate);
  }

  // ═══════════════════════════════════════════════════════════════
  //  NAVIGATION LOGIC
  //  FIX: Removed blocking Firestore await — was causing 10s delay.
  //  Admin check now uses email matching (instant, no network needed).
  //
  //  1. Check if user is already logged in (Firebase Auth — instant)
  //  2. If logged in → check email against admin list (instant)
  //  3. Admin email → Admin Dashboard
  //  4. Other email → Client Dashboard
  //  5. Not logged in → Login Screen
  // ═══════════════════════════════════════════════════════════════
  void _navigate() {
    if (!mounted) return;

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        // Nobody logged in → go to Login
        _goTo(const LoginScreen());
        return;
      }

      // Check admin by email — INSTANT, no Firestore await needed
      final isAdmin = _adminEmails.contains(
          user.email?.toLowerCase().trim() ?? '');

      if (isAdmin) {
        _goTo(const AdminDashboardScreen());
      } else {
        _goTo(const DashboardScreen());
      }

    } catch (e) {
      // Any error → go to Login
      _goTo(const LoginScreen());
    }
  }

  void _goTo(Widget screen) {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════
  //  UI — exactly same as original, nothing changed here
  // ═══════════════════════════════════════════════════════════════
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

            // BOUNCING LOGO — unchanged
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
                width: size.width * 0.40,
              ),
            ),

            const SizedBox(height: 50),

            // LOADING DOTS — unchanged
            const LoadingIndicator(),

          ],
        ),
      ),
    );
  }
}



// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../auth/login_screen.dart';
// import '../dashboard/dashboard_screen.dart';
// import '../dashboard/admin_dashboard_screen.dart';
// import '../../widgets/loading_indicator.dart';
//
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//
//   late AnimationController _controller;
//   late Animation<double> _bounce;
//
//   @override
//   void initState() {
//     super.initState();
//
//     // ── Animation (same as original) ──────────────────────────────
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1200),
//     );
//
//     _bounce = Tween<double>(begin: 0.95, end: 1.05).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: Curves.easeInOut,
//       ),
//     );
//
//     _controller.repeat(reverse: true);
//
//     // ── After 3 seconds → decide where to go ──────────────────────
//     Timer(const Duration(seconds: 3), _navigate);
//   }
//
//   // ═══════════════════════════════════════════════════════════════
//   //  NAVIGATION LOGIC
//   //  1. Check if user is already logged in (Firebase Auth)
//   //  2. If logged in → check if they are Admin (Firestore admins collection)
//   //  3. Admin → Admin Dashboard
//   //  4. Client → Client Dashboard
//   //  5. Not logged in → Login Screen
//   // ═══════════════════════════════════════════════════════════════
//   Future<void> _navigate() async {
//     if (!mounted) return;
//
//     try {
//       // Check Firebase Auth current user
//       final user = FirebaseAuth.instance.currentUser;
//
//       if (user == null) {
//         // Nobody logged in → go to Login
//         _goTo(const LoginScreen());
//         return;
//       }
//
//       // User is logged in → check if admin
//       final adminDoc = await FirebaseFirestore.instance
//           .collection('admins')
//           .doc(user.uid)
//           .get();
//
//       if (adminDoc.exists) {
//         // Admin user → Admin Dashboard
//         _goTo(const AdminDashboardScreen());
//       } else {
//         // Normal client → Client Dashboard
//         _goTo(const DashboardScreen());
//       }
//     } catch (e) {
//       // Any error (no internet etc.) → go to Login
//       _goTo(const LoginScreen());
//     }
//   }
//
//   void _goTo(Widget screen) {
//     if (!mounted) return;
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (_) => screen),
//     );
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   // ═══════════════════════════════════════════════════════════════
//   //  UI — exactly same as your original splash screen
//   // ═══════════════════════════════════════════════════════════════
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//
//     return Scaffold(
//       backgroundColor: const Color(0xFF0B0E14),
//
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               Color(0xFF0B0E14),
//               Color(0xFF101626),
//               Color(0xFF0B0E14),
//             ],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//
//             // BOUNCING LOGO
//             AnimatedBuilder(
//               animation: _bounce,
//               builder: (context, child) {
//                 return Transform.scale(
//                   scale: _bounce.value,
//                   child: child,
//                 );
//               },
//               child: Image.asset(
//                 "assets/logo.png",
//                 width: size.width * 0.40,
//               ),
//             ),
//
//             const SizedBox(height: 50),
//
//             // LOADING DOTS
//             const LoadingIndicator(),
//
//           ],
//         ),
//       ),
//     );
//   }
// }


// // ════════════════════════════════════════════════════════════════════
// //  lib/screens/splash/splash_screen.dart  — FIREBASE VERSION
// //
// //  Checks Firebase Auth state on startup.
// //  If already logged in → skip login, go directly to correct screen.
// //  UI is identical to the original.
// // ════════════════════════════════════════════════════════════════════
//
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../auth/login_screen.dart';
// import '../dashboard/dashboard_screen.dart';
// import '../dashboard/admin_dashboard_screen.dart';
// import '../../widgets/loading_indicator.dart';
//
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//
//   late AnimationController _controller;
//   late Animation<double> _bounce;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1200),
//     );
//     _bounce = Tween<double>(begin: 0.95, end: 1.05).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
//     );
//     _controller.repeat(reverse: true);
//
//     // Wait 2.5 seconds then decide navigation
//     Timer(const Duration(milliseconds: 2500), _navigate);
//   }
//
//   Future<void> _navigate() async {
//     if (!mounted) return;
//
//     final user = FirebaseAuth.instance.currentUser;
//
//     if (user == null) {
//       // Not logged in → go to login
//       _go(const LoginScreen());
//       return;
//     }
//
//     // Check if user is admin
//     try {
//       final doc = await FirebaseFirestore.instance
//           .collection('admins')
//           .doc(user.uid)
//           .get();
//
//       if (doc.exists) {
//         _go(const AdminDashboardScreen());
//       } else {
//         _go(const DashboardScreen());
//       }
//     } catch (_) {
//       _go(const LoginScreen());
//     }
//   }
//
//   void _go(Widget screen) {
//     if (!mounted) return;
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (_) => screen),
//     );
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
//     final size = MediaQuery.of(context).size;
//
//     return Scaffold(
//       backgroundColor: const Color(0xFF0B0E14),
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               Color(0xFF0B0E14),
//               Color(0xFF101626),
//               Color(0xFF0B0E14),
//             ],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             AnimatedBuilder(
//               animation: _bounce,
//               builder: (context, child) {
//                 return Transform.scale(scale: _bounce.value, child: child);
//               },
//               child: Image.asset("assets/logo.png", width: size.width * 0.40),
//             ),
//             const SizedBox(height: 50),
//             const LoadingIndicator(),
//           ],
//         ),
//       ),
//     );
//   }
// }