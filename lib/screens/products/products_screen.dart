import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../providers/order_draft_provider.dart';
import '../../services/product_service.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final List<ProductModel> _allProducts = ProductService.getProducts();

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
      backgroundColor: const Color(0xFF0F1218),

      appBar: AppBar(
        backgroundColor: const Color(0xFF161A22),
        elevation: 0,
        title: const Text("Products"),
        centerTitle: true,
      ),

      body: Column(
        children: [

          /// 🔍 SEARCH
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) => setState(() => _search = value),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search products...",
                hintStyle: const TextStyle(color: Color(0xFFA1A6B3)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFFA1A6B3)),
                filled: true,
                fillColor: const Color(0xFF161A22),
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
                          : const Color(0xFF161A22),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.white70,
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
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.78,
              ),
              itemBuilder: (_, index) {
                final product = _filteredProducts[index];

                return _HoverProductCard(
                  product: product,
                  onAdd: () {
                    context.read<OrderDraftProvider>().addProduct(product);
                  }
                  ,
                );
              },
            ),
          ),
        ],
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
            color: const Color(0xFF161A22),
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    widget.product.image,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              /// NAME
              Text(
                widget.product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
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
