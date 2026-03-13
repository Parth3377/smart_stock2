import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_stock2/providers/favorites_provider.dart';

import 'routes/app_routes.dart';
import 'providers/order_draft_provider.dart';
import 'providers/notification_provider.dart';
import 'core/theme_manager.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => OrderDraftProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => ThemeManager(),
        ),

        ChangeNotifierProvider(
            create: (_) => FavoritesProvider()
        ),

        ChangeNotifierProvider(
          create: (_) => NotificationProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      debugShowCheckedModeBanner: false,

      title: 'Order & Inventory System',

      /// 🌙 Global Dark Theme
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

      themeMode: ThemeMode.dark,

      /// ⭐ SmartStock Routing System
      initialRoute: AppRoutes.splash,

      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}