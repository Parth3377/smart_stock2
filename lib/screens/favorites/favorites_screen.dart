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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text("Favorites"),
        backgroundColor: Theme.of(context).cardColor,

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
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Icon(
              Icons.favorite_border,
              size: 70,
              color: Colors.red,
            ),

            const SizedBox(height: 16),

            Text(
              "No favorites yet",
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
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
          crossAxisCount: 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.75,
        ),

        // ✅ Uses _FavoriteCard so heart animation always works
        itemBuilder: (context, index) =>
            _FavoriteCard(product: favorites[index]),
      ),

    );
  }
}

// ── Favorite card with flying heart animation ──────────────────────
class _FavoriteCard extends StatefulWidget {
  final dynamic product;
  const _FavoriteCard({required this.product});

  @override
  State<_FavoriteCard> createState() => _FavoriteCardState();
}

class _FavoriteCardState extends State<_FavoriteCard> {

  void _flyHeart(BuildContext ctx) {
    final overlay = Overlay.of(ctx);
    final box     = ctx.findRenderObject() as RenderBox?;
    if (box == null) return;
    final pos = box.localToGlobal(Offset.zero);
    final entry = OverlayEntry(
      builder: (_) => Positioned(
        left: pos.dx + box.size.width / 2 - 18,
        top:  pos.dy + box.size.height / 2 - 18,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: -120),
          duration: const Duration(milliseconds: 700),
          builder: (_, val, child) => Transform.translate(
            offset: Offset(0, val),
            child: Opacity(
                opacity: 1 - (val.abs() / 120), child: child),
          ),
          child: const Icon(Icons.favorite, color: Colors.red, size: 36),
        ),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(milliseconds: 720), entry.remove);
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return Consumer<FavoritesProvider>(
      builder: (ctx, favProv, _) {
        final isFav = favProv.isFavorite(product);
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Image + heart button
              Expanded(
                child: Stack(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      product.image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (_, __, ___) => Container(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        child: Icon(Icons.image_not_supported,
                            color: Theme.of(context).textTheme.bodySmall?.color),
                      ),
                    ),
                  ),

                  // ── Flying heart button ──────────────────────────
                  Positioned(
                    top: 4, right: 4,
                    child: GestureDetector(
                      onTap: () {
                        favProv.toggleFavorite(product);
                        _flyHeart(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? Colors.red : Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
                ]),
              ),

              const SizedBox(height: 6),

              Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                "₹${product.price}",
                style: const TextStyle(
                  color: Color(0xFF2E6CF6),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Delete all favorites dialog ────────────────────────────────────
void _showDeleteFavoritesPopup(BuildContext context) {

  final favorites = context.read<FavoritesProvider>();
  final isDark = Theme.of(context).brightness == Brightness.dark;

  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.55),
    builder: (_) => Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: 260,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.white.withOpacity(0.92),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.15)
                    : Colors.black.withOpacity(0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 30,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete_outline,
                      color: Colors.red, size: 26),
                ),

                const SizedBox(height: 14),

                Text(
                  "Clear Favorites",
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "Remove all items?",
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 20),

                Row(children: [

                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? Colors.white24 : Colors.black12,
                          ),
                        ),
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

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
                ]),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}



// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../providers/favorites_provider.dart';
//
// class FavoritesScreen extends StatelessWidget {
//   const FavoritesScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//
//     final favoritesProvider = context.watch<FavoritesProvider>();
//     final favorites = favoritesProvider.favorites;
//
//     return Scaffold(
//       backgroundColor: const Color(0xFF0F1218),
//
//       appBar: AppBar(
//         title: const Text("Favorites"),
//         backgroundColor: const Color(0xFF161A22),
//
//         actions: [
//
//           Consumer<FavoritesProvider>(
//             builder: (context, favorites, _) {
//
//               if (favorites.count == 0) {
//                 return const SizedBox();
//               }
//
//               return IconButton(
//                 icon: const Icon(
//                   Icons.delete_outline,
//                   color: Colors.red,
//                 ),
//
//                 onPressed: () {
//                   _showDeleteFavoritesPopup(context);
//                 },
//               );
//             },
//           ),
//         ],
//       ),
//
//       body: favorites.isEmpty
//           ? const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//
//             Icon(
//               Icons.favorite_border,
//               size: 70,
//               color: Colors.red,
//             ),
//
//             SizedBox(height: 16),
//
//             Text(
//               "No favorites yet",
//               style: TextStyle(
//                 color: Colors.white70,
//                 fontSize: 16,
//               ),
//             ),
//           ],
//         ),
//       )
//
//           : GridView.builder(
//         padding: const EdgeInsets.all(12),
//         itemCount: favorites.length,
//
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 4,
//           crossAxisSpacing: 10,
//           mainAxisSpacing: 10,
//           childAspectRatio: 0.75,
//         ),
//
//         itemBuilder: (context, index) {
//
//           final product = favorites[index];
//
//           return _FavoriteCard(product: product);
//         },
//       ),
//     );
//   }
// }
//
// // ── Favorite card with flying heart animation ──────────────────────
// class _FavoriteCard extends StatefulWidget {
//   final dynamic product;
//   const _FavoriteCard({required this.product});
//
//   @override
//   State<_FavoriteCard> createState() => _FavoriteCardState();
// }
//
// class _FavoriteCardState extends State<_FavoriteCard> {
//
//   void _flyHeart(BuildContext ctx) {
//     final overlay = Overlay.of(ctx);
//     final box     = ctx.findRenderObject() as RenderBox?;
//     if (box == null) return;
//     final pos = box.localToGlobal(Offset.zero);
//     final entry = OverlayEntry(
//       builder: (_) => Positioned(
//         left: pos.dx + box.size.width / 2 - 18,
//         top:  pos.dy + box.size.height / 2 - 18,
//         child: TweenAnimationBuilder<double>(
//           tween: Tween(begin: 0, end: -120),
//           duration: const Duration(milliseconds: 700),
//           builder: (_, val, child) => Transform.translate(
//             offset: Offset(0, val),
//             child: Opacity(
//                 opacity: 1 - (val.abs() / 120), child: child),
//           ),
//           child: const Icon(Icons.favorite, color: Colors.red, size: 36),
//         ),
//       ),
//     );
//     overlay.insert(entry);
//     Future.delayed(const Duration(milliseconds: 720), entry.remove);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final product = widget.product;
//     return Consumer<FavoritesProvider>(
//       builder: (ctx, favProv, _) {
//         final isFav = favProv.isFavorite(product);
//         return Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: const Color(0xFF161A22),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//
//               // Image + heart button
//               Expanded(
//                 child: Stack(children: [
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(10),
//                     child: Image.asset(
//                       product.image,
//                       fit: BoxFit.cover,
//                       width: double.infinity,
//                       height: double.infinity,
//                       errorBuilder: (_, __, ___) => Container(
//                         color: Colors.white10,
//                         child: const Icon(Icons.image_not_supported,
//                             color: Colors.white30),
//                       ),
//                     ),
//                   ),
//
//                   // ── Flying heart button ──────────────────────────
//                   Positioned(
//                     top: 4, right: 4,
//                     child: GestureDetector(
//                       onTap: () {
//                         favProv.toggleFavorite(product);
//                         _flyHeart(context);
//                       },
//                       child: Container(
//                         padding: const EdgeInsets.all(5),
//                         decoration: const BoxDecoration(
//                           color: Colors.black54,
//                           shape: BoxShape.circle,
//                         ),
//                         child: Icon(
//                           isFav ? Icons.favorite : Icons.favorite_border,
//                           color: isFav ? Colors.red : Colors.white,
//                           size: 14,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ]),
//               ),
//
//               const SizedBox(height: 6),
//
//               Text(
//                 product.name,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w600,
//                   fontSize: 11,
//                 ),
//               ),
//
//               const SizedBox(height: 3),
//
//               Text(
//                 "₹${product.price}",
//                 style: const TextStyle(
//                   color: Color(0xFF2E6CF6),
//                   fontWeight: FontWeight.bold,
//                   fontSize: 12,
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
//
// void _showDeleteFavoritesPopup(BuildContext context) {
//
//   final favorites = context.read<FavoritesProvider>();
//
//   showDialog(
//     context: context,
//     barrierColor: Colors.black.withOpacity(0.55),
//
//     builder: (_) {
//
//       return Center(
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(26),
//
//           child: BackdropFilter(
//             filter: ImageFilter.blur(
//               sigmaX: 20,
//               sigmaY: 20,
//             ),
//
//             child: Container(
//               width: 260,
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 24,
//                 vertical: 28,
//               ),
//
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.06),
//                 borderRadius: BorderRadius.circular(26),
//
//                 border: Border.all(
//                   color: Colors.white.withOpacity(0.15),
//                 ),
//
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.35),
//                     blurRadius: 30,
//                     offset: const Offset(0, 20),
//                   )
//                 ],
//               ),
//
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//
//                   /// ICON
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Colors.red.withOpacity(0.15),
//                       shape: BoxShape.circle,
//                     ),
//                     child: const Icon(
//                       Icons.delete_outline,
//                       color: Colors.red,
//                       size: 26,
//                     ),
//                   ),
//
//                   const SizedBox(height: 14),
//
//                   /// TITLE
//                   const Text(
//                     "Clear Favorites",
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 17,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//
//                   const SizedBox(height: 6),
//
//                   const Text(
//                     "Remove all items?",
//                     style: TextStyle(
//                       color: Colors.white70,
//                       fontSize: 13,
//                     ),
//                   ),
//
//                   const SizedBox(height: 20),
//
//                   /// BUTTONS
//                   Row(
//                     children: [
//
//                       /// CANCEL
//                       Expanded(
//                         child: GestureDetector(
//                           onTap: () {
//                             Navigator.pop(context);
//                           },
//
//                           child: Container(
//                             height: 40,
//                             alignment: Alignment.center,
//
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(12),
//                               border: Border.all(
//                                 color: Colors.white24,
//                               ),
//                             ),
//
//                             child: const Text(
//                               "Cancel",
//                               style: TextStyle(
//                                 color: Colors.white70,
//                                 fontSize: 13,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//
//                       const SizedBox(width: 10),
//
//                       /// DELETE
//                       Expanded(
//                         child: GestureDetector(
//                           onTap: () {
//
//                             favorites.clearFavorites();
//
//                             Navigator.pop(context);
//                           },
//
//                           child: Container(
//                             height: 40,
//                             alignment: Alignment.center,
//
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(12),
//                               color: Colors.red,
//                             ),
//
//                             child: const Text(
//                               "Delete",
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 13,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   )
//                 ],
//               ),
//             ),
//           ),
//         ),
//       );
//     },
//   );
// }