import 'package:flutter/material.dart';

// ════════════════════════════════════════════════════════════════════
//  lib/providers/admin_providers.dart
//
//  All admin-side ChangeNotifier providers in ONE file.
//  You add these to your existing main.dart MultiProvider list.
//  They do NOT interfere with your existing providers at all.
// ════════════════════════════════════════════════════════════════════

// ── Load state enum (admin-only, won't conflict) ─────────────────────
enum AdminLoadState { idle, loading, loaded, error }

// ════════════════════════════════════════════════════════════════════
//  1. AUTH PROVIDER  — decides admin vs client after login
// ════════════════════════════════════════════════════════════════════
class AdminAuthProvider extends ChangeNotifier {
  bool _isAdmin = false;
  String _adminName = '';
  String _adminEmail = '';

  bool get isAdmin => _isAdmin;
  String get adminName => _adminName;
  String get adminEmail => _adminEmail;

  // ── Called from login_screen.dart after successful login ──────────
  void loginAsAdmin(String email) {
    _isAdmin = true;
    _adminEmail = email;
    _adminName = 'Admin';  // Replace with real name from your auth
    notifyListeners();
  }

  void logout() {
    _isAdmin = false;
    _adminEmail = '';
    _adminName = '';
    notifyListeners();
  }
}

// ════════════════════════════════════════════════════════════════════
//  2. ADMIN NAV PROVIDER  — sidebar page selection
// ════════════════════════════════════════════════════════════════════
class AdminNavProvider extends ChangeNotifier {
  int _selectedIndex = 0;
  bool _sidebarExpanded = true;

  int get selectedIndex => _selectedIndex;
  bool get sidebarExpanded => _sidebarExpanded;

  void selectPage(int i) {
    _selectedIndex = i;
    notifyListeners();
  }

  void toggleSidebar() {
    _sidebarExpanded = !_sidebarExpanded;
    notifyListeners();
  }

// Page index map:
// 0=Dashboard  1=Products  2=Sales  3=Purchase
// 4=Suppliers  5=StockTransfer  6=Reports
// 7=Profile    8=Customers  9=RevenueAnalytics
}

// ════════════════════════════════════════════════════════════════════
//  3. ADMIN DASHBOARD PROVIDER  — dashboard stats
// ════════════════════════════════════════════════════════════════════
class AdminDashboardProvider extends ChangeNotifier {
  AdminLoadState state = AdminLoadState.idle;
  AdminDashboardStats? stats;
  String? error;

  Future<void> load() async {
    if (state == AdminLoadState.loading) return;
    state = AdminLoadState.loading;
    notifyListeners();
    try {
      await Future.delayed(const Duration(milliseconds: 600)); // mock delay
      stats = AdminDashboardStats(
        totalRevenue: 124890,
        prevRevenue: 110000,
        totalOrders: 2340,
        prevOrders: 2150,
        totalProducts: 486,
        prevProducts: 500,
        totalCustomers: 1204,
        prevCustomers: 1140,
        monthlyRevenue: _seedMonthlyRevenue(),
        monthlyCost: _seedMonthlyCost(),
        categoryData: _seedCategories(),
      );
      state = AdminLoadState.loaded;
    } catch (e) {
      error = e.toString();
      state = AdminLoadState.error;
    }
    notifyListeners();
  }

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
    AdminCategoryData('Holograms', 38, 47450),
    AdminCategoryData('Stickers', 27, 33720),
    AdminCategoryData('Labels', 21, 26227),
    AdminCategoryData('Security Tags', 10, 12489),
    AdminCategoryData('Other', 4, 4995),
  ];
}

class AdminDashboardStats {
  final double totalRevenue, prevRevenue;
  final int totalOrders, prevOrders, totalProducts, prevProducts, totalCustomers, prevCustomers;
  final List<AdminMonthData> monthlyRevenue, monthlyCost;
  final List<AdminCategoryData> categoryData;

  AdminDashboardStats({
    required this.totalRevenue, required this.prevRevenue,
    required this.totalOrders, required this.prevOrders,
    required this.totalProducts, required this.prevProducts,
    required this.totalCustomers, required this.prevCustomers,
    required this.monthlyRevenue, required this.monthlyCost,
    required this.categoryData,
  });

  double get revenueChange => prevRevenue == 0 ? 0
      : (totalRevenue - prevRevenue) / prevRevenue * 100;
  double get ordersChange => prevOrders == 0 ? 0
      : (totalOrders - prevOrders) / prevOrders * 100;
  double get productsChange => prevProducts == 0 ? 0
      : (totalProducts - prevProducts) / prevProducts * 100;
  double get customersChange => prevCustomers == 0 ? 0
      : (totalCustomers - prevCustomers) / prevCustomers * 100;
}

class AdminMonthData { final String month; final double value;
AdminMonthData(this.month, this.value); }

class AdminCategoryData { final String name; final double percentage; final double revenue;
AdminCategoryData(this.name, this.percentage, this.revenue); }

// ════════════════════════════════════════════════════════════════════
//  4. ADMIN PRODUCTS PROVIDER
// ════════════════════════════════════════════════════════════════════
class AdminProductsProvider extends ChangeNotifier {
  AdminLoadState state = AdminLoadState.idle;
  List<AdminProduct> _all = [];
  List<AdminProduct> get filtered => _applyFilters();

  String searchQuery = '';
  String selectedCategory = 'All';
  String sortField = 'name';
  bool sortAsc = true;
  int page = 0;
  static const int pageSize = 10;

  int get totalPages => (filtered.length / pageSize).ceil().clamp(1, 999);
  List<AdminProduct> get currentPage {
    final start = page * pageSize;
    final end = (start + pageSize).clamp(0, filtered.length);
    return filtered.sublist(start, end);
  }

  List<AdminProduct> get lowStockItems =>
      _all.where((p) => p.stock > 0 && p.stock < p.minStock).toList();
  List<AdminProduct> get outOfStockItems =>
      _all.where((p) => p.stock == 0).toList();
  List<String> get categories =>
      ['All', ...{..._all.map((p) => p.category)}];

  Future<void> load() async {
    if (state == AdminLoadState.loading) return;
    state = AdminLoadState.loading; notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    _all = _seedProducts();
    state = AdminLoadState.loaded; notifyListeners();
  }

  Future<void> add(AdminProduct p) async {
    _all.insert(0, p); notifyListeners();
  }

  Future<void> update(AdminProduct p) async {
    final i = _all.indexWhere((x) => x.id == p.id);
    if (i != -1) { _all[i] = p; notifyListeners(); }
  }

  Future<void> delete(String id) async {
    _all.removeWhere((p) => p.id == id); notifyListeners();
  }

  void setSearch(String q) { searchQuery = q; page = 0; notifyListeners(); }
  void setCategory(String c) { selectedCategory = c; page = 0; notifyListeners(); }
  void setSort(String f) {
    if (sortField == f) sortAsc = !sortAsc;
    else { sortField = f; sortAsc = true; }
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
        case 'name': cmp = a.name.compareTo(b.name); break;
        case 'price': cmp = a.price.compareTo(b.price); break;
        case 'stock': cmp = a.stock.compareTo(b.stock); break;
        case 'category': cmp = a.category.compareTo(b.category); break;
      }
      return sortAsc ? cmp : -cmp;
    });
    return list;
  }

  static List<AdminProduct> _seedProducts() => [
    AdminProduct(id:'P001',name:'Hologram Security Sticker',sku:'HOL-001',category:'Holograms',price:8.50,stock:4,minStock:20),
    AdminProduct(id:'P002',name:'Gold Label Roll 100m',sku:'LBL-012',category:'Labels',price:1299,stock:28,minStock:5),
    AdminProduct(id:'P003',name:'Scratch-Off Sticker A4',sku:'STK-023',category:'Stickers',price:450,stock:0,minStock:10),
    AdminProduct(id:'P004',name:'Tamper-Evident Seal',sku:'SEC-012',category:'Security Tags',price:12.99,stock:2,minStock:50),
    AdminProduct(id:'P005',name:'Barcode Label 50x30',sku:'LBL-034',category:'Labels',price:320,stock:142,minStock:30),
    AdminProduct(id:'P006',name:'Prismatic Hologram',sku:'HOL-004',category:'Holograms',price:24.99,stock:6,minStock:20),
    AdminProduct(id:'P007',name:'Custom Logo Sticker',sku:'STK-056',category:'Stickers',price:180,stock:34,minStock:15),
    AdminProduct(id:'P008',name:'RFID Security Tag',sku:'SEC-057',category:'Security Tags',price:45,stock:19,minStock:10),
    AdminProduct(id:'P009',name:'Thermal Label 80x50',sku:'LBL-035',category:'Labels',price:280,stock:88,minStock:20),
    AdminProduct(id:'P010',name:'Silver Hologram Strip',sku:'HOL-008',category:'Holograms',price:6.50,stock:1,minStock:30),
    AdminProduct(id:'P011',name:'Glossy Round Sticker',sku:'STK-020',category:'Stickers',price:95,stock:12,minStock:25),
    AdminProduct(id:'P012',name:'Void Security Label',sku:'SEC-031',category:'Security Tags',price:18.99,stock:45,minStock:20),
  ];
}

class AdminProduct {
  final String id, name, sku, category;
  final double price;
  final int stock, minStock;
  String? imageUrl;

  AdminProduct({
    required this.id, required this.name, required this.sku,
    required this.category, required this.price,
    required this.stock, this.minStock = 10, this.imageUrl,
  });

  String get stockStatus {
    if (stock == 0) return 'Out of Stock';
    if (stock < minStock) return 'Low Stock';
    return 'In Stock';
  }

  AdminProduct copyWith({String? name, String? sku, String? category,
    double? price, int? stock, int? minStock}) => AdminProduct(
    id: id, name: name ?? this.name, sku: sku ?? this.sku,
    category: category ?? this.category, price: price ?? this.price,
    stock: stock ?? this.stock, minStock: minStock ?? this.minStock,
  );
}

// ════════════════════════════════════════════════════════════════════
//  5. ADMIN ORDERS PROVIDER
// ════════════════════════════════════════════════════════════════════
class AdminOrdersProvider extends ChangeNotifier {
  AdminLoadState state = AdminLoadState.idle;
  List<AdminOrder> _all = [];
  List<AdminOrder> get filtered => _applyFilters();
  List<AdminOrder> get allOrders => _all;

  String searchQuery = '';
  String statusFilter = 'All';
  int page = 0;
  static const int pageSize = 10;

  int get totalPages => (filtered.length / pageSize).ceil().clamp(1, 999);
  List<AdminOrder> get currentPage {
    final s = page * pageSize;
    final e = (s + pageSize).clamp(0, filtered.length);
    return filtered.sublist(s, e);
  }

  double get totalRevenue => _all
      .where((o) => o.status == 'Delivered')
      .fold(0.0, (s, o) => s + o.totalAmount);

  Future<void> load() async {
    if (state == AdminLoadState.loading) return;
    state = AdminLoadState.loading; notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    _all = _seedOrders();
    state = AdminLoadState.loaded; notifyListeners();
  }

  Future<void> add(AdminOrder o) async { _all.insert(0, o); notifyListeners(); }

  Future<void> updateStatus(String id, String status) async {
    final i = _all.indexWhere((o) => o.id == id);
    if (i != -1) { _all[i] = _all[i].copyWith(status: status); notifyListeners(); }
  }

  void setSearch(String q) { searchQuery = q; page = 0; notifyListeners(); }
  void setStatus(String s) { statusFilter = s; page = 0; notifyListeners(); }
  void setPage(int p) { page = p; notifyListeners(); }

  List<AdminOrder> _applyFilters() => _all.where((o) {
    final q = searchQuery.toLowerCase();
    return (q.isEmpty || o.id.toLowerCase().contains(q) || o.customerName.toLowerCase().contains(q))
        && (statusFilter == 'All' || o.status == statusFilter);
  }).toList();

  static List<AdminOrder> _seedOrders() => [
    AdminOrder(id:'SO-1041',customerName:'Rahul Mehta',items:3,totalAmount:4200,status:'Delivered',paymentMethod:'UPI',date:DateTime(2026,3,13)),
    AdminOrder(id:'SO-1042',customerName:'Priya Shah',items:1,totalAmount:1890,status:'Pending',paymentMethod:'Card',date:DateTime(2026,3,13)),
    AdminOrder(id:'SO-1043',customerName:'Amit Patel',items:5,totalAmount:7350,status:'Delivered',paymentMethod:'Cash',date:DateTime(2026,3,12)),
    AdminOrder(id:'SO-1044',customerName:'Sunita Rao',items:2,totalAmount:920,status:'Cancelled',paymentMethod:'UPI',date:DateTime(2026,3,12)),
    AdminOrder(id:'SO-1045',customerName:'Vikram Joshi',items:4,totalAmount:3600,status:'Pending',paymentMethod:'Card',date:DateTime(2026,3,11)),
    AdminOrder(id:'SO-1046',customerName:'Meena Gupta',items:2,totalAmount:2100,status:'Delivered',paymentMethod:'UPI',date:DateTime(2026,3,11)),
    AdminOrder(id:'SO-1047',customerName:'Dev Trivedi',items:6,totalAmount:9800,status:'Delivered',paymentMethod:'NEFT',date:DateTime(2026,3,10)),
    AdminOrder(id:'SO-1048',customerName:'Anjali Singh',items:1,totalAmount:599,status:'Cancelled',paymentMethod:'Card',date:DateTime(2026,3,10)),
  ];
}

class AdminOrder {
  final String id, customerName, status, paymentMethod;
  final int items;
  final double totalAmount;
  final DateTime date;

  AdminOrder({required this.id, required this.customerName,
    required this.items, required this.totalAmount,
    required this.status, required this.paymentMethod, required this.date});

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
  AdminLoadState state = AdminLoadState.idle;
  List<AdminSupplier> _all = [];
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
    await Future.delayed(const Duration(milliseconds: 400));
    _all = _seedSuppliers();
    state = AdminLoadState.loaded; notifyListeners();
  }

  Future<void> add(AdminSupplier s) async { _all.insert(0, s); notifyListeners(); }
  Future<void> update(AdminSupplier s) async {
    final i = _all.indexWhere((x) => x.id == s.id);
    if (i != -1) { _all[i] = s; notifyListeners(); }
  }
  Future<void> delete(String id) async {
    _all.removeWhere((s) => s.id == id); notifyListeners();
  }
  void setSearch(String q) { searchQuery = q; notifyListeners(); }

  static List<AdminSupplier> _seedSuppliers() => [
    AdminSupplier(id:'SUP-01',name:'HoloTech Pvt Ltd',contactPerson:'Ramesh Kumar',phone:'+91 98765 43210',email:'ramesh@holotech.in',city:'Mumbai',address:'14 Andheri East',categories:['Holograms'],totalOrders:24,totalSpend:324600,isActive:true),
    AdminSupplier(id:'SUP-02',name:'LabelMaster India',contactPerson:'Kavita Sharma',phone:'+91 87654 32109',email:'kvt@labelmaster.in',city:'Surat',address:'Ring Road, Surat',categories:['Labels'],totalOrders:18,totalSpend:98200,isActive:true),
    AdminSupplier(id:'SUP-03',name:'StickerPro Co.',contactPerson:'Ramji Patel',phone:'+91 76543 21098',email:'info@stickerpro.com',city:'Ahmedabad',address:'GIDC, Ahmedabad',categories:['Stickers'],totalOrders:42,totalSpend:145900,isActive:true),
    AdminSupplier(id:'SUP-04',name:'SecureTag Wholesale',contactPerson:'Suresh Mehta',phone:'+91 65432 10987',email:'s.mehta@securetag.in',city:'Delhi',address:'Lajpat Nagar, Delhi',categories:['Security Tags'],totalOrders:9,totalSpend:560000,isActive:false),
  ];
}

class AdminSupplier {
  final String id, name, contactPerson, phone, email, city, address;
  final List<String> categories;
  final int totalOrders;
  final double totalSpend;
  final bool isActive;

  AdminSupplier({required this.id, required this.name, required this.contactPerson,
    required this.phone, required this.email, required this.city, required this.address,
    required this.categories, required this.totalOrders, required this.totalSpend,
    required this.isActive});

  AdminSupplier copyWith({String? name, String? contactPerson, String? phone,
    String? email, String? city, String? address, bool? isActive}) => AdminSupplier(
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
  AdminLoadState state = AdminLoadState.idle;
  List<AdminTransfer> _all = [];
  List<AdminTransfer> get all => _all;

  Future<void> load() async {
    if (state == AdminLoadState.loading) return;
    state = AdminLoadState.loading; notifyListeners();
    await Future.delayed(const Duration(milliseconds: 400));
    _all = _seedTransfers();
    state = AdminLoadState.loaded; notifyListeners();
  }

  Future<void> add(AdminTransfer t) async { _all.insert(0, t); notifyListeners(); }

  static List<AdminTransfer> _seedTransfers() => [
    AdminTransfer(id:'ST-201',productName:'Hologram Security Sticker',fromLocation:'Main Warehouse',toLocation:'Outlet - Gandhinagar',quantity:200,date:DateTime(2026,3,13),initiatedBy:'Admin',status:'Completed'),
    AdminTransfer(id:'ST-202',productName:'Tamper-Evident Seal',fromLocation:'Main Warehouse',toLocation:'Outlet - Ahmedabad',quantity:500,date:DateTime(2026,3,12),initiatedBy:'Manager',status:'In Transit'),
    AdminTransfer(id:'ST-203',productName:'Prismatic Hologram',fromLocation:'Outlet - Surat',toLocation:'Main Warehouse',quantity:100,date:DateTime(2026,3,12),initiatedBy:'Admin',status:'Completed'),
    AdminTransfer(id:'ST-204',productName:'Barcode Label 50x30',fromLocation:'Main Warehouse',toLocation:'Outlet - Vadodara',quantity:1000,date:DateTime(2026,3,11),initiatedBy:'Manager',status:'In Transit'),
    AdminTransfer(id:'ST-205',productName:'Silver Hologram Strip',fromLocation:'Outlet - Ahmedabad',toLocation:'Outlet - Gandhinagar',quantity:150,date:DateTime(2026,3,10),initiatedBy:'Admin',status:'Completed'),
  ];
}

class AdminTransfer {
  final String id, productName, fromLocation, toLocation, initiatedBy, status;
  final int quantity;
  final DateTime date;
  AdminTransfer({required this.id, required this.productName,
    required this.fromLocation, required this.toLocation,
    required this.quantity, required this.date,
    required this.initiatedBy, required this.status});
}

// ════════════════════════════════════════════════════════════════════
//  8. ADMIN PROFILE PROVIDER
// ════════════════════════════════════════════════════════════════════
class AdminProfileProvider extends ChangeNotifier {
  String name = 'Admin';
  String email = 'admin@smartstock.com';
  String role = 'Super Admin';
  String id = 'ADM-001';

  void updateProfile({String? name, String? email}) {
    if (name != null) this.name = name;
    if (email != null) this.email = email;
    notifyListeners();
  }
}