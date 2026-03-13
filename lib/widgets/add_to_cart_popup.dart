import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/product_model.dart';

class AddToCartPopup extends StatefulWidget {

  final ProductModel product;

  const AddToCartPopup({
    super.key,
    required this.product,
  });

  @override
  State<AddToCartPopup> createState() => _AddToCartPopupState();
}

class _AddToCartPopupState extends State<AddToCartPopup> {

  @override
  void initState() {
    super.initState();

    /// Auto close after 3 seconds
    Timer(const Duration(seconds: 1), () {

      if (mounted) {
        Navigator.pop(context);
      }

    });
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 20,
      ),

      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),

        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 20,
            sigmaY: 20,
          ),

          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 28,
              vertical: 30,
            ),

            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                /// Success Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF2E6CF6)
                        .withValues(alpha: 0.15),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Color(0xFF2E6CF6),
                    size: 36,
                  ),
                ),

                const SizedBox(height: 20),

                /// Title
                const Text(
                  "Added to Cart",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 12),

                /// Product Name
                Text(
                  widget.product.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 8),

                /// Price
                Text(
                  "₹${widget.product.price}",
                  style: const TextStyle(
                    color: Color(0xFF2E6CF6),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}