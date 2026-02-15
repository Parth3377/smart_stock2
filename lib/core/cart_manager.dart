import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';

class CartManager {
  /// Internal cart list
  static final List<CartItemModel> _items = [];

  /// Notifier to update UI everywhere
  static final ValueNotifier<int> cartCount = ValueNotifier<int>(0);

  /// Get all items
  static List<CartItemModel> get items => _items;

  /// Add product to cart
  static void addToCart(CartItemModel item) {
    final index = _items.indexWhere((e) => e.productId == item.productId);

    if (index != -1) {
      _items[index].quantity++;
    } else {
      _items.add(item);
    }

    cartCount.value = _items.length;
  }

  /// Remove item completely
  static void removeFromCart(String productId) {
    _items.removeWhere((e) => e.productId == productId);
    cartCount.value = _items.length;
  }

  /// Change quantity
  static void updateQuantity(String productId, int qty) {
    final index = _items.indexWhere((e) => e.productId == productId);
    if (index != -1) {
      _items[index].quantity = qty;
    }
  }

  /// Clear full cart
  static void clearCart() {
    _items.clear();
    cartCount.value = 0;
  }

  /// Total price
  static double get totalAmount {
    return _items.fold(0, (sum, item) => sum + item.totalPrice);
  }
}
