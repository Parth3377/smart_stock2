import 'package:flutter/material.dart';
import '../../services/order_draft_service.dart';
import '../../routes/app_routes.dart';
import 'package:provider/provider.dart';
import '../../providers/order_draft_provider.dart';


class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderDraftProvider>();
    final cartItems = provider.items;
    final total = provider.totalPrice;


    return Scaffold(
      backgroundColor: const Color(0xFF0F1218),

      appBar: AppBar(
        backgroundColor: const Color(0xFF161A22),
        elevation: 0,
        title: const Text("Checkout"),
        centerTitle: true,
      ),

      /// ================= EMPTY CART =================
      body: cartItems.isEmpty
          ? const Center(
        child: Text(
          "Your cart is empty",
          style: TextStyle(color: Colors.white70, fontSize: 15),
        ),
      )

      /// ================= CART CONTENT =================
          : Column(
        children: [
          /// ================= CART ITEMS LIST =================
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161A22),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      /// PRODUCT IMAGE
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          item.product.image,
                          width: 50,
                          height: 50,
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
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// QUANTITY
                      Text(
                        "x${item.quantity}",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          /// ================= TOTAL + BUTTON SECTION =================
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              decoration: const BoxDecoration(
                color: Color(0xFF161A22),
                borderRadius:
                BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// TOTAL ROW
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
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

                  const SizedBox(height: 16),

                  /// PROCEED TO PAYMENT BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.payment,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E6CF6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Proceed to Payment",
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
          ),
        ],
      ),
    );
  }
}
