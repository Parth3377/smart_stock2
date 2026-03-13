import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/favorites_provider.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final favoritesProvider = context.watch<FavoritesProvider>();
    final favorites = favoritesProvider.favorites;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1218),

      appBar: AppBar(
        title: const Text("Favorites"),
        backgroundColor: const Color(0xFF161A22),

        actions: [

          Consumer<FavoritesProvider>(
            builder: (context, favorites, _) {

              if (favorites.count == 0) {
                return const SizedBox();
              }

              return IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                ),

                  onPressed: () {
                  _showDeleteFavoritesPopup(context);
                  },
              );
            },
          ),
        ],
      ),

      body: favorites.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Icon(
              Icons.favorite_border,
              size: 70,
              color: Colors.white24,
            ),

            SizedBox(height: 16),

            Text(
              "No favorites yet",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      )

       : GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: favorites.length,

        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.78,
        ),

        itemBuilder: (context, index) {

          final product = favorites[index];

          return Container(
            padding: const EdgeInsets.all(14),

            decoration: BoxDecoration(
              color: const Color(0xFF161A22),
              borderRadius: BorderRadius.circular(16),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// PRODUCT ICON
                Expanded(
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        product.image,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  "₹${product.price}",
                  style: const TextStyle(
                    color: Color(0xFF2E6CF6),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

void _showDeleteFavoritesPopup(BuildContext context) {

  final favorites = context.read<FavoritesProvider>();

  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.55),

    builder: (_) {

      return Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),

          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 20,
              sigmaY: 20,
            ),

            child: Container(
              width: 260,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 28,
              ),

              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(26),

                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                ),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 30,
                    offset: const Offset(0, 20),
                  )
                ],
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  /// ICON
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 26,
                    ),
                  ),

                  const SizedBox(height: 14),

                  /// TITLE
                  const Text(
                    "Clear Favorites",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    "Remove all items?",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// BUTTONS
                  Row(
                    children: [

                      /// CANCEL
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },

                          child: Container(
                            height: 40,
                            alignment: Alignment.center,

                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white24,
                              ),
                            ),

                            child: const Text(
                              "Cancel",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      /// DELETE
                      Expanded(
                        child: GestureDetector(
                          onTap: () {

                            favorites.clearFavorites();

                            Navigator.pop(context);
                          },

                          child: Container(
                            height: 40,
                            alignment: Alignment.center,

                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.red,
                            ),

                            child: const Text(
                              "Delete",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}