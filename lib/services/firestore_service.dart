// ════════════════════════════════════════════════════════════════════
//  lib/services/firestore_service.dart
//
//  Central Firestore backend service for SmartStock2.
//  Handles ALL collections:
//  ✅ orders      — save, stream, update status
//  ✅ products    — CRUD, stock updates, low stock alerts
//  ✅ users       — profile, order count
//  ✅ customers   — derived from users + orders
//  ✅ notifications — push to user subcollection
//  ✅ stock_transfers — create, stream
//  ✅ reports     — live sales aggregates
// ════════════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order_model.dart';
import '../models/order_item_model.dart';
import '../models/product_model.dart';

class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  final _db   = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  // ══════════════════════════════════════════════════════════════════
  //  ORDERS
  // ══════════════════════════════════════════════════════════════════

  /// Save a new order to Firestore
  Future<String?> saveOrder(OrderModel order) async {
    try {
      final uid   = _uid;
      final user  = _auth.currentUser;
      final docId = order.id.replaceAll('#', '').replaceAll('-', '_');

      await _db.collection('orders').doc(docId).set({
        'orderId':       order.id,
        'customerId':    uid ?? '',
        'customerName':  user?.displayName ?? '',
        'customerEmail': user?.email ?? '',
        'date':          order.date,
        'status':        order.status,
        'totalAmount':   order.total,
        'address':       order.address,
        'paymentMethod': order.paymentMethod,
        'paymentStatus': order.paymentStatus,
        'deliveryStatus': 'Pending',
        'items': order.items.map((i) => {
          'id': i.id, 'name': i.name,
          'image': i.image, 'quantity': i.quantity, 'price': i.price,
        }).toList(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Decrement stock for each ordered product
      for (final item in order.items) {
        decrementStock(item.id, item.quantity).catchError((_) {});
      }

      return docId;
    } catch (_) { return null; }
  }

  /// Stream all orders for current user
  Stream<List<OrderModel>> streamMyOrders() {
    final uid = _uid;
    if (uid == null) return Stream.value([]);
    return _db.collection('orders')
        .where('customerId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(_docToOrder).toList());
  }

  /// Stream all orders (admin)
  Stream<List<OrderModel>> streamAllOrders() {
    return _db.collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(_docToOrder).toList());
  }

  /// Stream order count for current user
  Stream<int> streamMyOrderCount() {
    final uid = _uid;
    if (uid == null) return Stream.value(0);
    return _db.collection('orders')
        .where('customerId', isEqualTo: uid)
        .snapshots()
        .map((s) => s.docs.length);
  }

  /// Update order status (admin) + notify customer
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      final docId = orderId.replaceAll('#', '').replaceAll('-', '_');
      await _db.collection('orders').doc(docId).update({
        'status':    status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Push notification to customer
      final doc = await _db.collection('orders').doc(docId).get();
      final customerId = doc.data()?['customerId'] as String?;
      final orderIdStr = doc.data()?['orderId']   as String? ?? orderId;
      if (customerId != null && customerId.isNotEmpty) {
        await pushNotificationToUser(
          uid:   customerId,
          title: _orderStatusTitle(status),
          body:  'Order $orderIdStr is now $status.',
          type:  'order_${status.toLowerCase()}',
          orderId: orderIdStr,
        );
      }
    } catch (_) {}
  }

  /// Update delivery status
  Future<void> updateDeliveryStatus(String orderId, String status,
      {String distance = '', String eta = ''}) async {
    try {
      final docId = orderId.replaceAll('#', '').replaceAll('-', '_');
      await _db.collection('orders').doc(docId).update({
        'deliveryStatus':   status,
        'deliveryDistance': distance,
        'estimatedArrival': eta,
        'updatedAt':        FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  OrderModel _docToOrder(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id:            d['orderId']       as String? ?? doc.id,
      date:          d['date']          as String? ?? '',
      status:        d['status']        as String? ?? 'Pending',
      total:         (d['totalAmount']  as num? ?? 0).toDouble(),
      address:       d['address']       as String? ?? '',
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
  }

  String _orderStatusTitle(String status) {
    switch (status) {
      case 'Confirmed':  return '✅ Order Confirmed!';
      case 'Delivered':  return '📦 Order Delivered!';
      case 'Cancelled':  return '❌ Order Cancelled';
      default:           return '🔔 Order Update';
    }
  }

  // ══════════════════════════════════════════════════════════════════
  //  PRODUCTS
  // ══════════════════════════════════════════════════════════════════

  /// Stream all products
  Stream<List<ProductModel>> streamProducts() {
    return _db.collection('products')
        .orderBy('name')
        .snapshots()
        .map((s) => s.docs
        .map((d) => ProductModel.fromMap(d.data(), d.id))
        .toList());
  }

  /// Stream low stock products (stock < minStock)
  Stream<List<Map<String, dynamic>>> streamLowStockAlerts() {
    return _db.collection('products')
        .snapshots()
        .map((s) => s.docs
        .where((d) {
      final data = d.data();
      final stock    = (data['stock']    as num? ?? 0).toInt();
      final minStock = (data['minStock'] as num? ?? 10).toInt();
      return stock <= minStock;
    })
        .map((d) => {'id': d.id, ...d.data()})
        .toList());
  }

  /// Decrement stock when order is placed
  Future<void> decrementStock(String productId, int quantity) async {
    try {
      await _db.collection('products').doc(productId).update({
        'stock': FieldValue.increment(-quantity),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Check if now low stock and notify admin
      final doc = await _db.collection('products').doc(productId).get();
      final data = doc.data()!;
      final stock    = (data['stock']    as num? ?? 0).toInt();
      final minStock = (data['minStock'] as num? ?? 10).toInt();
      final name     = data['name'] as String? ?? 'Unknown Product';

      if (stock <= minStock) {
        await _sendAdminNotification(
          title:   '⚠️ Low Stock Alert',
          body:    '$name has only $stock units left (min: $minStock).',
          type:    'low_stock',
        );
      }
    } catch (_) {}
  }

  /// Update product stock (admin)
  Future<void> updateProductStock(String productId, int newStock) async {
    try {
      await _db.collection('products').doc(productId).update({
        'stock':     newStock,
        'status':    newStock == 0 ? 'Out of Stock'
            : newStock < 10 ? 'Low Stock'
            : 'In Stock',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  // ══════════════════════════════════════════════════════════════════
  //  CUSTOMERS (users with role = client, enriched with order data)
  // ══════════════════════════════════════════════════════════════════

  /// Stream all customers with their order stats
  Stream<List<Map<String, dynamic>>> streamCustomers() {
    return _db.collection('users')
        .where('role', isEqualTo: 'client')
        .snapshots()
        .asyncMap((userSnap) async {
      final customers = <Map<String, dynamic>>[];
      for (final doc in userSnap.docs) {
        final user = doc.data();
        // Get order stats for this user
        final orderSnap = await _db.collection('orders')
            .where('customerId', isEqualTo: doc.id)
            .get();
        final totalOrders = orderSnap.docs.length;
        final totalSpend  = orderSnap.docs.fold<double>(
            0, (s, o) => s + ((o.data()['totalAmount'] as num?)?.toDouble() ?? 0));

        customers.add({
          'id':          doc.id,
          'name':        user['name']     ?? '',
          'email':       user['email']    ?? '',
          'phone':       user['phone']    ?? '',
          'city':        user['city']     ?? '',
          'photoUrl':    user['photoUrl'] ?? '',
          'totalOrders': totalOrders,
          'totalSpend':  totalSpend,
          'joinedAt':    user['joinedAt'],
        });
      }
      return customers;
    });
  }

  /// Save/update customer (user) profile
  Future<void> saveUserProfile({
    required String uid,
    required String name,
    String phone = '',
    String city  = '',
    String photoUrl = '',
  }) async {
    await _db.collection('users').doc(uid).set({
      'uid':       uid,
      'name':      name,
      'phone':     phone,
      'city':      city,
      'photoUrl':  photoUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ══════════════════════════════════════════════════════════════════
  //  STOCK TRANSFERS
  // ══════════════════════════════════════════════════════════════════

  /// Create stock transfer
  Future<void> createStockTransfer({
    required String productName,
    required String fromLocation,
    required String toLocation,
    required int quantity,
    String initiatedBy = 'Admin',
  }) async {
    try {
      final ref = await _db.collection('stock_transfers').add({
        'productName':   productName,
        'fromLocation':  fromLocation,
        'toLocation':    toLocation,
        'quantity':      quantity,
        'status':        'In Transit',
        'initiatedBy':   initiatedBy,
        'date':          FieldValue.serverTimestamp(),
        'createdAt':     FieldValue.serverTimestamp(),
      });

      // Notify admin
      await _sendAdminNotification(
        title:   '🚚 Stock Transfer Created',
        body:    '$quantity units of $productName → $toLocation.',
        type:    'stock_transfer',
      );
    } catch (_) {}
  }

  /// Update transfer status
  Future<void> updateTransferStatus(String transferId, String status) async {
    await _db.collection('stock_transfers').doc(transferId).update({
      'status':    status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    if (status == 'Completed') {
      await _sendAdminNotification(
        title: '✅ Transfer Completed',
        body:  'Stock transfer has been completed successfully.',
        type:  'stock_transfer',
      );
    }
  }

  /// Stream stock transfers
  Stream<List<Map<String, dynamic>>> streamStockTransfers() {
    return _db.collection('stock_transfers')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  // ══════════════════════════════════════════════════════════════════
  //  NOTIFICATIONS
  // ══════════════════════════════════════════════════════════════════

  /// Push notification to a specific user's subcollection
  Future<void> pushNotificationToUser({
    required String uid,
    required String title,
    required String body,
    required String type,
    String? orderId,
  }) async {
    try {
      await _db.collection('users').doc(uid)
          .collection('notifications')
          .add({
        'title':   title,
        'body':    body,
        'type':    type,
        'orderId': orderId ?? '',
        'isRead':  false,
        'time':    FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  /// Stream notifications for current user
  Stream<List<Map<String, dynamic>>> streamMyNotifications() {
    final uid = _uid;
    if (uid == null) return Stream.value([]);
    return _db.collection('users').doc(uid)
        .collection('notifications')
        .orderBy('time', descending: true)
        .limit(50)
        .snapshots()
        .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  /// Mark notification as read
  Future<void> markNotificationRead(String notifId) async {
    final uid = _uid;
    if (uid == null) return;
    await _db.collection('users').doc(uid)
        .collection('notifications').doc(notifId)
        .update({'isRead': true});
  }

  /// Send notification to admin (saves to admins notifications collection)
  Future<void> _sendAdminNotification({
    required String title,
    required String body,
    required String type,
  }) async {
    try {
      await _db.collection('admin_notifications').add({
        'title':   title,
        'body':    body,
        'type':    type,
        'isRead':  false,
        'time':    FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  /// Stream admin notifications
  Stream<List<Map<String, dynamic>>> streamAdminNotifications() {
    return _db.collection('admin_notifications')
        .orderBy('time', descending: true)
        .limit(50)
        .snapshots()
        .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  // ══════════════════════════════════════════════════════════════════
  //  REPORTS (dynamic, based on real order data)
  // ══════════════════════════════════════════════════════════════════

  /// Stream monthly revenue data for charts
  Stream<Map<String, dynamic>> streamReportData() {
    return _db.collection('orders')
        .snapshots()
        .map((snap) {
      final orders = snap.docs.map((d) => d.data()).toList();
      final now    = DateTime.now();

      // Monthly revenue (current year)
      final Map<int, double> monthlyRev  = {for (var i=1;i<=12;i++) i: 0};
      final Map<int, double> monthlyCost = {for (var i=1;i<=12;i++) i: 0};
      int totalOrders     = 0;
      double totalRevenue = 0;
      int totalCustomers  = 0;
      final Set<String> uniqueCustomers = {};

      // Category breakdown
      final Map<String, double> catRevenue = {};

      for (final o in orders) {
        final ts = o['createdAt'] as Timestamp?;
        if (ts == null) continue;
        final date   = ts.toDate();
        final amount = (o['totalAmount'] as num? ?? 0).toDouble();
        final status = o['status'] as String? ?? '';
        final cid    = o['customerId'] as String? ?? '';

        totalOrders++;
        uniqueCustomers.add(cid);

        if (status == 'Delivered') {
          totalRevenue += amount;
          if (date.year == now.year) {
            monthlyRev[date.month]  = (monthlyRev[date.month]  ?? 0) + amount;
            monthlyCost[date.month] = (monthlyCost[date.month] ?? 0) + amount * 0.65;
          }
        }

        // Category revenue
        final items = o['items'] as List? ?? [];
        for (final item in items) {
          final cat = item['category'] as String? ?? 'Other';
          catRevenue[cat] = (catRevenue[cat] ?? 0) + (item['price'] as num? ?? 0).toDouble();
        }
      }

      const months = ['Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec'];

      return {
        'totalRevenue':   totalRevenue,
        'totalOrders':    totalOrders,
        'totalCustomers': uniqueCustomers.length,
        'monthlyRevenue': [for(var i=1;i<=12;i++) {'month':months[i-1],'value':monthlyRev[i]}],
        'monthlyCost':    [for(var i=1;i<=12;i++) {'month':months[i-1],'value':monthlyCost[i]}],
        'categoryRevenue': catRevenue,
      };
    });
  }

  // ══════════════════════════════════════════════════════════════════
  //  DELIVERY LOCATION
  // ══════════════════════════════════════════════════════════════════

  /// Save delivery location for an order
  Future<void> saveDeliveryLocation({
    required String orderId,
    required double lat,
    required double lng,
    required String address,
  }) async {
    try {
      final docId = orderId.replaceAll('#', '').replaceAll('-', '_');
      await _db.collection('orders').doc(docId).update({
        'deliveryLocation': {'lat': lat, 'lng': lng, 'address': address},
        'deliveryStatus':   'Pending',
        'updatedAt':        FieldValue.serverTimestamp(),
      });
      // Notify: location selected
      final uid = _uid;
      if (uid != null) {
        await pushNotificationToUser(
          uid:   uid,
          title: '📍 Delivery Location Set',
          body:  'Your delivery location has been confirmed: $address',
          type:  'location_set',
          orderId: orderId,
        );
      }
    } catch (_) {}
  }

  /// Stream delivery info for order tracking
  Stream<Map<String, dynamic>?> streamOrderDelivery(String orderId) {
    final docId = orderId.replaceAll('#', '').replaceAll('-', '_');
    return _db.collection('orders').doc(docId)
        .snapshots()
        .map((s) {
      if (!s.exists) return null;
      final d = s.data()!;
      return {
        'deliveryLocation': d['deliveryLocation'],
        'deliveryStatus':   d['deliveryStatus'] ?? 'Pending',
        'deliveryDistance': d['deliveryDistance'] ?? '',
        'estimatedArrival': d['estimatedArrival'] ?? '',
      };
    });
  }
}