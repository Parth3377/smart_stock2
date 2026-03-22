import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../models/order_item_model.dart';

class OrderDetailScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailScreen({super.key, required this.order});

  // ================= STATUS INDEX =================
  int _statusIndex(String status) {
    switch (status) {
      case "Pending":
        return 0;
      case "Confirmed":
        return 1;
      case "Delivered":
        return 2;
      default:
        return 0;
    }
  }

  // ================= STEP WIDGET =================
  Widget _timelineStep(BuildContext context, {
    required String title,
    required int stepIndex,
    required int currentIndex,
    required bool isLast,
  }) {
    final bool completed = stepIndex <= currentIndex;
    final Color activeColor = const Color(0xFF2E6CF6);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// LEFT SIDE (DOT + LINE)
        Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: completed ? activeColor : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: completed ? activeColor : (Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey),
                  width: 2,
                ),
              ),
              child: completed
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),

            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: completed ? activeColor : (Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey).withOpacity(0.3),
              ),
          ],
        ),

        const SizedBox(width: 12),

        /// RIGHT SIDE (TEXT)
        Padding(
          padding: const EdgeInsets.only(top: 0),
          child: Text(
            title,
            style: TextStyle(
              color: completed ? Theme.of(context).textTheme.bodyLarge?.color : Theme.of(context).textTheme.bodySmall?.color,
              fontSize: 14,
              fontWeight: completed ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  // ================= SECTION CARD =================
  Widget _sectionCard(BuildContext context, {String? title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }

  // ================= PRODUCT TILE =================
  Widget _productTile(BuildContext context, OrderItemModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              item.image,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.name,
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
          ),
          Text(
            "x${item.quantity}",
            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
          ),
        ],
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final int currentIndex = _statusIndex(order.status);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        title: const Text("Order Details"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ORDER HEADER
            _sectionCard(context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.id,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    order.date,
                    style:
                    TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Total: ₹${order.total.toStringAsFixed(0)}",
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// PRODUCTS
            _sectionCard(context,
              title: "Ordered Products",
              child: Column(
                children: order.items.map((item) => _productTile(context, item)).toList(),
              ),
            ),

            const SizedBox(height: 16),

            /// DELIVERY
            _sectionCard(context,
              title: "Delivery Address",
              child: Text(
                order.address,
                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
              ),
            ),

            const SizedBox(height: 16),

            /// PAYMENT
            _sectionCard(context,
              title: "Payment Info",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Method: ${order.paymentMethod}",
                    style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Status: ${order.paymentStatus}",
                    style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// ================= TRACKING TIMELINE =================
            _sectionCard(context,
              title: "Order Tracking",
              child: Column(
                children: [
                  _timelineStep(context,
                    title: "Order Placed",
                    stepIndex: 0,
                    currentIndex: currentIndex,
                    isLast: false,
                  ),
                  _timelineStep(context,
                    title: "Order Confirmed",
                    stepIndex: 1,
                    currentIndex: currentIndex,
                    isLast: false,
                  ),
                  _timelineStep(context,
                    title: "Delivered",
                    stepIndex: 2,
                    currentIndex: currentIndex,
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// DELIVERY DISTANCE INFO (replaces Track on Map button)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF2E6CF6).withOpacity(0.3)),
                ),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E6CF6).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.local_shipping_outlined,
                        color: Color(0xFF2E6CF6), size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Estimated Delivery Distance',
                          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 12)),
                      SizedBox(height: 4),
                      Text('SmartStock Warehouse → Your Location',
                          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color,
                              fontWeight: FontWeight.w600, fontSize: 13)),
                      SizedBox(height: 4),
                      Row(children: [
                        Icon(Icons.route_outlined, size: 14, color: Color(0xFF2E6CF6)),
                        SizedBox(width: 4),
                        Text('Ahmedabad, Gujarat',
                            style: TextStyle(color: Color(0xFF2E6CF6), fontSize: 12)),
                      ]),
                    ],
                  )),
                ]),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../models/order_model.dart';
// import '../../models/order_item_model.dart';
// import '../../providers/location_provider.dart';
// import '../maps/delivery_location_screen.dart';
//
// class OrderDetailScreen extends StatelessWidget {
//   final OrderModel order;
//
//   const OrderDetailScreen({super.key, required this.order});
//
//   // ================= STATUS INDEX =================
//   int _statusIndex(String status) {
//     switch (status) {
//       case "Pending":
//         return 0;
//       case "Confirmed":
//         return 1;
//       case "Delivered":
//         return 2;
//       default:
//         return 0;
//     }
//   }
//
//   // ================= STEP WIDGET =================
//   Widget _timelineStep({
//     required String title,
//     required int stepIndex,
//     required int currentIndex,
//     required bool isLast,
//   }) {
//     final bool completed = stepIndex <= currentIndex;
//     final Color activeColor = const Color(0xFF2E6CF6);
//
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         /// LEFT SIDE (DOT + LINE)
//         Column(
//           children: [
//             AnimatedContainer(
//               duration: const Duration(milliseconds: 300),
//               width: 18,
//               height: 18,
//               decoration: BoxDecoration(
//                 color: completed ? activeColor : Colors.transparent,
//                 borderRadius: BorderRadius.circular(20),
//                 border: Border.all(
//                   color: completed ? activeColor : Colors.white38,
//                   width: 2,
//                 ),
//               ),
//               child: completed
//                   ? const Icon(Icons.check, size: 12, color: Colors.white)
//                   : null,
//             ),
//
//             if (!isLast)
//               Container(
//                 width: 2,
//                 height: 40,
//                 color: completed ? activeColor : Colors.white24,
//               ),
//           ],
//         ),
//
//         const SizedBox(width: 12),
//
//         /// RIGHT SIDE (TEXT)
//         Padding(
//           padding: const EdgeInsets.only(top: 0),
//           child: Text(
//             title,
//             style: TextStyle(
//               color: completed ? Colors.white : Colors.white38,
//               fontSize: 14,
//               fontWeight: completed ? FontWeight.w600 : FontWeight.w400,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   // ================= SECTION CARD =================
//   Widget _sectionCard({String? title, required Widget child}) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: const Color(0xFF161A22),
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           if (title != null) ...[
//             Text(
//               title,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: 12),
//           ],
//           child,
//         ],
//       ),
//     );
//   }
//
//   // ================= PRODUCT TILE =================
//   Widget _productTile(OrderItemModel item) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 10),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: const Color(0xFF161A22),
//         borderRadius: BorderRadius.circular(14),
//       ),
//       child: Row(
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(8),
//             child: Image.asset(
//               item.image,
//               width: 50,
//               height: 50,
//               fit: BoxFit.cover,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               item.name,
//               style: const TextStyle(color: Colors.white),
//             ),
//           ),
//           Text(
//             "x${item.quantity}",
//             style: const TextStyle(color: Colors.white70),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ================= UI =================
//   @override
//   Widget build(BuildContext context) {
//     final int currentIndex = _statusIndex(order.status);
//
//     return Scaffold(
//       backgroundColor: const Color(0xFF0F1218),
//
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF161A22),
//         elevation: 0,
//         title: const Text("Order History"),
//         centerTitle: true,
//       ),
//
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             /// ORDER HEADER
//             _sectionCard(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     order.id,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const SizedBox(height: 6),
//                   Text(
//                     order.date,
//                     style:
//                     const TextStyle(color: Colors.white70, fontSize: 12),
//                   ),
//                   const SizedBox(height: 12),
//                   Text(
//                     "Total: ₹${order.total.toStringAsFixed(0)}",
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 16),
//
//             /// PRODUCTS
//             _sectionCard(
//               title: "Ordered Products",
//               child: Column(
//                 children: order.items.map(_productTile).toList(),
//               ),
//             ),
//
//             const SizedBox(height: 16),
//
//             /// DELIVERY
//             _sectionCard(
//               title: "Delivery Address",
//               child: Text(
//                 order.address,
//                 style: const TextStyle(color: Colors.white70),
//               ),
//             ),
//
//             const SizedBox(height: 16),
//
//             /// PAYMENT
//             _sectionCard(
//               title: "Payment Info",
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "Method: ${order.paymentMethod}",
//                     style: const TextStyle(color: Colors.white70),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     "Status: ${order.paymentStatus}",
//                     style: const TextStyle(color: Colors.white70),
//                   ),
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 20),
//
//             /// ================= TRACKING TIMELINE =================
//             _sectionCard(
//               title: "Order Tracking",
//               child: Column(
//                 children: [
//                   _timelineStep(
//                     title: "Order Placed",
//                     stepIndex: 0,
//                     currentIndex: currentIndex,
//                     isLast: false,
//                   ),
//                   _timelineStep(
//                     title: "Order Confirmed",
//                     stepIndex: 1,
//                     currentIndex: currentIndex,
//                     isLast: false,
//                   ),
//                   _timelineStep(
//                     title: "Delivered",
//                     stepIndex: 2,
//                     currentIndex: currentIndex,
//                     isLast: true,
//                   ),
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 16),
//
//             /// TRACK ON MAP BUTTON
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton.icon(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => ChangeNotifierProvider(
//                           create: (_) => LocationProvider(),
//                           child: DeliveryLocationScreen(
//                             orderId:     order.id,
//                             isSelecting: false,
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                   icon: const Icon(Icons.map_outlined, color: Colors.white),
//                   label: const Text(
//                     'Track on Map',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF2E6CF6),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 30),
//           ],
//         ),
//       ),
//     );
//   }
// }