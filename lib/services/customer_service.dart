// ════════════════════════════════════════════════════════════════════
//  lib/services/customer_service.dart
// ════════════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomerService {
  CustomerService._();
  static final CustomerService instance = CustomerService._();

  final _db = FirebaseFirestore.instance;

  // ── Admin: stream all customers ────────────────────────────────────
  Stream<List<Map<String, dynamic>>> streamCustomers() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'client')
        .orderBy('joinedAt', descending: true)
        .snapshots()
        .map((s) => s.docs
            .map((d) => {'id': d.id, ...d.data()})
            .toList());
  }

  // ── Client: get own profile ────────────────────────────────────────
  Future<Map<String, dynamic>?> getMyProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return {'id': doc.id, ...doc.data()!};
  }

  // ── Client: update profile ─────────────────────────────────────────
  Future<void> updateMyProfile({
    String? name,
    String? phone,
    String? city,
    String? photoUrl,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final updates = <String, dynamic>{'updatedAt': FieldValue.serverTimestamp()};
    if (name != null) {
      updates['name'] = name;
      await FirebaseAuth.instance.currentUser?.updateDisplayName(name);
    }
    if (phone != null) updates['phone'] = phone;
    if (city != null) updates['city'] = city;
    if (photoUrl != null) updates['photoUrl'] = photoUrl;
    await _db.collection('users').doc(uid).update(updates);
  }

  // ── Admin: get customer by id ──────────────────────────────────────
  Future<Map<String, dynamic>?> getCustomer(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return {'id': doc.id, ...doc.data()!};
  }

  // ── Favorites ──────────────────────────────────────────────────────
  Future<void> addToFavorites(String productId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _db.collection('favorites').doc('${uid}_$productId').set({
      'userId': uid,
      'productId': productId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeFromFavorites(String productId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _db.collection('favorites').doc('${uid}_$productId').delete();
  }

  Stream<List<String>> streamFavoriteIds() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return _db
        .collection('favorites')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((s) => s.docs.map((d) => d['productId'] as String).toList());
  }

  // ── Cart ────────────────────────────────────────────────────────────
  Future<void> addToCart(String productId, int quantity) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _db.collection('cart').doc('${uid}_$productId').set({
      'userId': uid,
      'productId': productId,
      'quantity': quantity,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> removeFromCart(String productId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _db.collection('cart').doc('${uid}_$productId').delete();
  }

  Future<void> clearCart() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final snap = await _db
        .collection('cart')
        .where('userId', isEqualTo: uid)
        .get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Stream<List<Map<String, dynamic>>> streamCart() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return _db
        .collection('cart')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((s) => s.docs
            .map((d) => {'id': d.id, ...d.data()})
            .toList());
  }
}
