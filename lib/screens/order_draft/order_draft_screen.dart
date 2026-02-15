import 'package:flutter/material.dart';
import '../../core/cart_manager.dart';
import '../../models/cart_item_model.dart';

class OrderDraftScreen extends StatelessWidget {
  const OrderDraftScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1218),

      appBar: AppBar(
        backgroundColor: const Color(0xFF161A22),
        elevation: 0,
        title: const Text("Your Cart"),
        centerTitle: true,
      ),

      body: ValueListenableBuilder(
        valueListenable: CartManager.cartCount,
        builder: (context, _, __) {
          final items = CartManager.items;

          /// 🟡 EMPTY CART
          if (items.isEmpty) {
            return const Center(
              child: Text(
                "Your cart is empty",
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          /// 🟢 CART LIST
          return Column(
            children: [

              /// ITEM LIST
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _CartItemTile(item: item);
                  },
                ),
              ),

              /// TOTAL + CHECKOUT
              _CheckoutSection(),
            ],
          );
        },
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////
/// 🧾 CART ITEM TILE
////////////////////////////////////////////////////////////////////////

class _CartItemTile extends StatelessWidget {
  final CartItemModel item;

  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF161A22),
        borderRadius: BorderRadius.circular(16),
      ),

      child: Row(
        children: [

          /// PRODUCT IMAGE
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              item.image,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(width: 14),

          /// NAME + PRICE
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "₹${item.price.toStringAsFixed(0)}",
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          /// QUANTITY CONTROLS
          Row(
            children: [

              _qtyButton(Icons.remove, () {
                if (item.quantity > 1) {
                  CartManager.updateQuantity(item.productId, item.quantity - 1);
                } else {
                  CartManager.removeFromCart(item.productId);
                }
              }),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  item.quantity.toString(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),

              _qtyButton(Icons.add, () {
                CartManager.updateQuantity(item.productId, item.quantity + 1);
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFF2E6CF6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: Colors.white),
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////
/// 💳 CHECKOUT SECTION
////////////////////////////////////////////////////////////////////////

class _CheckoutSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final total = CartManager.totalAmount;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: const BoxDecoration(
        color: Color(0xFF161A22),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          /// TOTAL ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Amount",
                style: TextStyle(color: Colors.white70),
              ),
              Text(
                "₹${total.toStringAsFixed(0)}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          /// CHECKOUT BUTTON
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Checkout flow coming next"),
                  ),
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
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
