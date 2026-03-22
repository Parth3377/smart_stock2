// ════════════════════════════════════════════════════════════════════
//  lib/screens/dashboard/dashboard_screen.dart
//
//  Connected to Firebase Auth + Firestore:
//  ✅ Real user name from Firebase Auth
//  ✅ My Orders count from Firestore stream
//  ✅ Notification bell with unread badge → opens Notifications
//  ✅ Products from ProductService (Firestore or local)
// ════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../widgets/cart_badge.dart';
import '../../models/product_model.dart';
import '../../providers/order_draft_provider.dart';
import '../../providers/notification_provider.dart';
import '../../services/product_service.dart';
import '../../services/order_service.dart';
import '../products/products_screen.dart';
import '../order_draft/order_draft_screen.dart';
import '../orders/order_list_screen.dart';
import '../favorites/favorites_screen.dart';
import '../../providers/favorites_provider.dart';
import '../settings/profile_screen.dart';
import '../settings/notifications_screen.dart';
import '../../core/helpers.dart';
import '../../widgets/glass_bottom_navbar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  @override
  void initState() {
    super.initState();
    // Load notifications from Firestore
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadFromFirestore();
    });
  }

  String get greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  // Get initials from display name: "Parth Chauhan" → "PC"
  String _initials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final user      = FirebaseAuth.instance.currentUser;
    final userName  = user?.displayName ?? user?.email?.split('@')[0] ?? 'User';
    final products  = context.watch<ProductService>().products;
    final notifProv = context.watch<NotificationProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      bottomNavigationBar: GlassBottomNavbar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProductsScreen()));
          if (index == 2) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OrderDraftScreen()));
          if (index == 3) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
        },
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(children: [

            // ── HEADER ───────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0B3C5D), Color(0xFF2E6CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft:  Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(greeting, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(
                      'Hi, ${userName.split(' ')[0]}! 👋',
                      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 24,
                          fontWeight: FontWeight.w900),
                    ),
                  ]),

                  Row(children: [

                    // ── Notification Bell with Badge ──────────────────
                    GestureDetector(
                      onTap: () {
                        notifProv.markAllRead();
                        Navigator.push(context, MaterialPageRoute(
                            builder: (_) => const NotificationsScreen()));
                      },
                      child: Stack(children: [
                        const Icon(Icons.notifications_none,
                            color: Colors.white, size: 26),
                        if (notifProv.hasUnread)
                          Positioned(
                            right: 0, top: 0,
                            child: Container(
                              width: 9, height: 9,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ]),
                    ),

                    const SizedBox(width: 14),

                    // ── Cart Bell with Badge ──────────────────
                    GestureDetector(
                      onTap: () {
                        notifProv.markAllRead();
                        Navigator.push(context, MaterialPageRoute(
                            builder: (_) => const OrderDraftScreen()));
                      },
                      child: Stack(children: [
                        const Icon(Icons.shopping_cart_outlined,
                            color: Colors.white, size: 26),
                        if (notifProv.hasUnread)
                          Positioned(
                            right: 0, top: 0,
                            child: Container(
                              width: 9, height: 9,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ]),
                    ),
                    //const CartBadge(),
                  ]),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const _CurvedSurface(),
            const SizedBox(height: 16),

            // ── INFO CARDS ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [

                // My Orders — real count from Firestore
                Expanded(
                  child: StreamBuilder<int>(
                    stream: OrderService.streamOrderCount(),
                    builder: (ctx, snap) {
                      final count = snap.data ?? OrderService.orders.length;
                      return GestureDetector(
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const OrderListScreen())),
                        child: _AnimatedInfoCard(
                          title:    'My Orders',
                          value:    count.toString(),
                          icon:     Icons.shopping_cart_outlined,
                          gradient: const [Color(0xFF2C7A7B), Color(0xFF38A3A5)],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 16),

                // Cart Items — from local provider
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const OrderDraftScreen())),
                    child: _AnimatedInfoCard(
                      title:    'Cart Items',
                      value:    context.watch<OrderDraftProvider>().items.length.toString(),
                      icon:     Icons.receipt_long_outlined,
                      gradient: const [Color(0xFFB45309), Color(0xFFF59E0B)],
                    ),
                  ),
                ),

              ]),
            ),

            const SizedBox(height: 24),

            // ── QUICK ACTIONS ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Quick Actions', style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 18,
                      fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _QuickAction(icon: Icons.inventory_2_outlined, label: 'Products',
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductsScreen()))),
                      _QuickAction(icon: Icons.shopping_cart_outlined,  label: 'Cart',
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderDraftScreen()))),
                      _QuickAction(icon: Icons.favorite_border_outlined, label: 'Favorites',
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen()))),
                      _QuickAction(icon: Icons.history_outlined,          label: 'History',
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderListScreen()))),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── POPULAR PRODUCTS ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Popular Products', style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 18,
                      fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: products.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.72,
                    ),
                    itemBuilder: (ctx, i) {
                      final p = products[i];
                      return _ProductCard(
                        product: p,
                        onAdd: () {
                          final cart = ctx.read<OrderDraftProvider>();
                          cart.addProduct(p);
                          ctx.read<NotificationProvider>().addNotification(
                            title:   '🛒 Added to Cart',
                            body:    '${p.name} has been added to your cart.',
                            type:    'cart_add',
                          );
                          showAddToCartPopup(ctx, p);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ]),
        ),
      ),
    );
  }
}

// ── Curved decorative surface ──────────────────────────────────────
class _CurvedSurface extends StatelessWidget {
  const _CurvedSurface();
  @override
  Widget build(BuildContext context) => Container(
    height: 6,
    margin: const EdgeInsets.symmetric(horizontal: 60),
    decoration: BoxDecoration(
      color: const Color(0xFF2E6CF6).withOpacity(0.25),
      borderRadius: BorderRadius.circular(10),
    ),
  );
}

// ── Info card ─────────────────────────────────────────────────────
class _AnimatedInfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final List<Color> gradient;

  const _AnimatedInfoCard({
    required this.title, required this.value,
    required this.icon,  required this.gradient,
  });

  @override
  Widget build(BuildContext context) => Container(
    height: 110,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: gradient,
          begin: Alignment.topLeft, end: Alignment.bottomRight),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(title, style: TextStyle(color: Colors.white70, fontSize: 13)),
          Icon(icon, color: Colors.white70, size: 22),
        ]),
        Text(value, style: TextStyle(color: Colors.white,
            fontSize: 32, fontWeight: FontWeight.bold)),
      ],
    ),
  );
}

// ── Quick action button ────────────────────────────────────────────
class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Column(children: [
      Container(
        width: 56, height: 56,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: Color(0xFF2E6CF6), size: 24),
      ),
      const SizedBox(height: 8),
      Text(label, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 12)),
    ]),
  );
}

// ── Product card — 4-per-row with hover animation ──────────────────
class _ProductCard extends StatefulWidget {
  final ProductModel product;
  final VoidCallback onAdd;
  const _ProductCard({required this.product, required this.onAdd});

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _hovering = false;

  void _flyHeart(BuildContext context) {
    final overlay = Overlay.of(context);
    final box     = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final pos = box.localToGlobal(Offset.zero);
    final entry = OverlayEntry(
      builder: (_) => Positioned(
        left: pos.dx + box.size.width / 2 - 18,
        top:  pos.dy + box.size.height / 2 - 18,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: -100),
          duration: const Duration(milliseconds: 700),
          builder: (_, val, child) => Transform.translate(
            offset: Offset(0, val),
            child: Opacity(opacity: 1 - (val.abs() / 100), child: child),
          ),
          child: const Icon(Icons.favorite, color: Colors.red, size: 36),
        ),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(milliseconds: 720), entry.remove);
  }

  @override
  Widget build(BuildContext context) {
    final isFav = context.watch<FavoritesProvider>().isFavorite(widget.product);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit:  (_) => setState(() => _hovering = false),
      child: AnimatedScale(
        scale:    _hovering ? 1.04 : 1.0,
        duration: const Duration(milliseconds: 180),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_hovering ? 0.45 : 0.2),
                blurRadius: _hovering ? 24 : 10,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Stack(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(widget.product.image, fit: BoxFit.cover,
                      width: double.infinity, height: double.infinity,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.white10,
                        child: const Icon(Icons.image_not_supported,
                            color: Colors.white30),
                      )),
                ),
                Positioned(
                  top: 4, right: 4,
                  child: GestureDetector(
                    onTap: () {
                      context.read<FavoritesProvider>()
                          .toggleFavorite(widget.product);
                      _flyHeart(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? Colors.red : Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 5),
            Text(widget.product.name, maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 2),
            Text('₹${widget.product.price.toStringAsFixed(0)}',
                style: const TextStyle(color: Color(0xFF2E6CF6),
                    fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 5),
            SizedBox(
              width: double.infinity, height: 26,
              child: ElevatedButton(
                onPressed: widget.onAdd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E6CF6),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7)),
                ),
                child: const Text('+ Add', style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w900,
                    color: Colors.black)),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// import '../../widgets/cart_badge.dart';
// import '../../models/product_model.dart';
// import '../../providers/order_draft_provider.dart';
// import '../../providers/notification_provider.dart';
// import '../../services/product_service.dart';
// import '../../services/order_service.dart';
// import '../products/products_screen.dart';
// import '../order_draft/order_draft_screen.dart';
// import '../orders/order_list_screen.dart';
// import '../favorites/favorites_screen.dart';
// import '../../providers/favorites_provider.dart';
// import '../settings/profile_screen.dart';
// import '../settings/notifications_screen.dart';
// import '../../core/helpers.dart';
// import '../../widgets/glass_bottom_navbar.dart';
//
// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({super.key});
//
//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }
//
// class _DashboardScreenState extends State<DashboardScreen> {
//
//   @override
//   void initState() {
//     super.initState();
//     // Load notifications from Firestore
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<NotificationProvider>().loadFromFirestore();
//     });
//   }
//
//   String get greeting {
//     final h = DateTime.now().hour;
//     if (h < 12) return 'Good Morning';
//     if (h < 17) return 'Good Afternoon';
//     return 'Good Evening';
//   }
//
//   // Get initials from display name: "Parth Chauhan" → "PC"
//   String _initials(String? name) {
//     if (name == null || name.isEmpty) return '?';
//     final parts = name.trim().split(' ');
//     if (parts.length >= 2) {
//       return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
//     }
//     return parts[0][0].toUpperCase();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final user      = FirebaseAuth.instance.currentUser;
//     final userName  = user?.displayName ?? user?.email?.split('@')[0] ?? 'User';
//     final products  = context.watch<ProductService>().products;
//     final notifProv = context.watch<NotificationProvider>();
//
//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//
//       bottomNavigationBar: GlassBottomNavbar(
//         currentIndex: 0,
//         onTap: (index) {
//           if (index == 1) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProductsScreen()));
//           if (index == 2) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OrderDraftScreen()));
//           if (index == 3) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
//         },
//       ),
//
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(children: [
//
//             // ── HEADER ───────────────────────────────────────────────
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [Color(0xFF0B3C5D), Color(0xFF2E6CF6)],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: BorderRadius.only(
//                   bottomLeft:  Radius.circular(28),
//                   bottomRight: Radius.circular(28),
//                 ),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//
//                   Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                     Text(greeting, style: const TextStyle(color: Colors.white70, fontSize: 13)),
//                     const SizedBox(height: 4),
//                     Text(
//                       'Hi, ${userName.split(' ')[0]}! 👋',
//                       style: const TextStyle(color: Colors.white, fontSize: 20,
//                           fontWeight: FontWeight.w600),
//                     ),
//                   ]),
//
//                   Row(children: [
//
//                     // ── Notification Bell with Badge ──────────────────
//                     GestureDetector(
//                       onTap: () {
//                         notifProv.markAllRead();
//                         Navigator.push(context, MaterialPageRoute(
//                             builder: (_) => const NotificationsScreen()));
//                       },
//                       child: Stack(children: [
//                         const Icon(Icons.notifications_none,
//                             color: Colors.white, size: 26),
//                         if (notifProv.hasUnread)
//                           Positioned(
//                             right: 0, top: 0,
//                             child: Container(
//                               width: 9, height: 9,
//                               decoration: const BoxDecoration(
//                                 color: Colors.red,
//                                 shape: BoxShape.circle,
//                               ),
//                             ),
//                           ),
//                       ]),
//                     ),
//
//                     const SizedBox(width: 14),
//
//                     // ── Cart Bell with Badge ──────────────────
//                     GestureDetector(
//                       onTap: () {
//                         notifProv.markAllRead();
//                         Navigator.push(context, MaterialPageRoute(
//                             builder: (_) => const OrderDraftScreen()));
//                       },
//                       child: Stack(children: [
//                         const Icon(Icons.shopping_cart_outlined,
//                             color: Colors.white, size: 26),
//                         if (notifProv.hasUnread)
//                           Positioned(
//                             right: 0, top: 0,
//                             child: Container(
//                               width: 9, height: 9,
//                               decoration: const BoxDecoration(
//                                 color: Colors.red,
//                                 shape: BoxShape.circle,
//                               ),
//                             ),
//                           ),
//                       ]),
//                     ),
//                     //const CartBadge(),
//                   ]),
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 24),
//             const _CurvedSurface(),
//             const SizedBox(height: 16),
//
//             // ── INFO CARDS ────────────────────────────────────────────
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Row(children: [
//
//                 // My Orders — real count from Firestore
//                 Expanded(
//                   child: StreamBuilder<int>(
//                     stream: OrderService.streamOrderCount(),
//                     builder: (ctx, snap) {
//                       final count = snap.data ?? OrderService.orders.length;
//                       return GestureDetector(
//                         onTap: () => Navigator.push(context,
//                             MaterialPageRoute(builder: (_) => const OrderListScreen())),
//                         child: _AnimatedInfoCard(
//                           title:    'My Orders',
//                           value:    count.toString(),
//                           icon:     Icons.shopping_cart_outlined,
//                           gradient: const [Color(0xFF2C7A7B), Color(0xFF38A3A5)],
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//
//                 const SizedBox(width: 16),
//
//                 // Cart Items — from local provider
//                 Expanded(
//                   child: GestureDetector(
//                     onTap: () => Navigator.push(context,
//                         MaterialPageRoute(builder: (_) => const OrderDraftScreen())),
//                     child: _AnimatedInfoCard(
//                       title:    'Cart Items',
//                       value:    context.watch<OrderDraftProvider>().items.length.toString(),
//                       icon:     Icons.receipt_long_outlined,
//                       gradient: const [Color(0xFFB45309), Color(0xFFF59E0B)],
//                     ),
//                   ),
//                 ),
//
//               ]),
//             ),
//
//             const SizedBox(height: 24),
//
//             // ── QUICK ACTIONS ─────────────────────────────────────────
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('Quick Actions', style: TextStyle(
//                       color: Colors.white, fontSize: 18,
//                       fontWeight: FontWeight.w600)),
//                   const SizedBox(height: 16),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       _QuickAction(icon: Icons.inventory_2_outlined, label: 'Products',
//                           onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductsScreen()))),
//                       _QuickAction(icon: Icons.shopping_cart_outlined,  label: 'Cart',
//                           onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderDraftScreen()))),
//                       _QuickAction(icon: Icons.favorite_border_outlined, label: 'Favorites',
//                           onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen()))),
//                       _QuickAction(icon: Icons.history_outlined,          label: 'History',
//                           onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderListScreen()))),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 24),
//
//             // ── POPULAR PRODUCTS ──────────────────────────────────────
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('Popular Products', style: TextStyle(
//                       color: Colors.white, fontSize: 18,
//                       fontWeight: FontWeight.w600)),
//                   const SizedBox(height: 16),
//                   GridView.builder(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     itemCount: products.length,
//                     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 4,
//                       crossAxisSpacing: 10,
//                       mainAxisSpacing: 10,
//                       childAspectRatio: 0.72,
//                     ),
//                     itemBuilder: (ctx, i) {
//                       final p = products[i];
//                       return _ProductCard(
//                         product: p,
//                         onAdd: () {
//                           final cart = ctx.read<OrderDraftProvider>();
//                           cart.addProduct(p);
//                           ctx.read<NotificationProvider>().addNotification(
//                             title:   '🛒 Added to Cart',
//                             body:    '${p.name} has been added to your cart.',
//                             type:    'cart_add',
//                           );
//                           showAddToCartPopup(ctx, p);
//                         },
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 30),
//           ]),
//         ),
//       ),
//     );
//   }
// }
//
// // ── Curved decorative surface ──────────────────────────────────────
// class _CurvedSurface extends StatelessWidget {
//   const _CurvedSurface();
//   @override
//   Widget build(BuildContext context) => Container(
//     height: 6,
//     margin: const EdgeInsets.symmetric(horizontal: 60),
//     decoration: BoxDecoration(
//       color: const Color(0xFF2E6CF6).withOpacity(0.25),
//       borderRadius: BorderRadius.circular(10),
//     ),
//   );
// }
//
// // ── Info card ─────────────────────────────────────────────────────
// class _AnimatedInfoCard extends StatelessWidget {
//   final String title;
//   final String value;
//   final IconData icon;
//   final List<Color> gradient;
//
//   const _AnimatedInfoCard({
//     required this.title, required this.value,
//     required this.icon,  required this.gradient,
//   });
//
//   @override
//   Widget build(BuildContext context) => Container(
//     height: 110,
//     padding: const EdgeInsets.all(16),
//     decoration: BoxDecoration(
//       gradient: LinearGradient(colors: gradient,
//           begin: Alignment.topLeft, end: Alignment.bottomRight),
//       borderRadius: BorderRadius.circular(18),
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//           Text(title, style: const TextStyle(color: Colors.white70, fontSize: 13)),
//           Icon(icon, color: Colors.white70, size: 22),
//         ]),
//         Text(value, style: const TextStyle(color: Colors.white,
//             fontSize: 32, fontWeight: FontWeight.bold)),
//       ],
//     ),
//   );
// }
//
// // ── Quick action button ────────────────────────────────────────────
// class _QuickAction extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final VoidCallback onTap;
//   const _QuickAction({required this.icon, required this.label, required this.onTap});
//
//   @override
//   Widget build(BuildContext context) => GestureDetector(
//     onTap: onTap,
//     child: Column(children: [
//       Container(
//         width: 56, height: 56,
//         decoration: BoxDecoration(
//           color: Theme.of(context).cardColor,
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: Icon(icon, color: const Color(0xFF2E6CF6), size: 24),
//       ),
//       const SizedBox(height: 8),
//       Text(label, style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 12)),
//     ]),
//   );
// }
//
// // ── Product card — 4-per-row with hover animation ──────────────────
// class _ProductCard extends StatefulWidget {
//   final ProductModel product;
//   final VoidCallback onAdd;
//   const _ProductCard({required this.product, required this.onAdd});
//
//   @override
//   State<_ProductCard> createState() => _ProductCardState();
// }
//
// class _ProductCardState extends State<_ProductCard> {
//   bool _hovering = false;
//
//   void _flyHeart(BuildContext context) {
//     final overlay = Overlay.of(context);
//     final box     = context.findRenderObject() as RenderBox?;
//     if (box == null) return;
//     final pos = box.localToGlobal(Offset.zero);
//     final entry = OverlayEntry(
//       builder: (_) => Positioned(
//         left: pos.dx + box.size.width / 2 - 18,
//         top:  pos.dy + box.size.height / 2 - 18,
//         child: TweenAnimationBuilder<double>(
//           tween: Tween(begin: 0, end: -100),
//           duration: const Duration(milliseconds: 700),
//           builder: (_, val, child) => Transform.translate(
//             offset: Offset(0, val),
//             child: Opacity(opacity: 1 - (val.abs() / 100), child: child),
//           ),
//           child: const Icon(Icons.favorite, color: Colors.red, size: 36),
//         ),
//       ),
//     );
//     overlay.insert(entry);
//     Future.delayed(const Duration(milliseconds: 720), entry.remove);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isFav = context.watch<FavoritesProvider>().isFavorite(widget.product);
//     return MouseRegion(
//       onEnter: (_) => setState(() => _hovering = true),
//       onExit:  (_) => setState(() => _hovering = false),
//       child: AnimatedScale(
//         scale:    _hovering ? 1.04 : 1.0,
//         duration: const Duration(milliseconds: 180),
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 180),
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: Theme.of(context).cardColor,
//             borderRadius: BorderRadius.circular(14),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(_hovering ? 0.45 : 0.2),
//                 blurRadius: _hovering ? 24 : 10,
//                 offset: const Offset(0, 8),
//               ),
//             ],
//           ),
//           child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Expanded(
//               child: Stack(children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(10),
//                   child: Image.asset(widget.product.image, fit: BoxFit.cover,
//                       width: double.infinity, height: double.infinity,
//                       errorBuilder: (_, __, ___) => Container(
//                         color: Colors.white10,
//                         child: const Icon(Icons.image_not_supported,
//                             color: Colors.white30),
//                       )),
//                 ),
//                 Positioned(
//                   top: 4, right: 4,
//                   child: GestureDetector(
//                     onTap: () {
//                       context.read<FavoritesProvider>()
//                           .toggleFavorite(widget.product);
//                       _flyHeart(context);
//                     },
//                     child: Container(
//                       padding: const EdgeInsets.all(4),
//                       decoration: const BoxDecoration(
//                         color: Colors.black45,
//                         shape: BoxShape.circle,
//                       ),
//                       child: Icon(
//                         isFav ? Icons.favorite : Icons.favorite_border,
//                         color: isFav ? Colors.red : Colors.white,
//                         size: 14,
//                       ),
//                     ),
//                   ),
//                 ),
//               ]),
//             ),
//             const SizedBox(height: 5),
//             Text(widget.product.name, maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: const TextStyle(color: Colors.white,
//                     fontWeight: FontWeight.w600, fontSize: 11)),
//             const SizedBox(height: 2),
//             Text('₹${widget.product.price.toStringAsFixed(0)}',
//                 style: const TextStyle(color: Color(0xFF2E6CF6),
//                     fontWeight: FontWeight.bold, fontSize: 12)),
//             const SizedBox(height: 5),
//             SizedBox(
//               width: double.infinity, height: 26,
//               child: ElevatedButton(
//                 onPressed: widget.onAdd,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF2E6CF6),
//                   padding: EdgeInsets.zero,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(7)),
//                 ),
//                 child: const Text('+ Add', style: TextStyle(
//                     fontSize: 10, fontWeight: FontWeight.w900,
//                     color: Colors.black)),
//               ),
//             ),
//           ]),
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// import '../../widgets/cart_badge.dart';
// import '../../models/product_model.dart';
// import '../../providers/order_draft_provider.dart';
// import '../../providers/notification_provider.dart';
// import '../../services/product_service.dart';
// import '../../services/order_service.dart';
// import '../products/products_screen.dart';
// import '../order_draft/order_draft_screen.dart';
// import '../orders/order_list_screen.dart';
// import '../favorites/favorites_screen.dart';
// import '../../providers/favorites_provider.dart';
// import '../settings/profile_screen.dart';
// import '../settings/notifications_screen.dart';
// import '../../core/helpers.dart';
// import '../../widgets/glass_bottom_navbar.dart';
//
// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({super.key});
//
//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }
//
// class _DashboardScreenState extends State<DashboardScreen> {
//
//   @override
//   void initState() {
//     super.initState();
//     // Load notifications from Firestore
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<NotificationProvider>().loadFromFirestore();
//     });
//   }
//
//   String get greeting {
//     final h = DateTime.now().hour;
//     if (h < 12) return 'Good Morning';
//     if (h < 17) return 'Good Afternoon';
//     return 'Good Evening';
//   }
//
//   // Get initials from display name: "Parth Chauhan" → "PC"
//   String _initials(String? name) {
//     if (name == null || name.isEmpty) return '?';
//     final parts = name.trim().split(' ');
//     if (parts.length >= 2) {
//       return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
//     }
//     return parts[0][0].toUpperCase();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final user      = FirebaseAuth.instance.currentUser;
//     final userName  = user?.displayName ?? user?.email?.split('@')[0] ?? 'User';
//     final products  = context.watch<ProductService>().products;
//     final notifProv = context.watch<NotificationProvider>();
//
//     return Scaffold(
//       backgroundColor: const Color(0xFF0F1218),
//
//       bottomNavigationBar: GlassBottomNavbar(
//         currentIndex: 0,
//         onTap: (index) {
//           if (index == 1) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProductsScreen()));
//           if (index == 2) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OrderDraftScreen()));
//           if (index == 3) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
//         },
//       ),
//
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(children: [
//
//             // ── HEADER ───────────────────────────────────────────────
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [Color(0xFF0B3C5D), Color(0xFF2E6CF6)],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: BorderRadius.only(
//                   bottomLeft:  Radius.circular(28),
//                   bottomRight: Radius.circular(28),
//                 ),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//
//                   Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                     Text(greeting, style: const TextStyle(color: Colors.white70, fontSize: 13)),
//                     const SizedBox(height: 4),
//                     Text(
//                       'Hi, ${userName.split(' ')[0]}! 👋',
//                       style: const TextStyle(color: Colors.white, fontSize: 20,
//                           fontWeight: FontWeight.w600),
//                     ),
//                   ]),
//
//                   Row(children: [
//
//                     // ── Notification Bell with Badge ──────────────────
//                     GestureDetector(
//                       onTap: () {
//                         notifProv.markAllRead();
//                         Navigator.push(context, MaterialPageRoute(
//                             builder: (_) => const NotificationsScreen()));
//                       },
//                       child: Stack(children: [
//                         const Icon(Icons.notifications_none,
//                             color: Colors.white, size: 26),
//                         if (notifProv.hasUnread)
//                           Positioned(
//                             right: 0, top: 0,
//                             child: Container(
//                               width: 9, height: 9,
//                               decoration: const BoxDecoration(
//                                 color: Colors.red,
//                                 shape: BoxShape.circle,
//                               ),
//                             ),
//                           ),
//                       ]),
//                     ),
//
//                     const SizedBox(width: 14),
//
//                     // ── Cart Bell with Badge ──────────────────
//                     GestureDetector(
//                       onTap: () {
//                         notifProv.markAllRead();
//                         Navigator.push(context, MaterialPageRoute(
//                             builder: (_) => const OrderDraftScreen()));
//                       },
//                       child: Stack(children: [
//                         const Icon(Icons.shopping_cart_outlined,
//                             color: Colors.white, size: 26),
//                         if (notifProv.hasUnread)
//                           Positioned(
//                             right: 0, top: 0,
//                             child: Container(
//                               width: 9, height: 9,
//                               decoration: const BoxDecoration(
//                                 color: Colors.red,
//                                 shape: BoxShape.circle,
//                               ),
//                             ),
//                           ),
//                       ]),
//                     ),
//                     //const CartBadge(),
//                   ]),
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 24),
//             const _CurvedSurface(),
//             const SizedBox(height: 16),
//
//             // ── INFO CARDS ────────────────────────────────────────────
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Row(children: [
//
//                 // My Orders — real count from Firestore
//                 Expanded(
//                   child: StreamBuilder<int>(
//                     stream: OrderService.streamOrderCount(),
//                     builder: (ctx, snap) {
//                       final count = snap.data ?? OrderService.orders.length;
//                       return GestureDetector(
//                         onTap: () => Navigator.push(context,
//                             MaterialPageRoute(builder: (_) => const OrderListScreen())),
//                         child: _AnimatedInfoCard(
//                           title:    'My Orders',
//                           value:    count.toString(),
//                           icon:     Icons.shopping_cart_outlined,
//                           gradient: const [Color(0xFF2C7A7B), Color(0xFF38A3A5)],
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//
//                 const SizedBox(width: 16),
//
//                 // Cart Items — from local provider
//                 Expanded(
//                   child: GestureDetector(
//                     onTap: () => Navigator.push(context,
//                         MaterialPageRoute(builder: (_) => const OrderDraftScreen())),
//                     child: _AnimatedInfoCard(
//                       title:    'Cart Items',
//                       value:    context.watch<OrderDraftProvider>().items.length.toString(),
//                       icon:     Icons.receipt_long_outlined,
//                       gradient: const [Color(0xFFB45309), Color(0xFFF59E0B)],
//                     ),
//                   ),
//                 ),
//
//               ]),
//             ),
//
//             const SizedBox(height: 24),
//
//             // ── QUICK ACTIONS ─────────────────────────────────────────
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text('Quick Actions', style: TextStyle(
//                       color: Colors.white, fontSize: 18,
//                       fontWeight: FontWeight.w600)),
//                   const SizedBox(height: 16),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       _QuickAction(icon: Icons.inventory_2_outlined, label: 'Products',
//                           onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductsScreen()))),
//                       _QuickAction(icon: Icons.shopping_cart_outlined,  label: 'Cart',
//                           onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderDraftScreen()))),
//                       _QuickAction(icon: Icons.favorite_border_outlined, label: 'Favorites',
//                           onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen()))),
//                       _QuickAction(icon: Icons.history_outlined,          label: 'History',
//                           onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderListScreen()))),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 24),
//
//             // ── POPULAR PRODUCTS ──────────────────────────────────────
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text('Popular Products', style: TextStyle(
//                       color: Colors.white, fontSize: 18,
//                       fontWeight: FontWeight.w600)),
//                   const SizedBox(height: 16),
//                   GridView.builder(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     itemCount: products.length,
//                     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 4,
//                       crossAxisSpacing: 10,
//                       mainAxisSpacing: 10,
//                       childAspectRatio: 0.72,
//                     ),
//                     itemBuilder: (ctx, i) {
//                       final p = products[i];
//                       return _ProductCard(
//                         product: p,
//                         onAdd: () {
//                           final cart = ctx.read<OrderDraftProvider>();
//                           cart.addProduct(p);
//                           ctx.read<NotificationProvider>().addNotification(
//                             title:   '🛒 Added to Cart',
//                             body:    '${p.name} has been added to your cart.',
//                             type:    'cart_add',
//                           );
//                           showAddToCartPopup(ctx, p);
//                         },
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 30),
//           ]),
//         ),
//       ),
//     );
//   }
// }
//
// // ── Curved decorative surface ──────────────────────────────────────
// class _CurvedSurface extends StatelessWidget {
//   const _CurvedSurface();
//   @override
//   Widget build(BuildContext context) => Container(
//     height: 6,
//     margin: const EdgeInsets.symmetric(horizontal: 60),
//     decoration: BoxDecoration(
//       color: const Color(0xFF2E6CF6).withOpacity(0.25),
//       borderRadius: BorderRadius.circular(10),
//     ),
//   );
// }
//
// // ── Info card ─────────────────────────────────────────────────────
// class _AnimatedInfoCard extends StatelessWidget {
//   final String title;
//   final String value;
//   final IconData icon;
//   final List<Color> gradient;
//
//   const _AnimatedInfoCard({
//     required this.title, required this.value,
//     required this.icon,  required this.gradient,
//   });
//
//   @override
//   Widget build(BuildContext context) => Container(
//     height: 110,
//     padding: const EdgeInsets.all(16),
//     decoration: BoxDecoration(
//       gradient: LinearGradient(colors: gradient,
//           begin: Alignment.topLeft, end: Alignment.bottomRight),
//       borderRadius: BorderRadius.circular(18),
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//           Text(title, style: const TextStyle(color: Colors.white70, fontSize: 13)),
//           Icon(icon, color: Colors.white70, size: 22),
//         ]),
//         Text(value, style: const TextStyle(color: Colors.white,
//             fontSize: 32, fontWeight: FontWeight.bold)),
//       ],
//     ),
//   );
// }
//
// // ── Quick action button ────────────────────────────────────────────
// class _QuickAction extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final VoidCallback onTap;
//   const _QuickAction({required this.icon, required this.label, required this.onTap});
//
//   @override
//   Widget build(BuildContext context) => GestureDetector(
//     onTap: onTap,
//     child: Column(children: [
//       Container(
//         width: 56, height: 56,
//         decoration: BoxDecoration(
//           color: const Color(0xFF1E2532),
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: Icon(icon, color: const Color(0xFF2E6CF6), size: 24),
//       ),
//       const SizedBox(height: 8),
//       Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
//     ]),
//   );
// }
//
// // ── Product card — 4-per-row with hover animation ──────────────────
// class _ProductCard extends StatefulWidget {
//   final ProductModel product;
//   final VoidCallback onAdd;
//   const _ProductCard({required this.product, required this.onAdd});
//
//   @override
//   State<_ProductCard> createState() => _ProductCardState();
// }
//
// class _ProductCardState extends State<_ProductCard> {
//   bool _hovering = false;
//
//   void _flyHeart(BuildContext context) {
//     final overlay = Overlay.of(context);
//     final box = context.findRenderObject() as RenderBox?;
//     if (box == null) return;
//     final pos = box.localToGlobal(Offset.zero);
//     final entry = OverlayEntry(
//       builder: (_) =>
//           Positioned(
//             left: pos.dx + box.size.width / 2 - 18,
//             top: pos.dy + box.size.height / 2 - 18,
//             child: TweenAnimationBuilder<double>(
//               tween: Tween(begin: 0, end: -100),
//               duration: const Duration(milliseconds: 700),
//               builder: (_, val, child) =>
//                   Transform.translate(
//                     offset: Offset(0, val),
//                     child: Opacity(
//                         opacity: 1 - (val.abs() / 100), child: child),
//                   ),
//               child: const Icon(Icons.favorite, color: Colors.red, size: 36),
//             ),
//           ),
//     );
//     overlay.insert(entry);
//     Future.delayed(const Duration(milliseconds: 720), entry.remove);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isFav = context.watch<FavoritesProvider>().isFavorite(widget.product);
//     return MouseRegion(
//       onEnter: (_) => setState(() => _hovering = true),
//       onExit: (_) => setState(() => _hovering = false),
//       child: AnimatedScale(
//         scale: _hovering ? 1.04 : 1.0,
//         duration: const Duration(milliseconds: 180),
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 180),
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: const Color(0xFF161A22),
//             borderRadius: BorderRadius.circular(14),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(_hovering ? 0.45 : 0.2),
//                 blurRadius: _hovering ? 24 : 10,
//                 offset: const Offset(0, 8),
//               ),
//             ],
//           ),
//           child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Expanded(
//               child: Stack(children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(10),
//                   child: Image.asset(widget.product.image, fit: BoxFit.cover,
//                       width: double.infinity, height: double.infinity,
//                       errorBuilder: (_, __, ___) =>
//                           Container(
//                             color: Colors.white10,
//                             child: const Icon(Icons.image_not_supported,
//                                 color: Colors.white30),
//                           )),
//                 ),
//                 Positioned(
//                   top: 4, right: 4,
//                   child: GestureDetector(
//                     onTap: () {
//                       context.read<FavoritesProvider>()
//                           .toggleFavorite(widget.product);
//                       _flyHeart(context);
//                     },
//                     child: Container(
//                       padding: const EdgeInsets.all(4),
//                       decoration: const BoxDecoration(
//                         color: Colors.black45,
//                         shape: BoxShape.circle,
//                       ),
//                       child: Icon(
//                         isFav ? Icons.favorite : Icons.favorite_border,
//                         color: isFav ? Colors.red : Colors.white,
//                         size: 14,
//                       ),
//                     ),
//                   ),
//                 ),
//               ]),
//             ),
//             const SizedBox(height: 5),
//             Text(widget.product.name, maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: const TextStyle(color: Colors.white,
//                     fontWeight: FontWeight.w600, fontSize: 11)),
//             const SizedBox(height: 2),
//             Text('₹${widget.product.price.toStringAsFixed(0)}',
//                 style: const TextStyle(color: Color(0xFF2E6CF6),
//                     fontWeight: FontWeight.bold, fontSize: 12)),
//             const SizedBox(height: 5),
//             SizedBox(
//               width: double.infinity, height: 26,
//               child: ElevatedButton(
//                 onPressed: widget.onAdd,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF2E6CF6),
//                   padding: EdgeInsets.zero,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(7)),
//                 ),
//                 child: const Text('+ Add', style: TextStyle(
//                     fontSize: 10, fontWeight: FontWeight.w900,
//                     color: Colors.black)),
//               ),
//             ),
//           ]),
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// import '../../widgets/cart_badge.dart';
// import '../../models/product_model.dart';
// import '../../providers/order_draft_provider.dart';
// import '../../providers/notification_provider.dart';
// import '../../services/product_service.dart';
// import '../../services/order_service.dart';
// import '../products/products_screen.dart';
// import '../order_draft/order_draft_screen.dart';
// import '../orders/order_list_screen.dart';
// import '../favorites/favorites_screen.dart';
// import '../../providers/favorites_provider.dart';
// import '../settings/profile_screen.dart';
// import '../settings/notifications_screen.dart';
// import '../../core/helpers.dart';
// import '../../widgets/glass_bottom_navbar.dart';
//
// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({super.key});
//
//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }
//
// class _DashboardScreenState extends State<DashboardScreen> {
//
//   @override
//   void initState() {
//     super.initState();
//     // Load notifications from Firestore
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<NotificationProvider>().loadFromFirestore();
//     });
//   }
//
//   String get greeting {
//     final h = DateTime.now().hour;
//     if (h < 12) return 'Good Morning';
//     if (h < 17) return 'Good Afternoon';
//     return 'Good Evening';
//   }
//
//   // Get initials from display name: "Parth Chauhan" → "PC"
//   String _initials(String? name) {
//     if (name == null || name.isEmpty) return '?';
//     final parts = name.trim().split(' ');
//     if (parts.length >= 2) {
//       return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
//     }
//     return parts[0][0].toUpperCase();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final user      = FirebaseAuth.instance.currentUser;
//     final userName  = user?.displayName ?? user?.email?.split('@')[0] ?? 'User';
//     final products  = context.watch<ProductService>().products;
//     final notifProv = context.watch<NotificationProvider>();
//
//     return Scaffold(
//       backgroundColor: const Color(0xFF0F1218),
//
//       bottomNavigationBar: GlassBottomNavbar(
//         currentIndex: 0,
//         onTap: (index) {
//           if (index == 1) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProductsScreen()));
//           if (index == 2) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OrderDraftScreen()));
//           if (index == 3) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
//         },
//       ),
//
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(children: [
//
//             // ── HEADER ───────────────────────────────────────────────
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [Color(0xFF0B3C5D), Color(0xFF2E6CF6)],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: BorderRadius.only(
//                   bottomLeft:  Radius.circular(28),
//                   bottomRight: Radius.circular(28),
//                 ),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//
//                   Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                     Text(greeting, style: const TextStyle(color: Colors.white70, fontSize: 13)),
//                     const SizedBox(height: 4),
//                     Text(
//                       'Hi, ${userName.split(' ')[0]}! 👋',
//                       style: const TextStyle(color: Colors.white, fontSize: 20,
//                           fontWeight: FontWeight.w600),
//                     ),
//                   ]),
//
//                   Row(children: [
//
//                     // ── Notification Bell with Badge ──────────────────
//                     GestureDetector(
//                       onTap: () {
//                         notifProv.markAllRead();
//                         Navigator.push(context, MaterialPageRoute(
//                             builder: (_) => const NotificationsScreen()));
//                       },
//                       child: Stack(children: [
//                         const Icon(Icons.notifications_none,
//                             color: Colors.white, size: 26),
//                         if (notifProv.hasUnread)
//                           Positioned(
//                             right: 0, top: 0,
//                             child: Container(
//                               width: 9, height: 9,
//                               decoration: const BoxDecoration(
//                                 color: Colors.red,
//                                 shape: BoxShape.circle,
//                               ),
//                             ),
//                           ),
//                       ]),
//                     ),
//
//                     const SizedBox(width: 14),
//
//                     // ── Cart Bell with Badge ──────────────────
//                     GestureDetector(
//                       onTap: () {
//                         notifProv.markAllRead();
//                         Navigator.push(context, MaterialPageRoute(
//                             builder: (_) => const OrderDraftScreen()));
//                       },
//                       child: Stack(children: [
//                         const Icon(Icons.shopping_cart_outlined,
//                             color: Colors.white, size: 26),
//                         if (notifProv.hasUnread)
//                           Positioned(
//                             right: 0, top: 0,
//                             child: Container(
//                               width: 9, height: 9,
//                               decoration: const BoxDecoration(
//                                 color: Colors.red,
//                                 shape: BoxShape.circle,
//                               ),
//                             ),
//                           ),
//                       ]),
//                     ),
//                     //const CartBadge(),
//                   ]),
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 24),
//             const _CurvedSurface(),
//             const SizedBox(height: 16),
//
//             // ── INFO CARDS ────────────────────────────────────────────
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Row(children: [
//
//                 // My Orders — real count from Firestore
//                 Expanded(
//                   child: StreamBuilder<int>(
//                     stream: OrderService.streamOrderCount(),
//                     builder: (ctx, snap) {
//                       final count = snap.data ?? OrderService.orders.length;
//                       return GestureDetector(
//                         onTap: () => Navigator.push(context,
//                             MaterialPageRoute(builder: (_) => const OrderListScreen())),
//                         child: _AnimatedInfoCard(
//                           title:    'My Orders',
//                           value:    count.toString(),
//                           icon:     Icons.shopping_cart_outlined,
//                           gradient: const [Color(0xFF2C7A7B), Color(0xFF38A3A5)],
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//
//                 const SizedBox(width: 16),
//
//                 // Cart Items — from local provider
//                 Expanded(
//                   child: GestureDetector(
//                     onTap: () => Navigator.push(context,
//                         MaterialPageRoute(builder: (_) => const OrderDraftScreen())),
//                     child: _AnimatedInfoCard(
//                       title:    'Cart Items',
//                       value:    context.watch<OrderDraftProvider>().items.length.toString(),
//                       icon:     Icons.receipt_long_outlined,
//                       gradient: const [Color(0xFFB45309), Color(0xFFF59E0B)],
//                     ),
//                   ),
//                 ),
//
//               ]),
//             ),
//
//             const SizedBox(height: 24),
//
//             // ── QUICK ACTIONS ─────────────────────────────────────────
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text('Quick Actions', style: TextStyle(
//                       color: Colors.white, fontSize: 18,
//                       fontWeight: FontWeight.w600)),
//                   const SizedBox(height: 16),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       _QuickAction(icon: Icons.inventory_2_outlined, label: 'Products',
//                           onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductsScreen()))),
//                       _QuickAction(icon: Icons.shopping_cart_outlined,  label: 'Cart',
//                           onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderDraftScreen()))),
//                       _QuickAction(icon: Icons.favorite_border_outlined, label: 'Favorites',
//                           onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen()))),
//                       _QuickAction(icon: Icons.history_outlined,          label: 'History',
//                           onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderListScreen()))),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 24),
//
//             // ── POPULAR PRODUCTS ──────────────────────────────────────
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text('Popular Products', style: TextStyle(
//                       color: Colors.white, fontSize: 18,
//                       fontWeight: FontWeight.w600)),
//                   const SizedBox(height: 16),
//                   GridView.builder(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     itemCount: products.length,
//                     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 4,
//                       crossAxisSpacing: 10,
//                       mainAxisSpacing: 10,
//                       childAspectRatio: 0.72,
//                     ),
//                     itemBuilder: (ctx, i) {
//                       final p = products[i];
//                       return _ProductCard(
//                         product: p,
//                         onAdd: () {
//                           final cart = ctx.read<OrderDraftProvider>();
//                           cart.addProduct(p);
//                           ctx.read<NotificationProvider>().addNotification(
//                             title:   '🛒 Added to Cart',
//                             body:    '${p.name} has been added to your cart.',
//                             type:    'cart_add',
//                           );
//                           showAddToCartPopup(ctx, p);
//                         },
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 30),
//           ]),
//         ),
//       ),
//     );
//   }
// }
//
// // ── Curved decorative surface ──────────────────────────────────────
// class _CurvedSurface extends StatelessWidget {
//   const _CurvedSurface();
//   @override
//   Widget build(BuildContext context) => Container(
//     height: 6,
//     margin: const EdgeInsets.symmetric(horizontal: 60),
//     decoration: BoxDecoration(
//       color: const Color(0xFF2E6CF6).withOpacity(0.25),
//       borderRadius: BorderRadius.circular(10),
//     ),
//   );
// }
//
// // ── Info card ─────────────────────────────────────────────────────
// class _AnimatedInfoCard extends StatelessWidget {
//   final String title;
//   final String value;
//   final IconData icon;
//   final List<Color> gradient;
//
//   const _AnimatedInfoCard({
//     required this.title, required this.value,
//     required this.icon,  required this.gradient,
//   });
//
//   @override
//   Widget build(BuildContext context) => Container(
//     height: 110,
//     padding: const EdgeInsets.all(16),
//     decoration: BoxDecoration(
//       gradient: LinearGradient(colors: gradient,
//           begin: Alignment.topLeft, end: Alignment.bottomRight),
//       borderRadius: BorderRadius.circular(18),
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//           Text(title, style: const TextStyle(color: Colors.white70, fontSize: 13)),
//           Icon(icon, color: Colors.white70, size: 22),
//         ]),
//         Text(value, style: const TextStyle(color: Colors.white,
//             fontSize: 32, fontWeight: FontWeight.bold)),
//       ],
//     ),
//   );
// }
//
// // ── Quick action button ────────────────────────────────────────────
// class _QuickAction extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final VoidCallback onTap;
//   const _QuickAction({required this.icon, required this.label, required this.onTap});
//
//   @override
//   Widget build(BuildContext context) => GestureDetector(
//     onTap: onTap,
//     child: Column(children: [
//       Container(
//         width: 56, height: 56,
//         decoration: BoxDecoration(
//           color: const Color(0xFF1E2532),
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: Icon(icon, color: const Color(0xFF2E6CF6), size: 24),
//       ),
//       const SizedBox(height: 8),
//       Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
//     ]),
//   );
// }
//
// // ── Product card (horizontal list) ────────────────────────────────
// class _ProductCard extends StatelessWidget {
//   final ProductModel product;
//   final VoidCallback onAdd;
//   const _ProductCard({required this.product, required this.onAdd});
//
//   @override
//   Widget build(BuildContext context) {
//     final isFav = context.watch<FavoritesProvider>().isFavorite(product);
//     return Container(
//       padding: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         color: const Color(0xFF161A22),
//         borderRadius: BorderRadius.circular(14),
//       ),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Expanded(
//           child: Stack(children: [
//             ClipRRect(
//               borderRadius: BorderRadius.circular(12),
//               child: Image.asset(product.image, fit: BoxFit.cover,
//                   width: double.infinity, height: double.infinity,
//                   errorBuilder: (_, __, ___) => Container(
//                     color: Colors.white10,
//                     child: const Icon(Icons.image_not_supported,
//                         color: Colors.white30),
//                   )),
//             ),
//             Positioned(
//               top: 4, right: 4,
//               child: GestureDetector(
//                 onTap: () => context.read<FavoritesProvider>().toggleFavorite(product),
//                 child: Container(
//                   padding: const EdgeInsets.all(4),
//                   decoration: BoxDecoration(
//                     color: Colors.black45,
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(isFav ? Icons.favorite : Icons.favorite_border,
//                       color: isFav ? Colors.red : Colors.blueAccent, size: 16),
//                 ),
//               ),
//             ),
//           ]),
//         ),
//         const SizedBox(height: 5),
//         Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis,
//             style: const TextStyle(color: Colors.white,
//                 fontWeight: FontWeight.w600, fontSize: 11)),
//         const SizedBox(height: 2),
//         Text('₹${product.price.toStringAsFixed(0)}',
//             style: const TextStyle(color: Color(0xFF2E6CF6),
//                 fontWeight: FontWeight.bold, fontSize: 12)),
//         const SizedBox(height: 5),
//         SizedBox(
//           width: double.infinity, height: 26,
//           child: ElevatedButton(
//             onPressed: onAdd,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF2E6CF6),
//               padding: EdgeInsets.zero,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
//             ),
//             child: const Text('+ Add', style: TextStyle(
//                 fontSize: 10, fontWeight: FontWeight.w900, color: Colors.black)),
//           ),
//         ),
//       ]),
//     );
//   }
// }
