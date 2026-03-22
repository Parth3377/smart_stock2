// ════════════════════════════════════════════════════════════════════
//  lib/screens/payment/upi_payment_screen.dart
// ════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/order_model.dart';
import '../../providers/order_draft_provider.dart';
import '../../providers/notification_provider.dart';
import '../../services/order_service.dart';
import '../../routes/app_routes.dart';

class UpiPaymentScreen extends StatefulWidget {
  final OrderModel         order;
  final OrderDraftProvider draft;
  final double             total;

  const UpiPaymentScreen({
    super.key,
    required this.order,
    required this.draft,
    required this.total,
  });

  @override
  State<UpiPaymentScreen> createState() => _UpiPaymentScreenState();
}

class _UpiPaymentScreenState extends State<UpiPaymentScreen>
    with SingleTickerProviderStateMixin {

  final _upiController = TextEditingController();
  String? _selectedApp;
  bool    _isPaying    = false;

  late AnimationController _animCtrl;
  late Animation<double>   _fadeAnim;
  late Animation<double>   _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim  = Tween(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _slideAnim = Tween(begin: 30.0, end: 0.0)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _upiController.dispose();
    super.dispose();
  }

  // ── Place order and navigate to success ───────────────────────────
  void _pay() async {
    if (_selectedApp == null && _upiController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter UPI ID or select a payment app'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent,
      ));
      return;
    }

    setState(() => _isPaying = true);
    await Future.delayed(const Duration(seconds: 2)); // Simulate processing

    // Place order
    OrderService.addOrder(widget.order);
    try {
      if (mounted) {
        context.read<NotificationProvider>().addNotification(
          title:   '🎉 Order Placed!',
          body:    'Your order ${widget.order.id} has been placed for ₹${widget.order.total.toStringAsFixed(0)}.',
          type:    'order_placed',
          orderId: widget.order.id,
        );
      }
    } catch (_) {}

    widget.draft.clearCart();
    setState(() => _isPaying = false);

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
        context, AppRoutes.orderSuccess, (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        title: const Text('UPI Payment'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: AnimatedBuilder(
        animation: _animCtrl,
        builder: (_, child) => Opacity(
          opacity: _fadeAnim.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnim.value),
            child: child,
          ),
        ),
        child: Column(children: [

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Amount card ──────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A2744), Color(0xFF0F1218)],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFF2E6CF6).withOpacity(0.3)),
                    ),
                    child: Column(children: [
                      const Text('Total Amount',
                          style: TextStyle(color: Colors.white60, fontSize: 13)),
                      const SizedBox(height: 8),
                      Text(
                        '₹${widget.total.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('SmartStock2',
                          style: TextStyle(color: Color(0xFF2E6CF6), fontSize: 12)),
                    ]),
                  ),

                  const SizedBox(height: 24),

                  // ── UPI ID input ─────────────────────────────────
                  Text('Enter UPI ID',
                      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: TextField(
                      controller: _upiController,
                      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                      decoration: InputDecoration(
                        hintText: 'example@ybl or mobile@upi',
                        hintStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                        prefixIcon: Icon(Icons.account_balance_wallet_outlined,
                            color: Color(0xFF2E6CF6)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Pay using apps ───────────────────────────────
                  Text('Or pay using',
                      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      _appTile('GPay',    Icons.g_mobiledata_rounded,   const Color(0xFF4285F4)),
                      const SizedBox(width: 12),
                      _appTile('PhonePe', Icons.phone_android_outlined,  const Color(0xFF5F259F)),
                      const SizedBox(width: 12),
                      _appTile('Paytm',   Icons.payment_outlined,        const Color(0xFF00BAF2)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── QR option ────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E6CF6).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.qr_code_2_outlined,
                            color: Color(0xFF2E6CF6), size: 22),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Scan & Pay',
                              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color,
                                  fontWeight: FontWeight.w600)),
                          Text('Open your UPI app and scan QR',
                              style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 12)),
                        ],
                      ),
                    ]),
                  ),

                  const SizedBox(height: 16),

                  // ── Security note ────────────────────────────────
                  Row(children: [
                    Icon(Icons.lock_outline,
                        color: Theme.of(context).textTheme.bodySmall?.color, size: 14),
                    const SizedBox(width: 6),
                    Text('100% secure payment via UPI',
                        style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 12)),
                  ]),
                ],
              ),
            ),
          ),

          // ── Pay button ───────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isPaying ? null : _pay,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E6CF6),
                    disabledBackgroundColor: Colors.white10,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isPaying
                      ? const SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                      : Text(
                    'Pay ₹${widget.total.toStringAsFixed(0)} via UPI',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  // ── UPI app tile ───────────────────────────────────────────────────
  Widget _appTile(String name, IconData icon, Color color) {
    final selected = _selectedApp == name;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _selectedApp = selected ? null : name;
          _upiController.clear();
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected
                ? color.withOpacity(0.15)
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? color : (Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey).withOpacity(0.3),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(children: [
            Icon(icon, color: selected ? color : Theme.of(context).textTheme.bodySmall?.color, size: 26),
            const SizedBox(height: 6),
            Text(name,
                style: TextStyle(
                  color: selected ? color : Colors.white70,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                )),
          ]),
        ),
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../models/order_model.dart';
// import '../../providers/order_draft_provider.dart';
// import '../../providers/notification_provider.dart';
// import '../../services/order_service.dart';
// import '../../routes/app_routes.dart';
//
// class UpiPaymentScreen extends StatefulWidget {
//   final OrderModel         order;
//   final OrderDraftProvider draft;
//   final double             total;
//
//   const UpiPaymentScreen({
//     super.key,
//     required this.order,
//     required this.draft,
//     required this.total,
//   });
//
//   @override
//   State<UpiPaymentScreen> createState() => _UpiPaymentScreenState();
// }
//
// class _UpiPaymentScreenState extends State<UpiPaymentScreen>
//     with SingleTickerProviderStateMixin {
//
//   final _upiController = TextEditingController();
//   String? _selectedApp;
//   bool    _isPaying    = false;
//
//   late AnimationController _animCtrl;
//   late Animation<double>   _fadeAnim;
//   late Animation<double>   _slideAnim;
//
//   @override
//   void initState() {
//     super.initState();
//     _animCtrl = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 500));
//     _fadeAnim  = Tween(begin: 0.0, end: 1.0)
//         .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
//     _slideAnim = Tween(begin: 30.0, end: 0.0)
//         .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
//     _animCtrl.forward();
//   }
//
//   @override
//   void dispose() {
//     _animCtrl.dispose();
//     _upiController.dispose();
//     super.dispose();
//   }
//
//   // ── Place order and navigate to success ───────────────────────────
//   void _pay() async {
//     if (_selectedApp == null && _upiController.text.trim().isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//         content: Text('Please enter UPI ID or select a payment app'),
//         behavior: SnackBarBehavior.floating,
//         backgroundColor: Colors.redAccent,
//       ));
//       return;
//     }
//
//     setState(() => _isPaying = true);
//     await Future.delayed(const Duration(seconds: 2)); // Simulate processing
//
//     // Place order
//     OrderService.addOrder(widget.order);
//     try {
//       if (mounted) {
//         context.read<NotificationProvider>().addNotification(
//           title:   '🎉 Order Placed!',
//           body:    'Your order ${widget.order.id} has been placed for ₹${widget.order.total.toStringAsFixed(0)}.',
//           type:    'order_placed',
//           orderId: widget.order.id,
//         );
//       }
//     } catch (_) {}
//
//     widget.draft.clearCart();
//     setState(() => _isPaying = false);
//
//     if (!mounted) return;
//     Navigator.pushNamedAndRemoveUntil(
//         context, AppRoutes.orderSuccess, (r) => false);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0F1218),
//
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF161A22),
//         elevation: 0,
//         title: const Text('UPI Payment'),
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new, size: 18),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//
//       body: AnimatedBuilder(
//         animation: _animCtrl,
//         builder: (_, child) => Opacity(
//           opacity: _fadeAnim.value,
//           child: Transform.translate(
//             offset: Offset(0, _slideAnim.value),
//             child: child,
//           ),
//         ),
//         child: Column(children: [
//
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//
//                   // ── Amount card ──────────────────────────────────
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       gradient: const LinearGradient(
//                         colors: [Color(0xFF1A2744), Color(0xFF0F1218)],
//                         begin: Alignment.topLeft, end: Alignment.bottomRight,
//                       ),
//                       borderRadius: BorderRadius.circular(18),
//                       border: Border.all(color: const Color(0xFF2E6CF6).withOpacity(0.3)),
//                     ),
//                     child: Column(children: [
//                       const Text('Total Amount',
//                           style: TextStyle(color: Colors.white60, fontSize: 13)),
//                       const SizedBox(height: 8),
//                       Text(
//                         '₹${widget.total.toStringAsFixed(0)}',
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 32,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       const Text('SmartStock2',
//                           style: TextStyle(color: Color(0xFF2E6CF6), fontSize: 12)),
//                     ]),
//                   ),
//
//                   const SizedBox(height: 24),
//
//                   // ── UPI ID input ─────────────────────────────────
//                   const Text('Enter UPI ID',
//                       style: TextStyle(color: Colors.white,
//                           fontSize: 14, fontWeight: FontWeight.w600)),
//                   const SizedBox(height: 10),
//                   Container(
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF161A22),
//                       borderRadius: BorderRadius.circular(14),
//                       border: Border.all(color: Colors.white12),
//                     ),
//                     child: TextField(
//                       controller: _upiController,
//                       style: const TextStyle(color: Colors.white),
//                       decoration: const InputDecoration(
//                         hintText: 'example@ybl or mobile@upi',
//                         hintStyle: TextStyle(color: Colors.white38),
//                         prefixIcon: Icon(Icons.account_balance_wallet_outlined,
//                             color: Color(0xFF2E6CF6)),
//                         border: InputBorder.none,
//                         contentPadding: EdgeInsets.symmetric(
//                             horizontal: 16, vertical: 14),
//                       ),
//                     ),
//                   ),
//
//                   const SizedBox(height: 24),
//
//                   // ── Pay using apps ───────────────────────────────
//                   const Text('Or pay using',
//                       style: TextStyle(color: Colors.white,
//                           fontSize: 14, fontWeight: FontWeight.w600)),
//                   const SizedBox(height: 14),
//
//                   Row(
//                     children: [
//                       _appTile('GPay',    Icons.g_mobiledata_rounded,   const Color(0xFF4285F4)),
//                       const SizedBox(width: 12),
//                       _appTile('PhonePe', Icons.phone_android_outlined,  const Color(0xFF5F259F)),
//                       const SizedBox(width: 12),
//                       _appTile('Paytm',   Icons.payment_outlined,        const Color(0xFF00BAF2)),
//                     ],
//                   ),
//
//                   const SizedBox(height: 20),
//
//                   // ── QR option ────────────────────────────────────
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF161A22),
//                       borderRadius: BorderRadius.circular(14),
//                       border: Border.all(color: Colors.white12),
//                     ),
//                     child: Row(children: [
//                       Container(
//                         padding: const EdgeInsets.all(10),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFF2E6CF6).withOpacity(0.15),
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: const Icon(Icons.qr_code_2_outlined,
//                             color: Color(0xFF2E6CF6), size: 22),
//                       ),
//                       const SizedBox(width: 14),
//                       const Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text('Scan & Pay',
//                               style: TextStyle(color: Colors.white,
//                                   fontWeight: FontWeight.w600)),
//                           Text('Open your UPI app and scan QR',
//                               style: TextStyle(color: Colors.white54, fontSize: 12)),
//                         ],
//                       ),
//                     ]),
//                   ),
//
//                   const SizedBox(height: 16),
//
//                   // ── Security note ────────────────────────────────
//                   Row(children: [
//                     const Icon(Icons.lock_outline,
//                         color: Colors.white38, size: 14),
//                     const SizedBox(width: 6),
//                     const Text('100% secure payment via UPI',
//                         style: TextStyle(color: Colors.white38, fontSize: 12)),
//                   ]),
//                 ],
//               ),
//             ),
//           ),
//
//           // ── Pay button ───────────────────────────────────────────
//           Container(
//             padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
//             decoration: const BoxDecoration(
//               color: Color(0xFF161A22),
//               borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//             ),
//             child: SafeArea(
//               child: SizedBox(
//                 width: double.infinity,
//                 height: 52,
//                 child: ElevatedButton(
//                   onPressed: _isPaying ? null : _pay,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF2E6CF6),
//                     disabledBackgroundColor: Colors.white10,
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(14)),
//                   ),
//                   child: _isPaying
//                       ? const SizedBox(width: 22, height: 22,
//                       child: CircularProgressIndicator(
//                           color: Colors.white, strokeWidth: 2))
//                       : Text(
//                     'Pay ₹${widget.total.toStringAsFixed(0)} via UPI',
//                     style: const TextStyle(
//                       fontSize: 15,
//                       fontWeight: FontWeight.w700,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ]),
//       ),
//     );
//   }
//
//   // ── UPI app tile ───────────────────────────────────────────────────
//   Widget _appTile(String name, IconData icon, Color color) {
//     final selected = _selectedApp == name;
//     return Expanded(
//       child: GestureDetector(
//         onTap: () => setState(() {
//           _selectedApp = selected ? null : name;
//           _upiController.clear();
//         }),
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 200),
//           padding: const EdgeInsets.symmetric(vertical: 14),
//           decoration: BoxDecoration(
//             color: selected
//                 ? color.withOpacity(0.15)
//                 : const Color(0xFF161A22),
//             borderRadius: BorderRadius.circular(14),
//             border: Border.all(
//               color: selected ? color : Colors.white12,
//               width: selected ? 1.5 : 1,
//             ),
//           ),
//           child: Column(children: [
//             Icon(icon, color: selected ? color : Colors.white60, size: 26),
//             const SizedBox(height: 6),
//             Text(name,
//                 style: TextStyle(
//                   color: selected ? color : Colors.white70,
//                   fontSize: 12,
//                   fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
//                 )),
//           ]),
//         ),
//       ),
//     );
//   }
// }