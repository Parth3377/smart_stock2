import 'package:flutter/material.dart';
import '../../models/product_model.dart';

class OrderDraftScreen extends StatefulWidget {
  const OrderDraftScreen({super.key});

  @override
  State<OrderDraftScreen> createState() => _OrderDraftScreenState();
}

class _OrderDraftScreenState extends State<OrderDraftScreen> {
  /// 🔹 Temporary local cart (later from provider / Firebase)
  final List<_CartItem> _cart = [
    _CartItem(
      product: ProductModel(
        id: "1",
        name: "Security Labels",
        description: "High quality security labels.",
        image: "assets/products/label1.png",
        price: 120,
        category: "Labels",
      ),
      quantity: 2,
    ),
  ];

  double get total =>
      _cart.fold(0, (sum, item) => sum + item.product.price * item.quantity);

  void _increaseQty(int index) {
    setState(() => _cart[index].quantity++);
  }

  void _decreaseQty(int index) {
    setState(() {
      if (_cart[index].quantity > 1) {
        _cart[index].quantity--;
      } else {
        _cart.removeAt(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1218),

      appBar: AppBar(
        backgroundColor: const Color(0xFF161A22),
        elevation: 0,
        title: const Text("Order Draft"),
        centerTitle: true,
      ),

      body: _cart.isEmpty
          ? const Center(
        child: Text(
          "Your cart is empty",
          style: TextStyle(color: Colors.white70),
        ),
      )
          : Column(
        children: [
          /// 🧾 CART LIST
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _cart.length,
              itemBuilder: (_, index) {
                final item = _cart[index];
                return _CartTile(
                  item: item,
                  onAdd: () => _increaseQty(index),
                  onRemove: () => _decreaseQty(index),
                );
              },
            ),
          ),

          /// 💰 TOTAL + CHECKOUT
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF161A22),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Total: ₹${total.toStringAsFixed(0)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/checkout');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E6CF6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Checkout"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

///////////////////////////////////////////////////////////////////////////
/// CART TILE
///////////////////////////////////////////////////////////////////////////

class _CartTile extends StatelessWidget {
  final _CartItem item;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _CartTile({
    required this.item,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  "₹${item.product.price.toStringAsFixed(0)}",
                  style: const TextStyle(color: Color(0xFF2E6CF6)),
                ),
              ],
            ),
          ),

          /// QUANTITY CONTROL
          Row(
            children: [
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.remove, color: Colors.white70),
              ),
              Text(
                item.quantity.toString(),
                style: const TextStyle(color: Colors.white),
              ),
              IconButton(
                onPressed: onAdd,
                icon: const Icon(Icons.add, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

///////////////////////////////////////////////////////////////////////////
/// CART ITEM MODEL (temporary)
///////////////////////////////////////////////////////////////////////////

class _CartItem {
  final ProductModel product;
  int quantity;

  _CartItem({required this.product, required this.quantity});
}
