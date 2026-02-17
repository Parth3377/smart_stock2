import 'package:flutter/material.dart';

import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';

import '../screens/products/products_screen.dart'; // ⭐ IMPORTANT

import '../screens/orders/checkout_screen.dart';
import '../screens/payment/payment_screen.dart';
import '../screens/orders/order_success_screen.dart';



class AppRoutes {
  // ================= ROUTE NAMES =================
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';

  static const String products = '/products'; // ⭐ ADDED

  static const String checkout = '/checkout';
  static const String payment = '/payment';
  static const String orderSuccess = '/order-success';

  // ================= ROUTE GENERATOR =================
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _route(const SplashScreen());

      case login:
        return _route(const LoginScreen());

      case register:
        return _route(const RegisterScreen());

      case dashboard:
        return _route(const DashboardScreen());

      case products:
        return _route(const ProductsScreen()); // ⭐ ADDED

      case checkout:
        return _route(const CheckoutScreen());

      case payment:
        return _route(const PaymentScreen());

      case orderSuccess:
        return _route(const OrderSuccessScreen());

      default:
        return _errorRoute();
    }
  }

  // ================= COMMON ROUTE =================
  static MaterialPageRoute _route(Widget page) {
    return MaterialPageRoute(builder: (_) => page);
  }

  // ================= ERROR ROUTE =================
  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => const Scaffold(
        body: Center(
          child: Text(
            "Page not found",
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
