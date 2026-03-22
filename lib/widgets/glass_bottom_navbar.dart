import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme_manager.dart';

class GlassBottomNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const GlassBottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeManager>().isDark;

    final items = [
      {"icon": Icons.home_rounded,          "label": "Home"},
      {"icon": Icons.inventory_2_outlined,  "label": "Products"},
      {"icon": Icons.shopping_cart_outlined,"label": "Cart"},
      {"icon": Icons.person_outline,        "label": "Profile"},
    ];

    final bgColor      = isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.85);
    final borderColor  = isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.08);
    final unselected   = isDark ? Colors.white70 : Colors.black54;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 62,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: borderColor),
              boxShadow: isDark ? [] : [
                BoxShadow(color: Colors.black.withOpacity(0.08),
                    blurRadius: 16, offset: const Offset(0, -2)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(items.length, (index) {
                final selected = currentIndex == index;
                return GestureDetector(
                  onTap: () => onTap(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: selected ? [
                        BoxShadow(
                            color: const Color(0xFF2E6CF6).withOpacity(0.4),
                            blurRadius: 16, spreadRadius: 1)
                      ] : [],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          items[index]["icon"] as IconData,
                          size: selected ? 26 : 22,
                          color: selected ? const Color(0xFF2E6CF6) : unselected,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          items[index]["label"] as String,
                          style: TextStyle(
                            fontSize: 11,
                            color: selected ? const Color(0xFF2E6CF6) : unselected,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}


// import 'dart:ui';
// import 'package:flutter/material.dart';
//
// class GlassBottomNavbar extends StatelessWidget {
//
//   final int currentIndex;
//   final Function(int) onTap;
//
//   const GlassBottomNavbar({
//     super.key,
//     required this.currentIndex,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//
//     final items = [
//       {"icon": Icons.home_rounded, "label": "Home"},
//       {"icon": Icons.inventory_2_outlined, "label": "Products"},
//       {"icon": Icons.shopping_cart_outlined, "label": "Cart"},
//       {"icon": Icons.person_outline, "label": "Profile"},
//     ];
//
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
//
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(26),
//
//         child: BackdropFilter(
//           filter: ImageFilter.blur(
//             sigmaX: 20,
//             sigmaY: 20,
//           ),
//
//           child: Container(
//             height: 62,
//
//             decoration: BoxDecoration(
//               color: Colors.white.withValues(alpha: 0.05),
//               borderRadius: BorderRadius.circular(26),
//               border: Border.all(
//                 color: Colors.white.withValues(alpha: 0.12),
//               ),
//             ),
//
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: List.generate(items.length, (index) {
//
//                 final selected = currentIndex == index;
//
//                 return GestureDetector(
//                   onTap: () => onTap(index),
//
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 300),
//
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 6,
//                     ),
//
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(18),
//
//                       boxShadow: selected
//                           ? [
//                         BoxShadow(
//                           color: const Color(0xFF2E6CF6)
//                               .withValues(alpha: 0.5),
//                           blurRadius: 16,
//                           spreadRadius: 1,
//                         )
//                       ]
//                           : [],
//                     ),
//
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//
//                         Icon(
//                           items[index]["icon"] as IconData,
//                           size: selected ? 26 : 22,
//                           color: selected
//                               ? const Color(0xFF2E6CF6)
//                               : Colors.white70,
//                         ),
//
//                         const SizedBox(height: 2),
//
//                         Text(
//                           items[index]["label"] as String,
//                           style: TextStyle(
//                             fontSize: 11,
//                             color: selected
//                                 ? const Color(0xFF2E6CF6)
//                                 : Colors.white70,
//                           ),
//                         )
//                       ],
//                     ),
//                   ),
//                 );
//               }),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }