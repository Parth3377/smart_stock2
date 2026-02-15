import 'package:flutter/material.dart';
import 'routes/app_routes.dart';

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

      /// 🌙 Global dark theme
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

      /// ⭐ ADVANCED ROUTING
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
