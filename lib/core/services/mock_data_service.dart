import 'dart:async';
import '../models/models.dart';

// ═══════════════════════════════════════════════════════════════════
//  MockDataService  –  Simulates REST API / Firestore responses
//  Replace each method body with real http.get() / FirebaseFirestore
//  calls when you connect a real backend.
// ═══════════════════════════════════════════════════════════════════

class MockDataService {
  static final MockDataService _i = MockDataService._();
  factory MockDataService() => _i;
  MockDataService._();

  // ── In-memory stores (mimics a DB table) ────────────────────────
  final List<ProductModel> _products = _seedProducts();
  final List<OrderModel> _orders = _seedOrders();
  final List<PurchaseModel> _purchases = _seedPurchases();
  final List<SupplierModel> _suppliers = _seedSuppliers();
  final List<StockTransferModel> _transfers = _seedTransfers();
  final List<CustomerModel> _customers = _seedCustomers();

  // ── PRODUCTS ────────────────────────────────────────────────────
  Future<List<ProductModel>> getProducts() async {
    await _delay();
    return List.from(_products);
  }

  Future<void> addProduct(ProductModel p) async {
    await _delay();
    _products.add(p);
  }

  Future<void> updateProduct(ProductModel p) async {
    await _delay();
    final idx = _products.indexWhere((x) => x.id == p.id);
    if (idx != -1) _products[idx] = p;
  }

  Future<void> deleteProduct(String id) async {
    await _delay();
    _products.removeWhere((p) => p.id == id);
  }

  // ── ORDERS ──────────────────────────────────────────────────────
  Future<List<OrderModel>> getOrders() async {
    await _delay();
    return List.from(_orders);
  }

  Future<void> addOrder(OrderModel o) async {
    await _delay();
    _orders.insert(0, o);
    // deduct stock
    for (final item in o.items) {
      final idx = _products.indexWhere((p) => p.id == item.productId);
      if (idx != -1) {
        _products[idx] = _products[idx].copyWith(
          stock: (_products[idx].stock - item.quantity).clamp(0, 99999),
        );
      }
    }
  }

  Future<void> updateOrderStatus(String id, String status) async {
    await _delay();
    final idx = _orders.indexWhere((o) => o.id == id);
    if (idx != -1) _orders[idx] = _orders[idx].copyWith(status: status);
  }

  // ── PURCHASES ───────────────────────────────────────────────────
  Future<List<PurchaseModel>> getPurchases() async {
    await _delay();
    return List.from(_purchases);
  }

  // ── SUPPLIERS ───────────────────────────────────────────────────
  Future<List<SupplierModel>> getSuppliers() async {
    await _delay();
    return List.from(_suppliers);
  }

  Future<void> addSupplier(SupplierModel s) async {
    await _delay();
    _suppliers.add(s);
  }

  Future<void> updateSupplier(SupplierModel s) async {
    await _delay();
    final idx = _suppliers.indexWhere((x) => x.id == s.id);
    if (idx != -1) _suppliers[idx] = s;
  }

  Future<void> deleteSupplier(String id) async {
    await _delay();
    _suppliers.removeWhere((s) => s.id == id);
  }

  // ── STOCK TRANSFERS ─────────────────────────────────────────────
  Future<List<StockTransferModel>> getTransfers() async {
    await _delay();
    return List.from(_transfers);
  }

  Future<void> addTransfer(StockTransferModel t) async {
    await _delay();
    _transfers.insert(0, t);
  }

  // ── CUSTOMERS ───────────────────────────────────────────────────
  Future<List<CustomerModel>> getCustomers() async {
    await _delay();
    return List.from(_customers);
  }

  // ── DASHBOARD ───────────────────────────────────────────────────
  Future<DashboardStats> getDashboardStats() async {
    await _delay();
    final deliveredOrders = _orders.where((o) => o.status == 'Delivered');
    final totalRevenue = deliveredOrders.fold(0.0, (s, o) => s + o.totalAmount);

    return DashboardStats(
      totalRevenue: totalRevenue,
      prevRevenue: totalRevenue * 0.88,
      totalOrders: _orders.length,
      prevOrders: (_orders.length * 0.92).round(),
      totalProducts: _products.length,
      prevProducts: (_products.length * 1.03).round(),
      totalCustomers: _customers.length,
      prevCustomers: (_customers.length * 0.95).round(),
      monthlyRevenue: _monthlyRevenue(),
      monthlyCost: _monthlyCost(),
      categoryData: _categoryData(),
    );
  }

  List<MonthlyData> _monthlyRevenue() => [
    MonthlyData('Jan', 42000), MonthlyData('Feb', 67000),
    MonthlyData('Mar', 58000), MonthlyData('Apr', 80000),
    MonthlyData('May', 75000), MonthlyData('Jun', 92000),
    MonthlyData('Jul', 88000), MonthlyData('Aug', 105000),
    MonthlyData('Sep', 97000), MonthlyData('Oct', 120000),
    MonthlyData('Nov', 115000), MonthlyData('Dec', 124890),
  ];

  List<MonthlyData> _monthlyCost() => [
    MonthlyData('Jan', 28000), MonthlyData('Feb', 44000),
    MonthlyData('Mar', 39000), MonthlyData('Apr', 55000),
    MonthlyData('May', 50000), MonthlyData('Jun', 64000),
    MonthlyData('Jul', 60000), MonthlyData('Aug', 72000),
    MonthlyData('Sep', 66000), MonthlyData('Oct', 84000),
    MonthlyData('Nov', 79000), MonthlyData('Dec', 88000),
  ];

  List<CategoryData> _categoryData() => [
    CategoryData('Electronics', 38, 47450),
    CategoryData('Clothing', 27, 33720),
    CategoryData('Grocery', 21, 26227),
    CategoryData('Accessories', 10, 12489),
    CategoryData('Home', 4, 4995),
  ];

  Future<void> _delay([int ms = 400]) => Future.delayed(Duration(milliseconds: ms));
}

// ── Seed Data ───────────────────────────────────────────────────────

List<ProductModel> _seedProducts() => [
  ProductModel(id: 'P001', name: 'iPhone 15 Pro Case', sku: 'ACC-001', category: 'Accessories', price: 899, stock: 4, minStock: 10, supplierId: 'SUP-01', createdAt: DateTime(2025, 1, 15)),
  ProductModel(id: 'P002', name: 'Samsung Galaxy S24', sku: 'ELE-012', category: 'Electronics', price: 74999, stock: 28, supplierId: 'SUP-04', createdAt: DateTime(2025, 2, 10)),
  ProductModel(id: 'P003', name: "Men's Casual Shirt", sku: 'CLO-023', category: 'Clothing', price: 1299, stock: 0, supplierId: 'SUP-02', createdAt: DateTime(2025, 1, 20)),
  ProductModel(id: 'P004', name: 'USB-C Cable 2m', sku: 'CAB-012', category: 'Accessories', price: 499, stock: 2, minStock: 15, supplierId: 'SUP-06', createdAt: DateTime(2025, 3, 5)),
  ProductModel(id: 'P005', name: 'Basmati Rice 5kg', sku: 'GRO-034', category: 'Grocery', price: 650, stock: 142, supplierId: 'SUP-03', createdAt: DateTime(2025, 1, 8)),
  ProductModel(id: 'P006', name: 'Wireless Earbuds', sku: 'AUD-004', category: 'Electronics', price: 3499, stock: 6, minStock: 20, supplierId: 'SUP-04', createdAt: DateTime(2025, 2, 18)),
  ProductModel(id: 'P007', name: 'Yoga Mat Premium', sku: 'HOM-056', category: 'Home', price: 1100, stock: 34, supplierId: 'SUP-05', createdAt: DateTime(2025, 3, 1)),
  ProductModel(id: 'P008', name: 'LED Desk Lamp', sku: 'HOM-057', category: 'Home', price: 799, stock: 19, supplierId: 'SUP-05', createdAt: DateTime(2025, 2, 25)),
  ProductModel(id: 'P009', name: 'Atta 10kg Pack', sku: 'GRO-035', category: 'Grocery', price: 540, stock: 88, supplierId: 'SUP-03', createdAt: DateTime(2025, 1, 12)),
  ProductModel(id: 'P010', name: 'Screen Protector', sku: 'ACC-008', category: 'Accessories', price: 299, stock: 1, minStock: 10, supplierId: 'SUP-01', createdAt: DateTime(2025, 3, 10)),
  ProductModel(id: 'P011', name: 'Smart Watch Series 8', sku: 'ELE-020', category: 'Electronics', price: 24999, stock: 12, supplierId: 'SUP-04', createdAt: DateTime(2025, 2, 5)),
  ProductModel(id: 'P012', name: 'Cotton Kurti Set', sku: 'CLO-031', category: 'Clothing', price: 1599, stock: 45, supplierId: 'SUP-02', createdAt: DateTime(2025, 1, 22)),
];

List<CustomerModel> _seedCustomers() => [
  CustomerModel(id: 'C001', name: 'Rahul Mehta', email: 'rahul@email.com', phone: '+91 98765 43210', city: 'Mumbai', totalOrders: 12, totalSpend: 34200, joinedAt: DateTime(2024, 6, 10)),
  CustomerModel(id: 'C002', name: 'Priya Shah', email: 'priya@email.com', phone: '+91 87654 32109', city: 'Ahmedabad', totalOrders: 8, totalSpend: 18900, joinedAt: DateTime(2024, 8, 5)),
  CustomerModel(id: 'C003', name: 'Amit Patel', email: 'amit@email.com', phone: '+91 76543 21098', city: 'Gandhinagar', totalOrders: 21, totalSpend: 67350, joinedAt: DateTime(2024, 3, 15)),
  CustomerModel(id: 'C004', name: 'Sunita Rao', email: 'sunita@email.com', phone: '+91 65432 10987', city: 'Bangalore', totalOrders: 5, totalSpend: 9200, joinedAt: DateTime(2024, 11, 1)),
  CustomerModel(id: 'C005', name: 'Vikram Joshi', email: 'vikram@email.com', phone: '+91 54321 09876', city: 'Pune', totalOrders: 15, totalSpend: 43600, joinedAt: DateTime(2024, 5, 20)),
  CustomerModel(id: 'C006', name: 'Meena Gupta', email: 'meena@email.com', phone: '+91 43210 98765', city: 'Delhi', totalOrders: 9, totalSpend: 21000, joinedAt: DateTime(2024, 7, 12)),
];

List<OrderModel> _seedOrders() => [
  OrderModel(id: 'SO-1041', customerId: 'C001', customerName: 'Rahul Mehta', items: [OrderItem(productId: 'P002', productName: 'Samsung Galaxy S24', quantity: 1, unitPrice: 74999)], totalAmount: 4200, status: 'Delivered', paymentMethod: 'UPI', date: DateTime(2026, 3, 13)),
  OrderModel(id: 'SO-1042', customerId: 'C002', customerName: 'Priya Shah', items: [OrderItem(productId: 'P006', productName: 'Wireless Earbuds', quantity: 1, unitPrice: 3499)], totalAmount: 1890, status: 'Pending', paymentMethod: 'Card', date: DateTime(2026, 3, 13)),
  OrderModel(id: 'SO-1043', customerId: 'C003', customerName: 'Amit Patel', items: [OrderItem(productId: 'P011', productName: 'Smart Watch Series 8', quantity: 1, unitPrice: 24999)], totalAmount: 7350, status: 'Delivered', paymentMethod: 'Cash', date: DateTime(2026, 3, 12)),
  OrderModel(id: 'SO-1044', customerId: 'C004', customerName: 'Sunita Rao', items: [OrderItem(productId: 'P001', productName: 'iPhone 15 Pro Case', quantity: 1, unitPrice: 899)], totalAmount: 920, status: 'Cancelled', paymentMethod: 'UPI', date: DateTime(2026, 3, 12)),
  OrderModel(id: 'SO-1045', customerId: 'C005', customerName: 'Vikram Joshi', items: [OrderItem(productId: 'P007', productName: 'Yoga Mat Premium', quantity: 2, unitPrice: 1100)], totalAmount: 3600, status: 'Pending', paymentMethod: 'Card', date: DateTime(2026, 3, 11)),
  OrderModel(id: 'SO-1046', customerId: 'C006', customerName: 'Meena Gupta', items: [OrderItem(productId: 'P008', productName: 'LED Desk Lamp', quantity: 2, unitPrice: 799)], totalAmount: 2100, status: 'Delivered', paymentMethod: 'UPI', date: DateTime(2026, 3, 11)),
  OrderModel(id: 'SO-1047', customerId: 'C003', customerName: 'Amit Patel', items: [OrderItem(productId: 'P005', productName: 'Basmati Rice 5kg', quantity: 6, unitPrice: 650)], totalAmount: 9800, status: 'Delivered', paymentMethod: 'NEFT', date: DateTime(2026, 3, 10)),
];

List<PurchaseModel> _seedPurchases() => [
  PurchaseModel(id: 'PO-501', supplierId: 'SUP-01', supplierName: 'TechZone Pvt Ltd', items: [OrderItem(productId: 'P002', productName: 'Samsung Galaxy S24', quantity: 10, unitPrice: 65000)], totalAmount: 54600, status: 'Delivered', orderDate: DateTime(2026, 3, 12), expectedDelivery: DateTime(2026, 3, 15)),
  PurchaseModel(id: 'PO-502', supplierId: 'SUP-02', supplierName: 'FashionHub India', items: [OrderItem(productId: 'P003', productName: "Men's Casual Shirt", quantity: 30, unitPrice: 700)], totalAmount: 21000, status: 'Pending', orderDate: DateTime(2026, 3, 11), expectedDelivery: DateTime(2026, 3, 17)),
  PurchaseModel(id: 'PO-503', supplierId: 'SUP-03', supplierName: 'GrocerSupplies Co.', items: [OrderItem(productId: 'P005', productName: 'Basmati Rice 5kg', quantity: 50, unitPrice: 178)], totalAmount: 8900, status: 'Delivered', orderDate: DateTime(2026, 3, 10), expectedDelivery: DateTime(2026, 3, 14)),
  PurchaseModel(id: 'PO-504', supplierId: 'SUP-04', supplierName: 'ElectroWholesale', items: [OrderItem(productId: 'P011', productName: 'Smart Watch Series 8', quantity: 8, unitPrice: 16775)], totalAmount: 134200, status: 'Pending', orderDate: DateTime(2026, 3, 9), expectedDelivery: DateTime(2026, 3, 20)),
];

List<SupplierModel> _seedSuppliers() => [
  SupplierModel(id: 'SUP-01', name: 'TechZone Pvt Ltd', contactPerson: 'Ramesh Kumar', phone: '+91 98765 43210', email: 'ramesh@techzone.in', city: 'Mumbai', address: '14 Andheri East, Mumbai 400069', suppliedCategories: ['Electronics', 'Accessories'], totalOrders: 24, totalSpend: 324600),
  SupplierModel(id: 'SUP-02', name: 'FashionHub India', contactPerson: 'Kavita Sharma', phone: '+91 87654 32109', email: 'kvt@fashionhub.in', city: 'Surat', address: 'Ring Road, Surat 395002', suppliedCategories: ['Clothing'], totalOrders: 18, totalSpend: 98200),
  SupplierModel(id: 'SUP-03', name: 'GrocerSupplies Co.', contactPerson: 'Ramji Patel', phone: '+91 76543 21098', email: 'info@grocersupplies.com', city: 'Ahmedabad', address: 'APMC Yard, Ahmedabad', suppliedCategories: ['Grocery'], totalOrders: 42, totalSpend: 145900),
  SupplierModel(id: 'SUP-04', name: 'ElectroWholesale', contactPerson: 'Suresh Mehta', phone: '+91 65432 10987', email: 's.mehta@electrow.in', city: 'Delhi', address: 'Lajpat Nagar, Delhi 110024', suppliedCategories: ['Electronics'], isActive: false, totalOrders: 9, totalSpend: 560000),
  SupplierModel(id: 'SUP-05', name: 'HomeGoods Ltd', contactPerson: 'Anjali Desai', phone: '+91 54321 09876', email: 'anjali@homegoods.in', city: 'Pune', address: 'FC Road, Pune 411004', suppliedCategories: ['Home'], totalOrders: 15, totalSpend: 62400),
  SupplierModel(id: 'SUP-06', name: 'CableKing', contactPerson: 'Vinod Chauhan', phone: '+91 43210 98765', email: 'info@cableking.com', city: 'Jaipur', address: 'M.I. Road, Jaipur 302001', suppliedCategories: ['Accessories'], totalOrders: 6, totalSpend: 22000),
];

List<StockTransferModel> _seedTransfers() => [
  StockTransferModel(id: 'ST-201', productId: 'P001', productName: 'iPhone 15 Pro Case', fromLocation: 'Main Warehouse', toLocation: 'Outlet - Gandhinagar', quantity: 20, date: DateTime(2026, 3, 13), initiatedBy: 'Admin', status: 'Completed'),
  StockTransferModel(id: 'ST-202', productId: 'P004', productName: 'USB-C Cable 2m', fromLocation: 'Main Warehouse', toLocation: 'Outlet - Ahmedabad', quantity: 50, date: DateTime(2026, 3, 12), initiatedBy: 'Manager', status: 'In Transit'),
  StockTransferModel(id: 'ST-203', productId: 'P006', productName: 'Wireless Earbuds', fromLocation: 'Outlet - Surat', toLocation: 'Main Warehouse', quantity: 10, date: DateTime(2026, 3, 12), initiatedBy: 'Admin', status: 'Completed'),
  StockTransferModel(id: 'ST-204', productId: 'P005', productName: 'Basmati Rice 5kg', fromLocation: 'Main Warehouse', toLocation: 'Outlet - Vadodara', quantity: 100, date: DateTime(2026, 3, 11), initiatedBy: 'Manager', status: 'In Transit'),
  StockTransferModel(id: 'ST-205', productId: 'P010', productName: 'Screen Protector', fromLocation: 'Outlet - Ahmedabad', toLocation: 'Outlet - Gandhinagar', quantity: 15, date: DateTime(2026, 3, 10), initiatedBy: 'Admin', status: 'Completed'),
  StockTransferModel(id: 'ST-206', productId: 'P008', productName: 'LED Desk Lamp', fromLocation: 'Main Warehouse', toLocation: 'Outlet - Surat', quantity: 8, date: DateTime(2026, 3, 9), initiatedBy: 'Admin', status: 'Cancelled'),
];