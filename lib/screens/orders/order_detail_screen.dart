import 'package:flutter/material.dart';
import '../../models/order_item_model.dart';
import '../../models/order_model.dart';

class OrderDetailScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailScreen({super.key, required this.order});

  Color _statusColor(String status) {
    switch (status) {
      case "Delivered":
        return Colors.green;
      case "Confirmed":
        return Colors.orange;
      default:
        return const Color(0xFF2E6CF6);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 10),

                  /// STATUS BADGE
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor(order.status).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      order.status,
                      style: TextStyle(
                        color: _statusColor(order.status),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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

            /// PRODUCTS LIST
            const Text(
              "Ordered Products",
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),

            ...order.items.map((item) => _productTile(item)),

            const SizedBox(height: 16),

            /// DELIVERY LOCATION
            _sectionCard(
              title: "Delivery Location",
              child: Text(
                order.address,
                style: const TextStyle(color: Colors.white70),
              ),
            ),

            const SizedBox(height: 16),

            /// PAYMENT INFO
            _sectionCard(
              title: "Payment",
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

            /// ORDER TIMELINE
            const Text(
              "Order Status",
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),

            _timelineStep("Pending", order.status),
            _timelineStep("Confirmed", order.status),
            _timelineStep("Delivered", order.status),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  ////////////////////////////////////////////////////////////////////////////
  /// SECTION CARD UI
  ////////////////////////////////////////////////////////////////////////////

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
            const SizedBox(height: 8),
          ],
          child,
        ],
      ),
    );
  }

  ////////////////////////////////////////////////////////////////////////////
  /// PRODUCT TILE
  ////////////////////////////////////////////////////////////////////////////

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

  ////////////////////////////////////////////////////////////////////////////
  /// TIMELINE STEP
  ////////////////////////////////////////////////////////////////////////////

  Widget _timelineStep(String step, String currentStatus) {
    final bool completed =
        _statusOrder(step) <= _statusOrder(currentStatus);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            completed ? Icons.check_circle : Icons.radio_button_unchecked,
            color: completed ? Colors.green : Colors.white38,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            step,
            style: TextStyle(
              color: completed ? Colors.white : Colors.white38,
            ),
          ),
        ],
      ),
    );
  }

  int _statusOrder(String status) {
    switch (status) {
      case "Pending":
        return 1;
      case "Confirmed":
        return 2;
      case "Delivered":
        return 3;
      default:
        return 0;
    }
  }
}
