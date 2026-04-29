import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../services/admin_notification_service.dart';

enum AdminLoadState { idle, loading, loaded, error }

// ════════════════════════════════════════════════════════════════════
//  1. ADMIN AUTH PROVIDER
// ════════════════════════════════════════════════════════════════════
class AdminAuthProvider extends ChangeNotifier {
  bool _isAdmin = false;
  String _adminName = '';
  String _adminEmail = '';

  bool   get isAdmin    => _isAdmin;
  String get adminName  => _adminName;
  String get adminEmail => _adminEmail;

  void loginAsAdmin(String email, {String name = 'Admin'}) {
    _isAdmin    = true;
    _adminEmail = email;
    _adminName  = name;
    notifyListeners();
  }

  void logout() {
    _isAdmin    = false;
    _adminEmail = '';
    _adminName  = '';
    notifyListeners();
  }
}

// ════════════════════════════════════════════════════════════════════
//  2. ADMIN NAV PROVIDER
// ════════════════════════════════════════════════════════════════════
class AdminNavProvider extends ChangeNotifier {
  int  _selectedIndex   = 0;
  bool _sidebarExpanded = true;

  int  get selectedIndex    => _selectedIndex;
  bool get sidebarExpanded  => _sidebarExpanded;

  void selectPage(int i)  { _selectedIndex = i; notifyListeners(); }
  void toggleSidebar()    { _sidebarExpanded = !_sidebarExpanded; notifyListeners(); }
}

// ════════════════════════════════════════════════════════════════════
//  3. ADMIN DASHBOARD PROVIDER
// ════════════════════════════════════════════════════════════════════
class AdminDashboardProvider extends ChangeNotifier {
  AdminLoadState        state = AdminLoadState.idle;
  AdminDashboardStats?  stats;
  String?               error;
  StreamSubscription?   _dashSub;

  Future<void> load() async {
    if (state == AdminLoadState.loading) return;
    state = AdminLoadState.loading;
    notifyListeners();

    _dashSub?.cancel();
    _dashSub = FirestoreService.instance.streamReportData().listen(
          (data) {
        try {
          final mRev  = (data['monthlyRevenue'] as List).map((m) =>
              AdminMonthData(m['month'] as String, (m['value'] as num).toDouble())).toList();
          final mCost = (data['monthlyCost'] as List).map((m) =>
              AdminMonthData(m['month'] as String, (m['value'] as num).toDouble())).toList();

          final catMap     = data['categoryRevenue'] as Map<String, dynamic>;
          final totalCatRev = catMap.values.fold<double>(0, (s, v) => s + (v as num).toDouble());
          final catData = catMap.isEmpty
              ? _seedCategories()
              : catMap.entries.map((e) {
            final pct = totalCatRev == 0 ? 0.0 : (e.value as num).toDouble() / totalCatRev * 100;
            return AdminCategoryData(e.key, pct, (e.value as num).toDouble());
          }).toList();

          final totalRev  = (data['totalRevenue']   as num).toDouble();
          final totalOrd  = (data['totalOrders']    as num).toInt();
          final totalCust = (data['totalCustomers'] as num).toInt();

          stats = AdminDashboardStats(
            totalRevenue:   totalRev  > 0 ? totalRev  : 124890,
            prevRevenue:    totalRev  > 0 ? totalRev  * 0.88 : 110000,
            totalOrders:    totalOrd  > 0 ? totalOrd  : 2340,
            prevOrders:     totalOrd  > 0 ? (totalOrd * 0.92).round() : 2150,
            totalProducts:  486,
            prevProducts:   500,
            totalCustomers: totalCust > 0 ? totalCust : 1204,
            prevCustomers:  totalCust > 0 ? (totalCust * 0.95).round() : 1140,
            monthlyRevenue: mRev.any((m)  => m.value > 0) ? mRev  : _seedMonthlyRevenue(),
            monthlyCost:    mCost.any((m) => m.value > 0) ? mCost : _seedMonthlyCost(),
            categoryData:   catData,
          );
        } catch (_) {
          stats = _fallbackStats();
        }
        state = AdminLoadState.loaded;
        notifyListeners();
      },
      onError: (_) {
        stats = _fallbackStats();
        state = AdminLoadState.loaded;
        notifyListeners();
      },
    );
  }

  static AdminDashboardStats _fallbackStats() => AdminDashboardStats(
    totalRevenue: 124890, prevRevenue: 110000,
    totalOrders: 2340,   prevOrders: 2150,
    totalProducts: 486,  prevProducts: 500,
    totalCustomers: 1204, prevCustomers: 1140,
    monthlyRevenue: _seedMonthlyRevenue(),
    monthlyCost:    _seedMonthlyCost(),
    categoryData:   _seedCategories(),
  );

  static List<AdminMonthData> _seedMonthlyRevenue() => [
    AdminMonthData('Jan', 42000), AdminMonthData('Feb', 67000),
    AdminMonthData('Mar', 58000), AdminMonthData('Apr', 80000),
    AdminMonthData('May', 75000), AdminMonthData('Jun', 92000),
    AdminMonthData('Jul', 88000), AdminMonthData('Aug', 105000),
    AdminMonthData('Sep', 97000), AdminMonthData('Oct', 120000),
    AdminMonthData('Nov', 115000), AdminMonthData('Dec', 124890),
  ];

  static List<AdminMonthData> _seedMonthlyCost() => [
    AdminMonthData('Jan', 28000), AdminMonthData('Feb', 44000),
    AdminMonthData('Mar', 39000), AdminMonthData('Apr', 55000),
    AdminMonthData('May', 50000), AdminMonthData('Jun', 64000),
    AdminMonthData('Jul', 60000), AdminMonthData('Aug', 72000),
    AdminMonthData('Sep', 66000), AdminMonthData('Oct', 84000),
    AdminMonthData('Nov', 79000), AdminMonthData('Dec', 88000),
  ];

  static List<AdminCategoryData> _seedCategories() => [
    AdminCategoryData('Holograms',    38, 47450),
    AdminCategoryData('Stickers',     27, 33720),
    AdminCategoryData('Labels',       21, 26227),
    AdminCategoryData('Security Tags',10, 12489),
    AdminCategoryData('Other',         4,  4995),
  ];

  @override
  void dispose() { _dashSub?.cancel(); super.dispose(); }
}

// ── Dashboard models ───────────────────────────────────────────────
class AdminDashboardStats {
  final double totalRevenue, prevRevenue;
  final int    totalOrders, prevOrders, totalProducts, prevProducts;
  final int    totalCustomers, prevCustomers;
  final List<AdminMonthData>    monthlyRevenue, monthlyCost;
  final List<AdminCategoryData> categoryData;

  AdminDashboardStats({
    required this.totalRevenue, required this.prevRevenue,
    required this.totalOrders,  required this.prevOrders,
    required this.totalProducts,required this.prevProducts,
    required this.totalCustomers,required this.prevCustomers,
    required this.monthlyRevenue, required this.monthlyCost,
    required this.categoryData,
  });

  double get revenueChange   => prevRevenue   == 0 ? 0 : (totalRevenue   - prevRevenue)   / prevRevenue   * 100;
  double get ordersChange    => prevOrders    == 0 ? 0 : (totalOrders    - prevOrders)    / prevOrders    * 100;
  double get productsChange  => prevProducts  == 0 ? 0 : (totalProducts  - prevProducts)  / prevProducts  * 100;
  double get customersChange => prevCustomers == 0 ? 0 : (totalCustomers - prevCustomers) / prevCustomers * 100;
}

class AdminMonthData {
  final String month;
  final double value;
  AdminMonthData(this.month, this.value);
}

class AdminCategoryData {
  final String name;
  final double percentage;
  final double revenue;
  AdminCategoryData(this.name, this.percentage, this.revenue);
}

// ════════════════════════════════════════════════════════════════════
//  4. ADMIN PRODUCTS PROVIDER
// ════════════════════════════════════════════════════════════════════
class AdminProductsProvider extends ChangeNotifier {
  AdminLoadState     state = AdminLoadState.idle;
  List<AdminProduct> _all  = [];
  StreamSubscription? _prodSub;

  // Tracks previous stock levels to detect LOW STOCK / OUT OF STOCK transitions.
  // We only fire the notification when stock crosses the threshold (not every stream tick).
  final Map<String, int> _prevStockMap = {};

  String searchQuery      = '';
  String selectedCategory = 'All';
  String sortField        = 'name';
  bool   sortAsc          = true;
  int    page             = 0;
  static const int pageSize = 10;

  List<AdminProduct> get filtered       => _applyFilters();
  List<AdminProduct> get lowStockItems  => _all.where((p) => p.stock > 0 && p.stock < p.minStock).toList();
  List<AdminProduct> get outOfStockItems=> _all.where((p) => p.stock == 0).toList();
  List<String>       get categories     => ['All', ...{..._all.map((p) => p.category)}];

  int get totalPages {
    final f = filtered;
    return (f.length / pageSize).ceil().clamp(1, 999);
  }

  List<AdminProduct> get currentPage {
    final f = filtered;
    final s = page * pageSize;
    final e = (s + pageSize).clamp(0, f.length);
    return f.sublist(s, e);
  }

  Future<void> load() async {
    if (state == AdminLoadState.loading) return;
    state = AdminLoadState.loading;
    notifyListeners();

    _prodSub?.cancel();
    _prodSub = FirebaseFirestore.instance
        .collection('products')
        .orderBy('name')
        .snapshots()
        .listen(
          (snap) {
        if (snap.docs.isNotEmpty) {
          _all = snap.docs.map((d) {
            final data = d.data();
            return AdminProduct(
              id: d.id,
              name: data['name'] as String? ?? '',
              sku: data['sku'] as String? ?? d.id,
              category: data['category'] as String? ?? 'Other',
              price: (data['price'] as num? ?? 0).toDouble(),
              stock: (data['stock'] as num? ?? 0).toInt(),
              minStock: (data['minStock'] as num? ?? 10).toInt(),
            );
          }).toList();
        } else {
          _all = _seedProducts();
        }

        // ── LOW STOCK / OUT OF STOCK detection ──────────────────────
        // Only fires when stock TRANSITIONS across the threshold,
        // not on every stream refresh. _prevStockMap is empty on
        // the very first load, so no spurious notifications on startup.
        for (final product in _all) {
          final prev = _prevStockMap[product.id];
          if (prev != null) {
            // Transition: in-stock → out-of-stock
            if (prev > 0 && product.stock == 0) {
              AdminNotificationService.instance.notifyOutOfStock(
                productName: product.name,
              );
            }
            // Transition: above minStock → low stock (but not zero)
            else if (prev >= product.minStock &&
                product.stock > 0 &&
                product.stock < product.minStock) {
              AdminNotificationService.instance.notifyLowStock(
                productName: product.name,
                currentStock: product.stock,
                minStock: product.minStock,
              );
            }
          }
          // Always update the previous stock map
          _prevStockMap[product.id] = product.stock;
        }
        // ────────────────────────────────────────────────────────────

        state = AdminLoadState.loaded;
        notifyListeners();
      },
      onError: (_) {
        _all = _seedProducts();
        state = AdminLoadState.loaded;
        notifyListeners();
      },
    );
  }

  Future<void> add(AdminProduct p) async {
    _all.insert(0, p);
    notifyListeners();

    FirebaseFirestore.instance.collection('products').add({
      'name': p.name,
      'sku': p.sku,
      'category': p.category,
      'price': p.price,
      'stock': p.stock,
      'minStock': p.minStock,
      'status': p.stockStatus,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 🔔 Notify admin: new product purchased and now in stock
    AdminNotificationService.instance.notifyPurchaseArrived(
      productName: p.name,
      quantity: p.stock,
    );
  }

  Future<void> update(AdminProduct p) async {
    final i = _all.indexWhere((x) => x.id == p.id);
    if (i != -1) { _all[i] = p; notifyListeners(); }
    if (p.id.isNotEmpty) {
      FirebaseFirestore.instance.collection('products').doc(p.id).update({
        'name': p.name, 'sku': p.sku, 'category': p.category,
        'price': p.price, 'stock': p.stock, 'minStock': p.minStock,
        'status': p.stockStatus, 'updatedAt': FieldValue.serverTimestamp(),
      }).catchError((_) {});
    }
  }

  Future<void> delete(String id) async {
    _all.removeWhere((p) => p.id == id); notifyListeners();
    if (id.isNotEmpty) {
      FirebaseFirestore.instance.collection('products').doc(id)
          .delete().catchError((_) {});
    }
  }

  void setSearch(String q)   { searchQuery = q; page = 0; notifyListeners(); }
  void setCategory(String c) { selectedCategory = c; page = 0; notifyListeners(); }
  void setSort(String f) {
    if (sortField == f) sortAsc = !sortAsc; else { sortField = f; sortAsc = true; }
    notifyListeners();
  }
  void setPage(int p) { page = p; notifyListeners(); }

  List<AdminProduct> _applyFilters() {
    var list = _all.where((p) {
      final q = searchQuery.toLowerCase();
      return (q.isEmpty || p.name.toLowerCase().contains(q) || p.sku.toLowerCase().contains(q))
          && (selectedCategory == 'All' || p.category == selectedCategory);
    }).toList();
    list.sort((a, b) {
      int cmp = 0;
      switch (sortField) {
        case 'name':     cmp = a.name.compareTo(b.name);         break;
        case 'price':    cmp = a.price.compareTo(b.price);       break;
        case 'stock':    cmp = a.stock.compareTo(b.stock);       break;
        case 'category': cmp = a.category.compareTo(b.category); break;
      }
      return sortAsc ? cmp : -cmp;
    });
    return list;
  }

  static List<AdminProduct> _seedProducts() => [
    AdminProduct(id:'P001',name:'Hologram Security Sticker',sku:'HOL-001',category:'Holograms',  price:8.50,  stock:4,   minStock:20),
    AdminProduct(id:'P002',name:'Gold Label Roll 100m',     sku:'LBL-012',category:'Labels',      price:1299,  stock:28,  minStock:5),
    AdminProduct(id:'P003',name:'Scratch-Off Sticker A4',   sku:'STK-023',category:'Stickers',    price:450,   stock:0,   minStock:10),
    AdminProduct(id:'P004',name:'Tamper-Evident Seal',       sku:'SEC-012',category:'Security Tags',price:12.99,stock:2,   minStock:50),
    AdminProduct(id:'P005',name:'Barcode Label 50x30',       sku:'LBL-034',category:'Labels',      price:320,   stock:142, minStock:30),
    AdminProduct(id:'P006',name:'Prismatic Hologram',        sku:'HOL-004',category:'Holograms',   price:24.99, stock:6,   minStock:20),
  ];

  @override
  void dispose() {
    _prodSub?.cancel(); super.dispose();
  }
}



class AdminProduct {
  final String id, name, sku, category;
  final double price;
  final int    stock, minStock;
  String?      imageUrl;

  AdminProduct({
    required this.id, required this.name, required this.sku,
    required this.category, required this.price, required this.stock,
    this.minStock = 10, this.imageUrl,
  });

  String get stockStatus {
    if (stock == 0)        return 'Out of Stock';
    if (stock < minStock)  return 'Low Stock';
    return 'In Stock';
  }

  AdminProduct copyWith({String? name, String? sku, String? category,
    double? price, int? stock, int? minStock}) =>
      AdminProduct(
        id: id, name: name ?? this.name, sku: sku ?? this.sku,
        category: category ?? this.category, price: price ?? this.price,
        stock: stock ?? this.stock, minStock: minStock ?? this.minStock,
      );
}

// ════════════════════════════════════════════════════════════════════
//  5. ADMIN ORDERS PROVIDER
// ════════════════════════════════════════════════════════════════════
class AdminOrdersProvider extends ChangeNotifier {
  AdminLoadState   state = AdminLoadState.idle;
  List<AdminOrder> _all  = [];
  StreamSubscription? _orderSub;

  String searchQuery  = '';
  String statusFilter = 'All';
  int    page         = 0;
  static const int pageSize = 10;

  // Tracks order IDs we've already seen so we only notify for truly NEW orders.
  // _isFirstLoad prevents firing notifications for all historical orders on startup.
  final Set<String> _seenOrderIds = {};
  bool _isFirstLoad = true;

  List<AdminOrder> get filtered    => _applyFilters();
  List<AdminOrder> get allOrders   => _all;
  double get totalRevenue => _all
      .where((o) => o.status == 'Delivered')
      .fold(0.0, (s, o) => s + o.totalAmount);

  int get totalPages {
    final f = filtered;
    return (f.length / pageSize).ceil().clamp(1, 999);
  }

  List<AdminOrder> get currentPage {
    final f = filtered;
    final s = page * pageSize;
    final e = (s + pageSize).clamp(0, f.length);
    return f.sublist(s, e);
  }

  Future<void> load() async {
    if (state == AdminLoadState.loading) return;
    state = AdminLoadState.loading; notifyListeners();

    _orderSub?.cancel();
    _orderSub = FirebaseFirestore.instance
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (snap) {
        if (snap.docs.isNotEmpty) {
          _all = snap.docs.map((d) {
            final data = d.data();
            return AdminOrder(
              id:            data['orderId']       as String? ?? d.id,
              customerName:  data['customerName']  as String? ?? '',
              items:         (data['items'] as List? ?? []).length,
              totalAmount:   (data['totalAmount']  as num? ?? 0).toDouble(),
              status:        data['status']        as String? ?? 'Pending',
              paymentMethod: data['paymentMethod'] as String? ?? '',
              date:          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            );
          }).toList();
        } else {
          _all = _seedOrders();
        }

        // ── NEW SALE detection ────────────────────────────────────────
        // On first load, populate the seen-IDs set silently (no notifications).
        // On subsequent stream updates, notify for any order ID not seen before.
        if (_isFirstLoad) {
            _isFirstLoad = false;
            for (final o in _all) { _seenOrderIds.add(o.id); }
        } else {
          for (final o in _all) {
            if (!_seenOrderIds.contains(o.id)) {
                _seenOrderIds.add(o.id);
                AdminNotificationService.instance.notifyNewSale(
                    customerName: o.customerName,
                    amount:       o.totalAmount,
                    orderId:      o.id,
                );
            }
          }
        }
        // ─────────────────────────────────────────────────────────────

        state = AdminLoadState.loaded; notifyListeners();
      },
      onError: (_) { _all = _seedOrders(); state = AdminLoadState.loaded; notifyListeners(); },
    );
  }

  Future<void> add(AdminOrder o) async {
    _all.insert(0, o); notifyListeners();
    FirebaseFirestore.instance.collection('orders').add({
      'orderId': o.id, 'customerName': o.customerName,
      'totalAmount': o.totalAmount, 'status': o.status,
      'paymentMethod': o.paymentMethod, 'items': [],
      'customerId': '', 'address': '',
      'createdAt': FieldValue.serverTimestamp(),
    }).catchError((_) {});
  }

  Future<void> updateStatus(String id, String status) async {
    final i = _all.indexWhere((o) => o.id == id);
    if (i != -1) { _all[i] = _all[i].copyWith(status: status); notifyListeners(); }
    FirestoreService.instance.updateOrderStatus(id, status).catchError((_) {});
  }

  void setSearch(String q) { searchQuery = q; page = 0; notifyListeners(); }
  void setStatus(String s) { statusFilter = s; page = 0; notifyListeners(); }
  void setPage(int p)      { page = p; notifyListeners(); }

  List<AdminOrder> _applyFilters() => _all.where((o) {
    final q = searchQuery.toLowerCase();
    return (q.isEmpty || o.id.toLowerCase().contains(q) || o.customerName.toLowerCase().contains(q))
        && (statusFilter == 'All' || o.status == statusFilter);
  }).toList();

  static List<AdminOrder> _seedOrders() => [
    AdminOrder(id:'SO-1041',customerName:'Rahul Mehta',  items:3,totalAmount:4200, status:'Delivered',paymentMethod:'UPI',  date:DateTime(2026,3,13)),
    AdminOrder(id:'SO-1042',customerName:'Priya Shah',   items:1,totalAmount:1890, status:'Pending',  paymentMethod:'Card', date:DateTime(2026,3,13)),
    AdminOrder(id:'SO-1043',customerName:'Amit Patel',   items:5,totalAmount:7350, status:'Delivered',paymentMethod:'Cash', date:DateTime(2026,3,12)),
    AdminOrder(id:'SO-1044',customerName:'Sunita Rao',   items:2,totalAmount:920,  status:'Cancelled',paymentMethod:'UPI',  date:DateTime(2026,3,12)),
    AdminOrder(id:'SO-1045',customerName:'Vikram Joshi', items:4,totalAmount:3600, status:'Pending',  paymentMethod:'Card', date:DateTime(2026,3,11)),
    AdminOrder(id:'SO-1046',customerName:'Meena Gupta',  items:2,totalAmount:2100, status:'Delivered',paymentMethod:'UPI',  date:DateTime(2026,3,11)),
    AdminOrder(id:'SO-1047',customerName:'Dev Trivedi',  items:6,totalAmount:9800, status:'Delivered',paymentMethod:'NEFT', date:DateTime(2026,3,10)),
    AdminOrder(id:'SO-1048',customerName:'Anjali Singh', items:1,totalAmount:599,  status:'Cancelled',paymentMethod:'Card', date:DateTime(2026,3,10)),
  ];

  @override
  void dispose() { _orderSub?.cancel(); super.dispose(); }
}

class AdminOrder {
  final String   id, customerName, status, paymentMethod;
  final int      items;
  final double   totalAmount;
  final DateTime date;

  AdminOrder({
    required this.id, required this.customerName, required this.items,
    required this.totalAmount, required this.status,
    required this.paymentMethod, required this.date,
  });

  AdminOrder copyWith({String? status}) => AdminOrder(
    id: id, customerName: customerName, items: items,
    totalAmount: totalAmount, status: status ?? this.status,
    paymentMethod: paymentMethod, date: date,
  );
}

// ════════════════════════════════════════════════════════════════════
//  6. ADMIN SUPPLIERS PROVIDER
// ════════════════════════════════════════════════════════════════════
class AdminSuppliersProvider extends ChangeNotifier {
  AdminLoadState     state = AdminLoadState.idle;
  List<AdminSupplier> _all = [];
  StreamSubscription? _supSub;
  String searchQuery = '';

  List<AdminSupplier> get filtered {
    final q = searchQuery.toLowerCase();
    if (q.isEmpty) return _all;
    return _all.where((s) =>
    s.name.toLowerCase().contains(q) ||
        s.city.toLowerCase().contains(q) ||
        s.contactPerson.toLowerCase().contains(q)).toList();
  }

  Future<void> load() async {
    if (state == AdminLoadState.loading) return;
    state = AdminLoadState.loading; notifyListeners();

    _supSub?.cancel();
    _supSub = FirebaseFirestore.instance
        .collection('suppliers')
        .snapshots()
        .listen(
          (snap) {
        if (snap.docs.isNotEmpty) {
          _all = snap.docs.map((d) => _docToSupplier(d.id, d.data())).toList();
        } else {
          _all = _seedSuppliers();
        }
        state = AdminLoadState.loaded; notifyListeners();
      },
      onError: (_) { _all = _seedSuppliers(); state = AdminLoadState.loaded; notifyListeners(); },
    );
  }

  Future<void> add(AdminSupplier s) async {
    _all.insert(0, s); notifyListeners();
    FirebaseFirestore.instance.collection('suppliers').add({
      'name': s.name, 'contactPerson': s.contactPerson,
      'phone': s.phone, 'email': s.email, 'city': s.city,
      'address': s.address, 'suppliedCategories': s.categories,
      'isActive': s.isActive, 'totalOrders': s.totalOrders,
      'totalSpend': s.totalSpend, 'createdAt': FieldValue.serverTimestamp(),
    }).catchError((_) {});

      // 🔔 Notify admin: new supplier added
      AdminNotificationService.instance.notifySupplierAdded(
          supplierName: s.name,
          city:         s.city,
      );
    }

  Future<void> update(AdminSupplier s) async {
    final i = _all.indexWhere((x) => x.id == s.id);
    if (i != -1) { _all[i] = s; notifyListeners(); }
    if (s.id.isNotEmpty && !s.id.startsWith('SUP-')) {
      FirebaseFirestore.instance.collection('suppliers').doc(s.id).update({
        'name': s.name, 'contactPerson': s.contactPerson,
        'phone': s.phone, 'email': s.email, 'city': s.city,
        'address': s.address, 'isActive': s.isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      }).catchError((_) {});
    }
  }

  Future<void> delete(String id) async {
    _all.removeWhere((s) => s.id == id); notifyListeners();
    if (id.isNotEmpty && !id.startsWith('SUP-')) {
      FirebaseFirestore.instance.collection('suppliers').doc(id)
          .delete().catchError((_) {});
    }
  }

  void setSearch(String q) { searchQuery = q; notifyListeners(); }

  AdminSupplier _docToSupplier(String docId, Map<String, dynamic> d) => AdminSupplier(
    id:            docId,
    name:          d['name']             as String? ?? '',
    contactPerson: d['contactPerson']    as String? ?? '',
    phone:         d['phone']            as String? ?? '',
    email:         d['email']            as String? ?? '',
    city:          d['city']             as String? ?? '',
    address:       d['address']          as String? ?? '',
    categories:    List<String>.from(d['suppliedCategories'] as List? ?? []),
    totalOrders:   (d['totalOrders']     as num? ?? 0).toInt(),
    totalSpend:    (d['totalSpend']       as num? ?? 0).toDouble(),
    isActive:      d['isActive']          as bool? ?? true,
  );

  static List<AdminSupplier> _seedSuppliers() => [
    AdminSupplier(id:'SUP-01',name:'HoloTech Pvt Ltd',   contactPerson:'Ramesh Kumar', phone:'+91 98765 43210',email:'ramesh@holotech.in',  city:'Mumbai',    address:'14 Andheri East',          categories:['Holograms'],     totalOrders:24, totalSpend:324600, isActive:true),
    AdminSupplier(id:'SUP-02',name:'LabelMaster India',   contactPerson:'Kavita Sharma',phone:'+91 87654 32109',email:'kvt@labelmaster.in', city:'Surat',     address:'Ring Road, Surat',         categories:['Labels'],        totalOrders:18, totalSpend:98200,  isActive:true),
    AdminSupplier(id:'SUP-03',name:'StickerPro Co.',      contactPerson:'Ramji Patel',  phone:'+91 76543 21098',email:'info@stickerpro.com',city:'Ahmedabad', address:'GIDC, Ahmedabad',          categories:['Stickers'],      totalOrders:42, totalSpend:145900, isActive:true),
    AdminSupplier(id:'SUP-04',name:'SecureTag Wholesale', contactPerson:'Suresh Mehta', phone:'+91 65432 10987',email:'s.mehta@securetag.in',city:'Delhi',    address:'Lajpat Nagar, Delhi',      categories:['Security Tags'], totalOrders:9,  totalSpend:560000, isActive:false),
  ];

  @override
  void dispose() { _supSub?.cancel(); super.dispose(); }
}

class AdminSupplier {
  final String        id, name, contactPerson, phone, email, city, address;
  final List<String>  categories;
  final int           totalOrders;
  final double        totalSpend;
  final bool          isActive;

  AdminSupplier({
    required this.id, required this.name, required this.contactPerson,
    required this.phone, required this.email, required this.city,
    required this.address, required this.categories, required this.totalOrders,
    required this.totalSpend, required this.isActive,
  });

  AdminSupplier copyWith({String? name, String? contactPerson, String? phone,
    String? email, String? city, String? address, bool? isActive}) =>
      AdminSupplier(
        id: id, name: name ?? this.name,
        contactPerson: contactPerson ?? this.contactPerson,
        phone: phone ?? this.phone, email: email ?? this.email,
        city: city ?? this.city, address: address ?? this.address,
        categories: categories, totalOrders: totalOrders,
        totalSpend: totalSpend, isActive: isActive ?? this.isActive,
      );
}

// ════════════════════════════════════════════════════════════════════
//  7. ADMIN TRANSFERS PROVIDER
// ════════════════════════════════════════════════════════════════════
class AdminTransferProvider extends ChangeNotifier {
  AdminLoadState      state = AdminLoadState.idle;
  List<AdminTransfer> _all  = [];
  StreamSubscription? _tranSub;

  List<AdminTransfer> get all => _all;

  Future<void> load() async {
    if (state == AdminLoadState.loading) return;
    state = AdminLoadState.loading; notifyListeners();

    _tranSub?.cancel();
    _tranSub = FirebaseFirestore.instance
        .collection('stock_transfers')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (snap) {
        if (snap.docs.isNotEmpty) {
          _all = snap.docs.map((d) {
            final data = d.data();
            return AdminTransfer(
              id:           d.id,
              productName:  data['productName']  as String? ?? '',
              fromLocation: data['fromLocation'] as String? ?? '',
              toLocation:   data['toLocation']   as String? ?? '',
              quantity:     (data['quantity']    as num? ?? 0).toInt(),
              date:         (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
              initiatedBy:  data['initiatedBy']  as String? ?? 'Admin',
              status:       data['status']       as String? ?? 'In Transit',
            );
          }).toList();
        } else {
          _all = _seedTransfers();
        }
        state = AdminLoadState.loaded; notifyListeners();
      },
      onError: (_) { _all = _seedTransfers(); state = AdminLoadState.loaded; notifyListeners(); },
    );
  }

  Future<void> add(AdminTransfer t) async {
    _all.insert(0, t); notifyListeners();
    FirestoreService.instance.createStockTransfer(
      productName:  t.productName,
      fromLocation: t.fromLocation,
      toLocation:   t.toLocation,
      quantity:     t.quantity,
      initiatedBy:  t.initiatedBy,
    ).catchError((_) {});

      // 🔔 Notify admin: stock transfer initiated
      AdminNotificationService.instance.notifyStockTransfer(
          productName:  t.productName,
          fromLocation: t.fromLocation,
          toLocation:   t.toLocation,
          quantity:     t.quantity,
      );
  }

  static List<AdminTransfer> _seedTransfers() => [
    AdminTransfer(id:'ST-201',productName:'Hologram Security Sticker',fromLocation:'Main Warehouse',toLocation:'Outlet - Gandhinagar',quantity:200,date:DateTime(2026,3,13),initiatedBy:'Admin',   status:'Completed'),
    AdminTransfer(id:'ST-202',productName:'Tamper-Evident Seal',       fromLocation:'Main Warehouse',toLocation:'Outlet - Ahmedabad',  quantity:500,date:DateTime(2026,3,12),initiatedBy:'Manager', status:'In Transit'),
    AdminTransfer(id:'ST-203',productName:'Prismatic Hologram',        fromLocation:'Outlet - Surat',toLocation:'Main Warehouse',      quantity:100,date:DateTime(2026,3,12),initiatedBy:'Admin',   status:'Completed'),
    AdminTransfer(id:'ST-204',productName:'Barcode Label 50x30',       fromLocation:'Main Warehouse',toLocation:'Outlet - Vadodara',   quantity:1000,date:DateTime(2026,3,11),initiatedBy:'Manager',status:'In Transit'),
    AdminTransfer(id:'ST-205',productName:'Silver Hologram Strip',     fromLocation:'Outlet - Ahmedabad',toLocation:'Outlet - Gandhinagar',quantity:150,date:DateTime(2026,3,10),initiatedBy:'Admin',status:'Completed'),
  ];

  @override
  void dispose() { _tranSub?.cancel(); super.dispose(); }
}

class AdminTransfer {
  final String   id, productName, fromLocation, toLocation, initiatedBy, status;
  final int      quantity;
  final DateTime date;

  AdminTransfer({
    required this.id, required this.productName,
    required this.fromLocation, required this.toLocation,
    required this.quantity, required this.date,
    required this.initiatedBy, required this.status,
  });
}

// ════════════════════════════════════════════════════════════════════
//  8. ADMIN PROFILE PROVIDER
// ════════════════════════════════════════════════════════════════════
class AdminProfileProvider extends ChangeNotifier {
  String name  = 'Admin';
  String email = 'admin@smartstock.com';
  String role  = 'Super Admin';
  String id    = 'ADM-001';

  void updateProfile({String? name, String? email}) {
    if (name  != null) this.name  = name;
    if (email != null) this.email = email;
    notifyListeners();
  }
}



// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../services/firestore_service.dart';
//
// // ════════════════════════════════════════════════════════════════════
// //  lib/providers/admin_providers.dart
// //
// //  All admin-side ChangeNotifier providers in ONE file.
// //  You add these to your existing main.dart MultiProvider list.
// //  They do NOT interfere with your existing providers at all.
// // ════════════════════════════════════════════════════════════════════
//
// // ── Load state enum (admin-only, won't conflict) ─────────────────────
// enum AdminLoadState { idle, loading, loaded, error }
//
// // ════════════════════════════════════════════════════════════════════
// //  1. AUTH PROVIDER  — decides admin vs client after login
// // ════════════════════════════════════════════════════════════════════
// class AdminAuthProvider extends ChangeNotifier {
//   bool _isAdmin = false;
//   String _adminName = '';
//   String _adminEmail = '';
//
//   bool get isAdmin => _isAdmin;
//   String get adminName => _adminName;
//   String get adminEmail => _adminEmail;
//
//   // ── Called from login_screen.dart after successful login ──────────
//   void loginAsAdmin(String email) {
//     _isAdmin = true;
//     _adminEmail = email;
//     _adminName = 'Admin';  // Replace with real name from your auth
//     notifyListeners();
//   }
//
//   void logout() {
//     _isAdmin = false;
//     _adminEmail = '';
//     _adminName = '';
//     notifyListeners();
//   }
// }
//
// // ════════════════════════════════════════════════════════════════════
// //  2. ADMIN NAV PROVIDER  — sidebar page selection
// // ════════════════════════════════════════════════════════════════════
// class AdminNavProvider extends ChangeNotifier {
//   int _selectedIndex = 0;
//   bool _sidebarExpanded = true;
//
//   int get selectedIndex => _selectedIndex;
//   bool get sidebarExpanded => _sidebarExpanded;
//
//   void selectPage(int i) {
//     _selectedIndex = i;
//     notifyListeners();
//   }
//
//   void toggleSidebar() {
//     _sidebarExpanded = !_sidebarExpanded;
//     notifyListeners();
//   }
//
// // Page index map:
// // 0=Dashboard  1=Products  2=Sales  3=Purchase
// // 4=Suppliers  5=StockTransfer  6=Reports
// // 7=Profile    8=Customers  9=RevenueAnalytics
// }
//
// // ════════════════════════════════════════════════════════════════════
// //  3. ADMIN DASHBOARD PROVIDER  — dashboard stats
// // ════════════════════════════════════════════════════════════════════
// class AdminDashboardProvider extends ChangeNotifier {
//   AdminLoadState state = AdminLoadState.idle;
//   AdminDashboardStats? stats;
//   String? error;
//
//   StreamSubscription? _sub;
//
//   Future<void> load() async {
//     if (state == AdminLoadState.loading) return;
//     state = AdminLoadState.loading;
//     notifyListeners();
//
//     // Listen to real-time report stream from Firestore
//     _sub?.cancel();
//     _sub = FirestoreService.instance.streamReportData().listen(
//           (data) {
//         final monthlyRev  = (data['monthlyRevenue'] as List).map((m) =>
//             AdminMonthData(m['month'] as String, (m['value'] as num).toDouble())).toList();
//         final monthlyCost = (data['monthlyCost'] as List).map((m) =>
//             AdminMonthData(m['month'] as String, (m['value'] as num).toDouble())).toList();
//
//         final catMap = data['categoryRevenue'] as Map<String, dynamic>;
//         final totalCatRev = catMap.values.fold<double>(0, (s, v) => s + (v as num).toDouble());
//         final categoryData = catMap.isEmpty
//             ? _seedCategories()
//             : catMap.entries.map((e) {
//           final pct = totalCatRev == 0 ? 0.0 : (e.value as num).toDouble() / totalCatRev * 100;
//           return AdminCategoryData(e.key, pct, (e.value as num).toDouble());
//         }).toList();
//
//         final totalRevenue   = (data['totalRevenue']   as num).toDouble();
//         final totalOrders    = (data['totalOrders']    as num).toInt();
//         final totalCustomers = (data['totalCustomers'] as num).toInt();
//
//         // Use seed data for prev values (no historical data needed)
//         stats = AdminDashboardStats(
//           totalRevenue:    totalRevenue  > 0 ? totalRevenue  : 124890,
//           prevRevenue:     totalRevenue  > 0 ? totalRevenue  * 0.88 : 110000,
//           totalOrders:     totalOrders   > 0 ? totalOrders   : 2340,
//           prevOrders:      totalOrders   > 0 ? (totalOrders  * 0.92).round() : 2150,
//           totalProducts:   486,
//           prevProducts:    500,
//           totalCustomers:  totalCustomers > 0 ? totalCustomers : 1204,
//           prevCustomers:   totalCustomers > 0 ? (totalCustomers * 0.95).round() : 1140,
//           monthlyRevenue:  monthlyRev.any((m) => m.value > 0) ? monthlyRev  : _seedMonthlyRevenue(),
//           monthlyCost:     monthlyCost.any((m) => m.value > 0) ? monthlyCost : _seedMonthlyCost(),
//           categoryData:    categoryData,
//         );
//         state = AdminLoadState.loaded;
//         notifyListeners();
//       },
//       onError: (_) {
//         // Firestore failed — use seed data so charts always show
//         stats = AdminDashboardStats(
//           totalRevenue: 124890, prevRevenue: 110000,
//           totalOrders: 2340,   prevOrders: 2150,
//           totalProducts: 486,  prevProducts: 500,
//           totalCustomers: 1204, prevCustomers: 1140,
//           monthlyRevenue: _seedMonthlyRevenue(),
//           monthlyCost:    _seedMonthlyCost(),
//           categoryData:   _seedCategories(),
//         );
//         state = AdminLoadState.loaded;
//         notifyListeners();
//       },
//     );
//   }
//
//   @override
//   void dispose() { _sub?.cancel(); super.dispose(); }
// }
//
// static List<AdminMonthData> _seedMonthlyRevenue() => [
// AdminMonthData('Jan', 42000), AdminMonthData('Feb', 67000),
// AdminMonthData('Mar', 58000), AdminMonthData('Apr', 80000),
// AdminMonthData('May', 75000), AdminMonthData('Jun', 92000),
// AdminMonthData('Jul', 88000), AdminMonthData('Aug', 105000),
// AdminMonthData('Sep', 97000), AdminMonthData('Oct', 120000),
// AdminMonthData('Nov', 115000), AdminMonthData('Dec', 124890),
// ];
//
// static List<AdminMonthData> _seedMonthlyCost() => [
// AdminMonthData('Jan', 28000), AdminMonthData('Feb', 44000),
// AdminMonthData('Mar', 39000), AdminMonthData('Apr', 55000),
// AdminMonthData('May', 50000), AdminMonthData('Jun', 64000),
// AdminMonthData('Jul', 60000), AdminMonthData('Aug', 72000),
// AdminMonthData('Sep', 66000), AdminMonthData('Oct', 84000),
// AdminMonthData('Nov', 79000), AdminMonthData('Dec', 88000),
// ];
//
// static List<AdminCategoryData> _seedCategories() => [
// AdminCategoryData('Holograms', 38, 47450),
// AdminCategoryData('Stickers', 27, 33720),
// AdminCategoryData('Labels', 21, 26227),
// AdminCategoryData('Security Tags', 10, 12489),
// AdminCategoryData('Other', 4, 4995),
// ];
// }
//
// class AdminDashboardStats {
// final double totalRevenue, prevRevenue;
// final int totalOrders, prevOrders, totalProducts, prevProducts, totalCustomers, prevCustomers;
// final List<AdminMonthData> monthlyRevenue, monthlyCost;
// final List<AdminCategoryData> categoryData;
//
// AdminDashboardStats({
// required this.totalRevenue, required this.prevRevenue,
// required this.totalOrders, required this.prevOrders,
// required this.totalProducts, required this.prevProducts,
// required this.totalCustomers, required this.prevCustomers,
// required this.monthlyRevenue, required this.monthlyCost,
// required this.categoryData,
// });
//
// double get revenueChange => prevRevenue == 0 ? 0
//     : (totalRevenue - prevRevenue) / prevRevenue * 100;
// double get ordersChange => prevOrders == 0 ? 0
//     : (totalOrders - prevOrders) / prevOrders * 100;
// double get productsChange => prevProducts == 0 ? 0
//     : (totalProducts - prevProducts) / prevProducts * 100;
// double get customersChange => prevCustomers == 0 ? 0
//     : (totalCustomers - prevCustomers) / prevCustomers * 100;
// }
//
// class AdminMonthData { final String month; final double value;
// AdminMonthData(this.month, this.value); }
//
// class AdminCategoryData { final String name; final double percentage; final double revenue;
// AdminCategoryData(this.name, this.percentage, this.revenue); }
//
// // ════════════════════════════════════════════════════════════════════
// //  4. ADMIN PRODUCTS PROVIDER
// // ════════════════════════════════════════════════════════════════════
// class AdminProductsProvider extends ChangeNotifier {
// AdminLoadState state = AdminLoadState.idle;
// List<AdminProduct> _all = [];
// List<AdminProduct> get filtered => _applyFilters();
//
// String searchQuery = '';
// String selectedCategory = 'All';
// String sortField = 'name';
// bool sortAsc = true;
// int page = 0;
// static const int pageSize = 10;
//
// int get totalPages => (filtered.length / pageSize).ceil().clamp(1, 999);
// List<AdminProduct> get currentPage {
// final start = page * pageSize;
// final end = (start + pageSize).clamp(0, filtered.length);
// return filtered.sublist(start, end);
// }
//
// List<AdminProduct> get lowStockItems =>
// _all.where((p) => p.stock > 0 && p.stock < p.minStock).toList();
// List<AdminProduct> get outOfStockItems =>
// _all.where((p) => p.stock == 0).toList();
// List<String> get categories =>
// ['All', ...{..._all.map((p) => p.category)}];
//
// Future<void> load() async {
// if (state == AdminLoadState.loading) return;
// state = AdminLoadState.loading; notifyListeners();
// _sub?.cancel();
// _sub = FirestoreService.instance.streamProducts().listen(
// (products) {
// if (products.isNotEmpty) {
// _all = products.map((p) => AdminProduct(
// id: p.id, name: p.name, sku: p.id,
// category: p.category, price: p.price,
// stock: 10, minStock: 5,
// )).toList();
// } else {
// _all = _seedProducts();
// }
// state = AdminLoadState.loaded; notifyListeners();
// },
// onError: (_) { _all = _seedProducts(); state = AdminLoadState.loaded; notifyListeners(); },
// );
// }
//
// Future<void> add(AdminProduct p) async {
// _all.insert(0, p); notifyListeners();
// FirebaseFirestore.instance.collection('products').add({
// 'name': p.name, 'sku': p.sku, 'category': p.category,
// 'price': p.price, 'stock': p.stock, 'minStock': p.minStock,
// 'status': p.stockStatus, 'imageUrl': '', 'description': '',
// 'createdAt': FieldValue.serverTimestamp(),
// }).catchError((_) {});
// }
//
// Future<void> update(AdminProduct p) async {
// final i = _all.indexWhere((x) => x.id == p.id);
// if (i != -1) { _all[i] = p; notifyListeners(); }
// if (p.id.isNotEmpty) {
// FirebaseFirestore.instance.collection('products').doc(p.id).update({
// 'name': p.name, 'category': p.category, 'price': p.price,
// 'stock': p.stock, 'minStock': p.minStock, 'status': p.stockStatus,
// 'updatedAt': FieldValue.serverTimestamp(),
// }).catchError((_) {});
// }
// }
//
// Future<void> delete(String id) async {
// _all.removeWhere((p) => p.id == id); notifyListeners();
// if (id.isNotEmpty) {
// FirebaseFirestore.instance.collection('products').doc(id)
//     .delete().catchError((_) {});
// }
// }
//
// void setSearch(String q) { searchQuery = q; page = 0; notifyListeners(); }
// void setCategory(String c) { selectedCategory = c; page = 0; notifyListeners(); }
// void setSort(String f) {
// if (sortField == f) sortAsc = !sortAsc;
// else { sortField = f; sortAsc = true; }
// notifyListeners();
// }
// void setPage(int p) { page = p; notifyListeners(); }
//
// List<AdminProduct> _applyFilters() {
// var list = _all.where((p) {
// final q = searchQuery.toLowerCase();
// return (q.isEmpty || p.name.toLowerCase().contains(q) || p.sku.toLowerCase().contains(q))
// && (selectedCategory == 'All' || p.category == selectedCategory);
// }).toList();
// list.sort((a, b) {
// int cmp = 0;
// switch (sortField) {
// case 'name': cmp = a.name.compareTo(b.name); break;
// case 'price': cmp = a.price.compareTo(b.price); break;
// case 'stock': cmp = a.stock.compareTo(b.stock); break;
// case 'category': cmp = a.category.compareTo(b.category); break;
// }
// return sortAsc ? cmp : -cmp;
// });
// return list;
// }
//
// static List<AdminProduct> _seedProducts() => [
// AdminProduct(id:'P001',name:'Hologram Security Sticker',sku:'HOL-001',category:'Holograms',price:8.50,stock:4,minStock:20),
// AdminProduct(id:'P002',name:'Gold Label Roll 100m',sku:'LBL-012',category:'Labels',price:1299,stock:28,minStock:5),
// AdminProduct(id:'P003',name:'Scratch-Off Sticker A4',sku:'STK-023',category:'Stickers',price:450,stock:0,minStock:10),
// AdminProduct(id:'P004',name:'Tamper-Evident Seal',sku:'SEC-012',category:'Security Tags',price:12.99,stock:2,minStock:50),
// AdminProduct(id:'P005',name:'Barcode Label 50x30',sku:'LBL-034',category:'Labels',price:320,stock:142,minStock:30),
// AdminProduct(id:'P006',name:'Prismatic Hologram',sku:'HOL-004',category:'Holograms',price:24.99,stock:6,minStock:20),
// AdminProduct(id:'P007',name:'Custom Logo Sticker',sku:'STK-056',category:'Stickers',price:180,stock:34,minStock:15),
// AdminProduct(id:'P008',name:'RFID Security Tag',sku:'SEC-057',category:'Security Tags',price:45,stock:19,minStock:10),
// AdminProduct(id:'P009',name:'Thermal Label 80x50',sku:'LBL-035',category:'Labels',price:280,stock:88,minStock:20),
// AdminProduct(id:'P010',name:'Silver Hologram Strip',sku:'HOL-008',category:'Holograms',price:6.50,stock:1,minStock:30),
// AdminProduct(id:'P011',name:'Glossy Round Sticker',sku:'STK-020',category:'Stickers',price:95,stock:12,minStock:25),
// AdminProduct(id:'P012',name:'Void Security Label',sku:'SEC-031',category:'Security Tags',price:18.99,stock:45,minStock:20),
// ];
// }
//
// class AdminProduct {
// final String id, name, sku, category;
// final double price;
// final int stock, minStock;
// String? imageUrl;
//
// AdminProduct({
// required this.id, required this.name, required this.sku,
// required this.category, required this.price,
// required this.stock, this.minStock = 10, this.imageUrl,
// });
//
// String get stockStatus {
// if (stock == 0) return 'Out of Stock';
// if (stock < minStock) return 'Low Stock';
// return 'In Stock';
// }
//
// AdminProduct copyWith({String? name, String? sku, String? category,
// double? price, int? stock, int? minStock}) => AdminProduct(
// id: id, name: name ?? this.name, sku: sku ?? this.sku,
// category: category ?? this.category, price: price ?? this.price,
// stock: stock ?? this.stock, minStock: minStock ?? this.minStock,
// );
// }
//
// // ════════════════════════════════════════════════════════════════════
// //  5. ADMIN ORDERS PROVIDER
// // ════════════════════════════════════════════════════════════════════
// class AdminOrdersProvider extends ChangeNotifier {
// AdminLoadState state = AdminLoadState.idle;
// List<AdminOrder> _all = [];
// List<AdminOrder> get filtered => _applyFilters();
// List<AdminOrder> get allOrders => _all;
//
// String searchQuery = '';
// String statusFilter = 'All';
// int page = 0;
// static const int pageSize = 10;
//
// int get totalPages => (filtered.length / pageSize).ceil().clamp(1, 999);
// List<AdminOrder> get currentPage {
// final s = page * pageSize;
// final e = (s + pageSize).clamp(0, filtered.length);
// return filtered.sublist(s, e);
// }
//
// double get totalRevenue => _all
//     .where((o) => o.status == 'Delivered')
//     .fold(0.0, (s, o) => s + o.totalAmount);
//
// Future<void> load() async {
// if (state == AdminLoadState.loading) return;
// state = AdminLoadState.loading; notifyListeners();
// _sub?.cancel();
// _sub = FirestoreService.instance.streamAllOrders().listen(
// (orders) {
// if (orders.isNotEmpty) {
// _all = orders.map((o) => AdminOrder(
// id: o.id, customerName: o.address, items: o.items.length,
// totalAmount: o.total, status: o.status,
// paymentMethod: o.paymentMethod, date: DateTime.now(),
// )).toList();
// } else {
// _all = _seedOrders();
// }
// state = AdminLoadState.loaded; notifyListeners();
// },
// onError: (_) { _all = _seedOrders(); state = AdminLoadState.loaded; notifyListeners(); },
// );
// }
//
// Future<void> add(AdminOrder o) async {
// _all.insert(0, o); notifyListeners();
// // Save to Firestore in background
// FirebaseFirestore.instance.collection('orders').add({
// 'orderId': o.id, 'customerName': o.customerName,
// 'totalAmount': o.totalAmount, 'status': o.status,
// 'paymentMethod': o.paymentMethod, 'items': [],
// 'createdAt': FieldValue.serverTimestamp(),
// }).catchError((_) {});
// }
//
// Future<void> updateStatus(String id, String status) async {
// final i = _all.indexWhere((o) => o.id == id);
// if (i != -1) { _all[i] = _all[i].copyWith(status: status); notifyListeners(); }
// // Also update in Firestore + notify customer
// FirestoreService.instance.updateOrderStatus(id, status).catchError((_) {});
// }
//
// // Helper to convert AdminOrder to OrderModel for Firestore
//
//
// void setSearch(String q) { searchQuery = q; page = 0; notifyListeners(); }
// void setStatus(String s) { statusFilter = s; page = 0; notifyListeners(); }
// void setPage(int p) { page = p; notifyListeners(); }
//
// List<AdminOrder> _applyFilters() => _all.where((o) {
// final q = searchQuery.toLowerCase();
// return (q.isEmpty || o.id.toLowerCase().contains(q) || o.customerName.toLowerCase().contains(q))
// && (statusFilter == 'All' || o.status == statusFilter);
// }).toList();
//
// static List<AdminOrder> _seedOrders() => [
// AdminOrder(id:'SO-1041',customerName:'Rahul Mehta',items:3,totalAmount:4200,status:'Delivered',paymentMethod:'UPI',date:DateTime(2026,3,13)),
// AdminOrder(id:'SO-1042',customerName:'Priya Shah',items:1,totalAmount:1890,status:'Pending',paymentMethod:'Card',date:DateTime(2026,3,13)),
// AdminOrder(id:'SO-1043',customerName:'Amit Patel',items:5,totalAmount:7350,status:'Delivered',paymentMethod:'Cash',date:DateTime(2026,3,12)),
// AdminOrder(id:'SO-1044',customerName:'Sunita Rao',items:2,totalAmount:920,status:'Cancelled',paymentMethod:'UPI',date:DateTime(2026,3,12)),
// AdminOrder(id:'SO-1045',customerName:'Vikram Joshi',items:4,totalAmount:3600,status:'Pending',paymentMethod:'Card',date:DateTime(2026,3,11)),
// AdminOrder(id:'SO-1046',customerName:'Meena Gupta',items:2,totalAmount:2100,status:'Delivered',paymentMethod:'UPI',date:DateTime(2026,3,11)),
// AdminOrder(id:'SO-1047',customerName:'Dev Trivedi',items:6,totalAmount:9800,status:'Delivered',paymentMethod:'NEFT',date:DateTime(2026,3,10)),
// AdminOrder(id:'SO-1048',customerName:'Anjali Singh',items:1,totalAmount:599,status:'Cancelled',paymentMethod:'Card',date:DateTime(2026,3,10)),
// ];
// }
//
// class AdminOrder {
// final String id, customerName, status, paymentMethod;
// final int items;
// final double totalAmount;
// final DateTime date;
//
// AdminOrder({required this.id, required this.customerName,
// required this.items, required this.totalAmount,
// required this.status, required this.paymentMethod, required this.date});
//
// AdminOrder copyWith({String? status}) => AdminOrder(
// id: id, customerName: customerName, items: items,
// totalAmount: totalAmount, status: status ?? this.status,
// paymentMethod: paymentMethod, date: date,
// );
// }
//
// // ════════════════════════════════════════════════════════════════════
// //  6. ADMIN SUPPLIERS PROVIDER
// // ════════════════════════════════════════════════════════════════════
// class AdminSuppliersProvider extends ChangeNotifier {
// AdminLoadState state = AdminLoadState.idle;
// List<AdminSupplier> _all = [];
// String searchQuery = '';
// List<AdminSupplier> get filtered {
// final q = searchQuery.toLowerCase();
// if (q.isEmpty) return _all;
// return _all.where((s) =>
// s.name.toLowerCase().contains(q) ||
// s.city.toLowerCase().contains(q) ||
// s.contactPerson.toLowerCase().contains(q)).toList();
// }
//
// Future<void> load() async {
// if (state == AdminLoadState.loading) return;
// state = AdminLoadState.loading; notifyListeners();
// _sub?.cancel();
// _sub = FirebaseFirestore.instance.collection('suppliers').snapshots().listen(
// (snap) {
// if (snap.docs.isNotEmpty) {
// _all = snap.docs.map((d) => _docToSupplier({'id': d.id, ...d.data()})).toList();
// } else {
// _all = _seedSuppliers();
// }
// state = AdminLoadState.loaded; notifyListeners();
// },
// onError: (_) { _all = _seedSuppliers(); state = AdminLoadState.loaded; notifyListeners(); },
// );
// }
//
// Future<void> add(AdminSupplier s) async {
// _all.insert(0, s); notifyListeners();
// FirebaseFirestore.instance.collection('suppliers').add({
// 'name': s.name, 'contactPerson': s.contactPerson,
// 'phone': s.phone, 'email': s.email, 'city': s.city,
// 'address': s.address, 'suppliedCategories': s.categories,
// 'isActive': s.isActive, 'totalOrders': 0, 'totalSpend': 0.0,
// 'createdAt': FieldValue.serverTimestamp(),
// }).catchError((_) {});
// }
//
// Future<void> update(AdminSupplier s) async {
// final i = _all.indexWhere((x) => x.id == s.id);
// if (i != -1) { _all[i] = s; notifyListeners(); }
// if (s.id.isNotEmpty) {
// FirebaseFirestore.instance.collection('suppliers').doc(s.id).update({
// 'name': s.name, 'contactPerson': s.contactPerson,
// 'phone': s.phone, 'email': s.email, 'city': s.city,
// 'isActive': s.isActive, 'updatedAt': FieldValue.serverTimestamp(),
// }).catchError((_) {});
// }
// }
//
// Future<void> delete(String id) async {
// _all.removeWhere((s) => s.id == id); notifyListeners();
// if (id.isNotEmpty) {
// FirebaseFirestore.instance.collection('suppliers').doc(id)
//     .delete().catchError((_) {});
// }
// }
//
// void setSearch(String q) { searchQuery = q; notifyListeners(); }
//
// static List<AdminSupplier> _seedSuppliers() => [
// AdminSupplier(id:'SUP-01',name:'HoloTech Pvt Ltd',contactPerson:'Ramesh Kumar',phone:'+91 98765 43210',email:'ramesh@holotech.in',city:'Mumbai',address:'14 Andheri East',categories:['Holograms'],totalOrders:24,totalSpend:324600,isActive:true),
// AdminSupplier(id:'SUP-02',name:'LabelMaster India',contactPerson:'Kavita Sharma',phone:'+91 87654 32109',email:'kvt@labelmaster.in',city:'Surat',address:'Ring Road, Surat',categories:['Labels'],totalOrders:18,totalSpend:98200,isActive:true),
// AdminSupplier(id:'SUP-03',name:'StickerPro Co.',contactPerson:'Ramji Patel',phone:'+91 76543 21098',email:'info@stickerpro.com',city:'Ahmedabad',address:'GIDC, Ahmedabad',categories:['Stickers'],totalOrders:42,totalSpend:145900,isActive:true),
// AdminSupplier(id:'SUP-04',name:'SecureTag Wholesale',contactPerson:'Suresh Mehta',phone:'+91 65432 10987',email:'s.mehta@securetag.in',city:'Delhi',address:'Lajpat Nagar, Delhi',categories:['Security Tags'],totalOrders:9,totalSpend:560000,isActive:false),
// ];
// }
//
// class AdminSupplier {
// final String id, name, contactPerson, phone, email, city, address;
// final List<String> categories;
// final int totalOrders;
// final double totalSpend;
// final bool isActive;
//
// AdminSupplier({required this.id, required this.name, required this.contactPerson,
// required this.phone, required this.email, required this.city, required this.address,
// required this.categories, required this.totalOrders, required this.totalSpend,
// required this.isActive});
//
// AdminSupplier copyWith({String? name, String? contactPerson, String? phone,
// String? email, String? city, String? address, bool? isActive}) => AdminSupplier(
// id: id, name: name ?? this.name,
// contactPerson: contactPerson ?? this.contactPerson,
// phone: phone ?? this.phone, email: email ?? this.email,
// city: city ?? this.city, address: address ?? this.address,
// categories: categories, totalOrders: totalOrders,
// totalSpend: totalSpend, isActive: isActive ?? this.isActive,
// );
// }
//
// // ════════════════════════════════════════════════════════════════════
// //  7. ADMIN TRANSFERS PROVIDER
// // ════════════════════════════════════════════════════════════════════
// class AdminTransferProvider extends ChangeNotifier {
// AdminLoadState state = AdminLoadState.idle;
// List<AdminTransfer> _all = [];
// List<AdminTransfer> get all => _all;
//
// Future<void> load() async {
// if (state == AdminLoadState.loading) return;
// state = AdminLoadState.loading; notifyListeners();
// if (state == AdminLoadState.loading) return;
// state = AdminLoadState.loading; notifyListeners();
// FirestoreService.instance.streamStockTransfers().listen(
// (transfers) {
// if (transfers.isNotEmpty) {
// _all = transfers.map((t) => AdminTransfer(
// id: t['id'] as String, productName: t['productName'] as String? ?? '',
// fromLocation: t['fromLocation'] as String? ?? '',
// toLocation: t['toLocation'] as String? ?? '',
// quantity: (t['quantity'] as num? ?? 0).toInt(),
// date: (t['date'] as dynamic)?.toDate() ?? DateTime.now(),
// initiatedBy: t['initiatedBy'] as String? ?? 'Admin',
// status: t['status'] as String? ?? 'In Transit',
// )).toList();
// } else {
// _all = _seedTransfers();
// }
// state = AdminLoadState.loaded; notifyListeners();
// },
// onError: (_) { _all = _seedTransfers(); state = AdminLoadState.loaded; notifyListeners(); },
// );
// }
//
// Future<void> add(AdminTransfer t) async {
// _all.insert(0, t); notifyListeners();
// FirestoreService.instance.createStockTransfer(
// productName:  t.productName,
// fromLocation: t.fromLocation,
// toLocation:   t.toLocation,
// quantity:     t.quantity,
// initiatedBy:  t.initiatedBy,
// ).catchError((_) {});
//
// static List<AdminTransfer> _seedTransfers() => [
// AdminTransfer(id:'ST-201',productName:'Hologram Security Sticker',fromLocation:'Main Warehouse',toLocation:'Outlet - Gandhinagar',quantity:200,date:DateTime(2026,3,13),initiatedBy:'Admin',status:'Completed'),
// AdminTransfer(id:'ST-202',productName:'Tamper-Evident Seal',fromLocation:'Main Warehouse',toLocation:'Outlet - Ahmedabad',quantity:500,date:DateTime(2026,3,12),initiatedBy:'Manager',status:'In Transit'),
// AdminTransfer(id:'ST-203',productName:'Prismatic Hologram',fromLocation:'Outlet - Surat',toLocation:'Main Warehouse',quantity:100,date:DateTime(2026,3,12),initiatedBy:'Admin',status:'Completed'),
// AdminTransfer(id:'ST-204',productName:'Barcode Label 50x30',fromLocation:'Main Warehouse',toLocation:'Outlet - Vadodara',quantity:1000,date:DateTime(2026,3,11),initiatedBy:'Manager',status:'In Transit'),
// AdminTransfer(id:'ST-205',productName:'Silver Hologram Strip',fromLocation:'Outlet - Ahmedabad',toLocation:'Outlet - Gandhinagar',quantity:150,date:DateTime(2026,3,10),initiatedBy:'Admin',status:'Completed'),
// ];
// }
//
// class AdminTransfer {
// final String id, productName, fromLocation, toLocation, initiatedBy, status;
// final int quantity;
// final DateTime date;
// AdminTransfer({required this.id, required this.productName,
// required this.fromLocation, required this.toLocation,
// required this.quantity, required this.date,
// required this.initiatedBy, required this.status});
// }
//
// // ════════════════════════════════════════════════════════════════════
// //  8. ADMIN PROFILE PROVIDER
// // ════════════════════════════════════════════════════════════════════
// class AdminProfileProvider extends ChangeNotifier {
// String name = 'Admin';
// String email = 'admin@smartstock.com';
// String role = 'Super Admin';
// String id = 'ADM-001';
//
// void updateProfile({String? name, String? email}) {
// if (name != null) this.name = name;
// if (email != null) this.email = email;
// notifyListeners();
// }
// }


// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// enum AdminLoadState { idle, loading, loaded, error }
//
// // ════════════════════════════════════════════════════════════════════
// //  1. AUTH PROVIDER
// // ════════════════════════════════════════════════════════════════════
// class AdminAuthProvider extends ChangeNotifier {
//   bool _isAdmin = false;
//   String _adminName = '';
//   String _adminEmail = '';
//
//   bool get isAdmin => _isAdmin;
//   String get adminName => _adminName;
//   String get adminEmail => _adminEmail;
//
//   void loginAsAdmin(String email, {String name = 'Admin'}) {
//     _isAdmin = true;
//     _adminEmail = email;
//     _adminName = name;
//     notifyListeners();
//   }
//
//   void logout() {
//     _isAdmin = false;
//     _adminEmail = '';
//     _adminName = '';
//     notifyListeners();
//   }
// }
//
// // ════════════════════════════════════════════════════════════════════
// //  2. NAV PROVIDER
// // ════════════════════════════════════════════════════════════════════
// class AdminNavProvider extends ChangeNotifier {
//   int _selectedIndex = 0;
//   bool _sidebarExpanded = true;
//
//   int get selectedIndex => _selectedIndex;
//   bool get sidebarExpanded => _sidebarExpanded;
//
//   void selectPage(int i) { _selectedIndex = i; notifyListeners(); }
//   void toggleSidebar() { _sidebarExpanded = !_sidebarExpanded; notifyListeners(); }
// }
//
// // ════════════════════════════════════════════════════════════════════
// //  3. DASHBOARD PROVIDER — Firestore real-time + seed fallback
// // ════════════════════════════════════════════════════════════════════
// class AdminDashboardProvider extends ChangeNotifier {
//   AdminLoadState state = AdminLoadState.idle;
//   AdminDashboardStats? stats;
//   String? error;
//
//   Future<void> load() async {
//     if (state == AdminLoadState.loading) return;
//     state = AdminLoadState.loading;
//     notifyListeners();
//
//     try {
//       // Try to load from Firestore
//       final firestoreStats = await _loadFromFirestore();
//       stats = firestoreStats;
//       state = AdminLoadState.loaded;
//     } catch (e) {
//       // If Firestore fails, use seed data so charts still show
//       stats = _seedStats();
//       state = AdminLoadState.loaded;
//       error = e.toString();
//     }
//     notifyListeners();
//   }
//
//   Future<AdminDashboardStats> _loadFromFirestore() async {
//     final db = FirebaseFirestore.instance;
//
//     // Load products, orders, users in parallel
//     final results = await Future.wait([
//       db.collection('products').get(),
//       db.collection('orders').get(),
//       db.collection('users').get(),
//     ]).timeout(const Duration(seconds: 8));
//
//     final productDocs = results[0].docs;
//     final orderDocs   = results[1].docs;
//     final userDocs    = results[2].docs;
//
//     // ── Products stats ──────────────────────────────────────────
//     final products = productDocs.map((d) => {'id': d.id, ...d.data()}).toList();
//     final totalProducts = products.length;
//
//     // ── Category breakdown from products ────────────────────────
//     final Map<String, int> catCount = {};
//     for (final p in products) {
//       final cat = p['category'] as String? ?? 'Other';
//       catCount[cat] = (catCount[cat] ?? 0) + 1;
//     }
//     final categoryData = catCount.entries.map((e) {
//       final pct = totalProducts == 0 ? 0.0 : e.value / totalProducts * 100;
//       return AdminCategoryData(e.key, pct, 0);
//     }).toList();
//
//     // ── Orders stats ─────────────────────────────────────────────
//     final orders = orderDocs.map((d) => d.data()).toList();
//     final totalOrders = orders.length;
//     final totalRevenue = orders
//         .where((o) => o['status'] == 'Delivered')
//         .fold<double>(0, (s, o) => s + (o['totalAmount'] as num? ?? 0));
//
//     // ── Monthly revenue ───────────────────────────────────────────
//     final now = DateTime.now();
//     final Map<int, double> revMap = {for (var i = 1; i <= 12; i++) i: 0};
//     for (final o in orders.where((o) => o['status'] == 'Delivered')) {
//       final ts = o['createdAt'] as Timestamp?;
//       if (ts != null && ts.toDate().year == now.year) {
//         revMap[ts.toDate().month] =
//             (revMap[ts.toDate().month] ?? 0) + (o['totalAmount'] as num? ?? 0);
//       }
//     }
//     const months = ['Jan','Feb','Mar','Apr','May','Jun',
//       'Jul','Aug','Sep','Oct','Nov','Dec'];
//     final monthlyRevenue = [
//       for (var i = 1; i <= 12; i++) AdminMonthData(months[i-1], revMap[i] ?? 0)
//     ];
//     final monthlyCost = [
//       for (var i = 1; i <= 12; i++) AdminMonthData(months[i-1], (revMap[i] ?? 0) * 0.65)
//     ];
//
//     // ── Customers ─────────────────────────────────────────────────
//     final totalCustomers = userDocs
//         .where((d) => (d.data()['role'] as String?) == 'client')
//         .length;
//
//     // If Firestore has no data yet, use seed data for charts
//     final finalCategoryData = categoryData.isNotEmpty
//         ? categoryData
//         : _seedCategories();
//     final hasRevData = monthlyRevenue.any((m) => m.value > 0);
//     final finalMonthlyRevenue = hasRevData ? monthlyRevenue : _seedMonthlyRevenue();
//     final finalMonthlyCost    = hasRevData ? monthlyCost    : _seedMonthlyCost();
//
//     return AdminDashboardStats(
//       totalRevenue:    totalRevenue > 0 ? totalRevenue : 124890,
//       prevRevenue:     totalRevenue > 0 ? totalRevenue * 0.88 : 110000,
//       totalOrders:     totalOrders > 0  ? totalOrders  : 2340,
//       prevOrders:      totalOrders > 0  ? (totalOrders * 0.92).round() : 2150,
//       totalProducts:   totalProducts > 0 ? totalProducts : 486,
//       prevProducts:    totalProducts > 0 ? (totalProducts * 1.03).round() : 500,
//       totalCustomers:  totalCustomers > 0 ? totalCustomers : 1204,
//       prevCustomers:   totalCustomers > 0 ? (totalCustomers * 0.95).round() : 1140,
//       monthlyRevenue:  finalMonthlyRevenue,
//       monthlyCost:     finalMonthlyCost,
//       categoryData:    finalCategoryData,
//     );
//   }
//
//   // ── Seed data (always shown when Firestore is empty/offline) ────
//   static AdminDashboardStats _seedStats() => AdminDashboardStats(
//     totalRevenue: 124890, prevRevenue: 110000,
//     totalOrders: 2340,    prevOrders: 2150,
//     totalProducts: 486,   prevProducts: 500,
//     totalCustomers: 1204, prevCustomers: 1140,
//     monthlyRevenue: _seedMonthlyRevenue(),
//     monthlyCost:    _seedMonthlyCost(),
//     categoryData:   _seedCategories(),
//   );
//
//   static List<AdminMonthData> _seedMonthlyRevenue() => [
//     AdminMonthData('Jan', 42000), AdminMonthData('Feb', 67000),
//     AdminMonthData('Mar', 58000), AdminMonthData('Apr', 80000),
//     AdminMonthData('May', 75000), AdminMonthData('Jun', 92000),
//     AdminMonthData('Jul', 88000), AdminMonthData('Aug', 105000),
//     AdminMonthData('Sep', 97000), AdminMonthData('Oct', 120000),
//     AdminMonthData('Nov', 115000), AdminMonthData('Dec', 124890),
//   ];
//
//   static List<AdminMonthData> _seedMonthlyCost() => [
//     AdminMonthData('Jan', 28000), AdminMonthData('Feb', 44000),
//     AdminMonthData('Mar', 39000), AdminMonthData('Apr', 55000),
//     AdminMonthData('May', 50000), AdminMonthData('Jun', 64000),
//     AdminMonthData('Jul', 60000), AdminMonthData('Aug', 72000),
//     AdminMonthData('Sep', 66000), AdminMonthData('Oct', 84000),
//     AdminMonthData('Nov', 79000), AdminMonthData('Dec', 88000),
//   ];
//
//   static List<AdminCategoryData> _seedCategories() => [
//     AdminCategoryData('Holograms',    38, 47450),
//     AdminCategoryData('Stickers',     27, 33720),
//     AdminCategoryData('Labels',       21, 26227),
//     AdminCategoryData('Security Tags',10, 12489),
//     AdminCategoryData('Other',         4,  4995),
//   ];
// }
//
// // ── Models ─────────────────────────────────────────────────────────
// class AdminDashboardStats {
//   final double totalRevenue, prevRevenue;
//   final int totalOrders, prevOrders, totalProducts, prevProducts;
//   final int totalCustomers, prevCustomers;
//   final List<AdminMonthData> monthlyRevenue, monthlyCost;
//   final List<AdminCategoryData> categoryData;
//
//   AdminDashboardStats({
//     required this.totalRevenue, required this.prevRevenue,
//     required this.totalOrders,  required this.prevOrders,
//     required this.totalProducts,required this.prevProducts,
//     required this.totalCustomers,required this.prevCustomers,
//     required this.monthlyRevenue, required this.monthlyCost,
//     required this.categoryData,
//   });
//
//   double get revenueChange  => prevRevenue  == 0 ? 0 : (totalRevenue  - prevRevenue)  / prevRevenue  * 100;
//   double get ordersChange   => prevOrders   == 0 ? 0 : (totalOrders   - prevOrders)   / prevOrders   * 100;
//   double get productsChange => prevProducts == 0 ? 0 : (totalProducts - prevProducts) / prevProducts * 100;
//   double get customersChange=> prevCustomers== 0 ? 0 : (totalCustomers- prevCustomers)/ prevCustomers* 100;
// }
//
// class AdminMonthData { final String month; final double value; AdminMonthData(this.month, this.value); }
// class AdminCategoryData { final String name; final double percentage; final double revenue; AdminCategoryData(this.name, this.percentage, this.revenue); }
//
// // ════════════════════════════════════════════════════════════════════
// //  4. PRODUCTS PROVIDER
// // ════════════════════════════════════════════════════════════════════
// class AdminProductsProvider extends ChangeNotifier {
//   AdminLoadState state = AdminLoadState.idle;
//   List<AdminProduct> _all = [];
//   StreamSubscription? _sub;
//
//   String searchQuery = '';
//   String selectedCategory = 'All';
//   String sortField = 'name';
//   bool sortAsc = true;
//   int page = 0;
//   static const int pageSize = 10;
//
//   List<AdminProduct> get filtered => _applyFilters();
//   int get totalPages => (filtered.length / pageSize).ceil().clamp(1, 999);
//   List<AdminProduct> get currentPage {
//     final s = page * pageSize;
//     final e = (s + pageSize).clamp(0, filtered.length);
//     return filtered.sublist(s, e);
//   }
//   List<AdminProduct> get lowStockItems  => _all.where((p) => p.stock > 0 && p.stock < p.minStock).toList();
//   List<AdminProduct> get outOfStockItems=> _all.where((p) => p.stock == 0).toList();
//   List<String> get categories => ['All', ...{..._all.map((p) => p.category)}];
//
//   Future<void> load() async {
//     if (state == AdminLoadState.loading) return;
//     state = AdminLoadState.loading; notifyListeners();
//
//     _sub?.cancel();
//     _sub = FirebaseFirestore.instance
//         .collection('products')
//         .orderBy('name')
//         .snapshots()
//         .listen(
//           (snap) {
//         if (snap.docs.isNotEmpty) {
//           _all = snap.docs.map((d) => _docToProduct({'id': d.id, ...d.data()})).toList();
//         } else {
//           _all = _seedProducts();
//         }
//         state = AdminLoadState.loaded; notifyListeners();
//       },
//       onError: (_) {
//         _all = _seedProducts();
//         state = AdminLoadState.loaded; notifyListeners();
//       },
//     );
//   }
//
//   Future<void> add(AdminProduct p) async {
//     try {
//       await FirebaseFirestore.instance.collection('products').add({
//         'name': p.name, 'sku': p.sku, 'category': p.category,
//         'price': p.price, 'stock': p.stock, 'minStock': p.minStock,
//         'imageUrl': '', 'supplierId': '', 'description': '',
//         'status': p.stockStatus,
//         'createdAt': FieldValue.serverTimestamp(),
//       });
//     } catch (_) { _all.insert(0, p); notifyListeners(); }
//   }
//
//   Future<void> update(AdminProduct p) async {
//     try {
//       await FirebaseFirestore.instance.collection('products').doc(p.id).update({
//         'name': p.name, 'sku': p.sku, 'category': p.category,
//         'price': p.price, 'stock': p.stock, 'minStock': p.minStock,
//         'status': p.stockStatus,
//         'updatedAt': FieldValue.serverTimestamp(),
//       });
//     } catch (_) {
//       final i = _all.indexWhere((x) => x.id == p.id);
//       if (i != -1) { _all[i] = p; notifyListeners(); }
//     }
//   }
//
//   Future<void> delete(String id) async {
//     try {
//       await FirebaseFirestore.instance.collection('products').doc(id).delete();
//     } catch (_) { _all.removeWhere((p) => p.id == id); notifyListeners(); }
//   }
//
//   void setSearch(String q) { searchQuery = q; page = 0; notifyListeners(); }
//   void setCategory(String c) { selectedCategory = c; page = 0; notifyListeners(); }
//   void setSort(String f) {
//     if (sortField == f) sortAsc = !sortAsc; else { sortField = f; sortAsc = true; }
//     notifyListeners();
//   }
//   void setPage(int p) { page = p; notifyListeners(); }
//
//   List<AdminProduct> _applyFilters() {
//     var list = _all.where((p) {
//       final q = searchQuery.toLowerCase();
//       return (q.isEmpty || p.name.toLowerCase().contains(q) || p.sku.toLowerCase().contains(q))
//           && (selectedCategory == 'All' || p.category == selectedCategory);
//     }).toList();
//     list.sort((a, b) {
//       int cmp = 0;
//       switch (sortField) {
//         case 'name':     cmp = a.name.compareTo(b.name); break;
//         case 'price':    cmp = a.price.compareTo(b.price); break;
//         case 'stock':    cmp = a.stock.compareTo(b.stock); break;
//         case 'category': cmp = a.category.compareTo(b.category); break;
//       }
//       return sortAsc ? cmp : -cmp;
//     });
//     return list;
//   }
//
//   AdminProduct _docToProduct(Map<String, dynamic> d) => AdminProduct(
//     id: d['id'] as String? ?? '',
//     name: d['name'] as String? ?? '',
//     sku: d['sku'] as String? ?? '',
//     category: d['category'] as String? ?? 'Other',
//     price: (d['price'] as num? ?? 0).toDouble(),
//     stock: (d['stock'] as num? ?? 0).toInt(),
//     minStock: (d['minStock'] as num? ?? 10).toInt(),
//     imageUrl: d['imageUrl'] as String?,
//   );
//
//   static List<AdminProduct> _seedProducts() => [
//     AdminProduct(id:'P001',name:'Hologram Security Sticker',sku:'HOL-001',category:'Holograms',price:8.50,stock:4,minStock:20),
//     AdminProduct(id:'P002',name:'Gold Label Roll 100m',sku:'LBL-012',category:'Labels',price:1299,stock:28,minStock:5),
//     AdminProduct(id:'P003',name:'Scratch-Off Sticker A4',sku:'STK-023',category:'Stickers',price:450,stock:0,minStock:10),
//     AdminProduct(id:'P004',name:'Tamper-Evident Seal',sku:'SEC-012',category:'Security Tags',price:12.99,stock:2,minStock:50),
//     AdminProduct(id:'P005',name:'Barcode Label 50x30',sku:'LBL-034',category:'Labels',price:320,stock:142,minStock:30),
//     AdminProduct(id:'P006',name:'Prismatic Hologram',sku:'HOL-004',category:'Holograms',price:24.99,stock:6,minStock:20),
//   ];
//
//   @override
//   void dispose() { _sub?.cancel(); super.dispose(); }
// }
//
// class AdminProduct {
//   final String id, name, sku, category;
//   final double price;
//   final int stock, minStock;
//   String? imageUrl;
//
//   AdminProduct({required this.id, required this.name, required this.sku,
//     required this.category, required this.price, required this.stock,
//     this.minStock = 10, this.imageUrl});
//
//   String get stockStatus {
//     if (stock == 0) return 'Out of Stock';
//     if (stock < minStock) return 'Low Stock';
//     return 'In Stock';
//   }
//
//   AdminProduct copyWith({String? name, String? sku, String? category,
//     double? price, int? stock, int? minStock}) => AdminProduct(
//     id: id, name: name ?? this.name, sku: sku ?? this.sku,
//     category: category ?? this.category, price: price ?? this.price,
//     stock: stock ?? this.stock, minStock: minStock ?? this.minStock,
//   );
// }
//
// // ════════════════════════════════════════════════════════════════════
// //  5. ORDERS PROVIDER
// // ════════════════════════════════════════════════════════════════════
// class AdminOrdersProvider extends ChangeNotifier {
//   AdminLoadState state = AdminLoadState.idle;
//   List<AdminOrder> _all = [];
//   StreamSubscription? _sub;
//
//   String searchQuery = '';
//   String statusFilter = 'All';
//   int page = 0;
//   static const int pageSize = 10;
//
//   List<AdminOrder> get filtered => _applyFilters();
//   List<AdminOrder> get allOrders => _all;
//   int get totalPages => (filtered.length / pageSize).ceil().clamp(1, 999);
//   List<AdminOrder> get currentPage {
//     final s = page * pageSize;
//     final e = (s + pageSize).clamp(0, filtered.length);
//     return filtered.sublist(s, e);
//   }
//   double get totalRevenue => _all
//       .where((o) => o.status == 'Delivered')
//       .fold(0.0, (s, o) => s + o.totalAmount);
//
//   Future<void> load() async {
//     if (state == AdminLoadState.loading) return;
//     state = AdminLoadState.loading; notifyListeners();
//
//     _sub?.cancel();
//     _sub = FirebaseFirestore.instance
//         .collection('orders')
//         .orderBy('createdAt', descending: true)
//         .snapshots()
//         .listen(
//           (snap) {
//         if (snap.docs.isNotEmpty) {
//           _all = snap.docs.map((d) => _docToOrder({'id': d.id, ...d.data()})).toList();
//         } else {
//           _all = _seedOrders();
//         }
//         state = AdminLoadState.loaded; notifyListeners();
//       },
//       onError: (_) {
//         _all = _seedOrders();
//         state = AdminLoadState.loaded; notifyListeners();
//       },
//     );
//   }
//
//   // add() called by admin_other_pages and admin_sales_screen
//   Future<void> add(AdminOrder o) async {
//     try {
//       await FirebaseFirestore.instance.collection('orders').add({
//         'customerId': '', 'customerName': o.customerName, 'items': [],
//         'totalAmount': o.totalAmount, 'status': o.status,
//         'paymentMethod': o.paymentMethod, 'paymentStatus': 'Paid', 'address': '',
//         'createdAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp(),
//       });
//     } catch (_) { _all.insert(0, o); notifyListeners(); }
//   }
//
//   Future<void> updateStatus(String id, String status) async {
//     try {
//       await FirebaseFirestore.instance.collection('orders').doc(id).update({
//         'status': status, 'updatedAt': FieldValue.serverTimestamp(),
//       });
//     } catch (_) {
//       final i = _all.indexWhere((o) => o.id == id);
//       if (i != -1) { _all[i] = _all[i].copyWith(status: status); notifyListeners(); }
//     }
//   }
//
//   void setSearch(String q) { searchQuery = q; page = 0; notifyListeners(); }
//   void setStatus(String s) { statusFilter = s; page = 0; notifyListeners(); }
//   void setPage(int p) { page = p; notifyListeners(); }
//
//   List<AdminOrder> _applyFilters() => _all.where((o) {
//     final q = searchQuery.toLowerCase();
//     return (q.isEmpty || o.id.toLowerCase().contains(q) || o.customerName.toLowerCase().contains(q))
//         && (statusFilter == 'All' || o.status == statusFilter);
//   }).toList();
//
//   AdminOrder _docToOrder(Map<String, dynamic> d) => AdminOrder(
//     id: d['id'] as String? ?? '',
//     customerName: d['customerName'] as String? ?? '',
//     items: (d['items'] as List?)?.length ?? 0,
//     totalAmount: (d['totalAmount'] as num? ?? 0).toDouble(),
//     status: d['status'] as String? ?? 'Pending',
//     paymentMethod: d['paymentMethod'] as String? ?? '',
//     date: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
//   );
//
//   static List<AdminOrder> _seedOrders() => [
//     AdminOrder(id:'SO-1041',customerName:'Rahul Mehta',items:3,totalAmount:4200,status:'Delivered',paymentMethod:'UPI',date:DateTime(2026,3,13)),
//     AdminOrder(id:'SO-1042',customerName:'Priya Shah',items:1,totalAmount:1890,status:'Pending',paymentMethod:'Card',date:DateTime(2026,3,13)),
//     AdminOrder(id:'SO-1043',customerName:'Amit Patel',items:5,totalAmount:7350,status:'Delivered',paymentMethod:'Cash',date:DateTime(2026,3,12)),
//     AdminOrder(id:'SO-1044',customerName:'Sunita Rao',items:2,totalAmount:920,status:'Cancelled',paymentMethod:'UPI',date:DateTime(2026,3,12)),
//   ];
//
//   @override
//   void dispose() { _sub?.cancel(); super.dispose(); }
// }
//
// class AdminOrder {
//   final String id, customerName, status, paymentMethod;
//   final int items;
//   final double totalAmount;
//   final DateTime date;
//   AdminOrder({required this.id, required this.customerName, required this.items,
//     required this.totalAmount, required this.status, required this.paymentMethod, required this.date});
//   AdminOrder copyWith({String? status}) => AdminOrder(
//     id: id, customerName: customerName, items: items, totalAmount: totalAmount,
//     status: status ?? this.status, paymentMethod: paymentMethod, date: date,
//   );
// }
//
// // ════════════════════════════════════════════════════════════════════
// //  6. SUPPLIERS PROVIDER
// // ════════════════════════════════════════════════════════════════════
// class AdminSuppliersProvider extends ChangeNotifier {
//   AdminLoadState state = AdminLoadState.idle;
//   List<AdminSupplier> _all = [];
//   StreamSubscription? _sub;
//   String searchQuery = '';
//
//   List<AdminSupplier> get filtered {
//     final q = searchQuery.toLowerCase();
//     if (q.isEmpty) return _all;
//     return _all.where((s) =>
//     s.name.toLowerCase().contains(q) ||
//         s.city.toLowerCase().contains(q) ||
//         s.contactPerson.toLowerCase().contains(q)).toList();
//   }
//
//   Future<void> load() async {
//     if (state == AdminLoadState.loading) return;
//     state = AdminLoadState.loading; notifyListeners();
//     _sub?.cancel();
//     _sub = FirebaseFirestore.instance.collection('suppliers').snapshots().listen(
//           (snap) {
//         if (snap.docs.isNotEmpty) {
//           _all = snap.docs.map((d) => _docToSupplier({'id': d.id, ...d.data()})).toList();
//         } else {
//           _all = _seedSuppliers();
//         }
//         state = AdminLoadState.loaded; notifyListeners();
//       },
//       onError: (_) { _all = _seedSuppliers(); state = AdminLoadState.loaded; notifyListeners(); },
//     );
//   }
//
//   Future<void> add(AdminSupplier s) async {
//     try {
//       await FirebaseFirestore.instance.collection('suppliers').add({
//         'name': s.name, 'contactPerson': s.contactPerson, 'phone': s.phone,
//         'email': s.email, 'city': s.city, 'address': s.address,
//         'suppliedCategories': s.categories, 'isActive': s.isActive,
//         'totalOrders': 0, 'totalSpend': 0.0,
//         'createdAt': FieldValue.serverTimestamp(),
//       });
//     } catch (_) { _all.insert(0, s); notifyListeners(); }
//   }
//
//   Future<void> update(AdminSupplier s) async {
//     try {
//       await FirebaseFirestore.instance.collection('suppliers').doc(s.id).update({
//         'name': s.name, 'contactPerson': s.contactPerson, 'phone': s.phone,
//         'email': s.email, 'city': s.city, 'address': s.address,
//         'suppliedCategories': s.categories, 'isActive': s.isActive,
//         'updatedAt': FieldValue.serverTimestamp(),
//       });
//     } catch (_) {
//       final i = _all.indexWhere((x) => x.id == s.id);
//       if (i != -1) { _all[i] = s; notifyListeners(); }
//     }
//   }
//
//   Future<void> delete(String id) async {
//     try {
//       await FirebaseFirestore.instance.collection('suppliers').doc(id).delete();
//     } catch (_) { _all.removeWhere((s) => s.id == id); notifyListeners(); }
//   }
//
//   void setSearch(String q) { searchQuery = q; notifyListeners(); }
//
//   AdminSupplier _docToSupplier(Map<String, dynamic> d) => AdminSupplier(
//     id: d['id'] as String? ?? '',
//     name: d['name'] as String? ?? '',
//     contactPerson: d['contactPerson'] as String? ?? '',
//     phone: d['phone'] as String? ?? '',
//     email: d['email'] as String? ?? '',
//     city: d['city'] as String? ?? '',
//     address: d['address'] as String? ?? '',
//     categories: List<String>.from(d['suppliedCategories'] as List? ?? []),
//     totalOrders: (d['totalOrders'] as num? ?? 0).toInt(),
//     totalSpend: (d['totalSpend'] as num? ?? 0).toDouble(),
//     isActive: d['isActive'] as bool? ?? true,
//   );
//
//   static List<AdminSupplier> _seedSuppliers() => [
//     AdminSupplier(id:'SUP-01',name:'HoloTech Pvt Ltd',contactPerson:'Ramesh Kumar',phone:'+91 98765 43210',email:'ramesh@holotech.in',city:'Mumbai',address:'14 Andheri East',categories:['Holograms'],totalOrders:24,totalSpend:324600,isActive:true),
//     AdminSupplier(id:'SUP-02',name:'LabelMaster India',contactPerson:'Kavita Sharma',phone:'+91 87654 32109',email:'kvt@labelmaster.in',city:'Surat',address:'Ring Road, Surat',categories:['Labels'],totalOrders:18,totalSpend:98200,isActive:true),
//   ];
//
//   @override
//   void dispose() { _sub?.cancel(); super.dispose(); }
// }
//
// class AdminSupplier {
//   final String id, name, contactPerson, phone, email, city, address;
//   final List<String> categories;
//   final int totalOrders;
//   final double totalSpend;
//   final bool isActive;
//   AdminSupplier({required this.id, required this.name, required this.contactPerson,
//     required this.phone, required this.email, required this.city, required this.address,
//     required this.categories, required this.totalOrders, required this.totalSpend, required this.isActive});
//   AdminSupplier copyWith({String? name, String? contactPerson, String? phone,
//     String? email, String? city, String? address, bool? isActive}) => AdminSupplier(
//     id: id, name: name ?? this.name, contactPerson: contactPerson ?? this.contactPerson,
//     phone: phone ?? this.phone, email: email ?? this.email, city: city ?? this.city,
//     address: address ?? this.address, categories: categories, totalOrders: totalOrders,
//     totalSpend: totalSpend, isActive: isActive ?? this.isActive,
//   );
// }
//
// // ════════════════════════════════════════════════════════════════════
// //  7. TRANSFERS PROVIDER
// // ════════════════════════════════════════════════════════════════════
// class AdminTransferProvider extends ChangeNotifier {
//   AdminLoadState state = AdminLoadState.idle;
//   List<AdminTransfer> _all = [];
//   StreamSubscription? _sub;
//   List<AdminTransfer> get all => _all;
//
//   Future<void> load() async {
//     if (state == AdminLoadState.loading) return;
//     state = AdminLoadState.loading; notifyListeners();
//     _sub?.cancel();
//     _sub = FirebaseFirestore.instance.collection('stock_transfers').snapshots().listen(
//           (snap) {
//         if (snap.docs.isNotEmpty) {
//           _all = snap.docs.map((d) => _docToTransfer({'id': d.id, ...d.data()})).toList();
//         } else {
//           _all = _seedTransfers();
//         }
//         state = AdminLoadState.loaded; notifyListeners();
//       },
//       onError: (_) { _all = _seedTransfers(); state = AdminLoadState.loaded; notifyListeners(); },
//     );
//   }
//
//   Future<void> add(AdminTransfer t) async {
//     try {
//       await FirebaseFirestore.instance.collection('stock_transfers').add({
//         'productName': t.productName, 'fromLocation': t.fromLocation,
//         'toLocation': t.toLocation, 'quantity': t.quantity,
//         'status': 'In Transit', 'initiatedBy': t.initiatedBy,
//         'date': FieldValue.serverTimestamp(),
//       });
//     } catch (_) { _all.insert(0, t); notifyListeners(); }
//   }
//
//   AdminTransfer _docToTransfer(Map<String, dynamic> d) => AdminTransfer(
//     id: d['id'] as String? ?? '',
//     productName: d['productName'] as String? ?? '',
//     fromLocation: d['fromLocation'] as String? ?? '',
//     toLocation: d['toLocation'] as String? ?? '',
//     quantity: (d['quantity'] as num? ?? 0).toInt(),
//     date: (d['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
//     initiatedBy: d['initiatedBy'] as String? ?? 'Admin',
//     status: d['status'] as String? ?? 'In Transit',
//   );
//
//   static List<AdminTransfer> _seedTransfers() => [
//     AdminTransfer(id:'ST-201',productName:'Hologram Security Sticker',fromLocation:'Main Warehouse',toLocation:'Outlet - Gandhinagar',quantity:200,date:DateTime(2026,3,13),initiatedBy:'Admin',status:'Completed'),
//     AdminTransfer(id:'ST-202',productName:'Tamper-Evident Seal',fromLocation:'Main Warehouse',toLocation:'Outlet - Ahmedabad',quantity:500,date:DateTime(2026,3,12),initiatedBy:'Manager',status:'In Transit'),
//   ];
//
//   @override
//   void dispose() { _sub?.cancel(); super.dispose(); }
// }
//
// class AdminTransfer {
//   final String id, productName, fromLocation, toLocation, initiatedBy, status;
//   final int quantity;
//   final DateTime date;
//   AdminTransfer({required this.id, required this.productName, required this.fromLocation,
//     required this.toLocation, required this.quantity, required this.date,
//     required this.initiatedBy, required this.status});
// }
//
// // ════════════════════════════════════════════════════════════════════
// //  8. PROFILE PROVIDER
// // ════════════════════════════════════════════════════════════════════
// class AdminProfileProvider extends ChangeNotifier {
//   String name = 'Admin';
//   String email = 'admin@smartstock.com';
//   String role = 'Super Admin';
//   String id = 'ADM-001';
//
//   Future<void> loadProfile(String uid) async {
//     try {
//       final doc = await FirebaseFirestore.instance.collection('admins').doc(uid).get();
//       if (doc.exists) {
//         name  = doc.data()?['name']  as String? ?? 'Admin';
//         email = doc.data()?['email'] as String? ?? 'admin@smartstock.com';
//         role  = doc.data()?['role']  as String? ?? 'Super Admin';
//         id = doc.id;
//         notifyListeners();
//       }
//     } catch (_) {}
//   }
//
//   void updateProfile({String? name, String? email}) {
//     if (name != null) this.name = name;
//     if (email != null) this.email = email;
//     notifyListeners();
//   }
// }