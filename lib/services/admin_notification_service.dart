import 'package:cloud_firestore/cloud_firestore.dart';

class AdminNotificationService {
  AdminNotificationService._();
  static final AdminNotificationService instance = AdminNotificationService._();

  final _db = FirebaseFirestore.instance;

  Future<void> notifyPurchaseArrived({
    required String productName,
    required int quantity,
  }) =>
      _write(
        type: 'purchase_arrived',
        title: 'Purchase Arrived 📦',
        body:
        '"$productName" is now in stock and available for selling. Quantity added: $quantity units.',
        screen: 'purchase',
      );

  // ── NEW SALE ─────────────────────────────────────────────────────
  // Called automatically when a new order appears in Firestore
  // (detected by AdminOrdersProvider stream — not manually called).
  Future<void> notifyNewSale({
    required String customerName,
    required double amount,
    required String orderId,
  }) =>
      _write(
        type: 'new_sale',
        title: 'New Sale 🛒',
        body:
        '$customerName placed an order of ₹${amount.toStringAsFixed(0)}.',
        screen: 'sales',
        extra: {'orderId': orderId},
      );

  // ── SUPPLIER ADDED ───────────────────────────────────────────────
  // Called when admin adds a new supplier via the Add button.
  Future<void> notifySupplierAdded({
    required String supplierName,
    required String city,
  }) =>
      _write(
        type: 'supplier_added',
        title: 'New Supplier Added 🏭',
        body:
        '"$supplierName" from $city has been added to your supplier list.',
        screen: 'suppliers',
      );

  // ── STOCK TRANSFER ───────────────────────────────────────────────
  // Called when admin initiates a stock transfer.
  Future<void> notifyStockTransfer({
    required String productName,
    required String fromLocation,
    required String toLocation,
    required int quantity,
  }) =>
      _write(
        type: 'stock_transfer',
        title: 'Stock Transfer Initiated 🔄',
        body:
        '$quantity units of "$productName" transferred: $fromLocation → $toLocation.',
        screen: 'stock_transfer',
      );

  // ── LOW STOCK ⚠️ ─────────────────────────────────────────────────
  // Fired automatically by AdminProductsProvider stream when a product's
  // stock transitions from >= minStock to < minStock (but still > 0).
  // Shows in Dashboard bell as high priority.
  Future<void> notifyLowStock({
    required String productName,
    required int currentStock,
    required int minStock,
  }) =>
      _write(
        type: 'low_stock',
        title: 'Low Stock Alert ⚠️',
        body:
        '"$productName" has only $currentStock units left (minimum: $minStock). Reorder soon!',
        screen: 'dashboard',
        extra: {'priority': 'high'},
      );

  // ── OUT OF STOCK 🚨 ──────────────────────────────────────────────
  // Fired automatically by AdminProductsProvider stream when a product's
  // stock transitions from > 0 to 0 (client purchase or manual update).
  // Shows in Dashboard bell as critical priority.
  Future<void> notifyOutOfStock({
    required String productName,
  }) =>
      _write(
        type: 'out_of_stock',
        title: 'Out of Stock 🚨',
        body:
        '"$productName" is now OUT OF STOCK. Immediate reorder required!',
        screen: 'dashboard',
        extra: {'priority': 'critical'},
      );

  // ── Internal writer ──────────────────────────────────────────────
  Future<void> _write({
    required String type,
    required String title,
    required String body,
    required String screen,
    Map<String, dynamic>? extra,
  }) async {
    try {
      final ref = _db.collection('admin_notifications').doc();
      await ref.set({
        'id':        ref.id,
        'type':      type,
        'title':     title,
        'body':      body,
        'screen':    screen,
        'isRead':    false,
        'createdAt': FieldValue.serverTimestamp(),
        if (extra != null) ...extra,
      });

      // Also queue for Cloud Function → FCM device push (background delivery)
      await _db.collection('notifications_queue').add({
        'toUserId':  'admin',
        'title':     title,
        'body':      body,
        'data':      {'type': type, 'screen': screen, ...?extra},
        'processed': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Notifications are non-critical — never crash the app for these
    }
  }
}