import 'package:flutter/material.dart';
import '../models/product_model.dart';

/// ================= ORDER DRAFT ITEM =================
class OrderDraftItem {
  final ProductModel product;
  int quantity;

  OrderDraftItem({
    required this.product,
    this.quantity = 1,
  });
}

/// ================= ORDER DRAFT PROVIDER =================
class OrderDraftProvider extends ChangeNotifier {
  final List<OrderDraftItem> _items = [];

  List<OrderDraftItem> get items => _items;

  /// ================= ADD PRODUCT =================
  void addProduct(ProductModel product) {
    final index = _items.indexWhere((e) => e.product.id == product.id);

    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(OrderDraftItem(product: product));
    }

    notifyListeners();
  }

  /// ================= INCREASE QTY =================
  void increaseQty(String productId) {
    final index = _items.indexWhere((e) => e.product.id == productId);

    if (index >= 0) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  /// ================= DECREASE QTY =================
  void decreaseQty(String productId) {
    final index = _items.indexWhere((e) => e.product.id == productId);

    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index); // remove if qty = 0
      }

      notifyListeners();
    }
  }

  /// ================= TOTAL PRICE =================
  double get totalPrice {
    double total = 0;

    for (final item in _items) {
      total += item.product.price * item.quantity;
    }

    return total;
  }

  /// ================= CLEAR CART =================
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
