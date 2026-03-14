// ═══════════════════════════════════════════════════════════════════
//  api_service.dart  –  Production-ready service interface
//
//  HOW TO SWITCH FROM MOCK → REAL BACKEND:
//
//  1. Firebase Firestore:
//     Add to pubspec.yaml:
//       firebase_core: ^2.25.4
//       cloud_firestore: ^4.15.5
//       firebase_auth: ^4.17.8
//
//  2. REST API (Node/Laravel):
//     Add to pubspec.yaml:
//       http: ^1.2.1
//       dio: ^5.4.1   (optional, better error handling)
//
//  3. Replace MockDataService() calls in admin_providers.dart with
//     ApiService() — all method signatures are identical.
// ═══════════════════════════════════════════════════════════════════

import '../models/models.dart';

// ─── Abstract interface ─────────────────────────────────────────────
abstract class IDataService {
  Future<List<ProductModel>> getProducts();
  Future<void> addProduct(ProductModel p);
  Future<void> updateProduct(ProductModel p);
  Future<void> deleteProduct(String id);

  Future<List<OrderModel>> getOrders();
  Future<void> addOrder(OrderModel o);
  Future<void> updateOrderStatus(String id, String status);

  Future<List<PurchaseModel>> getPurchases();

  Future<List<SupplierModel>> getSuppliers();
  Future<void> addSupplier(SupplierModel s);
  Future<void> updateSupplier(SupplierModel s);
  Future<void> deleteSupplier(String id);

  Future<List<StockTransferModel>> getTransfers();
  Future<void> addTransfer(StockTransferModel t);

  Future<List<CustomerModel>> getCustomers();

  Future<DashboardStats> getDashboardStats();
}

// ─── Firebase Firestore Implementation ─────────────────────────────
// Uncomment and fill in when ready. Method signatures match IDataService.
/*
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService implements IDataService {
  final _db = FirebaseFirestore.instance;

  @override
  Future<List<ProductModel>> getProducts() async {
    final snap = await _db.collection('products').orderBy('createdAt', descending: true).get();
    return snap.docs.map((d) => ProductModel.fromMap({...d.data(), 'id': d.id})).toList();
  }

  @override
  Future<void> addProduct(ProductModel p) async {
    await _db.collection('products').doc(p.id).set(p.toMap());
  }

  @override
  Future<void> updateProduct(ProductModel p) async {
    await _db.collection('products').doc(p.id).update(p.toMap());
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _db.collection('products').doc(id).delete();
  }

  @override
  Future<List<OrderModel>> getOrders() async {
    final snap = await _db.collection('orders').orderBy('date', descending: true).get();
    return snap.docs.map((d) => OrderModel.fromMap({...d.data(), 'id': d.id})).toList();
  }

  @override
  Future<void> addOrder(OrderModel o) async {
    await _db.collection('orders').doc(o.id).set(o.toMap());
    // Deduct stock via batch write
    final batch = _db.batch();
    for (final item in o.items) {
      final ref = _db.collection('products').doc(item.productId);
      batch.update(ref, {'stock': FieldValue.increment(-item.quantity)});
    }
    await batch.commit();
  }

  @override
  Future<void> updateOrderStatus(String id, String status) async {
    await _db.collection('orders').doc(id).update({'status': status});
  }

  @override
  Future<List<PurchaseModel>> getPurchases() async {
    final snap = await _db.collection('purchases').orderBy('orderDate', descending: true).get();
    // Map to PurchaseModel similarly
    return [];
  }

  @override
  Future<List<SupplierModel>> getSuppliers() async {
    final snap = await _db.collection('suppliers').get();
    // Map to SupplierModel
    return [];
  }

  @override
  Future<void> addSupplier(SupplierModel s) async {
    await _db.collection('suppliers').doc(s.id).set({
      'id': s.id, 'name': s.name, 'contactPerson': s.contactPerson,
      'phone': s.phone, 'email': s.email, 'city': s.city,
      'address': s.address, 'suppliedCategories': s.suppliedCategories,
      'isActive': s.isActive,
    });
  }

  @override
  Future<void> updateSupplier(SupplierModel s) async {
    await _db.collection('suppliers').doc(s.id).update({
      'name': s.name, 'contactPerson': s.contactPerson,
      'phone': s.phone, 'email': s.email, 'city': s.city,
      'address': s.address, 'isActive': s.isActive,
    });
  }

  @override
  Future<void> deleteSupplier(String id) async {
    await _db.collection('suppliers').doc(id).delete();
  }

  @override
  Future<List<StockTransferModel>> getTransfers() async {
    final snap = await _db.collection('transfers').orderBy('date', descending: true).get();
    return [];
  }

  @override
  Future<void> addTransfer(StockTransferModel t) async {
    await _db.collection('transfers').doc(t.id).set({
      'id': t.id, 'productId': t.productId, 'productName': t.productName,
      'fromLocation': t.fromLocation, 'toLocation': t.toLocation,
      'quantity': t.quantity, 'date': t.date.toIso8601String(),
      'initiatedBy': t.initiatedBy, 'status': t.status,
    });
  }

  @override
  Future<List<CustomerModel>> getCustomers() async {
    final snap = await _db.collection('customers').get();
    return [];
  }

  @override
  Future<DashboardStats> getDashboardStats() async {
    // Aggregate from Firestore or use a Cloud Function for efficiency
    final orders = await getOrders();
    final products = await getProducts();
    final customers = await getCustomers();
    final revenue = orders.where((o) => o.status == 'Delivered')
        .fold(0.0, (s, o) => s + o.totalAmount);
    // Build and return DashboardStats...
    throw UnimplementedError('Build DashboardStats from live data');
  }
}
*/

// ─── REST API Implementation ────────────────────────────────────────
// Uncomment and fill in base URL when ready.
/*
import 'dart:convert';
import 'package:http/http.dart' as http;

class RestApiService implements IDataService {
  static const _base = 'https://your-api.example.com/api';
  static const _headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer YOUR_TOKEN_HERE',
  };

  @override
  Future<List<ProductModel>> getProducts() async {
    final res = await http.get(Uri.parse('$_base/products'), headers: _headers);
    if (res.statusCode != 200) throw Exception('Failed to load products');
    final list = jsonDecode(res.body) as List;
    return list.map((d) => ProductModel.fromMap(d)).toList();
  }

  @override
  Future<void> addProduct(ProductModel p) async {
    await http.post(Uri.parse('$_base/products'),
        headers: _headers, body: jsonEncode(p.toMap()));
  }

  @override
  Future<void> updateProduct(ProductModel p) async {
    await http.put(Uri.parse('$_base/products/${p.id}'),
        headers: _headers, body: jsonEncode(p.toMap()));
  }

  @override
  Future<void> deleteProduct(String id) async {
    await http.delete(Uri.parse('$_base/products/$id'), headers: _headers);
  }

  // ... implement remaining methods similarly
  @override Future<List<OrderModel>> getOrders() async => [];
  @override Future<void> addOrder(OrderModel o) async {}
  @override Future<void> updateOrderStatus(String id, String status) async {}
  @override Future<List<PurchaseModel>> getPurchases() async => [];
  @override Future<List<SupplierModel>> getSuppliers() async => [];
  @override Future<void> addSupplier(SupplierModel s) async {}
  @override Future<void> updateSupplier(SupplierModel s) async {}
  @override Future<void> deleteSupplier(String id) async {}
  @override Future<List<StockTransferModel>> getTransfers() async => [];
  @override Future<void> addTransfer(StockTransferModel t) async {}
  @override Future<List<CustomerModel>> getCustomers() async => [];
  @override Future<DashboardStats> getDashboardStats() async => throw UnimplementedError();
}
*/

// ─── Usage: swap service in admin_providers.dart ──────────────────────────
// final _svc = MockDataService();   ← current
// final _svc = FirebaseService();   ← Firebase
// final _svc = RestApiService();    ← REST API
