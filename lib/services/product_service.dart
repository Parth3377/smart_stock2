// ════════════════════════════════════════════════════════════════════
//  lib/services/product_service.dart
//
//  Fixes:
//  ✅ context.watch<ProductService>().products  (dashboard_screen.dart)
//  ✅ ProductService.instance.getProducts()     (products_screen.dart)
//  ✅ ProductService.getProducts()              (static call fallback)
// ════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductService extends ChangeNotifier {

  // ── Singleton instance ─────────────────────────────────────────────
  static final ProductService instance = ProductService._internal();
  factory ProductService() => instance;
  ProductService._internal();

  // ── Internal product list ──────────────────────────────────────────
  List<ProductModel> _products = _defaultProducts();

  // ── GETTER used by dashboard_screen.dart ──────────────────────────
  // context.watch<ProductService>().products
  List<ProductModel> get products => List.unmodifiable(_products);

  // ── INSTANCE METHOD used by products_screen.dart ──────────────────
  // ProductService.instance.getProducts()
  List<ProductModel> getProducts() => List.unmodifiable(_products);

  // ── STATIC METHOD (backward compatibility) ─────────────────────────
  // ProductService.getProducts()
  static List<ProductModel> getAllProducts() => instance.getProducts();

  // ── Load from Firestore ────────────────────────────────────────────
  Future<void> loadFromFirestore() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('products')
          .orderBy('name')
          .get();

      if (snap.docs.isNotEmpty) {
        _products = snap.docs
            .map((d) => ProductModel.fromMap(d.data(), d.id))
            .toList();
        notifyListeners();
      }
    } catch (_) {
      // Keep default products if Firestore fails
    }
  }

  // ── Default products (shown before Firestore loads) ────────────────
  static List<ProductModel> _defaultProducts() => [
    ProductModel(
      id: '1',
      name: 'Security Labels',
      description: 'High quality security labels for branding & protection.',
      image: 'assets/products/label1.png',
      price: 120,
      category: 'Labels',
    ),
    ProductModel(
      id: '2',
      name: 'QR Stickers',
      description: 'Durable QR code stickers for scanning solutions.',
      image: 'assets/products/qr1.png',
      price: 250,
      category: 'QR',
    ),
    ProductModel(
      id: '3',
      name: 'QR Codes',
      description: 'Custom QR codes for smart tracking.',
      image: 'assets/products/qr2.png',
      price: 340,
      category: 'QR',
    ),
    ProductModel(
      id: '4',
      name: 'Brand Stickers',
      description: 'Premium stickers for brand visibility.',
      image: 'assets/products/sticker.png',
      price: 499,
      category: 'Branding',
    ),
    ProductModel(
      id: '5',
      name: 'Holographic Stickers',
      description: 'Tamper-proof holographic protection labels.',
      image: 'assets/products/hologram.png',
      price: 180,
      category: 'Hologram',
    ),
    ProductModel(
      id: '6',
      name: 'Premium Labels',
      description: 'High-end polyester product labels.',
      image: 'assets/products/label2.png',
      price: 299,
      category: 'Labels',
    ),
  ];
}


// import '../models/product_model.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class ProductService {
//   // Singleton instance for Provider
//   ProductService();
//
//   /// Static cache — shared across all instances
//   static List<ProductModel> _cache = _defaultProducts();
//
//   /// Called by DashboardScreen and ProductsScreen
//   /// Works both as static call AND as instance call
//   static List<ProductModel> getProducts() => List.unmodifiable(_cache);
//
//   /// Load real products from Firestore (call once at startup)
//   static Future<void> loadFromFirestore() async {
//     try {
//       final snap = await FirebaseFirestore.instance
//           .collection('products')
//           .orderBy('name')
//           .get();
//       if (snap.docs.isNotEmpty) {
//         _cache = snap.docs.map((d) => ProductModel.fromMap(d.data(), d.id)).toList();
//       }
//     } catch (_) {
//       // Keep default products if Firestore fails
//     }
//   }
//
//   /// Default products shown before Firestore loads
//   static List<ProductModel> _defaultProducts() => [
//     ProductModel(
//       id: '1',
//       name: 'Security Labels',
//       description: 'High quality security labels for branding & protection.',
//       image: 'assets/products/label1.png',
//       price: 120,
//       category: 'Labels',
//     ),
//     ProductModel(
//       id: '2',
//       name: 'QR Stickers',
//       description: 'Durable QR code stickers for scanning solutions.',
//       image: 'assets/products/qr1.png',
//       price: 250,
//       category: 'QR',
//     ),
//     ProductModel(
//       id: '3',
//       name: 'QR Codes',
//       description: 'Custom QR codes for smart tracking.',
//       image: 'assets/products/qr2.png',
//       price: 340,
//       category: 'QR',
//     ),
//     ProductModel(
//       id: '4',
//       name: 'Brand Stickers',
//       description: 'Premium stickers for brand visibility.',
//       image: 'assets/products/sticker.png',
//       price: 499,
//       category: 'Branding',
//     ),
//     ProductModel(
//       id: '5',
//       name: 'Holographic Stickers',
//       description: 'Tamper-proof holographic protection labels.',
//       image: 'assets/products/hologram.png',
//       price: 180,
//       category: 'Hologram',
//     ),
//     ProductModel(
//       id: '6',
//       name: 'Premium Labels',
//       description: 'High-end polyester product labels.',
//       image: 'assets/products/label2.png',
//       price: 299,
//       category: 'Labels',
//     ),
//   ];
// }

// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import '../models/product_model.dart';
//
// class ProductService {
//   ProductService._();
//   static final ProductService instance = ProductService._();
//
//   final List<ProductModel> _products = [
//     ProductModel(
//       id: '1',
//       name: 'Security Labels',
//       description: 'High quality security labels',
//       image: 'assets/products/label1.png',
//       price: 120,
//       category: 'Labels',
//     ),
//     ProductModel(
//       id: '2',
//       name: 'QR Stickers',
//       description: 'Durable QR stickers',
//       image: 'assets/products/qr1.png',
//       price: 250,
//       category: 'QR',
//     ),
//   ];
//
//   List<ProductModel> get products => _products;
//
//   List<ProductModel> getProducts() {
//     return _products;
//   }
//
//   final _db = FirebaseFirestore.instance;
//   final _storage = FirebaseStorage.instance;
//   CollectionReference get _col => _db.collection('products');
//
//   // ── READ ALL (real-time stream) ────────────────────────────────────
//   Stream<List<Map<String, dynamic>>> streamProducts() {
//     return _col
//         .orderBy('createdAt', descending: true)
//         .snapshots()
//         .map((snap) => snap.docs
//         .map((d) => {'id': d.id, ...d.data() as Map<String, dynamic>})
//         .toList());
//   }
//
//   // ── READ ALL (one-time) ────────────────────────────────────────────
//   Future<List<Map<String, dynamic>>> fetchProducts() async {
//     final snap = await _col.orderBy('createdAt', descending: true).get();
//     return snap.docs
//         .map((d) => {'id': d.id, ...d.data() as Map<String, dynamic>})
//         .toList();
//   }
//
//   // ── READ BY CATEGORY ───────────────────────────────────────────────
//   Future<List<Map<String, dynamic>>> getProductsByCategory(
//       String category) async {
//     final snap = await _col.where('category', isEqualTo: category).get();
//     return snap.docs
//         .map((d) => {'id': d.id, ...d.data() as Map<String, dynamic>})
//         .toList();
//   }
//
//   // ── READ LOW-STOCK ─────────────────────────────────────────────────
//   Stream<List<Map<String, dynamic>>> streamLowStock() {
//     return _db
//         .collection('products')
//         .where('stock', isGreaterThan: 0)
//         .snapshots()
//         .map((snap) => snap.docs
//         .where((d) {
//       final data = d.data();
//       return (data['stock'] as int) < (data['minStock'] as int? ?? 10);
//     })
//         .map((d) => {'id': d.id, ...d.data()})
//         .toList());
//   }
//
//   // ── CREATE ─────────────────────────────────────────────────────────
//   Future<String> addProduct({
//     required String name,
//     required String sku,
//     required String category,
//     required double price,
//     required int stock,
//     int minStock = 10,
//     required String supplierId,
//     String description = '',
//     File? imageFile,
//   }) async {
//     String imageUrl = '';
//
//     if (imageFile != null) {
//       imageUrl = await _uploadImage(imageFile, sku);
//     }
//
//     final docRef = await _col.add({
//       'name': name,
//       'sku': sku,
//       'category': category,
//       'price': price,
//       'stock': stock,
//       'minStock': minStock,
//       'supplierId': supplierId,
//       'description': description,
//       'imageUrl': imageUrl,
//       'status': _stockStatus(stock, minStock),
//       'createdAt': FieldValue.serverTimestamp(),
//       'updatedAt': FieldValue.serverTimestamp(),
//     });
//
//     return docRef.id;
//   }
//
//   // ── UPDATE ─────────────────────────────────────────────────────────
//   Future<void> updateProduct({
//     required String productId,
//     String? name,
//     String? sku,
//     String? category,
//     double? price,
//     int? stock,
//     int? minStock,
//     String? supplierId,
//     String? description,
//     File? imageFile,
//   }) async {
//     final updates = <String, dynamic>{
//       'updatedAt': FieldValue.serverTimestamp(),
//     };
//
//     if (name != null) updates['name'] = name;
//     if (sku != null) updates['sku'] = sku;
//     if (category != null) updates['category'] = category;
//     if (price != null) updates['price'] = price;
//     if (stock != null) updates['stock'] = stock;
//     if (minStock != null) updates['minStock'] = minStock;
//     if (supplierId != null) updates['supplierId'] = supplierId;
//     if (description != null) updates['description'] = description;
//
//     // Recalculate stock status if stock or minStock changed
//     if (stock != null || minStock != null) {
//       final existing = await _col.doc(productId).get();
//       final data = existing.data() as Map<String, dynamic>;
//       final s = stock ?? data['stock'] as int;
//       final m = minStock ?? data['minStock'] as int? ?? 10;
//       updates['status'] = _stockStatus(s, m);
//     }
//
//     if (imageFile != null) {
//       final existing = await _col.doc(productId).get();
//       final data = existing.data() as Map<String, dynamic>;
//       final existingUrl = data['imageUrl'] as String? ?? '';
//       if (existingUrl.isNotEmpty) {
//         await _deleteImageByUrl(existingUrl);
//       }
//       final skuVal = (updates['sku'] ?? data['sku']) as String;
//       updates['imageUrl'] = await _uploadImage(imageFile, skuVal);
//     }
//
//     await _col.doc(productId).update(updates);
//   }
//
//   // ── DELETE ─────────────────────────────────────────────────────────
//   Future<void> deleteProduct(String productId) async {
//     final doc = await _col.doc(productId).get();
//     if (doc.exists) {
//       final data = doc.data() as Map<String, dynamic>;
//       final imageUrl = data['imageUrl'] as String? ?? '';
//       if (imageUrl.isNotEmpty) {
//         await _deleteImageByUrl(imageUrl);
//       }
//     }
//     await _col.doc(productId).delete();
//   }
//
//   // ── DECREMENT STOCK (called on order placement) ────────────────────
//   Future<void> decrementStock(String productId, int qty) async {
//     await _db.runTransaction((tx) async {
//       final ref = _col.doc(productId);
//       final snap = await tx.get(ref);
//       final data = snap.data() as Map<String, dynamic>;
//       final current = data['stock'] as int;
//       final minStock = data['minStock'] as int? ?? 10;
//       final newStock = (current - qty).clamp(0, 999999);
//       tx.update(ref, {
//         'stock': newStock,
//         'status': _stockStatus(newStock, minStock),
//         'updatedAt': FieldValue.serverTimestamp(),
//       });
//     });
//   }
//
//   // ── STORAGE HELPERS ────────────────────────────────────────────────
//   Future<String> _uploadImage(File file, String sku) async {
//     final ref = _storage.ref('products/$sku/${DateTime.now().millisecondsSinceEpoch}.jpg');
//     final task = await ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
//     return await task.ref.getDownloadURL();
//   }
//
//   Future<void> _deleteImageByUrl(String url) async {
//     try {
//       await _storage.refFromURL(url).delete();
//     } catch (_) {}
//   }
//
//   String _stockStatus(int stock, int minStock) {
//     if (stock == 0) return 'Out of Stock';
//     if (stock < minStock) return 'Low Stock';
//     return 'In Stock';
//   }
// }

