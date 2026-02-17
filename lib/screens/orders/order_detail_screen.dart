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
  Widget _timelineStep({
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
                  color: completed ? activeColor : Colors.white38,
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
                color: completed ? activeColor : Colors.white24,
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
              color: completed ? Colors.white : Colors.white38,
              fontSize: 14,
              fontWeight: completed ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  // ================= SECTION CARD =================
  Widget _sectionCard({String? title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161A22),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
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
  Widget _productTile(OrderItemModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF161A22),
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
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Text(
            "x${item.quantity}",
            style: const TextStyle(color: Colors.white70),
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
      backgroundColor: const Color(0xFF0F1218),

      appBar: AppBar(
        backgroundColor: const Color(0xFF161A22),
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
            _sectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.id,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    order.date,
                    style:
                    const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Total: ₹${order.total.toStringAsFixed(0)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// PRODUCTS
            _sectionCard(
              title: "Ordered Products",
              child: Column(
                children: order.items.map(_productTile).toList(),
              ),
            ),

            const SizedBox(height: 16),

            /// DELIVERY
            _sectionCard(
              title: "Delivery Address",
              child: Text(
                order.address,
                style: const TextStyle(color: Colors.white70),
              ),
            ),

            const SizedBox(height: 16),

            /// PAYMENT
            _sectionCard(
              title: "Payment Info",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Method: ${order.paymentMethod}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Status: ${order.paymentStatus}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// ================= TRACKING TIMELINE =================
            _sectionCard(
              title: "Order Tracking",
              child: Column(
                children: [
                  _timelineStep(
                    title: "Order Placed",
                    stepIndex: 0,
                    currentIndex: currentIndex,
                    isLast: false,
                  ),
                  _timelineStep(
                    title: "Order Confirmed",
                    stepIndex: 1,
                    currentIndex: currentIndex,
                    isLast: false,
                  ),
                  _timelineStep(
                    title: "Delivered",
                    stepIndex: 2,
                    currentIndex: currentIndex,
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
