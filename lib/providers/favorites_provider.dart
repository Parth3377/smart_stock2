import 'package:flutter/material.dart';
import '../models/product_model.dart';

class FavoritesProvider extends ChangeNotifier {

  final List<ProductModel> _favorites = [];

  List<ProductModel> get favorites => _favorites;

  /// FAVORITES COUNT (used for badge)
  int get count => _favorites.length;

  /// CHECK IF PRODUCT IS FAVORITE
  bool isFavorite(ProductModel product) {
    return _favorites.any((item) => item.id == product.id);
  }

  /// TOGGLE FAVORITE
  void toggleFavorite(ProductModel product) {

    if (isFavorite(product)) {
      _favorites.removeWhere((item) => item.id == product.id);
    } else {
      _favorites.add(product);
    }

    notifyListeners();
  }

  /// REMOVE ITEM
  void removeFavorite(ProductModel product) {
    _favorites.removeWhere((item) => item.id == product.id);
    notifyListeners();
  }

  // CLEAR FAVORITES ITEMS
  void clearFavorites() {
    _favorites.clear();
    notifyListeners();
  }

}