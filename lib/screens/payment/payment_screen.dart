import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../services/order_draft_service.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  void _completePayment(BuildContext context) {
    /// Clear cart after payment
    OrderDraftService.clear();

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.orderSuccess,
          (route) => false,
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1218),

      appBar: AppBar(
        backgroundColor: const Color(0xFF161A22),
        elevation: 0,
        title: const Text("Payment"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _paymentTile("Cash on Delivery", Icons.money),
            _paymentTile("UPI Payment", Icons.qr_code),
            _paymentTile("Card Payment", Icons.credit_card),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => _completePayment(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E6CF6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Pay Now"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentTile(String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161A22),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
