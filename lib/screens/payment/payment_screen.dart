import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/order_draft_provider.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';
import '../../routes/app_routes.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String selectedMethod = "UPI";
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final draftProvider = context.watch<OrderDraftProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F1218),

      appBar: AppBar(
        backgroundColor: const Color(0xFF161A22),
        elevation: 0,
        title: const Text("Payment"),
        centerTitle: true,
      ),

      body: Column(
        children: [

          /// ================= PAYMENT METHODS =================
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [

                const Text(
                  "Select Payment Method",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 16),

                _paymentOption("UPI", Icons.account_balance_wallet_outlined),
                _paymentOption("Card", Icons.credit_card_outlined),
                _paymentOption("Cash on Delivery", Icons.payments_outlined),

              ],
            ),
          ),

          /// ================= PAY BUTTON =================
          Container(
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
                  onPressed: loading
                      ? null
                      : () async {
                    setState(() => loading = true);

                    await Future.delayed(
                        const Duration(seconds: 1));

                    final newOrder =
                    OrderModel.createFromDraft(
                      draftItems: draftProvider.items,
                      paymentMethod: selectedMethod,
                      address:
                      "Kolkata, West Bengal",
                    );

                    OrderService.addOrder(newOrder);

                    draftProvider.clearCart();

                    if (!mounted) return;

                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.orderSuccess,
                          (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E6CF6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: loading
                      ? const CircularProgressIndicator(
                      color: Colors.white)
                      : const Text(
                    "Pay Now",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ////////////////////////////////////////////////////////////
  /// PAYMENT OPTION CARD
  ////////////////////////////////////////////////////////////

  Widget _paymentOption(String title, IconData icon) {
    final bool selected = selectedMethod == title;

    return GestureDetector(
      onTap: () {
        setState(() => selectedMethod = title);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF161A22),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? const Color(0xFF2E6CF6)
                : Colors.white12,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected
                  ? const Color(0xFF2E6CF6)
                  : Colors.white70,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: selected
                      ? Colors.white
                      : Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle,
                  color: Color(0xFF2E6CF6)),
          ],
        ),
      ),
    );
  }
}