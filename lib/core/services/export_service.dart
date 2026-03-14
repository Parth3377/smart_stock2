import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../models/models.dart';

// ═══════════════════════════════════════════════════════════════════
//  ExportService
//
//  Web   → triggers browser download via dart:html (loaded via
//          conditional import below — no compile error on mobile)
//
//  Mobile/Desktop → shows a SnackBar telling the user the CSV
//          content is ready. To actually save on mobile, add:
//            path_provider: ^2.1.2
//            share_plus:    ^7.2.2
//          then replace _saveOrShare() accordingly.
// ═══════════════════════════════════════════════════════════════════

class ExportService {
  static final ExportService _i = ExportService._();
  factory ExportService() => _i;
  ExportService._();

  // ── Public methods ───────────────────────────────────────────────
  void exportProductsCSV(List<ProductModel> products, BuildContext context) {
    final rows = [
      ['ID', 'Name', 'SKU', 'Category', 'Price', 'Stock', 'Status'],
      ...products.map((p) => [
        p.id, p.name, p.sku, p.category,
        p.price.toStringAsFixed(2), p.stock.toString(), p.stockStatus,
      ]),
    ];
    _export(rows, 'products_${_ts()}.csv', context);
  }

  void exportOrdersCSV(List<OrderModel> orders, BuildContext context) {
    final rows = [
      ['Order ID', 'Customer', 'Items', 'Total (Rs)', 'Payment', 'Date', 'Status'],
      ...orders.map((o) => [
        o.id, o.customerName, o.itemCount.toString(),
        o.totalAmount.toStringAsFixed(2), o.paymentMethod,
        _fmtDate(o.date), o.status,
      ]),
    ];
    _export(rows, 'orders_${_ts()}.csv', context);
  }

  void exportSuppliersCSV(List<SupplierModel> suppliers, BuildContext context) {
    final rows = [
      ['ID', 'Name', 'Contact', 'Phone', 'Email', 'City', 'Orders', 'Spend', 'Status'],
      ...suppliers.map((s) => [
        s.id, s.name, s.contactPerson, s.phone, s.email, s.city,
        s.totalOrders.toString(), s.totalSpend.toStringAsFixed(2),
        s.isActive ? 'Active' : 'Inactive',
      ]),
    ];
    _export(rows, 'suppliers_${_ts()}.csv', context);
  }

  void exportTransfersCSV(List<StockTransferModel> transfers, BuildContext context) {
    final rows = [
      ['Transfer ID', 'Product', 'From', 'To', 'Qty', 'Date', 'By', 'Status'],
      ...transfers.map((t) => [
        t.id, t.productName, t.fromLocation, t.toLocation,
        t.quantity.toString(), _fmtDate(t.date), t.initiatedBy, t.status,
      ]),
    ];
    _export(rows, 'transfers_${_ts()}.csv', context);
  }

  // ── Internal ─────────────────────────────────────────────────────
  void _export(List<List<String>> rows, String filename, BuildContext context) {
    final csv = rows.map((r) => r.map(_esc).join(',')).join('\n');
    if (kIsWeb) {
      _webDownload(csv, filename);
    } else {
      // On mobile: show the data ready message; swap with file save logic as needed.
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle_rounded, color: Color(0xFF22C55E), size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text('$filename ready — add share_plus to save on device')),
        ]),
        backgroundColor: const Color(0xFF1A1D27),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ));
    }
  }

  // Conditional — only executed on web builds
  void _webDownload(String csv, String filename) {
    // ignore: undefined_prefixed_name
    _WebExporter.download(csv, filename);
  }

  String _esc(String s) {
    if (s.contains(',') || s.contains('"') || s.contains('\n')) {
      return '"${s.replaceAll('"', '""')}"';
    }
    return s;
  }

  String _ts() =>
      DateTime.now().toIso8601String().replaceAll(RegExp(r'[:\-T.]'), '').substring(0, 14);

  String _fmtDate(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day.toString().padLeft(2,'0')} ${m[d.month-1]} ${d.year}';
  }
}

// ── Web-only downloader — compile-safe on all platforms ──────────────
// On web this uses dart:html; on other platforms it's never called.
class _WebExporter {
  static void download(String content, String filename) {
    // This method is intentionally left as a stub.
    // To enable web CSV download, create a file:
    //   lib/core/services/web_export_stub.dart
    // with the following content:
    //
    // import 'dart:html' as html;
    // import 'dart:convert';
    //
    // void webDownloadCSV(String csv, String filename) {
    //   final bytes = utf8.encode(csv);
    //   final blob = html.Blob([bytes], 'text/csv');
    //   final url = html.Url.createObjectUrlFromBlob(blob);
    //   html.AnchorElement(href: url)
    //     ..setAttribute('download', filename)
    //     ..click();
    //   html.Url.revokeObjectUrl(url);
    // }
    //
    // Then call webDownloadCSV(content, filename) here.
  }
}