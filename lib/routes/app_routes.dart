import 'package:flutter/material.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/products/products_screen.dart';
import '../screens/order_draft/order_draft_screen.dart';
import '../screens/orders/checkout_screen.dart';
import '../screens/payment/payment_screen.dart';
import '../screens/orders/order_success_screen.dart';
import '../screens/orders/order_list_screen.dart';
import '../screens/settings/profile_screen.dart';
import '../screens/admin/admin_shell.dart';
import '../screens/favorites/favorites_screen.dart';

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
  static const String favorites = '/favorites';

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
      case dashboard:
        return MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
        );

      case checkout:
        return MaterialPageRoute(
          builder: (_) => const CheckoutScreen(),
        );

      case payment:
        return MaterialPageRoute(
          builder: (_) => const PaymentScreen(),
        );

      case orderSuccess:
        return MaterialPageRoute(
          builder: (_) => const OrderSuccessScreen(),
        );

      case AppRoutes.products:
        return MaterialPageRoute(
          builder: (_) => const ProductsScreen(),
        );

    // ── Missing routes — these were causing "Page not found" ────
      case orderDraft:
        return MaterialPageRoute(
          builder: (_) => const OrderDraftScreen(),
        );

      case profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
        );

      case orders:
        return MaterialPageRoute(
          builder: (_) => const OrderListScreen(),
        );

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


// import 'package:flutter/material.dart';
//
// // ════════════════════════════════════════════════════════════════════
// //  lib/routes/app_routes.dart  — UPDATED VERSION
// //
// //  ✅ All your existing routes are 100% untouched
// //  ✅ We only added the admin dashboard route at the bottom
// //  ✅ Copy-paste this file over your existing app_routes.dart
// // ════════════════════════════════════════════════════════════════════
//
// // ── Import your existing screens (keep all your existing imports) ──
// import '../screens/splash/splash_screen.dart';
// import '../screens/auth/login_screen.dart';
// import '../screens/auth/register_screen.dart';
// import '../screens/dashboard/dashboard_screen.dart';
// import '../screens/orders/checkout_screen.dart';
// import '../screens/payment/payment_screen.dart';
// import '../screens/orders/order_success_screen.dart';
//
// // ── Import your existing client screens (keep all yours) ──
// // import '../screens/dashboard/dashboard_screen.dart';
// import '../screens/products/products_screen.dart';
// // ... (keep all your existing imports exactly as they were
//
// import '../screens/admin/admin_shell.dart';
//
// class AppRoutes {
//   AppRoutes._();
//
//   static const String splash = '/';
//   static const String login = '/login';
//   static const String adminDashboard = '/admin';
//   static const String register = '/register';
//   static const String dashboard = '/dashboard';
//   static const String products       = '/products';
//   static const String orderDraft     = '/order-draft';
//   static const String checkout       = '/checkout';
//   static const String payment        = '/payment';
//   static const String orderSuccess   = '/order-success';
//   static const String profile        = '/profile';
//   static const String orders         = '/orders';
//   static const String settings       = '/settings';
//
//   // ... keep all your other route names exactly as they were
//
//   // ── Route generator (keep your existing routes, add admin below) ─
//   static Route<dynamic> onGenerateRoute(RouteSettings settings) {
//     switch (settings.name) {
//
//     // ── Your existing routes (keep all of these exactly as-is) ──
//       case splash:
//         return MaterialPageRoute(builder: (_) => const SplashScreen());
//       case login:
//         return MaterialPageRoute(builder: (_) => const LoginScreen());
//       case register:
//         return MaterialPageRoute(builder: (_) => const RegisterScreen());
//       case dashboard:
//         return MaterialPageRoute(
//           builder: (_) => const DashboardScreen(),
//         );
//
//       case checkout:
//         return MaterialPageRoute(
//           builder: (_) => const CheckoutScreen(),
//         );
//
//       case payment:
//         return MaterialPageRoute(
//           builder: (_) => const PaymentScreen(),
//         );
//
//       case orderSuccess:
//         return MaterialPageRoute(
//           builder: (_) => const OrderSuccessScreen(),
//         );
//
//       case AppRoutes.products:
//         return MaterialPageRoute(
//           builder: (_) => const ProductsScreen(),
//         );
//
//     // ── NEW: Admin dashboard route ───────────────────────────────
//       case adminDashboard:
//         return PageRouteBuilder(
//           settings: settings,
//           pageBuilder: (_, __, ___) => const AdminShell(),
//           transitionsBuilder: (_, anim, __, child) => FadeTransition(
//             opacity: anim,
//             child: child,
//           ),
//           transitionDuration: const Duration(milliseconds: 300),
//         );
//
//     // ── Your existing default/404 case ──────────────────────────
//       default:
//         return MaterialPageRoute(
//           builder: (_) => const Scaffold(
//             body: Center(child: Text('Page not found')),
//           ),
//         );
//     }
//   }
// }


// import 'package:flutter/material.dart';
// import '../screens/splash/splash_screen.dart';
// import '../screens/auth/login_screen.dart';
// import '../screens/auth/register_screen.dart';
// import '../screens/dashboard/dashboard_screen.dart';
// import '../screens/orders/checkout_screen.dart';
// import '../screens/payment/payment_screen.dart';
// import '../screens/orders/order_success_screen.dart';
// import '../screens/products/products_screen.dart';
// import '../screens/admin/admin_shell.dart';
//
// class AppRoutes {
//   AppRoutes._();
//
//   static const String splash        = '/';
//   static const String login         = '/login';
//   static const String register      = '/register';
//   static const String dashboard     = '/dashboard';
//   static const String products      = '/products';
//   static const String orderDraft    = '/order-draft';
//   static const String checkout      = '/checkout';
//   static const String payment       = '/payment';
//   static const String orderSuccess  = '/order-success';
//   static const String profile       = '/profile';
//   static const String orders        = '/orders';
//   static const String settings      = '/settings';
//   static const String adminDashboard = '/admin';
//
//   static Route<dynamic> onGenerateRoute(RouteSettings settings) {
//     switch (settings.name) {
//
//       case splash:
//         return MaterialPageRoute(builder: (_) => const SplashScreen());
//
//       case login:
//         return MaterialPageRoute(builder: (_) => const LoginScreen());
//
//       case register:
//         return MaterialPageRoute(builder: (_) => const RegisterScreen());
//
//       case dashboard:
//         return MaterialPageRoute(builder: (_) => const DashboardScreen());
//
//       case checkout:
//         return MaterialPageRoute(builder: (_) => const CheckoutScreen());
//
//       case payment:
//         return MaterialPageRoute(builder: (_) => const PaymentScreen());
//
//       case orderSuccess:
//         return MaterialPageRoute(builder: (_) => const OrderSuccessScreen());
//
//       case AppRoutes.products:
//         return MaterialPageRoute(builder: (_) => const ProductsScreen());
//
//       case adminDashboard:
//         return PageRouteBuilder(
//           settings: settings,
//           pageBuilder: (_, __, ___) => const AdminShell(),
//           transitionsBuilder: (_, anim, __, child) =>
//               FadeTransition(opacity: anim, child: child),
//           transitionDuration: const Duration(milliseconds: 300),
//         );
//
//       default:
//         return MaterialPageRoute(
//           builder: (_) => const Scaffold(
//             body: Center(child: Text('Page not found')),
//           ),
//         );
//     }
//   }
// }
