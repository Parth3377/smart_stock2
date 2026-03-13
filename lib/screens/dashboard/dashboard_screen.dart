import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/cart_badge.dart';
import '../../models/product_model.dart';
import '../../providers/order_draft_provider.dart';
import '../../services/product_service.dart';
import '../products/products_screen.dart';
import '../order_draft/order_draft_screen.dart';
import '../orders/order_list_screen.dart';
import '../favorites/favorites_screen.dart';
import '../../providers/favorites_provider.dart';
import '../settings/profile_screen.dart';
import '../../core/helpers.dart';
import '../../widgets/glass_bottom_navbar.dart';


class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  @override
  Widget build(BuildContext context) {
    final List<ProductModel> products = ProductService.getProducts();

    return Scaffold(
      backgroundColor: const Color(0xFF0F1218),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              // ================= HEADER =================
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0B3C5D), Color(0xFF2E6CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getGreeting(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Client Dashboard",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    Row(
                      children: const [

                        Icon(
                          Icons.notifications_none,
                          color: Colors.white,
                          size: 26,
                        ),

                        SizedBox(width: 12),

                        CartBadge(),

                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              /// ⭐ CURVED SURFACE
              const _CurvedSurface(),

              const SizedBox(height: 16),

              // ================= TOP INFO CARDS =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [

                    const Expanded(
                      child: _AnimatedInfoCard(
                        title: "My Orders",
                        value: "1",
                        icon: Icons.shopping_cart_outlined,
                        gradient: [Color(0xFF2C7A7B), Color(0xFF38A3A5)],
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Consumer<OrderDraftProvider>(
                        builder: (context, cart, _) {
                          return _AnimatedInfoCard(
                            title: "Cart Items",
                            value: cart.items.length.toString(),
                            icon: Icons.inventory_2_outlined,
                            gradient: const [Color(0xFFFF9800), Color(0xFFFFB74D)],
                          );
                        },
                      ),
                    ),
                  ],
                )
              ),

              const SizedBox(height: 28),

              // ================= QUICK ACTIONS =================
              _sectionTitle("Quick Actions"),
              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _ActionItem(
                      icon: Icons.inventory_2_outlined,
                      title: "Products",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ProductsScreen()),
                        );
                      },
                    ),
                    _ActionItem(
                      icon: Icons.shopping_cart_outlined,
                      title: "Cart",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const OrderDraftScreen()),
                        );
                      },
                    ),

                    Consumer<FavoritesProvider>(
                      builder: (context, FavoritesProvider favorites, _) {

                        return Stack(
                          children: [

                            _ActionItem(
                              icon: Icons.favorite_border_sharp,
                              title: "Favorites",
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const FavoritesScreen(),
                                  ),
                                );
                              },
                            ),

                            if (favorites.count > 0)
                              Positioned(
                                right: 8,
                                top: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    favorites.count.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),


                    _ActionItem(
                      icon: Icons.history,
                      title: "History",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const OrderListScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),



              const SizedBox(height: 28),

              // ================= PRODUCTS GRID =================
              _sectionTitle("Popular Products"),
              const SizedBox(height: 16),

              // ONLY showing changed GRID section

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: products.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.78,
                  ),
                  itemBuilder: (context, index) {
                    return ProductCard(   // ✅ FIXED (was _ProductCard)
                      product: products[index],
                      onAdd: () {
                        final cart = context.read<OrderDraftProvider>();

                        cart.addProduct(products[index]);

                        showAddToCartPopup(context, products[index]);
                      },
                    );
                  },
                ),
              ),


              const SizedBox(height: 100),
            ],
          ),
        ),
      ),

      // ================= BOTTOM NAV =================
      bottomNavigationBar: GlassBottomNavbar(
        currentIndex: 0,
        onTap: (index) {

          if (index == 0) return;

          if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ProductsScreen()),
            );
          }

          if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const OrderDraftScreen()),
            );
          }

          if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          }

        },
      ),

    );
  }
}

////////////////////////////////////////////////////////////
/// CURVED SURFACE
////////////////////////////////////////////////////////////

class _CurvedSurface extends StatelessWidget {
  const _CurvedSurface();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 24,
      decoration: const BoxDecoration(
        color: Color(0xFF0F1218),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// ANIMATED INFO CARD
////////////////////////////////////////////////////////////

class _AnimatedInfoCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final List<Color> gradient;

  const _AnimatedInfoCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  @override
  State<_AnimatedInfoCard> createState() => _AnimatedInfoCardState();
}

class _AnimatedInfoCardState extends State<_AnimatedInfoCard>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

    _scale = Tween(begin: 0.95, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _opacity = Tween(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: widget.gradient),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: widget.gradient.last.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title,
                      style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 8),
                  Text(widget.value,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold)),
                ],
              ),

              Icon(widget.icon, color: Colors.white, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// SECTION TITLE
////////////////////////////////////////////////////////////

Widget _sectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    ),
  );
}

////////////////////////////////////////////////////////////
/// ACTION ITEM
////////////////////////////////////////////////////////////

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2E6CF6).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: const Color(0xFF2E6CF6), size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// PRODUCT CARD
////////////////////////////////////////////////////////////

class ProductCard extends StatefulWidget {
  final ProductModel product;
  final VoidCallback? onAdd;

  const ProductCard({
    super.key,
    required this.product,
    this.onAdd,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      child: AnimatedScale(
        scale: hovering ? 1.03 : 1,
        duration: const Duration(milliseconds: 180),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF161A22),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(hovering ? 0.45 : 0.25),
                blurRadius: hovering ? 28 : 18,
                offset: const Offset(0, 12),
              ),
            ],
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// IMAGE
              Expanded(
                child: Stack(
                  children: [

                    /// PRODUCT IMAGE
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        widget.product.image,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),

                    /// FAVORITE HEART BUTTON
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Consumer<FavoritesProvider>(
                        builder: (context, favorites, _) {

                          final isFav = favorites.isFavorite(widget.product);

                          return GestureDetector(
                            onTap: () {

                              favorites.toggleFavorite(widget.product);

                              /// ❤️ Flying heart animation
                              final overlay = Overlay.of(context);
                              final box = context.findRenderObject() as RenderBox;
                              final position = box.localToGlobal(Offset.zero);

                              final overlayEntry = OverlayEntry(
                                builder: (_) => Positioned(
                                  left: position.dx + 40,
                                  top: position.dy + 40,

                                  child: TweenAnimationBuilder(
                                    tween: Tween(begin: 0.0, end: -120.0),
                                    duration: const Duration(milliseconds: 700),

                                    builder: (context, value, child) {

                                      return Transform.translate(
                                        offset: Offset(0, value),

                                        child: Opacity(
                                          opacity: 1 - (value.abs() / 120),

                                          child: const Icon(
                                            Icons.favorite,
                                            color: Colors.red,
                                            size: 36,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );

                              overlay.insert(overlayEntry);

                              Future.delayed(
                                const Duration(milliseconds: 700),
                                    () => overlayEntry.remove(),
                              );
                            },

                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.35),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isFav ? Icons.favorite : Icons.favorite_border,
                                color: isFav ? Colors.red : Colors.white,
                                size: 20,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              /// NAME
              Text(
                widget.product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 4),

              /// DESCRIPTION
              Text(
                widget.product.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFFA1A6B3),
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 10),

              /// PRICE + ADD
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Text(
                    "₹${widget.product.price.toStringAsFixed(0)}",
                    style: const TextStyle(
                      color: Color(0xFF2E6CF6),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  /// + ADD BUTTON (NOW ALWAYS VISIBLE)
                  ElevatedButton(
                    onPressed: widget.onAdd,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E6CF6),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      minimumSize: const Size(0, 34),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "+ Add",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900 , color: Colors.black),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _QuickActionCard extends StatefulWidget {
  final IconData icon;
  final String title;

  const _QuickActionCard({
    required this.icon,
    required this.title,
  });

  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard> {
  double scale = 1.0;

  void _onTapDown(TapDownDetails _) {
    setState(() => scale = 0.95);
  }

  void _onTapUp(TapUpDetails _) {
    setState(() => scale = 1.0);
  }

  void _onTapCancel() {
    setState(() => scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigation will be added in next step
      },
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          height: 92,
          decoration: BoxDecoration(
            color: const Color(0xFF161A22),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E6CF6).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icon,
                  color: const Color(0xFF2E6CF6),
                  size: 22,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

