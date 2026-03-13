import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/order_draft_provider.dart';
import '../routes/app_routes.dart';

class CartBadge extends StatelessWidget {
  const CartBadge({super.key});

  @override
  Widget build(BuildContext context) {

    final cart = context.watch<OrderDraftProvider>();
    final count = cart.items.length;

    return Stack(
      clipBehavior: Clip.none,
      children: [

        /// Cart Icon
        IconButton(
          icon: const Icon(
            Icons.shopping_cart_outlined,
            color: Colors.white,
          ),
          onPressed: () {

            Navigator.pushNamed(
              context,
              AppRoutes.orderDraft,
            );

          },
        ),

        /// Badge
        if (count > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color(0xFF2E6CF6),
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Center(
                child: Text(
                  count.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}