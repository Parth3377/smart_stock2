import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../admin/widgets/shared_widgets.dart';
import '../admin/widgets/global_search.dart';
import '../dashboard/admin_home_screen.dart';
import '../products/admin_products_screen.dart';
import '../sales/admin_sales_screen.dart';
import '../purchase/admin_purchase_screen.dart';
import '../suppliers/admin_supplier_screen.dart';
import '../stock_transfer/admin_stock_transfer_screen.dart';
import '../reports/admin_reports_screen.dart';
import '../profile/admin_profile_screen.dart';
import '../customers/admin_customers_screen.dart';
import '../analytics/revenue_analytics_screen.dart';
import '../../providers/admin_providers.dart';


class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 280));
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminDashboardProvider>().load();
      context.read<AdminProductsProvider>().load();
      context.read<AdminOrdersProvider>().load();
      context.read<AdminSuppliersProvider>().load();
      context.read<AdminTransferProvider>().load();
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _switchPage(int i) {
    final nav = context.read<AdminNavProvider>();
    if (nav.selectedIndex != i) {
      _fadeCtrl.reset();
      nav.selectPage(i);
      _fadeCtrl.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AC.bg,
      body: Consumer<AdminNavProvider>(
        builder: (ctx, nav, _) => Row(children: [
          _Sidebar(
            selectedIndex: nav.selectedIndex,
            expanded: nav.sidebarExpanded,
            onSelect: _switchPage,
          ),
          Expanded(child: Column(children: [
            _TopBar(onNavigate: _switchPage),
            Expanded(child: FadeTransition(
              opacity: _fade,
              child: _buildPage(nav.selectedIndex),
            )),
          ])),
        ]),
      ),
    );
  }

  Widget _buildPage(int i) {
    switch (i) {
      case 0:  return AdminHomeScreen(onNavigate: _switchPage);
      case 1:  return const AdminProductsScreen();
      case 2:  return const AdminSalesScreen();
      case 3:  return const AdminPurchaseScreen();
      case 4:  return const AdminSupplierScreen();
      case 5:  return const AdminStockTransferScreen();
      case 6:  return const AdminReportsScreen();
      case 7:  return const AdminProfileScreen();
      case 8:  return const AdminCustomersScreen();
      case 9:  return const RevenueAnalyticsScreen();
      default: return AdminHomeScreen(onNavigate: _switchPage);
    }
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Sidebar
// ═══════════════════════════════════════════════════════════════════
class _Sidebar extends StatelessWidget {
  final int selectedIndex;
  final bool expanded;
  final Function(int) onSelect;

  const _Sidebar({
    required this.selectedIndex,
    required this.expanded,
    required this.onSelect,
  });

  static const _items = [
    (Icons.dashboard_rounded,    'Dashboard',      0),
    (Icons.inventory_2_rounded,  'Products',       1),
    (Icons.trending_up_rounded,  'Sales',          2),
    (Icons.shopping_bag_rounded, 'Purchase',       3),
    (Icons.people_alt_rounded,   'Suppliers',      4),
    (Icons.swap_horiz_rounded,   'Stock Transfer', 5),
    (Icons.bar_chart_rounded,    'Reports',        6),
    (Icons.person_rounded,       'Customers',      8),
  ];

  @override
  Widget build(BuildContext context) {
    final nav = context.read<AdminNavProvider>();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeInOut,
      width: expanded ? 240 : 72,
      decoration: const BoxDecoration(
        color: AC.surface,
        border: Border(right: BorderSide(color: AC.border, width: 1)),
      ),
      child: Column(children: [

        _LogoHeader(expanded: expanded, onToggle: nav.toggleSidebar),

        const SizedBox(height: 10),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            itemCount: _items.length,
            itemBuilder: (ctx, i) {
              final (icon, label, pageIdx) = _items[i];
              final selected = selectedIndex == pageIdx;
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Tooltip(
                  message: expanded ? '' : label,
                  preferBelow: false,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    decoration: BoxDecoration(
                      color: selected
                          ? AC.blue.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: expanded ? 12 : 8, vertical: 2),
                      leading: Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: selected
                              ? AC.blue.withOpacity(0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(icon,
                            color: selected ? AC.blue : AC.text3, size: 18),
                      ),
                      title: expanded
                          ? Text(label, style: TextStyle(
                        color: selected ? AC.blue : AC.text2,
                        fontSize: 13.5,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ))
                          : null,
                      onTap: () => onSelect(pageIdx),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // ── Admin profile footer ──
        // AdminProfileProvider exposes .name and .role directly (no .profile wrapper)
        Consumer<AdminProfileProvider>(builder: (_, prof, __) => InkWell(
          onTap: () => onSelect(7),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AC.border))),
            child: Row(children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AC.purple.withOpacity(0.25),
                child: Text(
                  prof.name.isNotEmpty ? prof.name[0] : 'A',
                  style: const TextStyle(
                      color: AC.purple, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
              if (expanded) ...[
                const SizedBox(width: 10),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(prof.name,
                        style: const TextStyle(
                            color: AC.text1,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis),
                    Text(prof.role,
                        style: const TextStyle(color: AC.text3, fontSize: 11)),
                  ],
                )),
                const Icon(Icons.chevron_right_rounded, color: AC.text3, size: 16),
              ],
            ]),
          ),
        )),
      ]),
    );
  }
}

class _LogoHeader extends StatelessWidget {
  final bool expanded;
  final VoidCallback onToggle;
  const _LogoHeader({required this.expanded, required this.onToggle});

  @override
  Widget build(BuildContext context) => Container(
    height: 72,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AC.border))),
    child: Row(children: [
      Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4F8EF7), Color(0xFF845EF7)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.inventory_rounded, color: Colors.white, size: 20),
      ),
      if (expanded) ...[
        const SizedBox(width: 12),
        const Expanded(child: Text('SmartStock', style: TextStyle(
            color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700))),
        GestureDetector(
          onTap: onToggle,
          child: const Icon(Icons.menu_open_rounded, color: AC.text3, size: 20),
        ),
      ] else ...[
        const Spacer(),
        GestureDetector(
          onTap: onToggle,
          child: const Icon(Icons.menu_rounded, color: AC.text3, size: 20),
        ),
      ],
    ]),
  );
}

// ═══════════════════════════════════════════════════════════════════
//  Top Bar
// ═══════════════════════════════════════════════════════════════════
class _TopBar extends StatelessWidget {
  final Function(int) onNavigate;
  const _TopBar({required this.onNavigate});

  static const _titles = [
    'Dashboard', 'Products', 'Sales', 'Purchase',
    'Suppliers', 'Stock Transfer', 'Reports', 'Profile',
    'Customers', 'Revenue Analytics',
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminNavProvider>(builder: (_, nav, __) => Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
          color: AC.surface,
          border: Border(bottom: BorderSide(color: AC.border))),
      child: Row(children: [

        Row(children: [
          const Text('Admin', style: TextStyle(color: AC.text3, fontSize: 14)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Icon(Icons.chevron_right_rounded, color: AC.text3, size: 16),
          ),
          Text(_titles[nav.selectedIndex.clamp(0, _titles.length - 1)],
              style: const TextStyle(
                  color: AC.text1, fontSize: 14, fontWeight: FontWeight.w600)),
        ]),

        const Spacer(),

        GlobalSearchBar(onNavigate: onNavigate),

        const SizedBox(width: 16),

        Stack(children: [
          _TopBtn(icon: Icons.notifications_rounded, onTap: () {}),
          Positioned(top: 6, right: 6, child: Container(
            width: 8, height: 8,
            decoration: const BoxDecoration(color: AC.red, shape: BoxShape.circle),
          )),
        ]),

        const SizedBox(width: 10),

        Tooltip(
          message: 'Admin Profile',
          child: _TopBtn(
            icon: Icons.settings_rounded,
            onTap: () => onNavigate(7),
          ),
        ),
      ]),
    ));
  }
}

class _TopBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _TopBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 38, height: 38,
      decoration: BoxDecoration(
        color: AC.card, borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AC.border2),
      ),
      child: Icon(icon, color: AC.text3, size: 18),
    ),
  );
}