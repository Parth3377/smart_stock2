import 'package:flutter/material.dart';

/// AUTH
import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';

/// DASHBOARD + ORDERS
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/orders/order_list_screen.dart';
import 'screens/orders/order_detail_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Order & Inventory System',

      /// 🌙 Industrial Dark Theme (Global)
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F1218),

        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF2E6CF6),
          background: Color(0xFF0F1218),
          surface: Color(0xFF161A22),
        ),

        fontFamily: 'IBM Plex Sans',
      ),

      /// 🚀 Initial Entry → Splash
      initialRoute: '/',

      /// 🧭 Centralized Navigation Map
      routes: {
        /// AUTH
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),

        /// CLIENT FLOW
        '/dashboard': (context) => const DashboardScreen(),
        '/orders': (context) => const OrderListScreen(),

        /// NOTE:
        /// OrderDetailScreen requires an OrderModel,
        /// so it should be opened using:
        /// Navigator.push(...) instead of routes.
      },
    );
  }
}
