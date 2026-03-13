import 'package:flutter/material.dart';

import '../products/product_list_screen.dart';
import '../orders/order_list_screen.dart';
import '../customers/customer_screen.dart';
import '../reports/reports_screen.dart';
import '../settings/settings_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {

  int selectedIndex = 0;

  final List<String> menuTitles = [
    "Dashboard",
    "Products",
    "Orders",
    "Customers",
    "Reports",
    "Settings",
  ];

  final List<IconData> menuIcons = [
    Icons.dashboard,
    Icons.inventory_2,
    Icons.shopping_cart,
    Icons.people,
    Icons.bar_chart,
    Icons.settings,
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Row(
        children: [

          /// SIDEBAR
          Container(
            width: 240,
            color: const Color(0xFF161A22),
            child: Column(
              children: [

                const SizedBox(height: 30),

                const Text(
                  "SmartStock",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                Expanded(
                  child: ListView.builder(
                    itemCount: menuTitles.length,
                    itemBuilder: (context, index) {

                      final selected = selectedIndex == index;

                      return ListTile(
                        leading: Icon(
                          menuIcons[index],
                          color: selected ? Colors.blue : Colors.white70,
                        ),

                        title: Text(
                          menuTitles[index],
                          style: TextStyle(
                            color: selected ? Colors.blue : Colors.white70,
                          ),
                        ),

                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          /// MAIN CONTENT
          Expanded(
            child: _buildPage(),
          ),
        ],
      ),
    );
  }

  /// PAGE SWITCHER

  Widget _buildPage() {

    switch (selectedIndex) {

      case 0:
        return const DashboardHome();

      case 1:
        return const ProductListScreen();

      case 2:
        return const OrderListScreen();

      case 3:
        return const CustomerScreen();

      case 4:
        return const ReportsScreen();

      case 5:
        return const SettingsScreen();

      default:
        return const SizedBox();
    }
  }
}

////////////////////////////////////////////////////////////
/// DASHBOARD HOME UI
////////////////////////////////////////////////////////////

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(24),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            "Dashboard",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          /// STAT CARDS
          Row(
            children: const [

              Expanded(child: _StatCard("Revenue", "₹73,890")),
              SizedBox(width: 16),

              Expanded(child: _StatCard("Orders", "1865")),
              SizedBox(width: 16),

              Expanded(child: _StatCard("Products", "120")),
              SizedBox(width: 16),

              Expanded(child: _StatCard("Customers", "54")),
            ],
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// STAT CARD
////////////////////////////////////////////////////////////

class _StatCard extends StatelessWidget {

  final String title;
  final String value;

  const _StatCard(this.title, this.value);

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            title,
            style: const TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 10),

          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}