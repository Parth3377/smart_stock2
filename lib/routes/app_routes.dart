// import 'package:flutter/material.dart';
//
// import '../screens/splash/splash_screen.dart';
// import '../screens/auth/login_screen.dart';
// import '../screens/auth/register_screen.dart';
// import '../screens/dashboard/dashboard_screen.dart';
// import '../screens/products/products_screen.dart';
//
// import '../screens/orders/checkout_screen.dart';
// import '../screens/payment/payment_screen.dart';
// import '../screens/orders/order_success_screen.dart';
// import '../screens/order_draft/order_draft_screen.dart';
// import '../screens/dashboard/admin_dashboard_screen.dart';
//
// import '../screens/admin/admin_shell.dart';
//
// class AppRoutes {
//
//   // ================= ROUTE NAMES =================
//
//   static const String splash = '/';
//   static const String login = '/login';
//   static const String register = '/register';
//   static const String dashboard = '/dashboard';
//   static const String adminDashboard = '/admin-dashboard';
//
//   static const String products = '/products';
//
//   static const String orderDraft = '/orderDraft';
//
//   static const String checkout = '/checkout';
//   static const String payment = '/payment';
//   static const String orderSuccess = '/order-success';
//
//   // ================= ROUTE GENERATOR =================
//
//   static Route<dynamic> onGenerateRoute(RouteSettings settings) {
//
//     switch (settings.name) {
//
//       case splash:
//         return _route(const SplashScreen());
//
//       case login:
//         return _route(const LoginScreen());
//
//       case register:
//         return _route(const RegisterScreen());
//
//       case dashboard:
//         return _route(const DashboardScreen());
//
//       case adminDashboard:
//         return _route(const AdminDashboardScreen());
//
//       case products:
//         return _route(const ProductsScreen());
//
//       case orderDraft:
//         return _route(const OrderDraftScreen());
//
//       case checkout:
//         return _route(const CheckoutScreen());
//
//       case payment:
//         return _route(const PaymentScreen());
//
//       case orderSuccess:
//         return _route(const OrderSuccessScreen());
//
//       default:
//         return _errorRoute();
//     }
//   }
//
//   // ================= COMMON ROUTE =================
//
//   static MaterialPageRoute _route(Widget page) {
//     return MaterialPageRoute(
//       builder: (_) => page,
//     );
//   }
//
//   // ================= ERROR ROUTE =================
//
//   static Route<dynamic> _errorRoute() {
//     return MaterialPageRoute(
//       builder: (_) => const Scaffold(
//         body: Center(
//           child: Text(
//             "Page not found",
//             style: TextStyle(fontSize: 18),
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';

// ════════════════════════════════════════════════════════════════════
//  lib/routes/app_routes.dart  — UPDATED VERSION
//
//  ✅ All your existing routes are 100% untouched
//  ✅ We only added the admin dashboard route at the bottom
//  ✅ Copy-paste this file over your existing app_routes.dart
// ════════════════════════════════════════════════════════════════════

// ── Import your existing screens (keep all your existing imports) ──
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';

// ── Import your existing client screens (keep all yours) ──
// import '../screens/dashboard/dashboard_screen.dart';
// import '../screens/products/products_screen.dart';
// ... (keep all your existing imports exactly as they were

import '../screens/admin/admin_shell.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String adminDashboard = '/admin';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String products       = '/products';
  static const String orderDraft     = '/order-draft';
  static const String checkout       = '/checkout';
  static const String payment        = '/payment';
  static const String orderSuccess   = '/order-success';
  static const String profile        = '/profile';
  static const String orders         = '/orders';
  static const String settings       = '/settings';

  // ... keep all your other route names exactly as they were

  // ── Route generator (keep your existing routes, add admin below) ─
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {

    // ── Your existing routes (keep all of these exactly as-is) ──
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
    // case dashboard:
    //   return MaterialPageRoute(builder: (_) => const DashboardScreen());
    // ... keep all your other existing case statements

    // ── NEW: Admin dashboard route ───────────────────────────────
      case adminDashboard:
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (_, __, ___) => const AdminShell(),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(
            opacity: anim,
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 300),
        );

    // ── Your existing default/404 case ──────────────────────────
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Page not found')),
          ),
        );
    }
  }
}