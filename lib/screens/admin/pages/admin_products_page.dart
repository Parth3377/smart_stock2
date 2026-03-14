// ════════════════════════════════════════════════════════════════════
//  lib/screens/admin/pages/admin_products_page.dart
// ════════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/admin_providers.dart';
import '../widgets/admin_widgets.dart';

class AdminProductsPage extends StatefulWidget {
  const AdminProductsPage({super.key});
  @override State<AdminProductsPage> createState() => _AdminProductsPageState();
}

class _AdminProductsPageState extends State<AdminProductsPage> {
  @override void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<AdminProductsProvider>().state == AdminLoadState.idle) {
        context.read<AdminProductsProvider>().load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProductsProvider>(builder: (_, prov, __) {
      if (prov.state == AdminLoadState.loading || prov.state == AdminLoadState.idle) return const ALoader();
      return Container(
        color: ACol.bg,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Header
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Product Inventory', style: TextStyle(color: ACol.text1, fontSize: 17, fontWeight: FontWeight.w700)),
                Text('${prov.filtered.length} products', style: const TextStyle(color: ACol.text3, fontSize: 12.5)),
              ]),
              Row(children: [
                APBtn(label: 'Export CSV', icon: Icons.download_rounded, primary: false, onTap: () => aSuccess(context, 'CSV exported')),
                const SizedBox(width: 10),
                APBtn(label: 'Add Product', icon: Icons.add_rounded, onTap: () => _showDialog(context, prov)),
              ]),
            ]),
            const SizedBox(height: 18),

            // Mini stats
            Row(children: [
              _PStat('Total', '${prov.filtered.length}', ACol.blue, Icons.inventory_2_rounded),
              const SizedBox(width: 10),
              _PStat('In Stock', '${prov.filtered.where((p) => p.stockStatus == "In Stock").length}', ACol.green, Icons.check_circle_rounded),
              const SizedBox(width: 10),
              _PStat('Low Stock', '${prov.lowStockItems.length}', ACol.orange, Icons.warning_rounded),
              const SizedBox(width: 10),
              _PStat('Out of Stock', '${prov.outOfStockItems.length}', ACol.red, Icons.cancel_rounded),
            ]),
            const SizedBox(height: 18),

            // Filters
            Row(children: [
              ASearchField(hint: 'Search by name or SKU...', onChanged: prov.setSearch, width: 270),
              const SizedBox(width: 10),
              Expanded(child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: prov.categories.map((c) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: AFilterChip(label: c, selected: prov.selectedCategory == c, onTap: () => prov.setCategory(c)),
                )).toList()),
              )),
            ]),
            const SizedBox(height: 14),

            // Table
            Expanded(child: Container(
              decoration: BoxDecoration(color: ACol.card, borderRadius: BorderRadius.circular(13), border: Border.all(color: ACol.border2)),
              child: Column(children: [
                ATableHeader(cols: const ['Product', 'SKU', 'Category', 'Price', 'Stock', 'Status', 'Actions'],
                    sortField: prov.sortField, sortAsc: prov.sortAsc, onSort: prov.setSort),
                Expanded(child: prov.currentPage.isEmpty
                    ? const AEmpty(msg: 'No products match your filters', icon: Icons.inventory_2_rounded)
                    : ListView.builder(
                  itemCount: prov.currentPage.length,
                  itemBuilder: (ctx, i) {
                    final p = prov.currentPage[i];
                    return ATableRow(cells: [
                      Row(children: [
                        Container(width: 30, height: 30, decoration: BoxDecoration(color: ACol.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(7)),
                            child: const Icon(Icons.inventory_2_rounded, color: ACol.blue, size: 15)),
                        const SizedBox(width: 9),
                        Expanded(child: Text(p.name, style: const TextStyle(color: ACol.text1, fontSize: 12.5, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
                      ]),
                      Text(p.sku, style: const TextStyle(color: ACol.text3, fontSize: 11.5, fontFamily: 'monospace')),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(color: ACol.purple.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
                          child: Text(p.category, style: const TextStyle(color: ACol.purple, fontSize: 11))),
                      Text('₹${p.price.toStringAsFixed(2)}', style: const TextStyle(color: ACol.text1, fontSize: 12.5, fontWeight: FontWeight.w600)),
                      Text('${p.stock}', style: TextStyle(color: p.stock == 0 ? ACol.red : p.stock < p.minStock ? ACol.orange : ACol.green, fontSize: 12.5, fontWeight: FontWeight.w600)),
                      ABadge.status(p.stockStatus),
                      Row(children: [
                        AIBtn(icon: Icons.edit_rounded, color: ACol.blue, tooltip: 'Edit', onTap: () => _showDialog(context, prov, product: p)),
                        const SizedBox(width: 6),
                        AIBtn(icon: Icons.delete_rounded, color: ACol.red, tooltip: 'Delete', onTap: () async {
                          final ok = await aConfirmDelete(context, p.name);
                          if (ok == true) { await prov.delete(p.id); if (mounted) aSuccess(context, '${p.name} deleted'); }
                        }),
                      ]),
                    ]);
                  },
                ),
                ),
                APagination(current: prov.page, total: prov.totalPages, onChanged: prov.setPage),
              ]),
            )),
          ]),
        ),
      );
    });
  }

  void _showDialog(BuildContext ctx, AdminProductsProvider prov, {AdminProduct? product}) {
    final isEdit = product != null;
    final nameCtrl = TextEditingController(text: product?.name ?? '');
    final skuCtrl  = TextEditingController(text: product?.sku  ?? '');
    final priceCtrl = TextEditingController(text: product?.price.toStringAsFixed(2) ?? '');
    final stockCtrl = TextEditingController(text: product?.stock.toString() ?? '');
    final minCtrl   = TextEditingController(text: product?.minStock.toString() ?? '10');
    String selCat = product?.category ?? 'Holograms';
    final formKey = GlobalKey<FormState>();

    showDialog(context: ctx, builder: (_) => StatefulBuilder(builder: (dctx, setSt) => Dialog(
      backgroundColor: ACol.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(
        width: 480, padding: const EdgeInsets.all(26),
        child: Form(key: formKey, child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(isEdit ? 'Edit Product' : 'Add New Product', style: const TextStyle(color: ACol.text1, fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          const Divider(color: ACol.border),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: AFormInput(label: 'Product Name *', hint: 'e.g. Hologram Sticker', ctrl: nameCtrl, validator: (v) => v!.isEmpty ? 'Required' : null)),
            const SizedBox(width: 12),
            Expanded(child: AFormInput(label: 'SKU *', hint: 'e.g. HOL-001', ctrl: skuCtrl, validator: (v) => v!.isEmpty ? 'Required' : null)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: AFormInput(label: 'Price (₹) *', hint: '0.00', ctrl: priceCtrl, keyboardType: TextInputType.number,
                validator: (v) => double.tryParse(v ?? '') == null ? 'Enter valid price' : null)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Category *', style: TextStyle(color: ACol.text2, fontSize: 12, fontWeight: FontWeight.w500)),
              const SizedBox(height: 5),
              DropdownButtonFormField<String>(
                value: selCat, dropdownColor: ACol.card,
                style: const TextStyle(color: ACol.text1, fontSize: 13),
                decoration: InputDecoration(filled: true, fillColor: ACol.surface,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: ACol.border2)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: ACol.border2))),
                items: ['Holograms','Labels','Stickers','Security Tags','Other']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setSt(() => selCat = v!),
              ),
            ])),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: AFormInput(label: 'Stock Quantity *', hint: '0', ctrl: stockCtrl, keyboardType: TextInputType.number,
                validator: (v) => int.tryParse(v ?? '') == null ? 'Invalid' : null)),
            const SizedBox(width: 12),
            Expanded(child: AFormInput(label: 'Min Stock Level', hint: '10', ctrl: minCtrl, keyboardType: TextInputType.number)),
          ]),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            TextButton(onPressed: () => Navigator.pop(dctx), child: const Text('Cancel', style: TextStyle(color: ACol.text3))),
            const SizedBox(width: 10),
            APBtn(label: isEdit ? 'Save Changes' : 'Add Product', icon: isEdit ? Icons.save_rounded : Icons.add_rounded, onTap: () async {
              if (!formKey.currentState!.validate()) return;
              final p = AdminProduct(
                id: isEdit ? product!.id : aUniqueId('P'),
                name: nameCtrl.text.trim(), sku: skuCtrl.text.trim(),
                category: selCat, price: double.parse(priceCtrl.text),
                stock: int.parse(stockCtrl.text), minStock: int.tryParse(minCtrl.text) ?? 10,
              );
              Navigator.pop(dctx);
              if (isEdit) { await prov.update(p); if (mounted) aSuccess(context, 'Product updated'); }
              else { await prov.add(p); if (mounted) aSuccess(context, 'Product added'); }
            }),
          ]),
        ])),
      ),
    )));
  }
}

Widget _PStat(String l, String v, Color c, IconData icon) => Expanded(child: Container(
  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  decoration: BoxDecoration(color: ACol.card, borderRadius: BorderRadius.circular(11), border: Border.all(color: ACol.border2)),
  child: Row(children: [
    Icon(icon, color: c, size: 17),
    const SizedBox(width: 9),
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(v, style: TextStyle(color: c, fontSize: 17, fontWeight: FontWeight.w700)),
      Text(l, style: const TextStyle(color: ACol.text3, fontSize: 10.5)),
    ]),
  ]),
));