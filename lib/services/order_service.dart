import '../models/order_model.dart';
import '../models/order_item_model.dart';

class OrderService {
  static List<OrderModel> orders = [
    OrderModel(
      id: "#ORD-1024",
      date: "12 Feb 2026",
      status: "Pending",
      total: 499,
      address: "Kolkata, West Bengal",
      paymentMethod: "UPI",
      paymentStatus: "Paid",
      items: [
        OrderItemModel(
          name: "Security Labels",
          image: "assets/products/label1.png",
          quantity: 2, id: '', price: 250,
        ),
      ],
    ),
    OrderModel(
      id: "#ORD-1021",
      date: "10 Feb 2026",
      status: "Delivered",
      total: 899,
      address: "Howrah, West Bengal",
      paymentMethod: "Card",
      paymentStatus: "Paid",
      items: [
        OrderItemModel(
          name: "Hologram Stickers",
          image: "assets/products/hologram.png",
          quantity: 3, id: '', price: 360,
        ),
      ],
    ),
  ];
}
