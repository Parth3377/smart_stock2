import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/order_draft_provider.dart';
import '../../routes/app_routes.dart';

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

      /// ================= BODY =================
      body: cartItems.isEmpty
          ? const Center(
        child: Text(
          "Your cart is empty",
          style: TextStyle(color: Colors.white70),
        ),
      )
          : Column(
        children: [
          /// ================= ITEMS + ADDRESS + SUMMARY =================
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                /// ORDER ITEMS
                const _SectionTitle("Order Items"),
                const SizedBox(height: 12),

                ...cartItems
                    .map((item) => _CheckoutItemTile(item: item))
                    .toList(),

                const SizedBox(height: 24),

                /// DELIVERY ADDRESS
                const _SectionTitle("Delivery Address"),
                const SizedBox(height: 12),
                const _AddressCard(),

                const SizedBox(height: 24),

                /// ORDER SUMMARY
                const _SectionTitle("Order Summary"),
                const SizedBox(height: 12),
                _OrderSummary(total: total),

                const SizedBox(height: 120),
              ],
            ),
          ),

          /// ================= CONTINUE BUTTON =================
          _CheckoutBottomBar(total: total),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// SECTION TITLE
////////////////////////////////////////////////////////////

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// CHECKOUT ITEM TILE
////////////////////////////////////////////////////////////

class _CheckoutItemTile extends StatelessWidget {
  final dynamic item;
  const _CheckoutItemTile({required this.item});

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
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              item.product.image,
              width: 52,
              height: 52,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(width: 12),

          /// NAME + QTY
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
                  "Qty: ${item.quantity}",
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),

          /// PRICE
          Text(
            "₹${(item.product.price * item.quantity).toStringAsFixed(0)}",
            style: const TextStyle(
              color: Color(0xFF2E6CF6),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// ADDRESS CARD
////////////////////////////////////////////////////////////

class _AddressCard extends StatelessWidget {
  const _AddressCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF161A22),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: const [
          Icon(Icons.location_on_outlined, color: Color(0xFF2E6CF6)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Kolkata, West Bengal\nIndia",
              style: TextStyle(color: Colors.white),
            ),
          ),
          Icon(Icons.edit_outlined, color: Colors.white54, size: 18),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// ORDER SUMMARY
////////////////////////////////////////////////////////////

class _OrderSummary extends StatelessWidget {
  final double total;
  const _OrderSummary({required this.total});

  @override
  Widget build(BuildContext context) {
    const delivery = 40.0;
    final grandTotal = total + delivery;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF161A22),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          _row("Subtotal", total),
          _row("Delivery", delivery),
          const Divider(color: Colors.white12, height: 20),
          _row("Total", grandTotal, isBold: true),
        ],
      ),
    );
  }

  Widget _row(String title, double value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white70,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          "₹${value.toStringAsFixed(0)}",
          style: TextStyle(
            color: Colors.white,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

////////////////////////////////////////////////////////////
/// BOTTOM BAR (CONTINUE TO PAYMENT)
////////////////////////////////////////////////////////////

class _CheckoutBottomBar extends StatelessWidget {
  final double total;
  const _CheckoutBottomBar({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF161A22),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.payment);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E6CF6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              "Continue to Payment",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600 , color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }
}
