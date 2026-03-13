import 'package:flutter/material.dart';
import 'package:smart_stock2/models/product_model.dart';
import 'package:smart_stock2/widgets/add_to_cart_popup.dart';

void showAddToCartPopup(BuildContext context, ProductModel product) {

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,

    builder: (_) {
      return AddToCartPopup(product: product);
    },
  );
}