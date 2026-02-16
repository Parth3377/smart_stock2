import '../models/product_model.dart';

class OrderDraftItem {
  final ProductModel product;
  int quantity;

  OrderDraftItem({
    required this.product,
    this.quantity = 1,
  });

  double get total => product.price * quantity;
}

class OrderDraftService {
  /// cart storage
  static final List<OrderDraftItem> _items = [];

  /// expose items
  static List<OrderDraftItem> get items => _items;

  /// total price
  static double get totalPrice =>
      _items.fold(0, (sum, item) => sum + item.total);

  /// add product to cart
  static void add(ProductModel product) {
    final index = _items.indexWhere((e) => e.product.id == product.id);

    if (index != -1) {
      _items[index].quantity++;
    } else {
      _items.add(OrderDraftItem(product: product));
    }
  }

  /// clear cart
  static void clear() {
    _items.clear();
  }
}
