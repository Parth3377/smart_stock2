import '../models/order_model.dart';
import '../models/order_item_model.dart';

class OrderService {
  /// ⭐ DEMO + RUNTIME ORDERS STORAGE
  static final List<OrderModel> orders = [
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
          id: "1",
          name: "Security Labels",
          image: "assets/products/label1.png",
          quantity: 2,
          price: 250,
        ),
      ],
    ),
    OrderModel(
      id: "#ORD-1021",
      date: "10 Feb 2026",
      status: "Delivered",
      total: 899,
      address: "Navrangpura , Ahmedabad",
      paymentMethod: "Card",
      paymentStatus: "Paid",
      items: [
        OrderItemModel(
          id: "2",
          name: "Hologram Stickers",
          image: "assets/products/hologram.png",
          quantity: 3,
          price: 360,
        ),
      ],
    ),
  ];

  /// ⭐ GET ALL ORDERS
  static List<OrderModel> getOrders() {
    return orders;
  }

  /// ⭐ ADD NEW ORDER FROM PAYMENT FLOW
  static void addOrder(OrderModel order) {
    orders.insert(0, order); // newest first
  }

  /// ⭐ CLEAR ALL ORDERS (future admin/testing)
  static void clearOrders() {
    orders.clear();
  }
}
