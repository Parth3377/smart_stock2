// ═══════════════════════════════════════════════════════════════════
//  SmartStock Admin — All Models
// ═══════════════════════════════════════════════════════════════════

// ── Product ─────────────────────────────────────────────────────────
class ProductModel {
  final String id;
  final String name;
  final String sku;
  final String category;
  final double price;
  final int stock;
  final int minStock;
  final String? imageUrl;
  final String supplierId;
  final DateTime createdAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.price,
    required this.stock,
    this.minStock = 10,
    this.imageUrl,
    required this.supplierId,
    required this.createdAt,
  });

  String get stockStatus {
    if (stock == 0) return 'Out of Stock';
    if (stock < minStock) return 'Low Stock';
    return 'In Stock';
  }

  ProductModel copyWith({
    String? name, String? sku, String? category,
    double? price, int? stock, int? minStock,
    String? imageUrl, String? supplierId,
  }) => ProductModel(
    id: id,
    name: name ?? this.name,
    sku: sku ?? this.sku,
    category: category ?? this.category,
    price: price ?? this.price,
    stock: stock ?? this.stock,
    minStock: minStock ?? this.minStock,
    imageUrl: imageUrl ?? this.imageUrl,
    supplierId: supplierId ?? this.supplierId,
    createdAt: createdAt,
  );

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'sku': sku, 'category': category,
    'price': price, 'stock': stock, 'minStock': minStock,
    'imageUrl': imageUrl, 'supplierId': supplierId,
    'createdAt': createdAt.toIso8601String(),
  };

  factory ProductModel.fromMap(Map<String, dynamic> m) => ProductModel(
    id: m['id'], name: m['name'], sku: m['sku'],
    category: m['category'], price: (m['price'] as num).toDouble(),
    stock: m['stock'], minStock: m['minStock'] ?? 10,
    imageUrl: m['imageUrl'], supplierId: m['supplierId'] ?? '',
    createdAt: DateTime.tryParse(m['createdAt'] ?? '') ?? DateTime.now(),
  );
}

// ── Order / Sale ────────────────────────────────────────────────────
class OrderModel {
  final String id;
  final String customerId;
  final String customerName;
  final List<OrderItem> items;
  final double totalAmount;
  final String status; // Delivered | Pending | Cancelled
  final String paymentMethod; // UPI | Card | Cash | NEFT
  final DateTime date;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.paymentMethod,
    required this.date,
  });

  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);

  OrderModel copyWith({String? status}) => OrderModel(
    id: id, customerId: customerId, customerName: customerName,
    items: items, totalAmount: totalAmount,
    status: status ?? this.status,
    paymentMethod: paymentMethod, date: date,
  );

  Map<String, dynamic> toMap() => {
    'id': id, 'customerId': customerId, 'customerName': customerName,
    'items': items.map((i) => i.toMap()).toList(),
    'totalAmount': totalAmount, 'status': status,
    'paymentMethod': paymentMethod, 'date': date.toIso8601String(),
  };

  factory OrderModel.fromMap(Map<String, dynamic> m) => OrderModel(
    id: m['id'], customerId: m['customerId'],
    customerName: m['customerName'],
    items: (m['items'] as List? ?? []).map((i) => OrderItem.fromMap(i)).toList(),
    totalAmount: (m['totalAmount'] as num).toDouble(),
    status: m['status'], paymentMethod: m['paymentMethod'],
    date: DateTime.tryParse(m['date'] ?? '') ?? DateTime.now(),
  );
}

class OrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;

  OrderItem({required this.productId, required this.productName, required this.quantity, required this.unitPrice});
  double get subtotal => quantity * unitPrice;

  Map<String, dynamic> toMap() => {'productId': productId, 'productName': productName, 'quantity': quantity, 'unitPrice': unitPrice};
  factory OrderItem.fromMap(Map<String, dynamic> m) => OrderItem(productId: m['productId'], productName: m['productName'], quantity: m['quantity'], unitPrice: (m['unitPrice'] as num).toDouble());
}

// ── Purchase Order ──────────────────────────────────────────────────
class PurchaseModel {
  final String id;
  final String supplierId;
  final String supplierName;
  final List<OrderItem> items;
  final double totalAmount;
  final String status;
  final DateTime orderDate;
  final DateTime expectedDelivery;

  PurchaseModel({
    required this.id, required this.supplierId, required this.supplierName,
    required this.items, required this.totalAmount, required this.status,
    required this.orderDate, required this.expectedDelivery,
  });

  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);
}

// ── Supplier ────────────────────────────────────────────────────────
class SupplierModel {
  final String id;
  final String name;
  final String contactPerson;
  final String phone;
  final String email;
  final String city;
  final String address;
  final List<String> suppliedCategories;
  final bool isActive;
  final int totalOrders;
  final double totalSpend;

  SupplierModel({
    required this.id, required this.name, required this.contactPerson,
    required this.phone, required this.email, required this.city,
    required this.address, required this.suppliedCategories,
    this.isActive = true, this.totalOrders = 0, this.totalSpend = 0,
  });

  SupplierModel copyWith({
    String? name, String? contactPerson, String? phone,
    String? email, String? city, String? address,
    List<String>? suppliedCategories, bool? isActive,
  }) => SupplierModel(
    id: id,
    name: name ?? this.name,
    contactPerson: contactPerson ?? this.contactPerson,
    phone: phone ?? this.phone,
    email: email ?? this.email,
    city: city ?? this.city,
    address: address ?? this.address,
    suppliedCategories: suppliedCategories ?? this.suppliedCategories,
    isActive: isActive ?? this.isActive,
    totalOrders: totalOrders,
    totalSpend: totalSpend,
  );
}

// ── Stock Transfer ──────────────────────────────────────────────────
class StockTransferModel {
  final String id;
  final String productId;
  final String productName;
  final String fromLocation;
  final String toLocation;
  final int quantity;
  final DateTime date;
  final String initiatedBy;
  final String status; // Completed | In Transit | Cancelled

  StockTransferModel({
    required this.id, required this.productId, required this.productName,
    required this.fromLocation, required this.toLocation,
    required this.quantity, required this.date,
    required this.initiatedBy, required this.status,
  });
}

// ── Customer ────────────────────────────────────────────────────────
class CustomerModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String city;
  final int totalOrders;
  final double totalSpend;
  final DateTime joinedAt;

  CustomerModel({
    required this.id, required this.name, required this.email,
    required this.phone, required this.city,
    this.totalOrders = 0, this.totalSpend = 0,
    required this.joinedAt,
  });
}

// ── Admin Profile ───────────────────────────────────────────────────
class AdminProfile {
  final String id;
  String name;
  String email;
  final String role;
  String? photoUrl;

  AdminProfile({required this.id, required this.name, required this.email, required this.role, this.photoUrl});
}

// ── Dashboard Stats ─────────────────────────────────────────────────
class DashboardStats {
  final double totalRevenue;
  final double prevRevenue;
  final int totalOrders;
  final int prevOrders;
  final int totalProducts;
  final int prevProducts;
  final int totalCustomers;
  final int prevCustomers;
  final List<MonthlyData> monthlyRevenue;
  final List<MonthlyData> monthlyCost;
  final List<CategoryData> categoryData;

  DashboardStats({
    required this.totalRevenue, required this.prevRevenue,
    required this.totalOrders, required this.prevOrders,
    required this.totalProducts, required this.prevProducts,
    required this.totalCustomers, required this.prevCustomers,
    required this.monthlyRevenue, required this.monthlyCost,
    required this.categoryData,
  });

  double get revenueChange => prevRevenue == 0 ? 0 : ((totalRevenue - prevRevenue) / prevRevenue * 100);
  double get ordersChange => prevOrders == 0 ? 0 : ((totalOrders - prevOrders) / prevOrders * 100);
  double get productsChange => prevProducts == 0 ? 0 : ((totalProducts - prevProducts) / prevProducts * 100);
  double get customersChange => prevCustomers == 0 ? 0 : ((totalCustomers - prevCustomers) / prevCustomers * 100);
}

class MonthlyData {
  final String month;
  final double value;
  MonthlyData(this.month, this.value);
}

class CategoryData {
  final String name;
  final double percentage;
  final double revenue;
  CategoryData(this.name, this.percentage, this.revenue);
}