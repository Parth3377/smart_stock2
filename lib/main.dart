import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_stock2/providers/favorites_provider.dart';

import 'routes/app_routes.dart';
import 'providers/order_draft_provider.dart';
import 'providers/notification_provider.dart';
import 'core/theme_manager.dart';

// ── NEW: Add this one import ──────────────────────────────────────
import 'providers/admin_providers.dart';

// ════════════════════════════════════════════════════════════════════
//  main.dart  — UPDATED (minimal change)
//
//  The only change from your original:
//  1. Added import for admin_providers.dart
//  2. Added 5 admin ChangeNotifierProviders to MultiProvider list
//  3. Everything else is IDENTICAL to your original main.dart
// ════════════════════════════════════════════════════════════════════

void main() {
  runApp(
    MultiProvider(
      providers: [
        // ── Your existing providers (100% unchanged) ──────────────
        ChangeNotifierProvider(
          create: (_) => OrderDraftProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeManager(),
        ),
        ChangeNotifierProvider(
          create: (_) => FavoritesProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(),
        ),

        // ── NEW: Admin providers (just add these below yours) ─────
        ChangeNotifierProvider(create: (_) => AdminAuthProvider()),
        ChangeNotifierProvider(create: (_) => AdminNavProvider()),
        ChangeNotifierProvider(create: (_) => AdminDashboardProvider()),
        ChangeNotifierProvider(create: (_) => AdminProductsProvider()),
        ChangeNotifierProvider(create: (_) => AdminOrdersProvider()),
        ChangeNotifierProvider(create: (_) => AdminSuppliersProvider()),
        ChangeNotifierProvider(create: (_) => AdminTransferProvider()),
        ChangeNotifierProvider(create: (_) => AdminProfileProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ── Your existing MyApp build (100% unchanged) ─────────────────
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