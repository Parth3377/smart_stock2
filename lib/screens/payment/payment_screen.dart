import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/order_draft_provider.dart';
import '../../routes/app_routes.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = "UPI";
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<OrderDraftProvider>();
    final total = cart.totalPrice;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1218),

      appBar: AppBar(
        backgroundColor: const Color(0xFF161A22),
        elevation: 0,
        title: const Text("Payment"),
        centerTitle: true,
      ),

      body: cart.items.isEmpty
          ? const Center(
        child: Text(
          "Cart is empty",
          style: TextStyle(color: Colors.white70),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// ================= TOTAL =================
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF161A22),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total Amount",
                    style: TextStyle(color: Colors.white70 , fontWeight: FontWeight.w900),
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
            ),

            const SizedBox(height: 24),

            /// ================= PAYMENT METHODS =================
            const Text(
              "Select Payment Method",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),

            _methodTile("UPI", Icons.account_balance_wallet),
            _methodTile("Card", Icons.credit_card),
            _methodTile("Cash on Delivery", Icons.money),

            const Spacer(),

            /// ================= PAY BUTTON =================
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : () => _pay(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E6CF6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "Pay Now",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= PAYMENT METHOD TILE =================
  Widget _methodTile(String method, IconData icon) {
    final selected = _selectedMethod == method;

    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = method),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF2E6CF6).withValues(alpha: 0.15)
              : const Color(0xFF161A22),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? const Color(0xFF2E6CF6) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                method,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, color: Color(0xFF2E6CF6)),
          ],
        ),
      ),
    );
  }

  /// ================= PAY LOGIC =================
  Future<void> _pay(BuildContext context) async {
    setState(() => _loading = true);

    await Future.delayed(const Duration(seconds: 2)); // simulate payment

    final cart = context.read<OrderDraftProvider>();

    /// CREATE ORDER MODEL
    final order = OrderModel.createFromDraft(
      items: cart.items,
      paymentMethod: _selectedMethod, draftItems: [], address: '',
    );

    /// SAVE ORDER (TEMP LOCAL SERVICE)
    OrderService.addOrder(order);

    /// CLEAR CART
    cart.clearCart();

    if (!mounted) return;

    /// NAVIGATE SUCCESS
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.orderSuccess,
          (route) => route.settings.name == AppRoutes.dashboard,
    );
  }
}
