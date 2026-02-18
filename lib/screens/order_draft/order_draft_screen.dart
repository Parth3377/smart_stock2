import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/order_draft_provider.dart';
import '../../routes/app_routes.dart';

class OrderDraftScreen extends StatelessWidget {
  const OrderDraftScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<OrderDraftProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F1218),

      /// ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: const Color(0xFF161A22),
        elevation: 0,
        title: const Text("Order Draft"),
        centerTitle: true,
      ),

      /// ================= BODY =================
      body: cart.items.isEmpty
          ? const _AnimatedEmptyCart()
          : Column(
        children: [
          /// ================= ITEM LIST =================
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cart.items.length,
              itemBuilder: (_, index) {
                final item = cart.items[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161A22),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      /// IMAGE
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          item.product.image,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),

                      const SizedBox(width: 12),

                      /// NAME + PRICE
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.product.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "₹${item.product.price.toStringAsFixed(0)}",
                              style: const TextStyle(
                                color: Color(0xFF2E6CF6),
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// ================= QUANTITY CONTROL =================
                      Row(
                        children: [
                          _qtyButton(
                            icon: Icons.remove,
                            onTap: () => cart.decreaseQty(item.product.id),
                          ),

                          Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              item.quantity.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          _qtyButton(
                            icon: Icons.add,
                            onTap: () => cart.increaseQty(item.product.id),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          /// ================= TOTAL + CHECKOUT =================
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF161A22),
              borderRadius:
              BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                /// TOTAL ROW
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total",
                      style:
                      TextStyle(color: Colors.white70, fontSize: 16 , fontWeight: FontWeight.w600),
                    ),
                    Text(
                      "₹${cart.totalPrice.toStringAsFixed(0)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                /// CHECKOUT BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.checkout,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E6CF6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Proceed to Checkout",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: Colors.black
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ================= QTY BUTTON =================
  Widget _qtyButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFF2E6CF6).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF2E6CF6)),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// EMPTY CART UI
////////////////////////////////////////////////////////////

class _AnimatedEmptyCart extends StatefulWidget {
  const _AnimatedEmptyCart();

  @override
  State<_AnimatedEmptyCart> createState() => _AnimatedEmptyCartState();
}

class _AnimatedEmptyCartState extends State<_AnimatedEmptyCart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 700));

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween(begin: 0.9, end: 1.0)
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
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// ICON
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: const Color(0xFF161A22),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 25,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  size: 48,
                  color: Color(0xFF2E6CF6),
                ),
              ),

              const SizedBox(height: 24),

              /// TITLE
              const Text(
                "Your cart is empty",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              /// SUBTITLE
              const Text(
                "Add products to start your order",
                style: TextStyle(
                  color: Color(0xFFA1A6B3),
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 28),

              /// EXPLORE BUTTON
              SizedBox(
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.products);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E6CF6),
                    padding: const EdgeInsets.symmetric(horizontal: 26),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 6,
                  ),
                  child: const Text(
                    "Explore Products",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

