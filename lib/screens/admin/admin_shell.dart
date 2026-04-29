import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_stock2/screens/dashboard/admin_home_screen.dart';
import 'package:smart_stock2/screens/products/admin_products_screen.dart';
import 'package:smart_stock2/screens/sales/admin_sales_screen.dart';
import 'package:smart_stock2/screens/stock_transfer/admin_stock_transfer_screen.dart';
import 'package:smart_stock2/screens/suppliers/admin_supplier_screen.dart';
import '../../providers/admin_providers.dart';
import '../../providers/admin_notification_provider.dart';
import 'widgets/admin_widgets.dart';
import '../purchase/admin_purchase_screen.dart';
import '../reports/admin_reports_screen.dart';
import '../profile/admin_profile_screen.dart';
import '../customers/admin_customers_screen.dart';

// ════════════════════════════════════════════════════════════════════
//  lib/screens/admin/admin_shell.dart
//
//  Main admin layout shell — sidebar + topbar + animated content area
//  Uses your app's existing dark theme colors
// ════════════════════════════════════════════════════════════════════

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});
  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();

    // Preload all admin data + start notification stream
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminDashboardProvider>().load();
      context.read<AdminProductsProvider>().load();
      context.read<AdminOrdersProvider>().load();
      context.read<AdminSuppliersProvider>().load();
      context.read<AdminTransferProvider>().load();
      // 🔔 Start streaming admin notifications
      context.read<AdminNotificationProvider>().startListening();
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
      backgroundColor: ACol.bg,
      body: Consumer<AdminNavProvider>(
        builder: (_, nav, __) => Row(children: [
          // ── Sidebar ──
          _AdminSidebar(
            selectedIndex: nav.selectedIndex,
            expanded: nav.sidebarExpanded,
            onSelect: _switchPage,
          ),
          // ── Main content ──
          Expanded(child: Column(children: [
            _AdminTopBar(onNavigate: _switchPage),
            Expanded(child: FadeTransition(
              opacity: _fadeAnim,
              child: _buildPage(nav.selectedIndex),
            )),
          ])),
        ]),
      ),
    );
  }

  Widget _buildPage(int idx) {
    switch (idx) {
      case 0:  return AdminHomeScreen(onNavigate: _switchPage);
      case 1:  return const AdminProductsScreen();
      case 2:  return const AdminSalesScreen();
      case 3:  return const AdminPurchaseScreen();
      case 4:  return const AdminSupplierScreen();
      case 5:  return const AdminStockTransferScreen();
      case 6:  return const AdminReportsScreen();
      case 7:  return const AdminProfileScreen();
      case 8:  return const AdminCustomersScreen();
      default: return AdminHomeScreen(onNavigate: _switchPage);
    }
  }
}

// ════════════════════════════════════════════════════════════════════
//  Sidebar
// ════════════════════════════════════════════════════════════════════
class _AdminSidebar extends StatelessWidget {
  final int selectedIndex;
  final bool expanded;
  final Function(int) onSelect;

  const _AdminSidebar({
    required this.selectedIndex,
    required this.expanded,
    required this.onSelect,
  });

  static const _navItems = [
    (Icons.dashboard_rounded,    'Dashboard',       0),
    (Icons.inventory_2_rounded,  'Products',        1),
    (Icons.trending_up_rounded,  'Sales',           2),
    (Icons.shopping_bag_rounded, 'Purchase',        3),
    (Icons.people_alt_rounded,   'Suppliers',       4),
    (Icons.swap_horiz_rounded,   'Stock Transfer',  5),
    (Icons.bar_chart_rounded,    'Reports',         6),
    (Icons.person_search_rounded,'Customers',       8),
  ];

  @override
  Widget build(BuildContext context) {
    final nav = context.read<AdminNavProvider>();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: expanded ? 240 : 70,
      decoration: const BoxDecoration(
        color: ACol.surface,
        border: Border(right: BorderSide(color: ACol.border, width: 1)),
      ),
      child: Column(children: [

        // ── Logo header ──────────────────────────────────────────
        Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: ACol.border)),
          ),
          child: Row(children: [
            // Logo mark
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E6CF6), Color(0xFF7C3AED)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
            ),
            if (expanded) ...[
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('SmartStock', style: TextStyle(
                      color: Colors.white, fontSize: 14,
                      fontWeight: FontWeight.w700, letterSpacing: 0.3,
                    )),
                    Text('Admin Panel', style: TextStyle(
                      color: ACol.text3, fontSize: 10.5,
                    )),
                  ],
                ),
              ),
              GestureDetector(
                onTap: nav.toggleSidebar,
                child: const Icon(Icons.menu_open_rounded, color: ACol.text3, size: 18),
              ),
            ] else ...[
              const Spacer(),
              GestureDetector(
                onTap: nav.toggleSidebar,
                child: const Icon(Icons.menu_rounded, color: ACol.text3, size: 18),
              ),
            ],
          ]),
        ),

        const SizedBox(height: 8),

        // ── Nav items ────────────────────────────────────────────
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            itemCount: _navItems.length,
            itemBuilder: (ctx, i) {
              final (icon, label, pageIdx) = _navItems[i];
              final selected = selectedIndex == pageIdx;
              return Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Tooltip(
                  message: expanded ? '' : label,
                  preferBelow: false,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF2E6CF6).withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      dense: true,
                      visualDensity: const VisualDensity(vertical: -1),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: expanded ? 10 : 6,
                        vertical: 1,
                      ),
                      leading: Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFF2E6CF6).withOpacity(0.18)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(icon,
                          color: selected ? const Color(0xFF2E6CF6) : ACol.text3,
                          size: 17,
                        ),
                      ),
                      title: expanded ? Text(label, style: TextStyle(
                        color: selected ? const Color(0xFF2E6CF6) : ACol.text2,
                        fontSize: 13,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      )) : null,
                      onTap: () => onSelect(pageIdx),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // ── Divider ──────────────────────────────────────────────
        const Divider(color: ACol.border, height: 1),

        // ── Profile footer ───────────────────────────────────────
        Consumer<AdminProfileProvider>(
          builder: (_, prof, __) => InkWell(
            onTap: () => onSelect(7),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                // Avatar
                Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFF2E6CF6)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      prof.name.isNotEmpty ? prof.name[0].toUpperCase() : 'A',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                if (expanded) ...[
                  const SizedBox(width: 10),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(prof.name, style: const TextStyle(
                          color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis),
                      Text(prof.role, style: const TextStyle(color: ACol.text3, fontSize: 10.5)),
                    ],
                  )),
                  const Icon(Icons.chevron_right_rounded, color: ACol.text3, size: 16),
                ],
              ]),
            ),
          ),
        ),
        const SizedBox(height: 4),
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
//  Top Bar
// ════════════════════════════════════════════════════════════════════
class _AdminTopBar extends StatelessWidget {
  final Function(int) onNavigate;
  const _AdminTopBar({required this.onNavigate});

  static const _pageTitles = [
    'Dashboard', 'Products', 'Sales', 'Purchase',
    'Suppliers', 'Stock Transfer', 'Reports', 'Profile',
    'Customers',
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminNavProvider>(builder: (_, nav, __) {
      final title = _pageTitles[nav.selectedIndex.clamp(0, _pageTitles.length - 1)];
      return Container(
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: const BoxDecoration(
          color: ACol.surface,
          border: Border(bottom: BorderSide(color: ACol.border)),
        ),
        child: Row(children: [

          // Breadcrumb
          Row(children: [
            const Text('Admin', style: TextStyle(color: ACol.text3, fontSize: 13)),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded, color: ACol.text3, size: 15),
            const SizedBox(width: 6),
            Text(title, style: const TextStyle(
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          ]),

          const Spacer(),

          // Search bar
          _AdminSearchBar(),
          const SizedBox(width: 12),

          // Notification bell
          // 🔔 Live notification bell — badge count from Firestore stream
          Consumer<AdminNotificationProvider>(
            builder: (ctx, notifProv, _) => Stack(children: [
              _TopBarBtn(
                icon: Icons.notifications_outlined,
                onTap: () => _showNotifPanel(ctx, notifProv, onNavigate),
              ),
              if (notifProv.hasUnread)
                Positioned(
                  top: 5, right: 5,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      notifProv.unreadCount > 99
                          ? '99+'
                          : '${notifProv.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ]),
          ),
          const SizedBox(width: 8),

          // Settings → profile
          Tooltip(
            message: 'Admin Profile',
            child: _TopBarBtn(
              icon: Icons.settings_outlined,
              onTap: () => onNavigate(7),
            ),
          ),
        ]),
      );
    });
  }
}

// ── Notification panel helper ─────────────────────────────────────
void _showNotifPanel(
    BuildContext context,
    AdminNotificationProvider notifProv,
    Function(int) onNavigate,
    ) {
  showDialog(
    context: context,
    barrierColor: Colors.black38,
    builder: (_) => Stack(
      children: [
        Positioned(
          top: 68, right: 56,
          child: Material(
            color: Colors.transparent,
            child: _NotifDropdown(
              notifProv:  notifProv,
              onNavigate: onNavigate,
            ),
          ),
        ),
      ],
    ),
  );
}

// ── Notification Dropdown Panel ───────────────────────────────────
class _NotifDropdown extends StatelessWidget {
  final AdminNotificationProvider notifProv;
  final Function(int) onNavigate;

  static const Map<String, int> _screenIndex = {
    'dashboard':     0,
    'products':      1,
    'sales':         2,
    'purchase':      3,
    'suppliers':     4,
    'stock_transfer':5,
    'reports':       6,
    'profile':       7,
    'customers':     8,
  };

  const _NotifDropdown({
    required this.notifProv,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final notifs = notifProv.all;
    return Container(
      width:  380,
      constraints: const BoxConstraints(maxHeight: 480),
      decoration: BoxDecoration(
        color: ACol.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ACol.border2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
            child: Row(children: [
              const Text('Notifications',
                  style: TextStyle(
                      color: ACol.text1,
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
              if (notifProv.hasUnread) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${notifProv.unreadCount} new',
                    style: const TextStyle(
                        color: Color(0xFFEF4444),
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
              const Spacer(),
              if (notifProv.hasUnread)
                TextButton(
                  onPressed: () {
                    notifProv.markAllRead();
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Mark all read',
                      style: TextStyle(color: ACol.blue, fontSize: 11.5)),
                ),
            ]),
          ),

          const Divider(color: ACol.border, height: 1),

          // ── Notification list ──
          if (notifs.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Column(children: [
                Icon(Icons.notifications_none_rounded,
                    color: ACol.text3, size: 32),
                SizedBox(height: 8),
                Text('No notifications yet',
                    style: TextStyle(color: ACol.text3, fontSize: 13)),
              ]),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 6),
                itemCount: notifs.length > 20 ? 20 : notifs.length,
                separatorBuilder: (_, __) =>
                const Divider(color: ACol.border, height: 1),
                itemBuilder: (ctx, i) {
                  final n = notifs[i];
                  return InkWell(
                    onTap: () {
                      notifProv.markRead(n.id);
                      Navigator.pop(context);
                      final idx = _screenIndex[n.screen] ?? 0;
                      onNavigate(idx);
                    },
                    child: Container(
                      color: n.isRead
                          ? Colors.transparent
                          : ACol.blue.withOpacity(0.04),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon circle
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: n.color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(n.icon, color: n.color, size: 17),
                          ),
                          const SizedBox(width: 12),
                          // Text
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Expanded(
                                  child: Text(n.title,
                                      style: TextStyle(
                                        color: n.isRead
                                            ? ACol.text2
                                            : ACol.text1,
                                        fontSize: 12.5,
                                        fontWeight: n.isRead
                                            ? FontWeight.w400
                                            : FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                ),
                                if (!n.isRead)
                                  Container(
                                    width: 6, height: 6,
                                    decoration: const BoxDecoration(
                                        color: Color(0xFF2E6CF6),
                                        shape: BoxShape.circle),
                                  ),
                              ]),
                              const SizedBox(height: 3),
                              Text(n.body,
                                  style: const TextStyle(
                                      color: ACol.text3, fontSize: 11.5),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Text(n.timeAgo,
                                  style: const TextStyle(
                                      color: ACol.text3, fontSize: 10.5)),
                            ],
                          )),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _TopBarBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _TopBarBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        color: ACol.card,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: ACol.border2),
      ),
      child: Icon(icon, color: ACol.text3, size: 17),
    ),
  );
}

// ── Inline search bar (no overlay needed in shell, handled per-page) ─
class _AdminSearchBar extends StatefulWidget {
  @override
  State<_AdminSearchBar> createState() => _AdminSearchBarState();
}

class _AdminSearchBarState extends State<_AdminSearchBar> {
  bool _focused = false;
  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    width: _focused ? 280 : 200,
    height: 36,
    decoration: BoxDecoration(
      color: ACol.card,
      borderRadius: BorderRadius.circular(9),
      border: Border.all(
        color: _focused ? const Color(0xFF2E6CF6).withOpacity(0.5) : ACol.border2,
      ),
    ),
    child: Focus(
      onFocusChange: (f) => setState(() => _focused = f),
      child: Row(children: [
        const SizedBox(width: 10),
        const Icon(Icons.search_rounded, color: ACol.text3, size: 16),
        const SizedBox(width: 8),
        const Expanded(child: TextField(
          style: TextStyle(color: Colors.white, fontSize: 12.5),
          decoration: InputDecoration(
            hintText: 'Search...',
            hintStyle: TextStyle(color: ACol.text3, fontSize: 12.5),
            border: InputBorder.none, isDense: true,
          ),
        )),
      ]),
    ),
  );
}


// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:smart_stock2/screens/dashboard/admin_home_screen.dart';
// import 'package:smart_stock2/screens/products/admin_products_screen.dart';
// import 'package:smart_stock2/screens/sales/admin_sales_screen.dart';
// import 'package:smart_stock2/screens/stock_transfer/admin_stock_transfer_screen.dart';
// import 'package:smart_stock2/screens/suppliers/admin_supplier_screen.dart';
// import '../../providers/admin_providers.dart';
// import 'widgets/admin_widgets.dart';
// import '../purchase/admin_purchase_screen.dart';
// import '../reports/admin_reports_screen.dart';
// import '../profile/admin_profile_screen.dart';
//
// // ════════════════════════════════════════════════════════════════════
// //  lib/screens/admin/admin_shell.dart
// //
// //  Main admin layout shell — sidebar + topbar + animated content area
// //  Uses your app's existing dark theme colors
// // ════════════════════════════════════════════════════════════════════
//
// class AdminShell extends StatefulWidget {
//   const AdminShell({super.key});
//   @override
//   State<AdminShell> createState() => _AdminShellState();
// }
//
// class _AdminShellState extends State<AdminShell>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _fadeCtrl;
//   late Animation<double> _fadeAnim;
//
//   @override
//   void initState() {
//     super.initState();
//     _fadeCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 260),
//     );
//     _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
//     _fadeCtrl.forward();
//
//     // Preload all admin data
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<AdminDashboardProvider>().load();
//       context.read<AdminProductsProvider>().load();
//       context.read<AdminOrdersProvider>().load();
//       context.read<AdminSuppliersProvider>().load();
//       context.read<AdminTransferProvider>().load();
//     });
//   }
//
//   @override
//   void dispose() {
//     _fadeCtrl.dispose();
//     super.dispose();
//   }
//
//   void _switchPage(int i) {
//     final nav = context.read<AdminNavProvider>();
//     if (nav.selectedIndex != i) {
//       _fadeCtrl.reset();
//       nav.selectPage(i);
//       _fadeCtrl.forward();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ACol.bg,
//       body: Consumer<AdminNavProvider>(
//         builder: (_, nav, __) => Row(children: [
//           // ── Sidebar ──
//           _AdminSidebar(
//             selectedIndex: nav.selectedIndex,
//             expanded: nav.sidebarExpanded,
//             onSelect: _switchPage,
//           ),
//           // ── Main content ──
//           Expanded(child: Column(children: [
//             _AdminTopBar(onNavigate: _switchPage),
//             Expanded(child: FadeTransition(
//               opacity: _fadeAnim,
//               child: _buildPage(nav.selectedIndex),
//             )),
//           ])),
//         ]),
//       ),
//     );
//   }
//
//   Widget _buildPage(int idx) {
//     switch (idx) {
//       case 0:  return AdminHomeScreen(onNavigate: _switchPage);
//       case 1:  return const AdminProductsScreen();
//       case 2:  return const AdminSalesScreen();
//       case 3:  return const AdminPurchaseScreen();
//       case 4:  return const AdminSupplierScreen();
//       case 5:  return const AdminStockTransferScreen();
//       case 6:  return const AdminReportsScreen();
//       case 7:  return const AdminProfileScreen();
//       default: return AdminHomeScreen(onNavigate: _switchPage);
//     }
//   }
// }
//
// // ════════════════════════════════════════════════════════════════════
// //  Sidebar
// // ════════════════════════════════════════════════════════════════════
// class _AdminSidebar extends StatelessWidget {
//   final int selectedIndex;
//   final bool expanded;
//   final Function(int) onSelect;
//
//   const _AdminSidebar({
//     required this.selectedIndex,
//     required this.expanded,
//     required this.onSelect,
//   });
//
//   static const _navItems = [
//     (Icons.dashboard_rounded,    'Dashboard',       0),
//     (Icons.inventory_2_rounded,  'Products',        1),
//     (Icons.trending_up_rounded,  'Sales',           2),
//     (Icons.shopping_bag_rounded, 'Purchase',        3),
//     (Icons.people_alt_rounded,   'Suppliers',       4),
//     (Icons.swap_horiz_rounded,   'Stock Transfer',  5),
//     (Icons.bar_chart_rounded,    'Reports',         6),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     final nav = context.read<AdminNavProvider>();
//
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 250),
//       curve: Curves.easeInOut,
//       width: expanded ? 240 : 70,
//       decoration: const BoxDecoration(
//         color: ACol.surface,
//         border: Border(right: BorderSide(color: ACol.border, width: 1)),
//       ),
//       child: Column(children: [
//
//         // ── Logo header ──────────────────────────────────────────
//         Container(
//           height: 68,
//           padding: const EdgeInsets.symmetric(horizontal: 14),
//           decoration: const BoxDecoration(
//             border: Border(bottom: BorderSide(color: ACol.border)),
//           ),
//           child: Row(children: [
//             // Logo mark
//             Container(
//               width: 36, height: 36,
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                   colors: [Color(0xFF2E6CF6), Color(0xFF7C3AED)],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
//             ),
//             if (expanded) ...[
//               const SizedBox(width: 10),
//               const Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text('SmartStock', style: TextStyle(
//                       color: Colors.white, fontSize: 14,
//                       fontWeight: FontWeight.w700, letterSpacing: 0.3,
//                     )),
//                     Text('Admin Panel', style: TextStyle(
//                       color: ACol.text3, fontSize: 10.5,
//                     )),
//                   ],
//                 ),
//               ),
//               GestureDetector(
//                 onTap: nav.toggleSidebar,
//                 child: const Icon(Icons.menu_open_rounded, color: ACol.text3, size: 18),
//               ),
//             ] else ...[
//               const Spacer(),
//               GestureDetector(
//                 onTap: nav.toggleSidebar,
//                 child: const Icon(Icons.menu_rounded, color: ACol.text3, size: 18),
//               ),
//             ],
//           ]),
//         ),
//
//         const SizedBox(height: 8),
//
//         // ── Nav items ────────────────────────────────────────────
//         Expanded(
//           child: ListView.builder(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             itemCount: _navItems.length,
//             itemBuilder: (ctx, i) {
//               final (icon, label, pageIdx) = _navItems[i];
//               final selected = selectedIndex == pageIdx;
//               return Padding(
//                 padding: const EdgeInsets.only(bottom: 2),
//                 child: Tooltip(
//                   message: expanded ? '' : label,
//                   preferBelow: false,
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 180),
//                     decoration: BoxDecoration(
//                       color: selected
//                           ? const Color(0xFF2E6CF6).withOpacity(0.15)
//                           : Colors.transparent,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: ListTile(
//                       dense: true,
//                       visualDensity: const VisualDensity(vertical: -1),
//                       contentPadding: EdgeInsets.symmetric(
//                         horizontal: expanded ? 10 : 6,
//                         vertical: 1,
//                       ),
//                       leading: Container(
//                         width: 32, height: 32,
//                         decoration: BoxDecoration(
//                           color: selected
//                               ? const Color(0xFF2E6CF6).withOpacity(0.18)
//                               : Colors.transparent,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Icon(icon,
//                           color: selected ? const Color(0xFF2E6CF6) : ACol.text3,
//                           size: 17,
//                         ),
//                       ),
//                       title: expanded ? Text(label, style: TextStyle(
//                         color: selected ? const Color(0xFF2E6CF6) : ACol.text2,
//                         fontSize: 13,
//                         fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
//                       )) : null,
//                       onTap: () => onSelect(pageIdx),
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//
//         // ── Divider ──────────────────────────────────────────────
//         const Divider(color: ACol.border, height: 1),
//
//         // ── Profile footer ───────────────────────────────────────
//         Consumer<AdminProfileProvider>(
//           builder: (_, prof, __) => InkWell(
//             onTap: () => onSelect(7),
//             borderRadius: BorderRadius.circular(8),
//             child: Container(
//               padding: const EdgeInsets.all(12),
//               child: Row(children: [
//                 // Avatar
//                 Container(
//                   width: 34, height: 34,
//                   decoration: BoxDecoration(
//                     gradient: const LinearGradient(
//                       colors: [Color(0xFF7C3AED), Color(0xFF2E6CF6)],
//                     ),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Center(
//                     child: Text(
//                       prof.name.isNotEmpty ? prof.name[0].toUpperCase() : 'A',
//                       style: const TextStyle(
//                           color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ),
//                 if (expanded) ...[
//                   const SizedBox(width: 10),
//                   Expanded(child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(prof.name, style: const TextStyle(
//                           color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
//                           overflow: TextOverflow.ellipsis),
//                       Text(prof.role, style: const TextStyle(color: ACol.text3, fontSize: 10.5)),
//                     ],
//                   )),
//                   const Icon(Icons.chevron_right_rounded, color: ACol.text3, size: 16),
//                 ],
//               ]),
//             ),
//           ),
//         ),
//         const SizedBox(height: 4),
//       ]),
//     );
//   }
// }
//
// // ════════════════════════════════════════════════════════════════════
// //  Top Bar
// // ════════════════════════════════════════════════════════════════════
// class _AdminTopBar extends StatelessWidget {
//   final Function(int) onNavigate;
//   const _AdminTopBar({required this.onNavigate});
//
//   static const _pageTitles = [
//     'Dashboard', 'Products', 'Sales', 'Purchase',
//     'Suppliers', 'Stock Transfer', 'Reports', 'Profile',
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<AdminNavProvider>(builder: (_, nav, __) {
//       final title = _pageTitles[nav.selectedIndex.clamp(0, _pageTitles.length - 1)];
//       return Container(
//         height: 68,
//         padding: const EdgeInsets.symmetric(horizontal: 24),
//         decoration: const BoxDecoration(
//           color: ACol.surface,
//           border: Border(bottom: BorderSide(color: ACol.border)),
//         ),
//         child: Row(children: [
//
//           // Breadcrumb
//           Row(children: [
//             const Text('Admin', style: TextStyle(color: ACol.text3, fontSize: 13)),
//             const SizedBox(width: 6),
//             const Icon(Icons.chevron_right_rounded, color: ACol.text3, size: 15),
//             const SizedBox(width: 6),
//             Text(title, style: const TextStyle(
//                 color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
//           ]),
//
//           const Spacer(),
//
//           // Search bar
//           _AdminSearchBar(),
//           const SizedBox(width: 12),
//
//           // Notification bell
//           Stack(children: [
//             _TopBarBtn(icon: Icons.notifications_outlined, onTap: () {}),
//             Positioned(top: 7, right: 7, child: Container(
//               width: 7, height: 7,
//               decoration: const BoxDecoration(
//                   color: Color(0xFFEF4444), shape: BoxShape.circle),
//             )),
//           ]),
//           const SizedBox(width: 8),
//
//           // Settings → profile
//           Tooltip(
//             message: 'Admin Profile',
//             child: _TopBarBtn(
//               icon: Icons.settings_outlined,
//               onTap: () => onNavigate(7),
//             ),
//           ),
//         ]),
//       );
//     });
//   }
// }
//
// class _TopBarBtn extends StatelessWidget {
//   final IconData icon;
//   final VoidCallback onTap;
//   const _TopBarBtn({required this.icon, required this.onTap});
//   @override
//   Widget build(BuildContext context) => GestureDetector(
//     onTap: onTap,
//     child: Container(
//       width: 36, height: 36,
//       decoration: BoxDecoration(
//         color: ACol.card,
//         borderRadius: BorderRadius.circular(9),
//         border: Border.all(color: ACol.border2),
//       ),
//       child: Icon(icon, color: ACol.text3, size: 17),
//     ),
//   );
// }
//
// // ── Inline search bar (no overlay needed in shell, handled per-page) ─
// class _AdminSearchBar extends StatefulWidget {
//   @override
//   State<_AdminSearchBar> createState() => _AdminSearchBarState();
// }
//
// class _AdminSearchBarState extends State<_AdminSearchBar> {
//   bool _focused = false;
//   @override
//   Widget build(BuildContext context) => AnimatedContainer(
//     duration: const Duration(milliseconds: 200),
//     width: _focused ? 280 : 200,
//     height: 36,
//     decoration: BoxDecoration(
//       color: ACol.card,
//       borderRadius: BorderRadius.circular(9),
//       border: Border.all(
//         color: _focused ? const Color(0xFF2E6CF6).withOpacity(0.5) : ACol.border2,
//       ),
//     ),
//     child: Focus(
//       onFocusChange: (f) => setState(() => _focused = f),
//       child: Row(children: [
//         const SizedBox(width: 10),
//         const Icon(Icons.search_rounded, color: ACol.text3, size: 16),
//         const SizedBox(width: 8),
//         const Expanded(child: TextField(
//           style: TextStyle(color: Colors.white, fontSize: 12.5),
//           decoration: InputDecoration(
//             hintText: 'Search...',
//             hintStyle: TextStyle(color: ACol.text3, fontSize: 12.5),
//             border: InputBorder.none, isDense: true,
//           ),
//         )),
//       ]),
//     ),
//   );
// }
