// ════════════════════════════════════════════════════════════════════
//  lib/screens/orders/order_list_screen.dart
//
//  ✅ Streams orders from Firestore in real-time
//  ✅ Falls back to local OrderService.orders if Firestore fails
// ════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';
import 'order_detail_screen.dart';

class OrderListScreen extends StatelessWidget {
  const OrderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        title: Text('My Orders'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<OrderModel>>(
        stream: OrderService.streamUserOrders(),
        builder: (ctx, snap) {

          // Loading
          if (snap.connectionState == ConnectionState.waiting &&
              OrderService.orders.isEmpty) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF2E6CF6)));
          }

          // Use Firestore data if available, else local
          final orders = snap.hasData && snap.data!.isNotEmpty
              ? snap.data!
              : OrderService.orders;

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 80, color: Theme.of(context).textTheme.bodySmall?.color),
                  const SizedBox(height: 16),
                  Text('No orders placed yet',
                      style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Your order history will appear here',
                      style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 13)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (ctx, i) => _OrderCard(order: orders[i]),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  Color _statusColor(String status) {
    switch (status) {
      case 'Delivered': return Colors.green;
      case 'Confirmed': return Colors.orange;
      default:          return const Color(0xFF2E6CF6);
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Delivered': return Icons.check_circle_outline;
      case 'Confirmed': return Icons.local_shipping_outlined;
      default:          return Icons.hourglass_top_outlined;
    }
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => Navigator.push(context,
        MaterialPageRoute(builder: (_) => OrderDetailScreen(order: order))),
    child: Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ID + Status
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(order.id, style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.w600)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _statusColor(order.status).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(children: [
              Icon(_statusIcon(order.status),
                  color: _statusColor(order.status), size: 12),
              const SizedBox(width: 4),
              Text(order.status, style: TextStyle(
                  color: _statusColor(order.status),
                  fontSize: 12, fontWeight: FontWeight.w600)),
            ]),
          ),
        ]),

        const SizedBox(height: 10),

        // Items preview
        if (order.items.isNotEmpty)
          Text(order.items.map((i) => i.name).take(2).join(', ') +
              (order.items.length > 2 ? ' +${order.items.length - 2} more' : ''),
              style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 12),
              overflow: TextOverflow.ellipsis),

        const SizedBox(height: 8),

        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(order.date, style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 12)),
          Text('₹${order.total.toStringAsFixed(0)}',
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 16, fontWeight: FontWeight.bold)),
        ]),

        const SizedBox(height: 8),

        Row(children: [
          Icon(Icons.payment_outlined, size: 14, color: Theme.of(context).textTheme.bodySmall?.color),
          const SizedBox(width: 4),
          Text(order.paymentMethod,
              style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 12)),
          const Spacer(),
          const Text('View Details →',
              style: TextStyle(color: Color(0xFF2E6CF6), fontSize: 12)),
        ]),
      ]),
    ),
  );
}



// import 'package:flutter/material.dart';
// import '../../models/order_model.dart';
// import '../../services/order_service.dart';
// import 'order_detail_screen.dart';
//
// class OrderListScreen extends StatelessWidget {
//   const OrderListScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).cardColor,
//         elevation: 0,
//         title: Text('History'),
//         centerTitle: true,
//       ),
//       body: StreamBuilder<List<OrderModel>>(
//         stream: OrderService.streamUserOrders(),
//         builder: (ctx, snap) {
//
//           // Loading
//           if (snap.connectionState == ConnectionState.waiting &&
//               OrderService.orders.isEmpty) {
//             return const Center(
//                 child: CircularProgressIndicator(color: Color(0xFF2E6CF6)));
//           }
//
//           // Use Firestore data if available, else local
//           final orders = snap.hasData && snap.data!.isNotEmpty
//               ? snap.data!
//               : OrderService.orders;
//
//           if (orders.isEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.receipt_long_outlined,
//                       size: 80, color: Colors.white.withOpacity(0.15)),
//                   const SizedBox(height: 16),
//                   Text('No orders placed yet',
//                       style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 16)),
//                   const SizedBox(height: 8),
//                   Text('Your order history will appear here',
//                       style: TextStyle(color: Colors.white38, fontSize: 13)),
//                 ],
//               ),
//             );
//           }
//
//           return ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: orders.length,
//             itemBuilder: (ctx, i) => _OrderCard(order: orders[i]),
//           );
//         },
//       ),
//     );
//   }
// }
//
// class _OrderCard extends StatelessWidget {
//   final OrderModel order;
//   const _OrderCard({required this.order});
//
//   Color _statusColor(String status) {
//     switch (status) {
//       case 'Delivered': return Colors.green;
//       case 'Confirmed': return Colors.orange;
//       default:          return const Color(0xFF2E6CF6);
//     }
//   }
//
//   IconData _statusIcon(String status) {
//     switch (status) {
//       case 'Delivered': return Icons.check_circle_outline;
//       case 'Confirmed': return Icons.local_shipping_outlined;
//       default:          return Icons.hourglass_top_outlined;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) => GestureDetector(
//     onTap: () => Navigator.push(context,
//         MaterialPageRoute(builder: (_) => OrderDetailScreen(order: order))),
//     child: Container(
//       margin: const EdgeInsets.only(bottom: 14),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Theme.of(context).cardColor,
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//
//         // ID + Status
//         Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//           Text(order.id, style: const TextStyle(
//               color: Colors.white, fontWeight: FontWeight.w600)),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//             decoration: BoxDecoration(
//               color: _statusColor(order.status).withOpacity(0.15),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Row(children: [
//               Icon(_statusIcon(order.status),
//                   color: _statusColor(order.status), size: 12),
//               const SizedBox(width: 4),
//               Text(order.status, style: TextStyle(
//                   color: _statusColor(order.status),
//                   fontSize: 12, fontWeight: FontWeight.w600)),
//             ]),
//           ),
//         ]),
//
//         const SizedBox(height: 10),
//
//         // Items preview
//         if (order.items.isNotEmpty)
//           Text(order.items.map((i) => i.name).take(2).join(', ') +
//               (order.items.length > 2 ? ' +${order.items.length - 2} more' : ''),
//               style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 12),
//               overflow: TextOverflow.ellipsis),
//
//         const SizedBox(height: 8),
//
//         Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//           Text(order.date, style: const TextStyle(color: Colors.white38, fontSize: 12)),
//           Text('₹${order.total.toStringAsFixed(0)}',
//               style: const TextStyle(color: Colors.white,
//                   fontSize: 16, fontWeight: FontWeight.bold)),
//         ]),
//
//         const SizedBox(height: 8),
//
//         Row(children: [
//           const Icon(Icons.payment_outlined, size: 14, color: Colors.white38),
//           const SizedBox(width: 4),
//           Text(order.paymentMethod,
//               style: const TextStyle(color: Colors.white38, fontSize: 12)),
//           const Spacer(),
//           const Text('View Details →',
//               style: TextStyle(color: Color(0xFF2E6CF6), fontSize: 12)),
//         ]),
//       ]),
//     ),
//   );
// }
