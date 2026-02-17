import 'order_item_model.dart';
import '../providers/order_draft_provider.dart';

class OrderModel {
  final String id;
  final String date;
  final String status;
  final double total;
  final String address;
  final String paymentMethod;
  final String paymentStatus;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.date,
    required this.status,
    required this.total,
    required this.address,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.items,
  });

  /// ⭐ CREATE ORDER FROM CART (FIXES YOUR PAYMENT ERROR)
  factory OrderModel.createFromDraft({
    required List<OrderDraftItem> draftItems,
    required String paymentMethod,
    required String address, required List<OrderDraftItem> items,
  }) {
    final totalAmount = draftItems.fold(
      0.0,
          (sum, e) => sum + (e.product.price * e.quantity),
    );

    return OrderModel(
      id: "#ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}",
      date: _formatDate(DateTime.now()),
      status: "Pending",
      total: totalAmount,
      address: address,
      paymentMethod: paymentMethod,
      paymentStatus: "Paid",
      items: draftItems
          .map(
            (e) => OrderItemModel(
          id: e.product.id,
          name: e.product.name,
          image: e.product.image,
          price: e.product.price,
          quantity: e.quantity,
        ),
      )
          .toList(),
    );
  }

  /// ⭐ DATE FORMATTER
  static String _formatDate(DateTime date) {
    return "${date.day} ${_monthName(date.month)} ${date.year}";
  }

  static String _monthName(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return months[month - 1];
  }
}
