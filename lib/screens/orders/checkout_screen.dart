import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/order_draft_provider.dart';
import '../../providers/location_provider.dart';
import '../../models/location_model.dart';
import '../../routes/app_routes.dart';
import '../../widgets/glass_bottom_navbar.dart';
import '../maps/delivery_location_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final bool selectAddressMode;

  const CheckoutScreen({
    super.key,
    this.selectAddressMode = false,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {

  int selectedAddress = 0;
  LocationModel? _selectedMapLocation; // from Google Maps picker

  List<Map<String, String>> addresses = [
    {
      "name": "Parth Chauhan",
      "address": "Navrangpura, Ahmedabad, Gujarat",
      "phone": "9876543210"
    },
    {
      "name": "Office Address",
      "address": "CG Road, Ahmedabad, Gujarat",
      "phone": "9123456780"
    }
  ];

  @override
  Widget build(BuildContext context) {

    final provider = context.watch<OrderDraftProvider>();
    final cartItems = provider.items;
    final total = provider.totalPrice;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1218),

      bottomNavigationBar: GlassBottomNavbar(
        currentIndex: 2,
        onTap: (index) {

          if (index == 0) {
            Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
          }

          if (index == 1) {
            Navigator.pushReplacementNamed(context, AppRoutes.products);
          }

          if (index == 2) return;

          if (index == 3) {
            Navigator.pushReplacementNamed(context, AppRoutes.profile);
          }

        },
      ),

      appBar: AppBar(
        backgroundColor: const Color(0xFF161A22),
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.selectAddressMode ? "Select Address" : "Checkout",
        ),
      ),

      body: widget.selectAddressMode
          ? _buildSelectAddress()
          : _buildCheckout(cartItems, total),
    );
  }

  ////////////////////////////////////////////////////////////
  /// SELECT ADDRESS PAGE
  ////////////////////////////////////////////////////////////

  Widget _buildSelectAddress() {
    return Column(
      children: [

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: addresses.length,
            itemBuilder: (_, index) {

              final address = addresses[index];
              final selected = selectedAddress == index;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedAddress = index;
                  });
                },

                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: const Color(0xFF161A22),
                    borderRadius: BorderRadius.circular(16),

                    border: Border.all(
                      color: selected
                          ? const Color(0xFF2E6CF6)
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),

                  child: Row(
                    children: [

                      Icon(
                        selected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: const Color(0xFF2E6CF6),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text(
                              address["name"]!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              address["address"]!,
                              style: const TextStyle(
                                color: Colors.white70,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              "Phone: ${address["phone"]}",
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Icon(
                        Icons.edit_outlined,
                        color: Colors.white54,
                        size: 18,
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        /// ADD ADDRESS BUTTON
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: OutlinedButton.icon(
            onPressed: () async {
              // Open Google Maps location picker
              final LocationModel? result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider(
                    create: (_) => LocationProvider(),
                    child: const DeliveryLocationScreen(isSelecting: true),
                  ),
                ),
              );
              if (result != null && mounted) {
                setState(() {
                  _selectedMapLocation = result;
                  // Add to addresses list
                  addresses.insert(0, {
                    'name':    'Map Location',
                    'address': result.address,
                    'phone':   '',
                    'lat':     result.lat.toString(),
                    'lng':     result.lng.toString(),
                  });
                  selectedAddress = 0;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Delivery location set from map ✅'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Color(0xFF2E6CF6),
                  ),
                );
              }
            },
            icon: const Icon(Icons.map_outlined),
            label: const Text('Pick on Google Maps'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF2E6CF6),
              side: const BorderSide(color: Color(0xFF2E6CF6)),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        /// DELIVER HERE BUTTON
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                final address = _selectedMapLocation?.address
                    ?? addresses[selectedAddress]['address']
                    ?? 'Ahmedabad, Gujarat';
                Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.payment,
                  arguments: address,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E6CF6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                "Deliver Here",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  ////////////////////////////////////////////////////////////
  /// CHECKOUT PAGE
  ////////////////////////////////////////////////////////////

  Widget _buildCheckout(cartItems, total) {

    if (cartItems.isEmpty) {
      return const Center(
        child: Text(
          "Your cart is empty",
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return Column(
      children: [

        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [

              const _SectionTitle("Order Items"),
              const SizedBox(height: 12),

              ...cartItems
                  .map((item) => _CheckoutItemTile(item: item))
                  .toList(),

              const SizedBox(height: 24),

              const _SectionTitle("Delivery Address"),
              const SizedBox(height: 12),
              const _AddressCard(),

              const SizedBox(height: 24),

              const _SectionTitle("Order Summary"),
              const SizedBox(height: 12),
              _OrderSummary(total: total),

              const SizedBox(height: 120),
            ],
          ),
        ),

        _CheckoutBottomBar(total: total),
      ],
    );
  }

  ////////////////////////////////////////////////////////////
  /// ADD ADDRESS GLASS POPUP
  ////////////////////////////////////////////////////////////

  void _showAddAddressPopup() {

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),

      builder: (_) {

        return Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),

            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 20,
                sigmaY: 20,
              ),

              child: Container(
                width: 280,
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(22),

                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    const Text(
                      "Add Address",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 16),

                    const TextField(
                      decoration: InputDecoration(
                        hintText: "Name",
                        hintStyle: TextStyle(color: Colors.white54),
                      ),
                    ),

                    const SizedBox(height: 12),

                    const TextField(
                      decoration: InputDecoration(
                        hintText: "Address",
                        hintStyle: TextStyle(color: Colors.white54),
                      ),
                    ),

                    const SizedBox(height: 12),

                    const TextField(
                      decoration: InputDecoration(
                        hintText: "Phone",
                        hintStyle: TextStyle(color: Colors.white54),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [

                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("Cancel"),
                        ),

                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("Save"),
                        )
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
}

////////////////////////////////////////////////////////////
/// SECTION TITLE
////////////////////////////////////////////////////////////

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// CHECKOUT ITEM TILE
////////////////////////////////////////////////////////////

class _CheckoutItemTile extends StatelessWidget {

  final dynamic item;

  const _CheckoutItemTile({required this.item});

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: const Color(0xFF161A22),
        borderRadius: BorderRadius.circular(14),
      ),

      child: Row(
        children: [

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              item.product.image,
              width: 52,
              height: 52,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  item.product.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  "Qty: ${item.quantity}",
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          Text(
            "₹${(item.product.price * item.quantity).toStringAsFixed(0)}",
            style: const TextStyle(
              color: Color(0xFF2E6CF6),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// ADDRESS CARD
////////////////////////////////////////////////////////////

class _AddressCard extends StatelessWidget {

  const _AddressCard();

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: const Color(0xFF161A22),
        borderRadius: BorderRadius.circular(14),
      ),

      child: Row(
        children: const [

          Icon(
            Icons.location_on_outlined,
            color: Color(0xFF2E6CF6),
          ),

          SizedBox(width: 10),

          Expanded(
            child: Text(
              "Surendranagar , Gujarat\nIndia",
              style: TextStyle(color: Colors.white),
            ),
          ),

          Icon(
            Icons.edit_outlined,
            color: Colors.white54,
            size: 18,
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// ORDER SUMMARY
////////////////////////////////////////////////////////////

class _OrderSummary extends StatelessWidget {

  final double total;

  const _OrderSummary({required this.total});

  @override
  Widget build(BuildContext context) {

    const delivery = 40.0;
    final grandTotal = total + delivery;

    return Container(
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: const Color(0xFF161A22),
        borderRadius: BorderRadius.circular(14),
      ),

      child: Column(
        children: [

          _row("Subtotal", total),
          _row("Delivery", delivery),

          const Divider(
            color: Colors.white12,
            height: 20,
          ),

          _row("Total", grandTotal, isBold: true),
        ],
      ),
    );
  }

  Widget _row(String title, double value, {bool isBold = false}) {

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        Text(
          title,
          style: TextStyle(
            color: Colors.white70,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
          ),
        ),

        Text(
          "₹${value.toStringAsFixed(0)}",
          style: TextStyle(
            color: Colors.white,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

////////////////////////////////////////////////////////////
/// BOTTOM BAR
////////////////////////////////////////////////////////////

class _CheckoutBottomBar extends StatelessWidget {

  final double total;

  const _CheckoutBottomBar({required this.total});

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(16),

      decoration: const BoxDecoration(
        color: Color(0xFF161A22),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),

      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 52,

          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.payment,
              );
            },

            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E6CF6),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),

            child: const Text(
              "Continue to Payment",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}


// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../providers/order_draft_provider.dart';
// import '../../routes/app_routes.dart';
// import '../../widgets/glass_bottom_navbar.dart';
//
// class CheckoutScreen extends StatefulWidget {
//   final bool selectAddressMode;
//
//   const CheckoutScreen({
//     super.key,
//     this.selectAddressMode = false,
//   });
//
//   @override
//   State<CheckoutScreen> createState() => _CheckoutScreenState();
// }
//
// class _CheckoutScreenState extends State<CheckoutScreen> {
//
//   int selectedAddress = 0;
//
//   List<Map<String, String>> addresses = [
//     {
//       "name": "Parth Chauhan",
//       "address": "Navrangpura, Ahmedabad, Gujarat",
//       "phone": "9876543210"
//     },
//     {
//       "name": "Office Address",
//       "address": "CG Road, Ahmedabad, Gujarat",
//       "phone": "9123456780"
//     }
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//
//     final provider = context.watch<OrderDraftProvider>();
//     final cartItems = provider.items;
//     final total = provider.totalPrice;
//
//     return Scaffold(
//       backgroundColor: const Color(0xFF0F1218),
//
//       bottomNavigationBar: GlassBottomNavbar(
//         currentIndex: 2,
//         onTap: (index) {
//
//           if (index == 0) {
//             Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
//           }
//
//           if (index == 1) {
//             Navigator.pushReplacementNamed(context, AppRoutes.products);
//           }
//
//           if (index == 2) return;
//
//           if (index == 3) {
//             Navigator.pushReplacementNamed(context, AppRoutes.profile);
//           }
//
//         },
//       ),
//
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF161A22),
//         elevation: 0,
//         centerTitle: true,
//         title: Text(
//           widget.selectAddressMode ? "Select Address" : "Checkout",
//         ),
//       ),
//
//       body: widget.selectAddressMode
//           ? _buildSelectAddress()
//           : _buildCheckout(cartItems, total),
//     );
//   }
//
//   ////////////////////////////////////////////////////////////
//   /// SELECT ADDRESS PAGE
//   ////////////////////////////////////////////////////////////
//
//   Widget _buildSelectAddress() {
//     return Column(
//       children: [
//
//         Expanded(
//           child: ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: addresses.length,
//             itemBuilder: (_, index) {
//
//               final address = addresses[index];
//               final selected = selectedAddress == index;
//
//               return GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     selectedAddress = index;
//                   });
//                 },
//
//                 child: Container(
//                   margin: const EdgeInsets.only(bottom: 12),
//                   padding: const EdgeInsets.all(16),
//
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF161A22),
//                     borderRadius: BorderRadius.circular(16),
//
//                     border: Border.all(
//                       color: selected
//                           ? const Color(0xFF2E6CF6)
//                           : Colors.transparent,
//                       width: 1.5,
//                     ),
//                   ),
//
//                   child: Row(
//                     children: [
//
//                       Icon(
//                         selected
//                             ? Icons.radio_button_checked
//                             : Icons.radio_button_off,
//                         color: const Color(0xFF2E6CF6),
//                       ),
//
//                       const SizedBox(width: 12),
//
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//
//                             Text(
//                               address["name"]!,
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//
//                             const SizedBox(height: 4),
//
//                             Text(
//                               address["address"]!,
//                               style: const TextStyle(
//                                 color: Colors.white70,
//                               ),
//                             ),
//
//                             const SizedBox(height: 4),
//
//                             Text(
//                               "Phone: ${address["phone"]}",
//                               style: const TextStyle(
//                                 color: Colors.white54,
//                                 fontSize: 12,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//
//                       const Icon(
//                         Icons.edit_outlined,
//                         color: Colors.white54,
//                         size: 18,
//                       )
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//
//         /// ADD ADDRESS BUTTON
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: OutlinedButton.icon(
//             onPressed: () {
//               _showAddAddressPopup();
//             },
//             icon: const Icon(Icons.add_location_alt_outlined),
//             label: const Text("Add New Address"),
//             style: OutlinedButton.styleFrom(
//               foregroundColor: const Color(0xFF2E6CF6),
//               side: const BorderSide(color: Color(0xFF2E6CF6)),
//               minimumSize: const Size(double.infinity, 50),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(14),
//               ),
//             ),
//           ),
//         ),
//
//         const SizedBox(height: 12),
//
//         /// DELIVER HERE BUTTON
//         Padding(
//           padding: const EdgeInsets.all(16),
//           child: SizedBox(
//             width: double.infinity,
//             height: 52,
//
//             child: ElevatedButton(
//               onPressed: () {
//
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => const CheckoutScreen(),
//                   ),
//                 );
//
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF2E6CF6),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(14),
//                 ),
//               ),
//               child: const Text(
//                 "Deliver Here",
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   ////////////////////////////////////////////////////////////
//   /// CHECKOUT PAGE
//   ////////////////////////////////////////////////////////////
//
//   Widget _buildCheckout(cartItems, total) {
//
//     if (cartItems.isEmpty) {
//       return const Center(
//         child: Text(
//           "Your cart is empty",
//           style: TextStyle(color: Colors.white70),
//         ),
//       );
//     }
//
//     return Column(
//       children: [
//
//         Expanded(
//           child: ListView(
//             padding: const EdgeInsets.all(16),
//             children: [
//
//               const _SectionTitle("Order Items"),
//               const SizedBox(height: 12),
//
//               ...cartItems
//                   .map((item) => _CheckoutItemTile(item: item))
//                   .toList(),
//
//               const SizedBox(height: 24),
//
//               const _SectionTitle("Delivery Address"),
//               const SizedBox(height: 12),
//               const _AddressCard(),
//
//               const SizedBox(height: 24),
//
//               const _SectionTitle("Order Summary"),
//               const SizedBox(height: 12),
//               _OrderSummary(total: total),
//
//               const SizedBox(height: 120),
//             ],
//           ),
//         ),
//
//         _CheckoutBottomBar(total: total),
//       ],
//     );
//   }
//
//   ////////////////////////////////////////////////////////////
//   /// ADD ADDRESS GLASS POPUP
//   ////////////////////////////////////////////////////////////
//
//   void _showAddAddressPopup() {
//
//     showDialog(
//       context: context,
//       barrierColor: Colors.black.withOpacity(0.6),
//
//       builder: (_) {
//
//         return Center(
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(22),
//
//             child: BackdropFilter(
//               filter: ImageFilter.blur(
//                 sigmaX: 20,
//                 sigmaY: 20,
//               ),
//
//               child: Container(
//                 width: 280,
//                 padding: const EdgeInsets.all(20),
//
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.05),
//                   borderRadius: BorderRadius.circular(22),
//
//                   border: Border.all(
//                     color: Colors.white.withOpacity(0.1),
//                   ),
//                 ),
//
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//
//                     const Text(
//                       "Add Address",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//
//                     const SizedBox(height: 16),
//
//                     const TextField(
//                       decoration: InputDecoration(
//                         hintText: "Name",
//                         hintStyle: TextStyle(color: Colors.white54),
//                       ),
//                     ),
//
//                     const SizedBox(height: 12),
//
//                     const TextField(
//                       decoration: InputDecoration(
//                         hintText: "Address",
//                         hintStyle: TextStyle(color: Colors.white54),
//                       ),
//                     ),
//
//                     const SizedBox(height: 12),
//
//                     const TextField(
//                       decoration: InputDecoration(
//                         hintText: "Phone",
//                         hintStyle: TextStyle(color: Colors.white54),
//                       ),
//                     ),
//
//                     const SizedBox(height: 18),
//
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
//
//                         TextButton(
//                           onPressed: () {
//                             Navigator.pop(context);
//                           },
//                           child: const Text("Cancel"),
//                         ),
//
//                         ElevatedButton(
//                           onPressed: () {
//                             Navigator.pop(context);
//                           },
//                           child: const Text("Save"),
//                         )
//                       ],
//                     )
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
//
// ////////////////////////////////////////////////////////////
// /// SECTION TITLE
// ////////////////////////////////////////////////////////////
//
// class _SectionTitle extends StatelessWidget {
//   final String title;
//   const _SectionTitle(this.title);
//
//   @override
//   Widget build(BuildContext context) {
//     return Text(
//       title,
//       style: const TextStyle(
//         color: Colors.white,
//         fontSize: 16,
//         fontWeight: FontWeight.w600,
//       ),
//     );
//   }
// }
//
// ////////////////////////////////////////////////////////////
// /// CHECKOUT ITEM TILE
// ////////////////////////////////////////////////////////////
//
// class _CheckoutItemTile extends StatelessWidget {
//
//   final dynamic item;
//
//   const _CheckoutItemTile({required this.item});
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(12),
//
//       decoration: BoxDecoration(
//         color: const Color(0xFF161A22),
//         borderRadius: BorderRadius.circular(14),
//       ),
//
//       child: Row(
//         children: [
//
//           ClipRRect(
//             borderRadius: BorderRadius.circular(10),
//             child: Image.asset(
//               item.product.image,
//               width: 52,
//               height: 52,
//               fit: BoxFit.cover,
//             ),
//           ),
//
//           const SizedBox(width: 12),
//
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//
//                 Text(
//                   item.product.name,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//
//                 const SizedBox(height: 4),
//
//                 Text(
//                   "Qty: ${item.quantity}",
//                   style: const TextStyle(
//                     color: Colors.white54,
//                     fontSize: 12,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           Text(
//             "₹${(item.product.price * item.quantity).toStringAsFixed(0)}",
//             style: const TextStyle(
//               color: Color(0xFF2E6CF6),
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// ////////////////////////////////////////////////////////////
// /// ADDRESS CARD
// ////////////////////////////////////////////////////////////
//
// class _AddressCard extends StatelessWidget {
//
//   const _AddressCard();
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Container(
//       padding: const EdgeInsets.all(14),
//
//       decoration: BoxDecoration(
//         color: const Color(0xFF161A22),
//         borderRadius: BorderRadius.circular(14),
//       ),
//
//       child: Row(
//         children: const [
//
//           Icon(
//             Icons.location_on_outlined,
//             color: Color(0xFF2E6CF6),
//           ),
//
//           SizedBox(width: 10),
//
//           Expanded(
//             child: Text(
//               "Surendranagar , Gujarat\nIndia",
//               style: TextStyle(color: Colors.white),
//             ),
//           ),
//
//           Icon(
//             Icons.edit_outlined,
//             color: Colors.white54,
//             size: 18,
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// ////////////////////////////////////////////////////////////
// /// ORDER SUMMARY
// ////////////////////////////////////////////////////////////
//
// class _OrderSummary extends StatelessWidget {
//
//   final double total;
//
//   const _OrderSummary({required this.total});
//
//   @override
//   Widget build(BuildContext context) {
//
//     const delivery = 40.0;
//     final grandTotal = total + delivery;
//
//     return Container(
//       padding: const EdgeInsets.all(14),
//
//       decoration: BoxDecoration(
//         color: const Color(0xFF161A22),
//         borderRadius: BorderRadius.circular(14),
//       ),
//
//       child: Column(
//         children: [
//
//           _row("Subtotal", total),
//           _row("Delivery", delivery),
//
//           const Divider(
//             color: Colors.white12,
//             height: 20,
//           ),
//
//           _row("Total", grandTotal, isBold: true),
//         ],
//       ),
//     );
//   }
//
//   Widget _row(String title, double value, {bool isBold = false}) {
//
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//
//         Text(
//           title,
//           style: TextStyle(
//             color: Colors.white70,
//             fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
//           ),
//         ),
//
//         Text(
//           "₹${value.toStringAsFixed(0)}",
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// ////////////////////////////////////////////////////////////
// /// BOTTOM BAR
// ////////////////////////////////////////////////////////////
//
// class _CheckoutBottomBar extends StatelessWidget {
//
//   final double total;
//
//   const _CheckoutBottomBar({required this.total});
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Container(
//       padding: const EdgeInsets.all(16),
//
//       decoration: const BoxDecoration(
//         color: Color(0xFF161A22),
//         borderRadius: BorderRadius.vertical(
//           top: Radius.circular(20),
//         ),
//       ),
//
//       child: SafeArea(
//         child: SizedBox(
//           width: double.infinity,
//           height: 52,
//
//           child: ElevatedButton(
//             onPressed: () {
//               Navigator.pushNamed(
//                 context,
//                 AppRoutes.payment,
//               );
//             },
//
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF2E6CF6),
//
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(14),
//               ),
//             ),
//
//             child: const Text(
//               "Continue to Payment",
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.black,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }