import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/order_draft_provider.dart';
import '../../providers/notification_provider.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';
import '../../routes/app_routes.dart';
import '../../widgets/glass_bottom_navbar.dart';
import 'upi_payment_screen.dart';
import 'card_payment_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {

  String? selectedMethod;
  bool loading = false;

  @override
  Widget build(BuildContext context) {

    final draftProvider = context.watch<OrderDraftProvider>();
    final double subtotal = draftProvider.items.fold(
        0, (sum, item) => sum + (item.product.price * item.quantity));
    final double delivery = subtotal > 0 ? 40 : 0;
    final double total    = subtotal + delivery;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      bottomNavigationBar: GlassBottomNavbar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
          if (index == 1) Navigator.pushReplacementNamed(context, AppRoutes.products);
          if (index == 3) Navigator.pushReplacementNamed(context, AppRoutes.profile);
        },
      ),

      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        title: Text('Payment Method'),
        centerTitle: true,
      ),

      body: Column(children: [

        // ── Payment method list ────────────────────────────────────
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [

              Text('Choose how you want to pay',
                  style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 14)),
              const SizedBox(height: 20),

              _option('UPI', 'Google Pay, PhonePe, Paytm', Icons.account_balance_wallet_outlined),
              _option('Credit / Debit Card', 'Visa, Mastercard, RuPay', Icons.credit_card_outlined),
              _option('Cash on Delivery', 'Pay when product arrives',   Icons.payments_outlined),

              const SizedBox(height: 16),

              // Order summary
              if (subtotal > 0) Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(children: [
                  _summaryRow('Subtotal', '₹${subtotal.toStringAsFixed(0)}'),
                  const SizedBox(height: 8),
                  _summaryRow('Delivery',  '₹${delivery.toStringAsFixed(0)}'),
                  Divider(color: Theme.of(context).brightness == Brightness.dark ? Colors.white12 : Colors.black12, height: 20),
                  _summaryRow('Total', '₹${total.toStringAsFixed(0)}',
                      isBold: true, color: const Color(0xFF2E6CF6)),
                ]),
              ),
            ],
          ),
        ),

        // ── Pay button ─────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration:  BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: loading ? null : () => _placeOrder(context, draftProvider, total),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E6CF6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: loading
                    ? const SizedBox(width: 24, height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(
                    selectedMethod == 'Cash on Delivery'
                        ? 'Place Order • ₹${total.toStringAsFixed(0)}'
                        : 'Pay ₹${total.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 16,
                        fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  // ── Place order — routes based on selected payment method ──────────
  void _placeOrder(BuildContext ctx, OrderDraftProvider draft, double total) {
    if (selectedMethod == null) {
      ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(content: Text('Please select a payment method'),
              behavior: SnackBarBehavior.floating));
      return;
    }

    if (draft.items.isEmpty) {
      ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(content: Text('Your cart is empty'),
              behavior: SnackBarBehavior.floating));
      return;
    }

    // Build the order object once — passed to payment screens
    final order = OrderModel.createFromDraft(
      draftItems:    draft.items,
      paymentMethod: selectedMethod!,
      address:       'Ahmedabad, Gujarat',
    );

    if (selectedMethod == 'UPI') {
      // Navigate to UPI screen — it will place the order on success
      Navigator.push(ctx, MaterialPageRoute(
        builder: (_) => UpiPaymentScreen(
          order: order,
          draft: draft,
          total: total,
        ),
      ));
      return;
    }

    if (selectedMethod == 'Credit / Debit Card') {
      // Navigate to Card screen — it will place the order on success
      Navigator.push(ctx, MaterialPageRoute(
        builder: (_) => CardPaymentScreen(
          order: order,
          draft: draft,
          total: total,
        ),
      ));
      return;
    }

    // Cash on Delivery — place order directly, go to success
    setState(() => loading = true);
    OrderService.addOrder(order);
    try {
      ctx.read<NotificationProvider>().addNotification(
        title:   '🎉 Order Placed!',
        body:    'Your order ${order.id} has been placed for ₹${order.total.toStringAsFixed(0)}.',
        type:    'order_placed',
        orderId: order.id,
      );
    } catch (_) {}
    draft.clearCart();
    setState(() => loading = false);
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
        ctx, AppRoutes.orderSuccess, (route) => false);
  }

  // ── Summary row helper ─────────────────────────────────────────────
  Widget _summaryRow(String label, String value,
      {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(
            color: isBold ? Theme.of(context).textTheme.bodyLarge?.color : Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: TextStyle(
            color: color ?? (isBold ? Theme.of(context).textTheme.bodyLarge?.color : Theme.of(context).textTheme.bodyMedium?.color),
            fontSize: isBold ? 16 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  // ── Payment option card ────────────────────────────────────────────
  Widget _option(String title, String subtitle, IconData icon) {
    final bool selected = selectedMethod == title;
    return GestureDetector(
      onTap: () => setState(() => selectedMethod = title),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: selected
                  ? const Color(0xFF2E6CF6)
                  : Theme.of(context).brightness == Brightness.dark
                      ? Colors.white12
                      : Colors.black12,
              width: 1.5),
        ),
        child: Row(children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
                color: selected ? const Color(0xFF2E6CF6) : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: selected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(
                  color: selected ? const Color(0xFF2E6CF6) : Theme.of(context).textTheme.bodyMedium?.color,
                  fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 12)),
            ],
          )),
          Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? Color(0xFF2E6CF6) : Theme.of(context).textTheme.bodySmall?.color),
        ]),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../providers/order_draft_provider.dart';
// import '../../providers/notification_provider.dart';
// import '../../models/order_model.dart';
// import '../../services/order_service.dart';
// import '../../routes/app_routes.dart';
// import '../../widgets/glass_bottom_navbar.dart';
// import 'upi_payment_screen.dart';
// import 'card_payment_screen.dart';
//
// class PaymentScreen extends StatefulWidget {
//   const PaymentScreen({super.key});
//
//   @override
//   State<PaymentScreen> createState() => _PaymentScreenState();
// }
//
// class _PaymentScreenState extends State<PaymentScreen> {
//
//   String? selectedMethod;
//   bool loading = false;
//
//   @override
//   Widget build(BuildContext context) {
//
//     final draftProvider = context.watch<OrderDraftProvider>();
//     final double subtotal = draftProvider.items.fold(
//         0, (sum, item) => sum + (item.product.price * item.quantity));
//     final double delivery = subtotal > 0 ? 40 : 0;
//     final double total    = subtotal + delivery;
//
//     return Scaffold(
//       backgroundColor: const Color(0xFF0F1218),
//
//       bottomNavigationBar: GlassBottomNavbar(
//         currentIndex: 2,
//         onTap: (index) {
//           if (index == 0) Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
//           if (index == 1) Navigator.pushReplacementNamed(context, AppRoutes.products);
//           if (index == 3) Navigator.pushReplacementNamed(context, AppRoutes.profile);
//         },
//       ),
//
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF161A22),
//         elevation: 0,
//         title: const Text('Payment Method'),
//         centerTitle: true,
//       ),
//
//       body: Column(children: [
//
//         // ── Payment method list ────────────────────────────────────
//         Expanded(
//           child: ListView(
//             padding: const EdgeInsets.all(16),
//             children: [
//
//               const Text('Choose how you want to pay',
//                   style: TextStyle(color: Colors.white70, fontSize: 14)),
//               const SizedBox(height: 20),
//
//               _option('UPI',              'Google Pay, PhonePe, Paytm', Icons.account_balance_wallet_outlined),
//               _option('Credit / Debit Card', 'Visa, Mastercard, RuPay', Icons.credit_card_outlined),
//               _option('Cash on Delivery', 'Pay when product arrives',   Icons.payments_outlined),
//
//               const SizedBox(height: 16),
//
//               // Order summary
//               if (subtotal > 0) Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF161A22),
//                   borderRadius: BorderRadius.circular(14),
//                 ),
//                 child: Column(children: [
//                   _summaryRow('Subtotal', '₹${subtotal.toStringAsFixed(0)}'),
//                   const SizedBox(height: 8),
//                   _summaryRow('Delivery',  '₹${delivery.toStringAsFixed(0)}'),
//                   const Divider(color: Colors.white12, height: 20),
//                   _summaryRow('Total', '₹${total.toStringAsFixed(0)}',
//                       isBold: true, color: const Color(0xFF2E6CF6)),
//                 ]),
//               ),
//             ],
//           ),
//         ),
//
//         // ── Pay button ─────────────────────────────────────────────
//         Container(
//           padding: const EdgeInsets.all(16),
//           decoration: const BoxDecoration(
//             color: Color(0xFF161A22),
//             borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//           ),
//           child: SafeArea(
//             child: SizedBox(
//               width: double.infinity,
//               height: 54,
//               child: ElevatedButton(
//                 onPressed: loading ? null : () => _placeOrder(context, draftProvider, total),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF2E6CF6),
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(14)),
//                 ),
//                 child: loading
//                     ? const SizedBox(width: 24, height: 24,
//                     child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
//                     : Text(
//                     selectedMethod == 'Cash on Delivery'
//                         ? 'Place Order • ₹${total.toStringAsFixed(0)}'
//                         : 'Pay ₹${total.toStringAsFixed(0)}',
//                     style: const TextStyle(fontSize: 16,
//                         fontWeight: FontWeight.w600, color: Colors.white)),
//               ),
//             ),
//           ),
//         ),
//       ]),
//     );
//   }
//
//   // ── Place order — routes based on selected payment method ──────────
//   void _placeOrder(BuildContext ctx, OrderDraftProvider draft, double total) {
//     if (selectedMethod == null) {
//       ScaffoldMessenger.of(ctx).showSnackBar(
//           const SnackBar(content: Text('Please select a payment method'),
//               behavior: SnackBarBehavior.floating));
//       return;
//     }
//
//     if (draft.items.isEmpty) {
//       ScaffoldMessenger.of(ctx).showSnackBar(
//           const SnackBar(content: Text('Your cart is empty'),
//               behavior: SnackBarBehavior.floating));
//       return;
//     }
//
//     // Build the order object once — passed to payment screens
//     final order = OrderModel.createFromDraft(
//       draftItems:    draft.items,
//       paymentMethod: selectedMethod!,
//       address:       'Ahmedabad, Gujarat',
//     );
//
//     if (selectedMethod == 'UPI') {
//       // Navigate to UPI screen — it will place the order on success
//       Navigator.push(ctx, MaterialPageRoute(
//         builder: (_) => UpiPaymentScreen(
//           order: order,
//           draft: draft,
//           total: total,
//         ),
//       ));
//       return;
//     }
//
//     if (selectedMethod == 'Credit / Debit Card') {
//       // Navigate to Card screen — it will place the order on success
//       Navigator.push(ctx, MaterialPageRoute(
//         builder: (_) => CardPaymentScreen(
//           order: order,
//           draft: draft,
//           total: total,
//         ),
//       ));
//       return;
//     }
//
//     // Cash on Delivery — place order directly, go to success
//     setState(() => loading = true);
//     OrderService.addOrder(order);
//     try {
//       ctx.read<NotificationProvider>().addNotification(
//         title:   '🎉 Order Placed!',
//         body:    'Your order ${order.id} has been placed for ₹${order.total.toStringAsFixed(0)}.',
//         type:    'order_placed',
//         orderId: order.id,
//       );
//     } catch (_) {}
//     draft.clearCart();
//     setState(() => loading = false);
//     if (!mounted) return;
//     Navigator.pushNamedAndRemoveUntil(
//         ctx, AppRoutes.orderSuccess, (route) => false);
//   }
//
//   // ── Summary row helper ─────────────────────────────────────────────
//   Widget _summaryRow(String label, String value,
//       {bool isBold = false, Color? color}) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(label, style: TextStyle(
//             color: isBold ? Colors.white : Colors.white70,
//             fontSize: isBold ? 15 : 13,
//             fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
//         Text(value, style: TextStyle(
//             color: color ?? (isBold ? Colors.white : Colors.white70),
//             fontSize: isBold ? 16 : 13,
//             fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
//       ],
//     );
//   }
//
//   // ── Payment option card ────────────────────────────────────────────
//   Widget _option(String title, String subtitle, IconData icon) {
//     final bool selected = selectedMethod == title;
//     return GestureDetector(
//       onTap: () => setState(() => selectedMethod = title),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         margin: const EdgeInsets.only(bottom: 14),
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: const Color(0xFF161A22),
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(
//               color: selected ? const Color(0xFF2E6CF6) : Colors.white12,
//               width: 1.5),
//         ),
//         child: Row(children: [
//           Container(
//             width: 42, height: 42,
//             decoration: BoxDecoration(
//                 color: selected ? const Color(0xFF2E6CF6) : Colors.white10,
//                 borderRadius: BorderRadius.circular(10)),
//             child: Icon(icon, color: selected ? Colors.white : Colors.white70),
//           ),
//           const SizedBox(width: 14),
//           Expanded(child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(title, style: TextStyle(
//                   color: selected ? Colors.white : Colors.white70,
//                   fontSize: 15, fontWeight: FontWeight.w600)),
//               const SizedBox(height: 4),
//               Text(subtitle, style: const TextStyle(
//                   color: Colors.white38, fontSize: 12)),
//             ],
//           )),
//           Icon(
//               selected ? Icons.radio_button_checked : Icons.radio_button_off,
//               color: selected ? const Color(0xFF2E6CF6) : Colors.white30),
//         ]),
//       ),
//     );
//   }
// }