import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smart_stock2/providers/favorites_provider.dart';

import 'firebase_options.dart';
import 'routes/app_routes.dart';
import 'providers/order_draft_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/auth_provider.dart';
import 'core/theme_manager.dart';
import 'providers/admin_providers.dart';
import 'services/product_service.dart';
import 'providers/location_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Load products from Firestore in background after Firebase init
  ProductService.instance.loadFromFirestore();

  runApp(
    MultiProvider(
      providers: [

        // ── FIX: ProductService as ChangeNotifierProvider ─────────
        // dashboard_screen uses context.watch<ProductService>().products
        // This MUST be ChangeNotifierProvider so .watch() works
        ChangeNotifierProvider<ProductService>.value(
          value: ProductService.instance,
        ),

        // ── Client providers ──────────────────────────────────────
        ChangeNotifierProvider(create: (_) => OrderDraftProvider()),
        ChangeNotifierProvider(create: (_) => ThemeManager()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),

        // ── Firebase Auth provider ────────────────────────────────
        ChangeNotifierProvider(create: (_) => FirebaseAuthProvider()),

        // ── Location / Maps provider ──────────────────────────────
        ChangeNotifierProvider(create: (_) => LocationProvider()),

        // ── Admin providers ───────────────────────────────────────
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
    // ✅ Listen to ThemeManager so Dark Mode toggle actually works
    return Consumer<ThemeManager>(
      builder: (context, themeManager, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Order & Inventory System',

          // ── Dark theme (default) ─────────────────────────────
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0F1218),
            cardColor: const Color(0xFF161A22),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF2E6CF6),
              background: Color(0xFF0F1218),
              surface: Color(0xFF161A22),
            ),
            fontFamily: 'IBM Plex Sans',
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF161A22),
              foregroundColor: Colors.white,
              elevation: 0,
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'IBM Plex Sans',
              ),
            ),
          ),

          // ── Light theme ──────────────────────────────────────
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF4F6FA),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2E6CF6),
              background: Color(0xFFF4F6FA),
              surface: Colors.white,
            ),
            cardColor: Colors.white,
            fontFamily: 'IBM Plex Sans',
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFF1A1D26),
              elevation: 0,
              iconTheme: IconThemeData(color: Color(0xFF1A1D26)),
              titleTextStyle: TextStyle(
                color: Color(0xFF1A1D26),
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'IBM Plex Sans',
              ),
            ),
            textTheme: const TextTheme(
              bodyLarge:   TextStyle(color: Color(0xFF1A1D26)),
              bodyMedium:  TextStyle(color: Color(0xFF1A1D26)),
              bodySmall:   TextStyle(color: Color(0xFF6B7280)),
              titleLarge:  TextStyle(color: Color(0xFF1A1D26), fontWeight: FontWeight.w600),
              titleMedium: TextStyle(color: Color(0xFF1A1D26)),
            ),
            switchTheme: SwitchThemeData(
              thumbColor: MaterialStateProperty.all(Colors.white),
              trackColor: MaterialStateProperty.resolveWith((states) =>
              states.contains(MaterialState.selected)
                  ? const Color(0xFF2E6CF6)
                  : Colors.black26),
            ),
          ),

          // ✅ This is what makes the toggle actually work
          themeMode: themeManager.isDark ? ThemeMode.dark : ThemeMode.light,

          initialRoute: AppRoutes.splash,
          onGenerateRoute: AppRoutes.onGenerateRoute,
        );
      },
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:smart_stock2/providers/favorites_provider.dart';
//
// import 'firebase_options.dart';
// import 'routes/app_routes.dart';
// import 'providers/order_draft_provider.dart';
// import 'providers/notification_provider.dart';
// import 'providers/auth_provider.dart';
// import 'core/theme_manager.dart';
// import 'providers/admin_providers.dart';
// import 'services/product_service.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // Initialize Firebase
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//
//   // Load products from Firestore in background after Firebase init
//   ProductService.instance.loadFromFirestore();
//
//   runApp(
//     MultiProvider(
//       providers: [
//
//         // ── FIX: ProductService as ChangeNotifierProvider ─────────
//         // dashboard_screen uses context.watch<ProductService>().products
//         // This MUST be ChangeNotifierProvider so .watch() works
//         ChangeNotifierProvider<ProductService>.value(
//           value: ProductService.instance,
//         ),
//
//         // ── Client providers ──────────────────────────────────────
//         ChangeNotifierProvider(create: (_) => OrderDraftProvider()),
//         ChangeNotifierProvider(create: (_) => ThemeManager()),
//         ChangeNotifierProvider(create: (_) => FavoritesProvider()),
//         ChangeNotifierProvider(create: (_) => NotificationProvider()),
//
//         // ── Firebase Auth provider ────────────────────────────────
//         ChangeNotifierProvider(create: (_) => FirebaseAuthProvider()),
//
//         // ── Admin providers ───────────────────────────────────────
//         ChangeNotifierProvider(create: (_) => AdminAuthProvider()),
//         ChangeNotifierProvider(create: (_) => AdminNavProvider()),
//         ChangeNotifierProvider(create: (_) => AdminDashboardProvider()),
//         ChangeNotifierProvider(create: (_) => AdminProductsProvider()),
//         ChangeNotifierProvider(create: (_) => AdminOrdersProvider()),
//         ChangeNotifierProvider(create: (_) => AdminSuppliersProvider()),
//         ChangeNotifierProvider(create: (_) => AdminTransferProvider()),
//         ChangeNotifierProvider(create: (_) => AdminProfileProvider()),
//       ],
//       child: const MyApp(),
//     ),
//   );
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Order & Inventory System',
//
//       theme: ThemeData(
//         brightness: Brightness.dark,
//         scaffoldBackgroundColor: const Color(0xFF0F1218),
//         colorScheme: const ColorScheme.dark(
//           primary: Color(0xFF2E6CF6),
//           background: Color(0xFF0F1218),
//           surface: Color(0xFF161A22),
//         ),
//         fontFamily: 'IBM Plex Sans',
//       ),
//
//       themeMode: ThemeMode.dark,
//       initialRoute: AppRoutes.splash,
//       onGenerateRoute: AppRoutes.onGenerateRoute,
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:smart_stock2/providers/favorites_provider.dart';
//
// import 'firebase_options.dart';
// import 'routes/app_routes.dart';
// import 'providers/order_draft_provider.dart';
// import 'providers/notification_provider.dart';
// import 'core/theme_manager.dart';
// import 'providers/admin_providers.dart';
// import 'services/product_service.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // Initialize Firebase
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//
//   runApp(
//     MultiProvider(
//       providers: [
//         // ── Existing client providers ─────────────────────────────
//         ChangeNotifierProvider(create: (_) => OrderDraftProvider()),
//         ChangeNotifierProvider(create: (_) => ThemeManager()),
//         ChangeNotifierProvider(create: (_) => FavoritesProvider()),
//         ChangeNotifierProvider(create: (_) => NotificationProvider()),
//
//         // ── FIX: ProductService as Provider (not ChangeNotifier) ──
//         // This fixes "Provider<ProductService> not found" error
//         // that happens when DashboardScreen is navigated to
//         Provider<ProductService>(create: (_) => ProductService()),
//
//         // ── Admin providers ───────────────────────────────────────
//         ChangeNotifierProvider(create: (_) => AdminAuthProvider()),
//         ChangeNotifierProvider(create: (_) => AdminNavProvider()),
//         ChangeNotifierProvider(create: (_) => AdminDashboardProvider()),
//         ChangeNotifierProvider(create: (_) => AdminProductsProvider()),
//         ChangeNotifierProvider(create: (_) => AdminOrdersProvider()),
//         ChangeNotifierProvider(create: (_) => AdminSuppliersProvider()),
//         ChangeNotifierProvider(create: (_) => AdminTransferProvider()),
//         ChangeNotifierProvider(create: (_) => AdminProfileProvider()),
//       ],
//       child: const MyApp(),
//     ),
//   );
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Order & Inventory System',
//
//       theme: ThemeData(
//         brightness: Brightness.dark,
//         scaffoldBackgroundColor: const Color(0xFF0F1218),
//         colorScheme: const ColorScheme.dark(
//           primary: Color(0xFF2E6CF6),
//           background: Color(0xFF0F1218),
//           surface: Color(0xFF161A22),
//         ),
//         fontFamily: 'IBM Plex Sans',
//       ),
//
//       themeMode: ThemeMode.dark,
//       initialRoute: AppRoutes.splash,
//       onGenerateRoute: AppRoutes.onGenerateRoute,
//     );
//   }
// }