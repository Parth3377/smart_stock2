import 'package:flutter/material.dart';
import '../../services/order_draft_service.dart';
import '../../models/order_item_model.dart';

class OrderDraftScreen extends StatefulWidget {
  const OrderDraftScreen({super.key});

  @override
  State<OrderDraftScreen> createState() => _OrderDraftScreenState();
}

class _OrderDraftScreenState extends State<OrderDraftScreen> {
  @override
  Widget build(BuildContext context) {
    final List<OrderItemModel> items = OrderDraftService.items;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1218),

      appBar: AppBar(
        backgroundColor: const Color(0xFF161A22),
        elevation: 0,
        title: const Text("My Cart"),
        centerTitle: true,
      ),

      body: items.isEmpty
          ? const Center(
        child: Text(
          "Your cart is empty",
          style: TextStyle(color: Colors.white70),
        ),
      )
          : Column(
        children: [
          /// ITEM LIST
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return _CartItemTile(
                  item: item,
                  onChanged: () => setState(() {}),
                );
              },
            ),
          ),

          /// TOTAL + CHECKOUT
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF161A22),
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total",
                      style: TextStyle(color: Colors.white70),
                    ),
                    Text(
                      "₹${OrderDraftService.totalAmount.toStringAsFixed(0)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Checkout coming next…"),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E6CF6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Proceed to Checkout"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

///////////////////////////////////////////////////////////////////////////////
/// CART ITEM TILE
///////////////////////////////////////////////////////////////////////////////

class _CartItemTile extends StatelessWidget {
  final OrderItemModel item;
  final VoidCallback onChanged;

  const _CartItemTile({required this.item, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF161A22),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          /// IMAGE
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              item.image,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
              const Icon(Icons.image_not_supported, color: Colors.white38),
            ),
          ),

          const SizedBox(width: 12),

          /// NAME + PRICE
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(color: Colors.white)),
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
              IconButton(
                icon: const Icon(Icons.remove, color: Colors.white),
                onPressed: () {
                  if (item.quantity > 1) {
                    OrderDraftService.updateQuantity(item.id, item.quantity - 1);
                  } else {
                    OrderDraftService.removeItem(item.id);
                  }
                  onChanged();
                },
              ),
              Text("${item.quantity}", style: const TextStyle(color: Colors.white)),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: () {
                  OrderDraftService.updateQuantity(item.id, item.quantity + 1);
                  onChanged();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
