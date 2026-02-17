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
          ? const _EmptyCart()
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
                      TextStyle(color: Colors.white70, fontSize: 16),
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
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
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

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Your cart is empty",
        style: TextStyle(color: Colors.white54, fontSize: 16),
      ),
    );
  }
}
