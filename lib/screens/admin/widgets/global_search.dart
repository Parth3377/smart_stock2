// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'dart:async';
// import '/core/models/models.dart';
// import '/providers/admin_providers.dart';
// import '../widgets/shared_widgets.dart';
//
// // ═══════════════════════════════════════════════════════════════════
// //  GlobalSearchOverlay
// //  Drop this widget into the top bar. It overlays search results
// //  live as the user types, across Products, Orders, Customers.
// // ═══════════════════════════════════════════════════════════════════
//
// class GlobalSearchBar extends StatefulWidget {
//   final Function(int page) onNavigate;
//   const GlobalSearchBar({super.key, required this.onNavigate});
//
//   @override
//   State<GlobalSearchBar> createState() => _GlobalSearchBarState();
// }
//
// class _GlobalSearchBarState extends State<GlobalSearchBar> {
//   final _ctrl = TextEditingController();
//   final _focus = FocusNode();
//   final _layerLink = LayerLink();
//   OverlayEntry? _overlay;
//   Timer? _debounce;
//   bool _focused = false;
//   String _query = '';
//
//   @override
//   void initState() {
//     super.initState();
//     _focus.addListener(() {
//       setState(() => _focused = _focus.hasFocus);
//       if (_focus.hasFocus && _query.isNotEmpty) {
//         _showOverlay();
//       } else if (!_focus.hasFocus) {
//         Future.delayed(const Duration(milliseconds: 200), _hideOverlay);
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _debounce?.cancel();
//     _ctrl.dispose();
//     _focus.dispose();
//     _hideOverlay();
//     super.dispose();
//   }
//
//   void _onChanged(String v) {
//     _debounce?.cancel();
//     _debounce = Timer(const Duration(milliseconds: 300), () {
//       setState(() => _query = v.trim());
//       if (v.trim().isNotEmpty) {
//         _showOverlay();
//       } else {
//         _hideOverlay();
//       }
//     });
//   }
//
//   void _showOverlay() {
//     _hideOverlay();
//     _overlay = OverlayEntry(builder: (_) => _SearchResults(
//       query: _query,
//       link: _layerLink,
//       onNavigate: (page) {
//         _hideOverlay();
//         _focus.unfocus();
//         widget.onNavigate(page);
//       },
//       onClose: _hideOverlay,
//     ));
//     Overlay.of(context).insert(_overlay!);
//   }
//
//   void _hideOverlay() {
//     _overlay?.remove();
//     _overlay = null;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return CompositedTransformTarget(
//       link: _layerLink,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         width: _focused ? 320 : 240,
//         height: 38,
//         decoration: BoxDecoration(
//           color: AC.card,
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(color: _focused ? AC.blue.withOpacity(0.6) : AC.border2),
//         ),
//         child: Row(children: [
//           const SizedBox(width: 12),
//           const Icon(Icons.search_rounded, color: AC.text3, size: 17),
//           const SizedBox(width: 8),
//           Expanded(
//             child: TextField(
//               controller: _ctrl,
//               focusNode: _focus,
//               style: const TextStyle(color: AC.text1, fontSize: 13),
//               decoration: const InputDecoration(
//                 hintText: 'Search products, orders, customers...',
//                 hintStyle: TextStyle(color: AC.text3, fontSize: 12.5),
//                 border: InputBorder.none,
//                 isDense: true,
//               ),
//               onChanged: _onChanged,
//             ),
//           ),
//           if (_ctrl.text.isNotEmpty)
//             GestureDetector(
//               onTap: () {
//                 _ctrl.clear();
//                 setState(() => _query = '');
//                 _hideOverlay();
//               },
//               child: const Padding(
//                 padding: EdgeInsets.only(right: 10),
//                 child: Icon(Icons.close_rounded, color: AC.text3, size: 15),
//               ),
//             ),
//         ]),
//       ),
//     );
//   }
// }
//
// // ── Search Results Overlay ────────────────────────────────────────────
// class _SearchResults extends StatelessWidget {
//   final String query;
//   final LayerLink link;
//   final Function(int) onNavigate;
//   final VoidCallback onClose;
//
//   const _SearchResults({
//     required this.query,
//     required this.link,
//     required this.onNavigate,
//     required this.onClose,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Positioned(
//       width: 380,
//       child: CompositedTransformFollower(
//         link: link,
//         showWhenUnlinked: false,
//         offset: const Offset(0, 44),
//         child: Material(
//           color: Colors.transparent,
//           child: Consumer3<AdminProductsProvider, AdminOrdersProvider, AdminCustomersProvider>(
//             builder: (_, prods, orders, customers, __) {
//               final q = query.toLowerCase();
//
//               final matchProds = prods.filtered
//                   .where((p) =>
//               p.name.toLowerCase().contains(q) ||
//                   p.sku.toLowerCase().contains(q) ||
//                   p.category.toLowerCase().contains(q))
//                   .take(4)
//                   .toList();
//
//               final matchOrders = orders.filtered
//                   .where((o) =>
//               o.id.toLowerCase().contains(q) ||
//                   o.customerName.toLowerCase().contains(q))
//                   .take(3)
//                   .toList();
//
//               final matchCustomers = customers.filtered
//                   .where((c) =>
//               c.name.toLowerCase().contains(q) ||
//                   c.email.toLowerCase().contains(q) ||
//                   c.city.toLowerCase().contains(q))
//                   .take(3)
//                   .toList();
//
//               final hasResults = matchProds.isNotEmpty ||
//                   matchOrders.isNotEmpty ||
//                   matchCustomers.isNotEmpty;
//
//               return Container(
//                 constraints: const BoxConstraints(maxHeight: 480),
//                 decoration: BoxDecoration(
//                   color: AC.card,
//                   borderRadius: BorderRadius.circular(14),
//                   border: Border.all(color: AC.border2),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.5),
//                       blurRadius: 24,
//                       offset: const Offset(0, 8),
//                     ),
//                   ],
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(14),
//                   child: SingleChildScrollView(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Header
//                         Padding(
//                           padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 hasResults
//                                     ? 'Results for "$query"'
//                                     : 'No results for "$query"',
//                                 style: const TextStyle(
//                                     color: AC.text3,
//                                     fontSize: 11.5,
//                                     fontWeight: FontWeight.w500),
//                               ),
//                               GestureDetector(
//                                 onTap: onClose,
//                                 child: const Icon(Icons.close_rounded,
//                                     color: AC.text3, size: 14),
//                               ),
//                             ],
//                           ),
//                         ),
//
//                         if (!hasResults)
//                           const Padding(
//                             padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
//                             child: Text(
//                               'Try searching for a product name, SKU, order ID or customer name.',
//                               style: TextStyle(color: AC.text3, fontSize: 12),
//                             ),
//                           ),
//
//                         // Products
//                         if (matchProds.isNotEmpty) ...[
//                           _SectionHeader('Products', matchProds.length, () => onNavigate(1)),
//                           ...matchProds.map((p) => _ProductResult(p, () => onNavigate(1))),
//                         ],
//
//                         // Orders
//                         if (matchOrders.isNotEmpty) ...[
//                           _SectionHeader('Orders', matchOrders.length, () => onNavigate(2)),
//                           ...matchOrders.map((o) => _OrderResult(o, () => onNavigate(2))),
//                         ],
//
//                         // Customers
//                         if (matchCustomers.isNotEmpty) ...[
//                           _SectionHeader('Customers', matchCustomers.length, () => onNavigate(7)),
//                           ...matchCustomers.map((c) => _CustomerResult(c, () => onNavigate(7))),
//                         ],
//
//                         const SizedBox(height: 8),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _SectionHeader extends StatelessWidget {
//   final String label;
//   final int count;
//   final VoidCallback onViewAll;
//   const _SectionHeader(this.label, this.count, this.onViewAll);
//
//   @override
//   Widget build(BuildContext context) => Container(
//     padding: const EdgeInsets.fromLTRB(16, 10, 12, 6),
//     decoration: const BoxDecoration(
//       border: Border(top: BorderSide(color: AC.border, width: 0.5)),
//     ),
//     child: Row(children: [
//       Text(label.toUpperCase(),
//           style: const TextStyle(
//               color: AC.text3, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
//       const SizedBox(width: 8),
//       Container(
//         padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//         decoration: BoxDecoration(
//             color: AC.blue.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
//         child: Text('$count', style: const TextStyle(color: AC.blue, fontSize: 10)),
//       ),
//       const Spacer(),
//       GestureDetector(
//         onTap: onViewAll,
//         child: const Text('View all →',
//             style: TextStyle(color: AC.blue, fontSize: 11)),
//       ),
//     ]),
//   );
// }
//
// class _ProductResult extends StatelessWidget {
//   final ProductModel p;
//   final VoidCallback onTap;
//   const _ProductResult(this.p, this.onTap);
//
//   @override
//   Widget build(BuildContext context) => InkWell(
//     onTap: onTap,
//     hoverColor: AC.blue.withOpacity(0.05),
//     child: Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
//       child: Row(children: [
//         Container(
//           width: 30, height: 30,
//           decoration: BoxDecoration(
//               color: AC.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(7)),
//           child: const Icon(Icons.inventory_2_rounded, color: AC.blue, size: 15),
//         ),
//         const SizedBox(width: 10),
//         Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Text(p.name,
//               style: const TextStyle(
//                   color: AC.text1, fontSize: 12.5, fontWeight: FontWeight.w500),
//               overflow: TextOverflow.ellipsis),
//           Text('${p.sku}  ·  ${p.category}',
//               style: const TextStyle(color: AC.text3, fontSize: 11)),
//         ])),
//         Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
//           Text('₹${p.price.toStringAsFixed(0)}',
//               style: const TextStyle(color: AC.text1, fontSize: 12, fontWeight: FontWeight.w600)),
//           SBadge.fromStatus(p.stockStatus),
//         ]),
//       ]),
//     ),
//   );
// }
//
// class _OrderResult extends StatelessWidget {
//   final OrderModel o;
//   final VoidCallback onTap;
//   const _OrderResult(this.o, this.onTap);
//
//   @override
//   Widget build(BuildContext context) => InkWell(
//     onTap: onTap,
//     hoverColor: AC.blue.withOpacity(0.05),
//     child: Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
//       child: Row(children: [
//         Container(
//           width: 30, height: 30,
//           decoration: BoxDecoration(
//               color: AC.purple.withOpacity(0.1), borderRadius: BorderRadius.circular(7)),
//           child: const Icon(Icons.receipt_long_rounded, color: AC.purple, size: 15),
//         ),
//         const SizedBox(width: 10),
//         Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Text(o.id,
//               style: const TextStyle(
//                   color: AC.blue, fontSize: 12.5, fontWeight: FontWeight.w600)),
//           Text(o.customerName, style: const TextStyle(color: AC.text3, fontSize: 11)),
//         ])),
//         Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
//           Text(fmtCurrency(o.totalAmount),
//               style: const TextStyle(
//                   color: AC.text1, fontSize: 12, fontWeight: FontWeight.w600)),
//           SBadge.fromStatus(o.status),
//         ]),
//       ]),
//     ),
//   );
// }
//
// class _CustomerResult extends StatelessWidget {
//   final CustomerModel c;
//   final VoidCallback onTap;
//   const _CustomerResult(this.c, this.onTap);
//
//   @override
//   Widget build(BuildContext context) => InkWell(
//     onTap: onTap,
//     hoverColor: AC.blue.withOpacity(0.05),
//     child: Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
//       child: Row(children: [
//         CircleAvatar(
//           radius: 15,
//           backgroundColor: AC.green.withOpacity(0.15),
//           child: Text(c.name[0],
//               style: const TextStyle(
//                   color: AC.green, fontSize: 13, fontWeight: FontWeight.bold)),
//         ),
//         const SizedBox(width: 10),
//         Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Text(c.name,
//               style: const TextStyle(
//                   color: AC.text1, fontSize: 12.5, fontWeight: FontWeight.w500)),
//           Text('${c.email}  ·  ${c.city}',
//               style: const TextStyle(color: AC.text3, fontSize: 11),
//               overflow: TextOverflow.ellipsis),
//         ])),
//         Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
//           Text('${c.totalOrders} orders',
//               style: const TextStyle(color: AC.text3, fontSize: 11)),
//           Text(fmtCurrency(c.totalSpend),
//               style: const TextStyle(
//                   color: AC.green, fontSize: 12, fontWeight: FontWeight.w600)),
//         ]),
//       ]),
//     ),
//   );
// }


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:smart_stock2/providers/admin_providers.dart';
import 'shared_widgets.dart';

// ═══════════════════════════════════════════════════════════════════
//  GlobalSearchBar
//  Drop into the top bar. Overlays live search results across
//  Products and Orders using Admin providers only.
// ═══════════════════════════════════════════════════════════════════

class GlobalSearchBar extends StatefulWidget {
  final Function(int page) onNavigate;
  const GlobalSearchBar({super.key, required this.onNavigate});

  @override
  State<GlobalSearchBar> createState() => _GlobalSearchBarState();
}

class _GlobalSearchBarState extends State<GlobalSearchBar> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  final _layerLink = LayerLink();
  OverlayEntry? _overlay;
  Timer? _debounce;
  bool _focused = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      setState(() => _focused = _focus.hasFocus);
      if (_focus.hasFocus && _query.isNotEmpty) {
        _showOverlay();
      } else if (!_focus.hasFocus) {
        Future.delayed(const Duration(milliseconds: 200), _hideOverlay);
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    _focus.dispose();
    _hideOverlay();
    super.dispose();
  }

  void _onChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() => _query = v.trim());
      if (v.trim().isNotEmpty) {
        _showOverlay();
      } else {
        _hideOverlay();
      }
    });
  }

  void _showOverlay() {
    _hideOverlay();
    _overlay = OverlayEntry(builder: (_) => _SearchResults(
      query: _query,
      link: _layerLink,
      onNavigate: (page) {
        _hideOverlay();
        _focus.unfocus();
        widget.onNavigate(page);
      },
      onClose: _hideOverlay,
    ));
    Overlay.of(context).insert(_overlay!);
  }

  void _hideOverlay() {
    _overlay?.remove();
    _overlay = null;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: _focused ? 320 : 240,
        height: 38,
        decoration: BoxDecoration(
          color: AC.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: _focused ? AC.blue.withOpacity(0.6) : AC.border2),
        ),
        child: Row(children: [
          const SizedBox(width: 12),
          const Icon(Icons.search_rounded, color: AC.text3, size: 17),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _ctrl,
              focusNode: _focus,
              style: const TextStyle(color: AC.text1, fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'Search products, orders...',
                hintStyle: TextStyle(color: AC.text3, fontSize: 12.5),
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: _onChanged,
            ),
          ),
          if (_ctrl.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _ctrl.clear();
                setState(() => _query = '');
                _hideOverlay();
              },
              child: const Padding(
                padding: EdgeInsets.only(right: 10),
                child: Icon(Icons.close_rounded, color: AC.text3, size: 15),
              ),
            ),
        ]),
      ),
    );
  }
}

// ── Search Results Overlay ────────────────────────────────────────────
class _SearchResults extends StatelessWidget {
  final String query;
  final LayerLink link;
  final Function(int) onNavigate;
  final VoidCallback onClose;

  const _SearchResults({
    required this.query,
    required this.link,
    required this.onNavigate,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      width: 380,
      child: CompositedTransformFollower(
        link: link,
        showWhenUnlinked: false,
        offset: const Offset(0, 44),
        child: Material(
          color: Colors.transparent,
          child: Consumer2<AdminProductsProvider, AdminOrdersProvider>(
            builder: (_, prods, orders, __) {
              final q = query.toLowerCase();

              final matchProds = prods.filtered
                  .where((p) =>
              p.name.toLowerCase().contains(q) ||
                  p.sku.toLowerCase().contains(q) ||
                  p.category.toLowerCase().contains(q))
                  .take(4)
                  .toList();

              final matchOrders = orders.filtered
                  .where((o) =>
              o.id.toLowerCase().contains(q) ||
                  o.customerName.toLowerCase().contains(q))
                  .take(3)
                  .toList();

              final hasResults =
                  matchProds.isNotEmpty || matchOrders.isNotEmpty;

              return Container(
                constraints: const BoxConstraints(maxHeight: 480),
                decoration: BoxDecoration(
                  color: AC.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AC.border2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Header ──
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                hasResults
                                    ? 'Results for "$query"'
                                    : 'No results for "$query"',
                                style: const TextStyle(
                                    color: AC.text3,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500),
                              ),
                              GestureDetector(
                                onTap: onClose,
                                child: const Icon(Icons.close_rounded,
                                    color: AC.text3, size: 14),
                              ),
                            ],
                          ),
                        ),

                        if (!hasResults)
                          const Padding(
                            padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                            child: Text(
                              'Try searching for a product name, SKU, or order ID.',
                              style: TextStyle(color: AC.text3, fontSize: 12),
                            ),
                          ),

                        // ── Products ──
                        if (matchProds.isNotEmpty) ...[
                          _SectionHeader('Products', matchProds.length,
                                  () => onNavigate(1)),
                          ...matchProds.map(
                                  (p) => _ProductResult(p, () => onNavigate(1))),
                        ],

                        // ── Orders ──
                        if (matchOrders.isNotEmpty) ...[
                          _SectionHeader('Orders', matchOrders.length,
                                  () => onNavigate(2)),
                          ...matchOrders.map(
                                  (o) => _OrderResult(o, () => onNavigate(2))),
                        ],

                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String label;
  final int count;
  final VoidCallback onViewAll;
  const _SectionHeader(this.label, this.count, this.onViewAll);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 10, 12, 6),
    decoration: const BoxDecoration(
      border: Border(top: BorderSide(color: AC.border, width: 0.5)),
    ),
    child: Row(children: [
      Text(label.toUpperCase(),
          style: const TextStyle(
              color: AC.text3,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1)),
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
            color: AC.blue.withOpacity(0.15),
            borderRadius: BorderRadius.circular(4)),
        child: Text('$count',
            style: const TextStyle(color: AC.blue, fontSize: 10)),
      ),
      const Spacer(),
      GestureDetector(
        onTap: onViewAll,
        child: const Text('View all →',
            style: TextStyle(color: AC.blue, fontSize: 11)),
      ),
    ]),
  );
}

// ── Product Result Row ────────────────────────────────────────────────
class _ProductResult extends StatelessWidget {
  final AdminProduct p;          // ← AdminProduct from admin_providers.dart
  final VoidCallback onTap;
  const _ProductResult(this.p, this.onTap);

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    hoverColor: AC.blue.withOpacity(0.05),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      child: Row(children: [
        Container(
          width: 30, height: 30,
          decoration: BoxDecoration(
              color: AC.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(7)),
          child: const Icon(Icons.inventory_2_rounded, color: AC.blue, size: 15),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(p.name,
                  style: const TextStyle(
                      color: AC.text1,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis),
              Text('${p.sku}  ·  ${p.category}',
                  style: const TextStyle(color: AC.text3, fontSize: 11)),
            ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('₹${p.price.toStringAsFixed(0)}',
              style: const TextStyle(
                  color: AC.text1,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
          SBadge.fromStatus(p.stockStatus),
        ]),
      ]),
    ),
  );
}

// ── Order Result Row ──────────────────────────────────────────────────
class _OrderResult extends StatelessWidget {
  final AdminOrder o;            // ← AdminOrder from admin_providers.dart
  final VoidCallback onTap;
  const _OrderResult(this.o, this.onTap);

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    hoverColor: AC.blue.withOpacity(0.05),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      child: Row(children: [
        Container(
          width: 30, height: 30,
          decoration: BoxDecoration(
              color: AC.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(7)),
          child: const Icon(Icons.receipt_long_rounded,
              color: AC.purple, size: 15),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(o.id,
                  style: const TextStyle(
                      color: AC.blue,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600)),
              Text(o.customerName,
                  style: const TextStyle(color: AC.text3, fontSize: 11)),
            ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(fmtCurrency(o.totalAmount),
              style: const TextStyle(
                  color: AC.text1,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
          SBadge.fromStatus(o.status),
        ]),
      ]),
    ),
  );
}