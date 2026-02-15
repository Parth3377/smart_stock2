import '../models/order_item_model.dart';

class OrderDraftService {
  static final List<OrderItemModel> _items = [];

  /// Get all cart items
  static List<OrderItemModel> get items => _items;

  /// Add product to cart
  static void addItem(OrderItemModel item) {
    final index = _items.indexWhere((e) => e.id == item.id);

    if (index != -1) {
      _items[index].quantity++;
    } else {
      _items.add(item);
    }
  }

  /// Remove item
  static void removeItem(String id) {
    _items.removeWhere((e) => e.id == id);
  }

  /// Change quantity
  static void updateQuantity(String id, int quantity) {
    final index = _items.indexWhere((e) => e.id == id);
    if (index != -1 && quantity > 0) {
      _items[index].quantity = quantity;
    }
  }

  /// Total price
  static double get totalAmount {
    return _items.fold(0, (sum, item) => sum + item.total);
  }

  /// Clear cart
  static void clear() {
    _items.clear();
  }
}
