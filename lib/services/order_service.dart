// ════════════════════════════════════════════════════════════════════
//  lib/services/order_service.dart
//
//  Saves orders to Firestore + keeps local list for instant UI updates
// ════════════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order_model.dart';
import '../models/order_item_model.dart';

class OrderService {
  static final _db   = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  // ── Local cache (for instant display) ─────────────────────────────
  static final List<OrderModel> orders = [
    OrderModel(
      id: '#ORD-1024', date: '12 Feb 2026', status: 'Pending',
      total: 499, address: 'Kolkata, West Bengal',
      paymentMethod: 'UPI', paymentStatus: 'Paid',
      items: [OrderItemModel(id:'1', name:'Security Labels',
          image:'assets/products/label1.png', quantity:2, price:250)],
    ),
  ];

  // ── ADD ORDER — saves to Firestore in background, updates local instantly ──
  static void addOrder(OrderModel order) {
    orders.insert(0, order);                    // instant local update
    _saveToFirestore(order).catchError((_) {}); // background save
  }

  // ── FIRESTORE SAVE ─────────────────────────────────────────────────
  static Future<void> _saveToFirestore(OrderModel order) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final cleanId = order.id.replaceAll('#', '').replaceAll('-', '_');

    await _db.collection('orders').doc(cleanId).set({
      'orderId':       order.id,
      'customerId':    uid,
      'customerEmail': _auth.currentUser?.email ?? '',
      'customerName':  _auth.currentUser?.displayName ?? '',
      'date':          order.date,
      'status':        order.status,
      'total':         order.total,
      'address':       order.address,
      'paymentMethod': order.paymentMethod,
      'paymentStatus': order.paymentStatus,
      'items': order.items.map((i) => {
        'id': i.id, 'name': i.name, 'image': i.image,
        'quantity': i.quantity, 'price': i.price,
      }).toList(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── STREAM ORDERS FROM FIRESTORE (real-time) ───────────────────────
  static Stream<List<OrderModel>> streamUserOrders() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value([]);

    return _db
        .collection('orders')
        .where('customerId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
      final d = doc.data();
      return OrderModel(
        id:            d['orderId'] as String? ?? doc.id,
        date:          d['date']    as String? ?? '',
        status:        d['status']  as String? ?? 'Pending',
        total:         (d['total']  as num? ?? 0).toDouble(),
        address:       d['address'] as String? ?? '',
        paymentMethod: d['paymentMethod'] as String? ?? '',
        paymentStatus: d['paymentStatus'] as String? ?? '',
        items: (d['items'] as List? ?? []).map((i) => OrderItemModel(
          id:       i['id']       as String? ?? '',
          name:     i['name']     as String? ?? '',
          image:    i['image']    as String? ?? '',
          quantity: (i['quantity'] as num? ?? 1).toInt(),
          price:    (i['price']   as num? ?? 0).toDouble(),
        )).toList(),
      );
    }).toList());
  }

  // ── GET ORDER COUNT FROM FIRESTORE ─────────────────────────────────
  static Stream<int> streamOrderCount() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(0);
    return _db
        .collection('orders')
        .where('customerId', isEqualTo: uid)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  static List<OrderModel> getOrders()      => orders;
  static void clearOrders()                => orders.clear();
}



// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'product_service.dart';
// import 'notification_service.dart';
// import '../models/order_model.dart';
//
// class OrderService {
//   OrderService._();
//   static final OrderService instance = OrderService._();
//
//   // Local cache for UI screens like OrderListScreen
//   static List<OrderModel> orders = [];
//
//   final _db = FirebaseFirestore.instance;
//   CollectionReference get _col => _db.collection('orders');
//
//   // ── STREAM: Client's own orders ────────────────────────────────────
//   Stream<List<Map<String, dynamic>>> streamMyOrders() {
//     final uid = FirebaseAuth.instance.currentUser?.uid;
//     if (uid == null) return const Stream.empty();
//
//     return _col
//         .where('customerId', isEqualTo: uid)
//         .orderBy('createdAt', descending: true)
//         .snapshots()
//         .map((s) => s.docs
//         .map((d) => {'id': d.id, ...d.data() as Map<String, dynamic>})
//         .toList());
//   }
//
//   // ── STREAM: All orders (Admin) ─────────────────────────────────────
//   Stream<List<Map<String, dynamic>>> streamAllOrders() {
//     return _col
//         .orderBy('createdAt', descending: true)
//         .snapshots()
//         .map((s) => s.docs
//         .map((d) => {'id': d.id, ...d.data() as Map<String, dynamic>})
//         .toList());
//   }
//
//   // ── PLACE ORDER ────────────────────────────────────────────────────
//   Future<String> placeOrder({
//     required List<Map<String, dynamic>> items,
//     // Each item: { productId, productName, quantity, unitPrice, imageUrl }
//     required String paymentMethod,
//     required String address,
//     required Map<String, dynamic> deliveryLocation,
//     // { lat, lng, address }
//   }) async {
//     final user = FirebaseAuth.instance.currentUser!;
//     final total = items.fold<double>(
//         0, (s, i) => s + (i['unitPrice'] as num) * (i['quantity'] as num));
//
//     final orderData = {
//       'customerId': user.uid,
//       'customerName': user.displayName ?? '',
//       'customerEmail': user.email ?? '',
//       'items': items,
//       'totalAmount': total,
//       'status': 'Pending',
//       'paymentMethod': paymentMethod,
//       'paymentStatus': 'Paid',
//       'address': address,
//       'deliveryLocation': deliveryLocation,
//       'deliveryStatus': 'Pending',
//       'deliveryDistance': '',
//       'estimatedArrival': '',
//       'createdAt': FieldValue.serverTimestamp(),
//       'updatedAt': FieldValue.serverTimestamp(),
//     };
//
//     // Write order in a batch with stock decrements
//     final batch = _db.batch();
//     final orderRef = _col.doc();
//     batch.set(orderRef, orderData);
//
//     for (final item in items) {
//       final productRef =
//       _db.collection('products').doc(item['productId'] as String);
//       batch.update(productRef, {
//         'stock': FieldValue.increment(-(item['quantity'] as int)),
//         'updatedAt': FieldValue.serverTimestamp(),
//       });
//     }
//
//     // Update customer total spend
//     batch.update(_db.collection('users').doc(user.uid), {
//       'totalOrders': FieldValue.increment(1),
//       'totalSpend': FieldValue.increment(total),
//       'updatedAt': FieldValue.serverTimestamp(),
//     });
//
//     await batch.commit();
//
//     // Send FCM notification to client
//     await NotificationService.instance.sendOrderNotification(
//       userId: user.uid,
//       orderId: orderRef.id,
//       status: 'Pending',
//     );
//
//     // Send FCM notification to admin
//     await NotificationService.instance.sendAdminNewOrderNotification(
//       orderId: orderRef.id,
//       customerName: user.displayName ?? user.email ?? 'Customer',
//       amount: total,
//     );
//
//     // update local UI cache
//     orders.insert(
//       0,
//       OrderModel(
//         id: orderRef.id,
//         date: DateTime.now().toString(),
//         total: total,
//         status: 'Pending',
//         address: address,
//         paymentMethod: paymentMethod,
//         paymentStatus: 'Paid',
//         items: [],
//       ),
//     );
//
//     return orderRef.id;
//   }
//
//   // ── GET ORDER BY ID ────────────────────────────────────────────────
//   Future<Map<String, dynamic>?> getOrder(String orderId) async {
//     final doc = await _col.doc(orderId).get();
//     if (!doc.exists) return null;
//     return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
//   }
//
//   // ── UPDATE ORDER STATUS (Admin) ────────────────────────────────────
//   Future<void> updateOrderStatus(String orderId, String status) async {
//     await _col.doc(orderId).update({
//       'status': status,
//       'updatedAt': FieldValue.serverTimestamp(),
//     });
//
//     // Notify client
//     final doc = await _col.doc(orderId).get();
//     final data = doc.data() as Map<String, dynamic>;
//     await NotificationService.instance.sendOrderNotification(
//       userId: data['customerId'] as String,
//       orderId: orderId,
//       status: status,
//     );
//   }
//
//   // ── UPDATE DELIVERY INFO ───────────────────────────────────────────
//   Future<void> updateDelivery({
//     required String orderId,
//     required String deliveryStatus,
//     required String distance,
//     required String estimatedArrival,
//   }) async {
//     await _col.doc(orderId).update({
//       'deliveryStatus': deliveryStatus,
//       'deliveryDistance': distance,
//       'estimatedArrival': estimatedArrival,
//       'updatedAt': FieldValue.serverTimestamp(),
//     });
//   }
//
//   // ── CANCEL ORDER ───────────────────────────────────────────────────
//   Future<void> cancelOrder(String orderId) async {
//     await _col.doc(orderId).update({
//       'status': 'Cancelled',
//       'updatedAt': FieldValue.serverTimestamp(),
//     });
//   }
//
//   // ── DASHBOARD STATS ────────────────────────────────────────────────
//   Future<Map<String, dynamic>> getOrderStats() async {
//     final snap = await _col.get();
//     final docs = snap.docs.map((d) => d.data() as Map<String, dynamic>).toList();
//     final total = docs.length;
//     final delivered = docs.where((d) => d['status'] == 'Delivered').length;
//     final pending = docs.where((d) => d['status'] == 'Pending').length;
//     final cancelled = docs.where((d) => d['status'] == 'Cancelled').length;
//     final revenue = docs
//         .where((d) => d['status'] == 'Delivered')
//         .fold<double>(0, (s, d) => s + (d['totalAmount'] as num));
//
//     return {
//       'total': total,
//       'delivered': delivered,
//       'pending': pending,
//       'cancelled': cancelled,
//       'revenue': revenue,
//     };
//   }
// }


// import '../models/order_model.dart';
// import '../models/order_item_model.dart';
//
// class OrderService {
//   /// ⭐ DEMO + RUNTIME ORDERS STORAGE
//   static final List<OrderModel> orders = [
//     OrderModel(
//       id: "#ORD-1024",
//       date: "12 Feb 2026",
//       status: "Pending",
//       total: 499,
//       address: "Kolkata, West Bengal",
//       paymentMethod: "UPI",
//       paymentStatus: "Paid",
//       items: [
//         OrderItemModel(
//           id: "1",
//           name: "Security Labels",
//           image: "assets/products/label1.png",
//           quantity: 2,
//           price: 250,
//         ),
//       ],
//     ),
//     OrderModel(
//       id: "#ORD-1021",
//       date: "10 Feb 2026",
//       status: "Delivered",
//       total: 899,
//       address: "Navrangpura , Ahmedabad",
//       paymentMethod: "Card",
//       paymentStatus: "Paid",
//       items: [
//         OrderItemModel(
//           id: "2",
//           name: "Hologram Stickers",
//           image: "assets/products/hologram.png",
//           quantity: 3,
//           price: 360,
//         ),
//       ],
//     ),
//   ];
//
//   /// ⭐ GET ALL ORDERS
//   static List<OrderModel> getOrders() {
//     return orders;
//   }
//
//   /// ⭐ ADD NEW ORDER FROM PAYMENT FLOW
//   static void addOrder(OrderModel order) {
//     orders.insert(0, order); // newest first
//   }
//
//   /// ⭐ CLEAR ALL ORDERS (future admin/testing)
//   static void clearOrders() {
//     orders.clear();
//   }
// }
