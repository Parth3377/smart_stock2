import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../providers/order_draft_provider.dart';
import '../../services/product_service.dart';
import '../dashboard/dashboard_screen.dart';
import '../order_draft/order_draft_screen.dart';
import '../settings/profile_screen.dart';
import '../../core/helpers.dart';
import '../../widgets/glass_bottom_navbar.dart';
import '../../providers/favorites_provider.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final List<ProductModel> _allProducts =
  ProductService.instance.getProducts();

  String _search = "";
  String _selectedCategory = "All";

  List<String> get _categories {
    final set = _allProducts.map((e) => e.category).toSet().toList();
    return ["All", ...set];
  }

  List<ProductModel> get _filteredProducts {
    return _allProducts.where((product) {
      final matchesSearch =
      product.name.toLowerCase().contains(_search.toLowerCase());

      final matchesCategory =
          _selectedCategory == "All" || product.category == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        title: Text("Products"),
        centerTitle: true,
      ),

      body: Column(
        children: [

          /// 🔍 SEARCH
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) => setState(() => _search = value),
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
              decoration: InputDecoration(
                hintText: "Search products...",
                hintStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                prefixIcon: Icon(Icons.search, color: Theme.of(context).textTheme.bodySmall?.color),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          /// 🏷 CATEGORY CHIPS (CENTERED FIX)
          SizedBox(
            height: 42,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, i) {
                final category = _categories[i];
                final selected = category == _selectedCategory;

                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = category),
                  child: Container(
                    alignment: Alignment.center, // ⭐ CENTER FIX
                    padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF2E6CF6)
                          : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: selected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemCount: _categories.length,
            ),
          ),

          const SizedBox(height: 16),

          /// 🧱 GRID WITH HOVER CARD
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredProducts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemBuilder: (_, index) {
                final product = _filteredProducts[index];

                return _HoverProductCard(
                  product: product,
                  onAdd: () {
                    final cart = context.read<OrderDraftProvider>();
                    cart.addProduct(product);
                    showAddToCartPopup(context, product);
                  },
                );
              },
            ),
          ),
        ],
      ),

      bottomNavigationBar: GlassBottomNavbar(

        currentIndex: 1,

        onTap: (index) {

          if (index == 1) return;

          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const DashboardScreen(),
              ),
            );
          }

          if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const OrderDraftScreen(),
              ),
            );
          }

          if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const ProfileScreen(),
              ),
            );
          }

        },

      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// HOVER PRODUCT CARD (MATCHES DASHBOARD STYLE)
////////////////////////////////////////////////////////////

class _HoverProductCard extends StatefulWidget {
  final ProductModel product;
  final VoidCallback onAdd;

  const _HoverProductCard({
    required this.product,
    required this.onAdd,
  });

  @override
  State<_HoverProductCard> createState() => _HoverProductCardState();
}

class _HoverProductCardState extends State<_HoverProductCard> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      child: AnimatedScale(
        scale: hovering ? 1.03 : 1,
        duration: const Duration(milliseconds: 180),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(hovering ? 0.45 : 0.25),
                blurRadius: hovering ? 28 : 18,
                offset: const Offset(0, 12),
              ),
            ],
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// IMAGE
              Expanded(
                child: Stack(
                  children: [

                    /// PRODUCT IMAGE
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        widget.product.image,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),

                    /// FAVORITE BUTTON
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Consumer<FavoritesProvider>(
                        builder: (context, favorites, _) {

                          final isFav = favorites.isFavorite(widget.product);

                          return GestureDetector(
                            onTap: () {

                              favorites.toggleFavorite(widget.product);

                              /// Flying heart animation
                              final overlay = Overlay.of(context);
                              final box = context.findRenderObject() as RenderBox;
                              final position = box.localToGlobal(Offset.zero);

                              final overlayEntry = OverlayEntry(
                                builder: (_) => Positioned(
                                  left: position.dx + 40,
                                  top: position.dy + 40,
                                  child: TweenAnimationBuilder(
                                    tween: Tween(begin: 0.0, end: -120.0),
                                    duration: const Duration(milliseconds: 700),

                                    builder: (context, value, child) {
                                      return Transform.translate(
                                        offset: Offset(0, value),
                                        child: Opacity(
                                          opacity: 1 - (value.abs() / 120),
                                          child: const Icon(
                                            Icons.favorite,
                                            color: Colors.red,
                                            size: 36,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );

                              overlay.insert(overlayEntry);

                              Future.delayed(
                                const Duration(milliseconds: 700),
                                    () => overlayEntry.remove(),
                              );
                            },

                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.35),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isFav ? Icons.favorite : Icons.favorite_border,
                                color: isFav ? Colors.red : Colors.white,
                                size: 20,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              /// NAME
              Text(
                widget.product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 4),

              /// PRICE
              Text(
                "₹${widget.product.price.toStringAsFixed(0)}",
                style: const TextStyle(
                  color: Color(0xFF2E6CF6),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 10),

              /// ADD BUTTON (CLEARLY VISIBLE)
              SizedBox(
                width: double.infinity,
                height: 36,
                child: ElevatedButton(
                  onPressed: widget.onAdd,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E6CF6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "+ Add",
                    style:
                    TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../models/product_model.dart';
// import '../../providers/order_draft_provider.dart';
// import '../../services/product_service.dart';
// import '../dashboard/dashboard_screen.dart';
// import '../order_draft/order_draft_screen.dart';
// import '../settings/profile_screen.dart';
// import '../../core/helpers.dart';
// import '../../widgets/glass_bottom_navbar.dart';
// import '../../providers/favorites_provider.dart';
//
// class ProductsScreen extends StatefulWidget {
//   const ProductsScreen({super.key});
//
//   @override
//   State<ProductsScreen> createState() => _ProductsScreenState();
// }
//
// class _ProductsScreenState extends State<ProductsScreen> {
//   final List<ProductModel> _allProducts =
//   ProductService.instance.getProducts();
//
//   String _search = "";
//   String _selectedCategory = "All";
//
//   List<String> get _categories {
//     final set = _allProducts.map((e) => e.category).toSet().toList();
//     return ["All", ...set];
//   }
//
//   List<ProductModel> get _filteredProducts {
//     return _allProducts.where((product) {
//       final matchesSearch =
//       product.name.toLowerCase().contains(_search.toLowerCase());
//
//       final matchesCategory =
//           _selectedCategory == "All" || product.category == _selectedCategory;
//
//       return matchesSearch && matchesCategory;
//     }).toList();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).cardColor,
//         elevation: 0,
//         title: const Text("Products"),
//         centerTitle: true,
//       ),
//
//       body: Column(
//         children: [
//
//           /// 🔍 SEARCH
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: TextField(
//               onChanged: (value) => setState(() => _search = value),
//               style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
//               decoration: InputDecoration(
//                 hintText: "Search products...",
//                 hintStyle: const TextStyle(color: Color(0xFFA1A6B3)),
//                 prefixIcon: const Icon(Icons.search, color: Color(0xFFA1A6B3)),
//                 filled: true,
//                 fillColor: Theme.of(context).cardColor,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(14),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//             ),
//           ),
//
//           /// 🏷 CATEGORY CHIPS (CENTERED FIX)
//           SizedBox(
//             height: 42,
//             child: ListView.separated(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               scrollDirection: Axis.horizontal,
//               itemBuilder: (_, i) {
//                 final category = _categories[i];
//                 final selected = category == _selectedCategory;
//
//                 return GestureDetector(
//                   onTap: () => setState(() => _selectedCategory = category),
//                   child: Container(
//                     alignment: Alignment.center, // ⭐ CENTER FIX
//                     padding:
//                     const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
//                     decoration: BoxDecoration(
//                       color: selected
//                           ? const Color(0xFF2E6CF6)
//                           : const Color(0xFF161A22),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text(
//                       category,
//                       style: TextStyle(
//                         color: selected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
//                         fontSize: 12,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 );
//               },
//               separatorBuilder: (_, __) => const SizedBox(width: 10),
//               itemCount: _categories.length,
//             ),
//           ),
//
//           const SizedBox(height: 16),
//
//           /// 🧱 GRID WITH HOVER CARD
//           Expanded(
//             child: GridView.builder(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               itemCount: _filteredProducts.length,
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 4,
//                 mainAxisSpacing: 12,
//                 crossAxisSpacing: 12,
//                 childAspectRatio: 0.72,
//               ),
//               itemBuilder: (_, index) {
//                 final product = _filteredProducts[index];
//
//                 return _HoverProductCard(
//                   product: product,
//                   onAdd: () {
//                     final cart = context.read<OrderDraftProvider>();
//                     cart.addProduct(product);
//                     showAddToCartPopup(context, product);
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//
//       bottomNavigationBar: GlassBottomNavbar(
//
//         currentIndex: 1,
//
//         onTap: (index) {
//
//           if (index == 1) return;
//
//           if (index == 0) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => const DashboardScreen(),
//               ),
//             );
//           }
//
//           if (index == 2) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => const OrderDraftScreen(),
//               ),
//             );
//           }
//
//           if (index == 3) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => const ProfileScreen(),
//               ),
//             );
//           }
//
//         },
//
//       ),
//     );
//   }
// }
//
// ////////////////////////////////////////////////////////////
// /// HOVER PRODUCT CARD (MATCHES DASHBOARD STYLE)
// ////////////////////////////////////////////////////////////
//
// class _HoverProductCard extends StatefulWidget {
//   final ProductModel product;
//   final VoidCallback onAdd;
//
//   const _HoverProductCard({
//     required this.product,
//     required this.onAdd,
//   });
//
//   @override
//   State<_HoverProductCard> createState() => _HoverProductCardState();
// }
//
// class _HoverProductCardState extends State<_HoverProductCard> {
//   bool hovering = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return MouseRegion(
//       onEnter: (_) => setState(() => hovering = true),
//       onExit: (_) => setState(() => hovering = false),
//       child: AnimatedScale(
//         scale: hovering ? 1.03 : 1,
//         duration: const Duration(milliseconds: 180),
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 180),
//           padding: const EdgeInsets.all(14),
//           decoration: BoxDecoration(
//             color: Theme.of(context).cardColor,
//             borderRadius: BorderRadius.circular(20),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(hovering ? 0.45 : 0.25),
//                 blurRadius: hovering ? 28 : 18,
//                 offset: const Offset(0, 12),
//               ),
//             ],
//           ),
//
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//
//               /// IMAGE
//               Expanded(
//                 child: Stack(
//                   children: [
//
//                     /// PRODUCT IMAGE
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(14),
//                       child: Image.asset(
//                         widget.product.image,
//                         fit: BoxFit.cover,
//                         width: double.infinity,
//                         height: double.infinity,
//                       ),
//                     ),
//
//                     /// FAVORITE BUTTON
//                     Positioned(
//                       top: 6,
//                       right: 6,
//                       child: Consumer<FavoritesProvider>(
//                         builder: (context, favorites, _) {
//
//                           final isFav = favorites.isFavorite(widget.product);
//
//                           return GestureDetector(
//                             onTap: () {
//
//                               favorites.toggleFavorite(widget.product);
//
//                               /// Flying heart animation
//                               final overlay = Overlay.of(context);
//                               final box = context.findRenderObject() as RenderBox;
//                               final position = box.localToGlobal(Offset.zero);
//
//                               final overlayEntry = OverlayEntry(
//                                 builder: (_) => Positioned(
//                                   left: position.dx + 40,
//                                   top: position.dy + 40,
//                                   child: TweenAnimationBuilder(
//                                     tween: Tween(begin: 0.0, end: -120.0),
//                                     duration: const Duration(milliseconds: 700),
//
//                                     builder: (context, value, child) {
//                                       return Transform.translate(
//                                         offset: Offset(0, value),
//                                         child: Opacity(
//                                           opacity: 1 - (value.abs() / 120),
//                                           child: const Icon(
//                                             Icons.favorite,
//                                             color: Colors.red,
//                                             size: 36,
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 ),
//                               );
//
//                               overlay.insert(overlayEntry);
//
//                               Future.delayed(
//                                 const Duration(milliseconds: 700),
//                                     () => overlayEntry.remove(),
//                               );
//                             },
//
//                             child: Container(
//                               padding: const EdgeInsets.all(6),
//                               decoration: BoxDecoration(
//                                 color: Colors.black.withValues(alpha: 0.35),
//                                 shape: BoxShape.circle,
//                               ),
//                               child: Icon(
//                                 isFav ? Icons.favorite : Icons.favorite_border,
//                                 color: isFav ? Colors.red : Colors.white,
//                                 size: 20,
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               const SizedBox(height: 12),
//
//               /// NAME
//               Text(
//                 widget.product.name,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w600,
//                   fontSize: 15,
//                 ),
//               ),
//
//               const SizedBox(height: 4),
//
//               /// PRICE
//               Text(
//                 "₹${widget.product.price.toStringAsFixed(0)}",
//                 style: const TextStyle(
//                   color: Color(0xFF2E6CF6),
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                 ),
//               ),
//
//               const SizedBox(height: 10),
//
//               /// ADD BUTTON (CLEARLY VISIBLE)
//               SizedBox(
//                 width: double.infinity,
//                 height: 36,
//                 child: ElevatedButton(
//                   onPressed: widget.onAdd,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF2E6CF6),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   child: const Text(
//                     "+ Add",
//                     style:
//                     TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.black),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../models/product_model.dart';
// import '../../providers/order_draft_provider.dart';
// import '../../services/product_service.dart';
// import '../dashboard/dashboard_screen.dart';
// import '../order_draft/order_draft_screen.dart';
// import '../settings/profile_screen.dart';
// import '../../core/helpers.dart';
// import '../../widgets/glass_bottom_navbar.dart';
// import '../../providers/favorites_provider.dart';
//
// class ProductsScreen extends StatefulWidget {
//   const ProductsScreen({super.key});
//
//   @override
//   State<ProductsScreen> createState() => _ProductsScreenState();
// }
//
// class _ProductsScreenState extends State<ProductsScreen> {
//   final List<ProductModel> _allProducts =
//   ProductService.instance.getProducts();
//
//   String _search = "";
//   String _selectedCategory = "All";
//
//   List<String> get _categories {
//     final set = _allProducts.map((e) => e.category).toSet().toList();
//     return ["All", ...set];
//   }
//
//   List<ProductModel> get _filteredProducts {
//     return _allProducts.where((product) {
//       final matchesSearch =
//       product.name.toLowerCase().contains(_search.toLowerCase());
//
//       final matchesCategory =
//           _selectedCategory == "All" || product.category == _selectedCategory;
//
//       return matchesSearch && matchesCategory;
//     }).toList();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0F1218),
//
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF161A22),
//         elevation: 0,
//         title: const Text("Products"),
//         centerTitle: true,
//       ),
//
//       body: Column(
//         children: [
//
//           /// 🔍 SEARCH
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: TextField(
//               onChanged: (value) => setState(() => _search = value),
//               style: const TextStyle(color: Colors.white),
//               decoration: InputDecoration(
//                 hintText: "Search products...",
//                 hintStyle: const TextStyle(color: Color(0xFFA1A6B3)),
//                 prefixIcon: const Icon(Icons.search, color: Color(0xFFA1A6B3)),
//                 filled: true,
//                 fillColor: const Color(0xFF161A22),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(14),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//             ),
//           ),
//
//           /// 🏷 CATEGORY CHIPS (CENTERED FIX)
//           SizedBox(
//             height: 42,
//             child: ListView.separated(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               scrollDirection: Axis.horizontal,
//               itemBuilder: (_, i) {
//                 final category = _categories[i];
//                 final selected = category == _selectedCategory;
//
//                 return GestureDetector(
//                   onTap: () => setState(() => _selectedCategory = category),
//                   child: Container(
//                     alignment: Alignment.center, // ⭐ CENTER FIX
//                     padding:
//                     const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
//                     decoration: BoxDecoration(
//                       color: selected
//                           ? const Color(0xFF2E6CF6)
//                           : const Color(0xFF161A22),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text(
//                       category,
//                       style: TextStyle(
//                         color: selected ? Colors.white : Colors.white70,
//                         fontSize: 12,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 );
//               },
//               separatorBuilder: (_, __) => const SizedBox(width: 10),
//               itemCount: _categories.length,
//             ),
//           ),
//
//           const SizedBox(height: 16),
//
//           /// 🧱 GRID WITH HOVER CARD
//           Expanded(
//             child: GridView.builder(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               itemCount: _filteredProducts.length,
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 4,
//                 mainAxisSpacing: 12,
//                 crossAxisSpacing: 12,
//                 childAspectRatio: 0.72,
//               ),
//               itemBuilder: (_, index) {
//                 final product = _filteredProducts[index];
//
//                 return _HoverProductCard(
//                   product: product,
//                   onAdd: () {
//                     final cart = context.read<OrderDraftProvider>();
//                     cart.addProduct(product);
//                     showAddToCartPopup(context, product);
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//
//       bottomNavigationBar: GlassBottomNavbar(
//
//         currentIndex: 1,
//
//         onTap: (index) {
//
//           if (index == 1) return;
//
//           if (index == 0) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => const DashboardScreen(),
//               ),
//             );
//           }
//
//           if (index == 2) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => const OrderDraftScreen(),
//               ),
//             );
//           }
//
//           if (index == 3) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => const ProfileScreen(),
//               ),
//             );
//           }
//
//         },
//
//       ),
//     );
//   }
// }
//
// ////////////////////////////////////////////////////////////
// /// HOVER PRODUCT CARD (MATCHES DASHBOARD STYLE)
// ////////////////////////////////////////////////////////////
//
// class _HoverProductCard extends StatefulWidget {
//   final ProductModel product;
//   final VoidCallback onAdd;
//
//   const _HoverProductCard({
//     required this.product,
//     required this.onAdd,
//   });
//
//   @override
//   State<_HoverProductCard> createState() => _HoverProductCardState();
// }
//
// class _HoverProductCardState extends State<_HoverProductCard> {
//   bool hovering = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return MouseRegion(
//       onEnter: (_) => setState(() => hovering = true),
//       onExit: (_) => setState(() => hovering = false),
//       child: AnimatedScale(
//         scale: hovering ? 1.03 : 1,
//         duration: const Duration(milliseconds: 180),
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 180),
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: const Color(0xFF161A22),
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(hovering ? 0.45 : 0.25),
//                 blurRadius: hovering ? 28 : 18,
//                 offset: const Offset(0, 12),
//               ),
//             ],
//           ),
//
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//
//               /// IMAGE
//               Expanded(
//                 child: Stack(
//                   children: [
//
//                     /// PRODUCT IMAGE
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(14),
//                       child: Image.asset(
//                         widget.product.image,
//                         fit: BoxFit.cover,
//                         width: double.infinity,
//                         height: double.infinity,
//                       ),
//                     ),
//
//                     /// FAVORITE BUTTON
//                     Positioned(
//                       top: 6,
//                       right: 6,
//                       child: Consumer<FavoritesProvider>(
//                         builder: (context, favorites, _) {
//
//                           final isFav = favorites.isFavorite(widget.product);
//
//                           return GestureDetector(
//                             onTap: () {
//
//                               favorites.toggleFavorite(widget.product);
//
//                               /// Flying heart animation
//                               final overlay = Overlay.of(context);
//                               final box = context.findRenderObject() as RenderBox;
//                               final position = box.localToGlobal(Offset.zero);
//
//                               final overlayEntry = OverlayEntry(
//                                 builder: (_) => Positioned(
//                                   left: position.dx + 40,
//                                   top: position.dy + 40,
//                                   child: TweenAnimationBuilder(
//                                     tween: Tween(begin: 0.0, end: -120.0),
//                                     duration: const Duration(milliseconds: 700),
//
//                                     builder: (context, value, child) {
//                                       return Transform.translate(
//                                         offset: Offset(0, value),
//                                         child: Opacity(
//                                           opacity: 1 - (value.abs() / 120),
//                                           child: const Icon(
//                                             Icons.favorite,
//                                             color: Colors.red,
//                                             size: 36,
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 ),
//                               );
//
//                               overlay.insert(overlayEntry);
//
//                               Future.delayed(
//                                 const Duration(milliseconds: 700),
//                                     () => overlayEntry.remove(),
//                               );
//                             },
//
//                             child: Container(
//                               padding: const EdgeInsets.all(6),
//                               decoration: BoxDecoration(
//                                 color: Colors.black.withValues(alpha: 0.35),
//                                 shape: BoxShape.circle,
//                               ),
//                               child: Icon(
//                                 isFav ? Icons.favorite : Icons.favorite_border,
//                                 color: isFav ? Colors.red : Colors.white,
//                                 size: 20,
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               const SizedBox(height: 5),
//
//               /// NAME
//               Text(
//                 widget.product.name,
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
//               /// PRICE
//               Text(
//                 "₹${widget.product.price.toStringAsFixed(0)}",
//                 style: const TextStyle(
//                   color: Color(0xFF2E6CF6),
//                   fontWeight: FontWeight.bold,
//                   fontSize: 12,
//                 ),
//               ),
//
//               const SizedBox(height: 6),
//
//               /// ADD BUTTON (CLEARLY VISIBLE)
//               SizedBox(
//                 width: double.infinity,
//                 height: 28,
//                 child: ElevatedButton(
//                   onPressed: widget.onAdd,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF2E6CF6),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: const Text(
//                     "+ Add",
//                     style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.black),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../models/product_model.dart';
// import '../../providers/order_draft_provider.dart';
// import '../../services/product_service.dart';
// import '../dashboard/dashboard_screen.dart';
// import '../order_draft/order_draft_screen.dart';
// import '../settings/profile_screen.dart';
// import '../../core/helpers.dart';
// import '../../widgets/glass_bottom_navbar.dart';
// import '../../providers/favorites_provider.dart';
//
// class ProductsScreen extends StatefulWidget {
//   const ProductsScreen({super.key});
//
//   @override
//   State<ProductsScreen> createState() => _ProductsScreenState();
// }
//
// class _ProductsScreenState extends State<ProductsScreen> {
//   final List<ProductModel> _allProducts =
//       ProductService.instance.getProducts();
//
//   String _search = "";
//   String _selectedCategory = "All";
//
//   List<String> get _categories {
//     final set = _allProducts.map((e) => e.category).toSet().toList();
//     return ["All", ...set];
//   }
//
//   List<ProductModel> get _filteredProducts {
//     return _allProducts.where((product) {
//       final matchesSearch =
//       product.name.toLowerCase().contains(_search.toLowerCase());
//
//       final matchesCategory =
//           _selectedCategory == "All" || product.category == _selectedCategory;
//
//       return matchesSearch && matchesCategory;
//     }).toList();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0F1218),
//
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF161A22),
//         elevation: 0,
//         title: const Text("Products"),
//         centerTitle: true,
//       ),
//
//       body: Column(
//         children: [
//
//           /// 🔍 SEARCH
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: TextField(
//               onChanged: (value) => setState(() => _search = value),
//               style: const TextStyle(color: Colors.white),
//               decoration: InputDecoration(
//                 hintText: "Search products...",
//                 hintStyle: const TextStyle(color: Color(0xFFA1A6B3)),
//                 prefixIcon: const Icon(Icons.search, color: Color(0xFFA1A6B3)),
//                 filled: true,
//                 fillColor: const Color(0xFF161A22),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(14),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//             ),
//           ),
//
//           /// 🏷 CATEGORY CHIPS (CENTERED FIX)
//           SizedBox(
//             height: 42,
//             child: ListView.separated(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               scrollDirection: Axis.horizontal,
//               itemBuilder: (_, i) {
//                 final category = _categories[i];
//                 final selected = category == _selectedCategory;
//
//                 return GestureDetector(
//                   onTap: () => setState(() => _selectedCategory = category),
//                   child: Container(
//                     alignment: Alignment.center, // ⭐ CENTER FIX
//                     padding:
//                     const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
//                     decoration: BoxDecoration(
//                       color: selected
//                           ? const Color(0xFF2E6CF6)
//                           : const Color(0xFF161A22),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text(
//                       category,
//                       style: TextStyle(
//                         color: selected ? Colors.white : Colors.white70,
//                         fontSize: 12,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 );
//               },
//               separatorBuilder: (_, __) => const SizedBox(width: 10),
//               itemCount: _categories.length,
//             ),
//           ),
//
//           const SizedBox(height: 16),
//
//           /// 🧱 GRID WITH HOVER CARD
//           Expanded(
//             child: GridView.builder(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               itemCount: _filteredProducts.length,
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 mainAxisSpacing: 16,
//                 crossAxisSpacing: 16,
//                 childAspectRatio: 0.78,
//               ),
//               itemBuilder: (_, index) {
//                 final product = _filteredProducts[index];
//
//                 return _HoverProductCard(
//                   product: product,
//                   onAdd: () {
//                     final cart = context.read<OrderDraftProvider>();
//                     cart.addProduct(product);
//                     showAddToCartPopup(context, product);
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//
//       bottomNavigationBar: GlassBottomNavbar(
//
//         currentIndex: 1,
//
//         onTap: (index) {
//
//           if (index == 1) return;
//
//           if (index == 0) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => const DashboardScreen(),
//               ),
//             );
//           }
//
//           if (index == 2) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => const OrderDraftScreen(),
//               ),
//             );
//           }
//
//           if (index == 3) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => const ProfileScreen(),
//               ),
//             );
//           }
//
//         },
//
//       ),
//     );
//   }
// }
//
// ////////////////////////////////////////////////////////////
// /// HOVER PRODUCT CARD (MATCHES DASHBOARD STYLE)
// ////////////////////////////////////////////////////////////
//
// class _HoverProductCard extends StatefulWidget {
//   final ProductModel product;
//   final VoidCallback onAdd;
//
//   const _HoverProductCard({
//     required this.product,
//     required this.onAdd,
//   });
//
//   @override
//   State<_HoverProductCard> createState() => _HoverProductCardState();
// }
//
// class _HoverProductCardState extends State<_HoverProductCard> {
//   bool hovering = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return MouseRegion(
//       onEnter: (_) => setState(() => hovering = true),
//       onExit: (_) => setState(() => hovering = false),
//       child: AnimatedScale(
//         scale: hovering ? 1.03 : 1,
//         duration: const Duration(milliseconds: 180),
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 180),
//           padding: const EdgeInsets.all(14),
//           decoration: BoxDecoration(
//             color: const Color(0xFF161A22),
//             borderRadius: BorderRadius.circular(20),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(hovering ? 0.45 : 0.25),
//                 blurRadius: hovering ? 28 : 18,
//                 offset: const Offset(0, 12),
//               ),
//             ],
//           ),
//
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//
//               /// IMAGE
//               Expanded(
//                 child: Stack(
//                   children: [
//
//                     /// PRODUCT IMAGE
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(14),
//                       child: Image.asset(
//                         widget.product.image,
//                         fit: BoxFit.cover,
//                         width: double.infinity,
//                         height: double.infinity,
//                       ),
//                     ),
//
//                     /// FAVORITE BUTTON
//                     Positioned(
//                       top: 6,
//                       right: 6,
//                       child: Consumer<FavoritesProvider>(
//                         builder: (context, favorites, _) {
//
//                           final isFav = favorites.isFavorite(widget.product);
//
//                           return GestureDetector(
//                             onTap: () {
//
//                               favorites.toggleFavorite(widget.product);
//
//                               /// Flying heart animation
//                               final overlay = Overlay.of(context);
//                               final box = context.findRenderObject() as RenderBox;
//                               final position = box.localToGlobal(Offset.zero);
//
//                               final overlayEntry = OverlayEntry(
//                                 builder: (_) => Positioned(
//                                   left: position.dx + 40,
//                                   top: position.dy + 40,
//                                   child: TweenAnimationBuilder(
//                                     tween: Tween(begin: 0.0, end: -120.0),
//                                     duration: const Duration(milliseconds: 700),
//
//                                     builder: (context, value, child) {
//                                       return Transform.translate(
//                                         offset: Offset(0, value),
//                                         child: Opacity(
//                                           opacity: 1 - (value.abs() / 120),
//                                           child: const Icon(
//                                             Icons.favorite,
//                                             color: Colors.red,
//                                             size: 36,
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 ),
//                               );
//
//                               overlay.insert(overlayEntry);
//
//                               Future.delayed(
//                                 const Duration(milliseconds: 700),
//                                     () => overlayEntry.remove(),
//                               );
//                             },
//
//                             child: Container(
//                               padding: const EdgeInsets.all(6),
//                               decoration: BoxDecoration(
//                                 color: Colors.black.withValues(alpha: 0.35),
//                                 shape: BoxShape.circle,
//                               ),
//                               child: Icon(
//                                 isFav ? Icons.favorite : Icons.favorite_border,
//                                 color: isFav ? Colors.red : Colors.white,
//                                 size: 20,
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               const SizedBox(height: 12),
//
//               /// NAME
//               Text(
//                 widget.product.name,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w600,
//                   fontSize: 15,
//                 ),
//               ),
//
//               const SizedBox(height: 4),
//
//               /// PRICE
//               Text(
//                 "₹${widget.product.price.toStringAsFixed(0)}",
//                 style: const TextStyle(
//                   color: Color(0xFF2E6CF6),
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                 ),
//               ),
//
//               const SizedBox(height: 10),
//
//               /// ADD BUTTON (CLEARLY VISIBLE)
//               SizedBox(
//                 width: double.infinity,
//                 height: 36,
//                 child: ElevatedButton(
//                   onPressed: widget.onAdd,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF2E6CF6),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   child: const Text(
//                     "+ Add",
//                     style:
//                     TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.black),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
