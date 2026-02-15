import 'order_item_model.dart';

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
}
