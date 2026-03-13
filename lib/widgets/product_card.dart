import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../providers/order_draft_provider.dart';
import '../core/helpers.dart';
import '../providers/favorites_provider.dart';

class ProductCard extends StatelessWidget {

  final ProductModel product;

  const ProductCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {

    final favorites = context.watch<FavoritesProvider>();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161A22),
        borderRadius: BorderRadius.circular(16),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// Product Icon
          /// Product Icon + Favorite Button
          Expanded(
            child: Stack(
              children: [

                Center(
                  child: Icon(
                    Icons.inventory_2_outlined,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                ),

                Positioned(
                  top: 0,
                  right: 0,
                  child: Consumer<FavoritesProvider>(
                    builder: (context, favorites, _) {

                      final isFav = favorites.isFavorite(product);

                      return IconButton(
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? Colors.red : Colors.white54,
                        ),
                        onPressed: () {

                          favorites.toggleFavorite(product);

                          /// HEART POP ANIMATION
                          final overlay = Overlay.of(context);

                          final box = context.findRenderObject() as RenderBox;
                          final position = box.localToGlobal(Offset.zero);

                          overlay.insert(
                            OverlayEntry(
                              builder: (_) => Positioned(
                                left: position.dx + 40,
                                top: position.dy + 40,
                                child: const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                  size: 40,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          /// Product Name
          Text(
            product.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 6),

          /// Price
          Text(
            "₹${product.price}",
            style: const TextStyle(
              color: Color(0xFF2E6CF6),
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          /// Add To Cart Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E6CF6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              onPressed: () {
                final cart = context.read<OrderDraftProvider>();
                /// FIXED METHOD
                cart.addProduct(product);
                /// SHOW POPUP
                showAddToCartPopup(context, product);
              },

              child: const Text("Add to Cart"),
            ),
          ),
        ],
      ),
    );
  }
}