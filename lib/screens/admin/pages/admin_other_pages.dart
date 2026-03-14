// ════════════════════════════════════════════════════════════════════
//  lib/screens/admin/pages/admin_sales_page.dart
// ════════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/admin_providers.dart';
import '../widgets/admin_widgets.dart';

class AdminSalesPage extends StatelessWidget {
  const AdminSalesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminOrdersProvider>(builder: (_, prov, __) {
      if (prov.state == AdminLoadState.loading || prov.state == AdminLoadState.idle) return const ALoader();

      final counts = {
        'All': prov.filtered.length,
        'Delivered': prov.filtered.where((o) => o.status == 'Delivered').length,
        'Pending': prov.filtered.where((o) => o.status == 'Pending').length,
        'Cancelled': prov.filtered.where((o) => o.status == 'Cancelled').length,
      };

      return Container(
        color: ACol.bg,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Sales Orders', style: TextStyle(color: ACol.text1, fontSize: 17, fontWeight: FontWeight.w700)),
                Text('${prov.filtered.length} orders total', style: const TextStyle(color: ACol.text3, fontSize: 12.5)),
              ]),
              Row(children: [
                APBtn(label: 'Export CSV', icon: Icons.download_rounded, primary: false, onTap: () => aSuccess(context, 'Sales CSV exported')),
                const SizedBox(width: 10),
                APBtn(label: 'New Sale', icon: Icons.add_rounded, onTap: () => _showNewSale(context, prov)),
              ]),
            ]),
            const SizedBox(height: 18),

            // Stats
            Row(children: [
              _OStat('Revenue', aCurrency(prov.totalRevenue), ACol.green, Icons.trending_up_rounded),
              const SizedBox(width: 10),
              _OStat('Orders', '${prov.filtered.length}', ACol.blue, Icons.receipt_long_rounded),
              const SizedBox(width: 10),
              _OStat('Pending', '${counts['Pending']}', ACol.orange, Icons.hourglass_empty_rounded),
              const SizedBox(width: 10),
              _OStat('Cancelled', '${counts['Cancelled']}', ACol.red, Icons.cancel_rounded),
            ]),
            const SizedBox(height: 18),

            // Filters
            Row(children: [
              ASearchField(hint: 'Search by order ID or customer...', onChanged: prov.setSearch, width: 290),
              const SizedBox(width: 10),
              ...['All', 'Delivered', 'Pending', 'Cancelled'].map((s) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: AFilterChip(
                  label: '$s (${counts[s]})',
                  selected: prov.statusFilter == s,
                  onTap: () => prov.setStatus(s),
                ),
              )),
            ]),
            const SizedBox(height: 14),

            // Table
            Expanded(child: Container(
              decoration: BoxDecoration(color: ACol.card, borderRadius: BorderRadius.circular(13), border: Border.all(color: ACol.border2)),
              child: Column(children: [
                ATableHeader(cols: const ['Order ID', 'Customer', 'Items', 'Amount', 'Payment', 'Date', 'Status', 'Actions']),
                Expanded(child: prov.currentPage.isEmpty
                    ? const AEmpty(msg: 'No orders found', icon: Icons.receipt_long_rounded)
                    : ListView.builder(
                  itemCount: prov.currentPage.length,
                  itemBuilder: (ctx, i) {
                    final o = prov.currentPage[i];
                    return ATableRow(cells: [
                      Text(o.id, style: const TextStyle(color: ACol.blue, fontSize: 12.5, fontWeight: FontWeight.w600)),
                      Text(o.customerName, style: const TextStyle(color: ACol.text1, fontSize: 12.5)),
                      Text('${o.items} item${o.items > 1 ? 's' : ''}', style: const TextStyle(color: ACol.text3, fontSize: 12)),
                      Text(aCurrency(o.totalAmount), style: const TextStyle(color: ACol.text1, fontSize: 12.5, fontWeight: FontWeight.w600)),
                      _PayBadge(o.paymentMethod),
                      Text(aDate(o.date), style: const TextStyle(color: ACol.text3, fontSize: 11.5)),
                      ABadge.status(o.status),
                      Row(children: [
                        AIBtn(icon: Icons.visibility_rounded, color: ACol.blue, onTap: () => _showDetail(context, o)),
                        const SizedBox(width: 6),
                        AIBtn(icon: Icons.edit_rounded, color: ACol.orange, tooltip: 'Update Status', onTap: () => _showStatusDialog(context, prov, o)),
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

  void _showNewSale(BuildContext ctx, AdminOrdersProvider prov) {
    final custCtrl = TextEditingController();
    final amtCtrl  = TextEditingController();
    String selPayment = 'UPI';
    final formKey = GlobalKey<FormState>();
    showDialog(context: ctx, builder: (_) => StatefulBuilder(builder: (dctx, setSt) => Dialog(
      backgroundColor: ACol.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(width: 460, padding: const EdgeInsets.all(26),
        child: Form(key: formKey, child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('New Sale', style: TextStyle(color: ACol.text1, fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14), const Divider(color: ACol.border), const SizedBox(height: 14),
          AFormInput(label: 'Customer Name *', hint: 'e.g. Rahul Mehta', ctrl: custCtrl, validator: (v) => v!.isEmpty ? 'Required' : null),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: AFormInput(label: 'Total Amount (₹) *', hint: '0.00', ctrl: amtCtrl, keyboardType: TextInputType.number,
                validator: (v) => double.tryParse(v ?? '') == null ? 'Invalid' : null)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Payment Method', style: TextStyle(color: ACol.text2, fontSize: 12, fontWeight: FontWeight.w500)),
              const SizedBox(height: 5),
              DropdownButtonFormField<String>(
                value: selPayment, dropdownColor: ACol.card,
                style: const TextStyle(color: ACol.text1, fontSize: 13),
                decoration: InputDecoration(filled: true, fillColor: ACol.surface, contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: ACol.border2)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: ACol.border2))),
                items: ['UPI','Card','Cash','NEFT'].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                onChanged: (v) => setSt(() => selPayment = v!),
              ),
            ])),
          ]),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            TextButton(onPressed: () => Navigator.pop(dctx), child: const Text('Cancel', style: TextStyle(color: ACol.text3))),
            const SizedBox(width: 10),
            APBtn(label: 'Create Sale', icon: Icons.add_shopping_cart_rounded, onTap: () async {
              if (!formKey.currentState!.validate()) return;
              final order = AdminOrder(
                id: 'SO-${aUniqueId('')}', customerName: custCtrl.text.trim(),
                items: 1, totalAmount: double.parse(amtCtrl.text),
                status: 'Pending', paymentMethod: selPayment, date: DateTime.now(),
              );
              Navigator.pop(dctx);
              await prov.add(order);
              if (ctx.mounted) aSuccess(ctx, 'Sale created');
            }),
          ]),
        ])),
      ),
    )));
  }

  void _showStatusDialog(BuildContext ctx, AdminOrdersProvider prov, AdminOrder o) {
    showDialog(context: ctx, builder: (_) => AlertDialog(
      backgroundColor: ACol.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      title: Text('Update ${o.id}', style: const TextStyle(color: ACol.text1, fontSize: 14, fontWeight: FontWeight.w700)),
      content: Column(mainAxisSize: MainAxisSize.min, children: ['Delivered','Pending','Cancelled'].map((s) => ListTile(
        title: Text(s, style: TextStyle(color: o.status == s ? ACol.blue : ACol.text2, fontSize: 13)),
        leading: ABadge.status(s),
        onTap: () async {
          Navigator.pop(ctx);
          await prov.updateStatus(o.id, s);
          if (ctx.mounted) aSuccess(ctx, 'Status updated to $s');
        },
      )).toList()),
    ));
  }

  void _showDetail(BuildContext ctx, AdminOrder o) {
    showDialog(context: ctx, builder: (_) => Dialog(
      backgroundColor: ACol.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(width: 380, padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(o.id, style: const TextStyle(color: ACol.text1, fontSize: 15, fontWeight: FontWeight.w700)),
          ABadge.status(o.status),
        ]),
        const SizedBox(height: 14), const Divider(color: ACol.border), const SizedBox(height: 10),
        ...[['Customer', o.customerName],['Date', aDate(o.date)],['Payment', o.paymentMethod],
          ['Items', '${o.items}'],['Total', aCurrency(o.totalAmount)]].map((r) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(children: [
            SizedBox(width: 80, child: Text(r[0], style: const TextStyle(color: ACol.text3, fontSize: 12))),
            Text(r[1], style: const TextStyle(color: ACol.text1, fontSize: 12.5, fontWeight: FontWeight.w500)),
          ]),
        )),
        const SizedBox(height: 14),
        Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close', style: TextStyle(color: ACol.blue)))),
      ])),
    ));
  }
}

Widget _OStat(String l, String v, Color c, IconData icon) => Expanded(child: Container(
  padding: const EdgeInsets.all(14),
  decoration: BoxDecoration(color: ACol.card, borderRadius: BorderRadius.circular(11), border: Border.all(color: ACol.border2)),
  child: Row(children: [
    Container(width: 34, height: 34, decoration: BoxDecoration(color: c.withOpacity(0.14), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: c, size: 17)),
    const SizedBox(width: 10),
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(v, style: TextStyle(color: c, fontSize: 16, fontWeight: FontWeight.w700)),
      Text(l, style: const TextStyle(color: ACol.text3, fontSize: 10.5)),
    ]),
  ]),
));

class _PayBadge extends StatelessWidget {
  final String m;
  const _PayBadge(this.m);
  @override
  Widget build(BuildContext context) {
    final c = m == 'UPI' ? ACol.purple : m == 'Card' ? ACol.blue : m == 'Cash' ? ACol.green : ACol.orange;
    return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
        child: Text(m, style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w600)));
  }
}

// ════════════════════════════════════════════════════════════════════
//  Purchase Page (stub — expand same as Sales)
// ════════════════════════════════════════════════════════════════════
class AdminPurchasePage extends StatelessWidget {
  const AdminPurchasePage({super.key});
  @override
  Widget build(BuildContext context) => Container(
    color: ACol.bg,
    child: const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.shopping_bag_rounded, color: ACol.blue, size: 48),
      SizedBox(height: 14),
      Text('Purchase Orders', style: TextStyle(color: ACol.text1, fontSize: 18, fontWeight: FontWeight.w700)),
      SizedBox(height: 6),
      Text('Add purchase order data in AdminSuppliersProvider\nand build table same as Sales page.',
          style: TextStyle(color: ACol.text3, fontSize: 13), textAlign: TextAlign.center),
    ])),
  );
}

// ════════════════════════════════════════════════════════════════════
//  Suppliers Page
// ════════════════════════════════════════════════════════════════════
class AdminSuppliersPage extends StatefulWidget {
  const AdminSuppliersPage({super.key});
  @override State<AdminSuppliersPage> createState() => _AdminSuppliersPageState();
}

class _AdminSuppliersPageState extends State<AdminSuppliersPage> {
  @override void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<AdminSuppliersProvider>().state == AdminLoadState.idle)
        context.read<AdminSuppliersProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminSuppliersProvider>(builder: (_, prov, __) {
      if (prov.state == AdminLoadState.loading || prov.state == AdminLoadState.idle) return const ALoader();
      return Container(
        color: ACol.bg,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Suppliers', style: TextStyle(color: ACol.text1, fontSize: 17, fontWeight: FontWeight.w700)),
                Text('${prov.filtered.length} suppliers', style: const TextStyle(color: ACol.text3, fontSize: 12.5)),
              ]),
              Row(children: [
                APBtn(label: 'Export CSV', icon: Icons.download_rounded, primary: false, onTap: () => aSuccess(context, 'Suppliers exported')),
                const SizedBox(width: 10),
                APBtn(label: 'Add Supplier', icon: Icons.add_rounded, onTap: () => _showDialog(context, prov)),
              ]),
            ]),
            const SizedBox(height: 16),
            ASearchField(hint: 'Search by name, city or contact...', onChanged: prov.setSearch, width: 300),
            const SizedBox(height: 18),
            Expanded(child: prov.filtered.isEmpty
                ? const AEmpty(msg: 'No suppliers found', icon: Icons.people_alt_rounded)
                : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: 1.45),
              itemCount: prov.filtered.length,
              itemBuilder: (ctx, i) => _SupCard(
                s: prov.filtered[i],
                onEdit: () => _showDialog(context, prov, supplier: prov.filtered[i]),
                onDelete: () async {
                  final ok = await aConfirmDelete(context, prov.filtered[i].name);
                  if (ok == true) { await prov.delete(prov.filtered[i].id); if (mounted) aSuccess(context, 'Supplier deleted'); }
                },
                onToggle: () async {
                  final s = prov.filtered[i];
                  await prov.update(s.copyWith(isActive: !s.isActive));
                  if (mounted) aSuccess(context, '${s.name} ${!s.isActive ? "activated" : "deactivated"}');
                },
              ),
            ),
            ),
          ]),
        ),
      );
    });
  }

  void _showDialog(BuildContext ctx, AdminSuppliersProvider prov, {AdminSupplier? supplier}) {
    final isEdit = supplier != null;
    final nameCtrl    = TextEditingController(text: supplier?.name ?? '');
    final contactCtrl = TextEditingController(text: supplier?.contactPerson ?? '');
    final phoneCtrl   = TextEditingController(text: supplier?.phone ?? '');
    final emailCtrl   = TextEditingController(text: supplier?.email ?? '');
    final cityCtrl    = TextEditingController(text: supplier?.city ?? '');
    final addrCtrl    = TextEditingController(text: supplier?.address ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(context: ctx, builder: (_) => Dialog(
      backgroundColor: ACol.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(width: 500, padding: const EdgeInsets.all(26),
        child: Form(key: formKey, child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(isEdit ? 'Edit Supplier' : 'Add Supplier', style: const TextStyle(color: ACol.text1, fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14), const Divider(color: ACol.border), const SizedBox(height: 14),
          Row(children: [
            Expanded(child: AFormInput(label: 'Company Name *', hint: 'e.g. HoloTech Pvt Ltd', ctrl: nameCtrl, validator: (v) => v!.isEmpty ? 'Required' : null)),
            const SizedBox(width: 12),
            Expanded(child: AFormInput(label: 'Contact Person *', hint: 'e.g. Ramesh Kumar', ctrl: contactCtrl, validator: (v) => v!.isEmpty ? 'Required' : null)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: AFormInput(label: 'Phone *', hint: '+91 98765 43210', ctrl: phoneCtrl, validator: (v) => v!.isEmpty ? 'Required' : null)),
            const SizedBox(width: 12),
            Expanded(child: AFormInput(label: 'Email *', hint: 'supplier@email.com', ctrl: emailCtrl, validator: (v) => v!.isEmpty ? 'Required' : null)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: AFormInput(label: 'City', hint: 'e.g. Mumbai', ctrl: cityCtrl)),
            const SizedBox(width: 12),
            Expanded(child: AFormInput(label: 'Address', hint: 'Full address', ctrl: addrCtrl)),
          ]),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: ACol.text3))),
            const SizedBox(width: 10),
            APBtn(label: isEdit ? 'Save Changes' : 'Add Supplier', icon: isEdit ? Icons.save_rounded : Icons.add_rounded, onTap: () async {
              if (!formKey.currentState!.validate()) return;
              final s = AdminSupplier(
                id: isEdit ? supplier!.id : aUniqueId('SUP'),
                name: nameCtrl.text.trim(), contactPerson: contactCtrl.text.trim(),
                phone: phoneCtrl.text.trim(), email: emailCtrl.text.trim(),
                city: cityCtrl.text.trim(), address: addrCtrl.text.trim(),
                categories: supplier?.categories ?? [], isActive: supplier?.isActive ?? true,
                totalOrders: supplier?.totalOrders ?? 0, totalSpend: supplier?.totalSpend ?? 0,
              );
              Navigator.pop(ctx);
              if (isEdit) { await prov.update(s); if (ctx.mounted) aSuccess(ctx, 'Supplier updated'); }
              else { await prov.add(s); if (ctx.mounted) aSuccess(ctx, 'Supplier added'); }
            }),
          ]),
        ])),
      ),
    ));
  }
}

class _SupCard extends StatefulWidget {
  final AdminSupplier s; final VoidCallback onEdit, onDelete, onToggle;
  const _SupCard({required this.s, required this.onEdit, required this.onDelete, required this.onToggle});
  @override State<_SupCard> createState() => _SupCardState();
}

class _SupCardState extends State<_SupCard> {
  bool _hov = false;
  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: ACol.card, borderRadius: BorderRadius.circular(13),
          border: Border.all(color: _hov ? ACol.blue.withOpacity(0.3) : ACol.border2),
          boxShadow: _hov ? [BoxShadow(color: ACol.blue.withOpacity(0.07), blurRadius: 14)] : [],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 40, height: 40,
                decoration: BoxDecoration(gradient: const LinearGradient(colors: [ACol.blue, ACol.purple]), borderRadius: BorderRadius.circular(11)),
                child: Center(child: Text(s.name[0], style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)))),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.name, style: const TextStyle(color: ACol.text1, fontSize: 12.5, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
              Text(s.id, style: const TextStyle(color: ACol.text3, fontSize: 10.5)),
            ])),
            GestureDetector(onTap: widget.onToggle, child: ABadge.status(s.isActive ? 'Active' : 'Inactive')),
          ]),
          const SizedBox(height: 12), const Divider(color: ACol.border, height: 1), const SizedBox(height: 10),
          _SL(Icons.person_rounded, s.contactPerson),
          const SizedBox(height: 4), _SL(Icons.location_on_rounded, s.city.isEmpty ? 'N/A' : s.city),
          const SizedBox(height: 4), _SL(Icons.phone_rounded, s.phone),
          const Spacer(),
          Row(children: [
            Expanded(child: _SS('Orders', '${s.totalOrders}')),
            const SizedBox(width: 7),
            Expanded(child: _SS('Spend', aCurrency(s.totalSpend))),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: OutlinedButton.icon(
              onPressed: widget.onEdit,
              icon: const Icon(Icons.edit_rounded, size: 13),
              label: const Text('Edit', style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(foregroundColor: ACol.blue, side: const BorderSide(color: ACol.blue, width: 0.7),
                  padding: const EdgeInsets.symmetric(vertical: 7), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7))),
            )),
            const SizedBox(width: 7),
            OutlinedButton.icon(
              onPressed: widget.onDelete,
              icon: const Icon(Icons.delete_rounded, size: 13),
              label: const Text('', style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(foregroundColor: ACol.red, side: const BorderSide(color: ACol.red, width: 0.7),
                  padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7))),
            ),
          ]),
        ]),
      ),
    );
  }
}

Widget _SL(IconData i, String t) => Row(children: [
  Icon(i, color: ACol.text3, size: 12), const SizedBox(width: 5),
  Expanded(child: Text(t, style: const TextStyle(color: ACol.text2, fontSize: 11.5), overflow: TextOverflow.ellipsis)),
]);

Widget _SS(String l, String v) => Container(
  padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 9),
  decoration: BoxDecoration(color: ACol.surface, borderRadius: BorderRadius.circular(7)),
  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(l, style: const TextStyle(color: ACol.text3, fontSize: 10)),
    Text(v, style: const TextStyle(color: ACol.text1, fontSize: 12, fontWeight: FontWeight.w600)),
  ]),
);

// ════════════════════════════════════════════════════════════════════
//  Stock Transfer Page
// ════════════════════════════════════════════════════════════════════
class AdminTransferPage extends StatelessWidget {
  const AdminTransferPage({super.key});

  static const _locations = ['Main Warehouse','Outlet - Gandhinagar','Outlet - Ahmedabad','Outlet - Surat','Outlet - Vadodara'];

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminTransferProvider>(builder: (_, prov, __) {
      if (prov.state == AdminLoadState.loading || prov.state == AdminLoadState.idle) return const ALoader();
      return Container(
        color: ACol.bg,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Stock Transfer', style: TextStyle(color: ACol.text1, fontSize: 17, fontWeight: FontWeight.w700)),
                Text('${prov.all.length} transfers', style: const TextStyle(color: ACol.text3, fontSize: 12.5)),
              ]),
              APBtn(label: 'New Transfer', icon: Icons.swap_horiz_rounded, onTap: () => _showDialog(context, prov)),
            ]),
            const SizedBox(height: 18),
            Row(children: [
              _TStat('Total', '${prov.all.length}', ACol.blue, Icons.swap_horiz_rounded),
              const SizedBox(width: 10),
              _TStat('Completed', '${prov.all.where((t) => t.status == "Completed").length}', ACol.green, Icons.check_circle_rounded),
              const SizedBox(width: 10),
              _TStat('In Transit', '${prov.all.where((t) => t.status == "In Transit").length}', ACol.orange, Icons.local_shipping_rounded),
              const SizedBox(width: 10),
              _TStat('Locations', '${_locations.length}', ACol.purple, Icons.warehouse_rounded),
            ]),
            const SizedBox(height: 14),
            Expanded(child: Container(
              decoration: BoxDecoration(color: ACol.card, borderRadius: BorderRadius.circular(13), border: Border.all(color: ACol.border2)),
              child: Column(children: [
                ATableHeader(cols: const ['Transfer ID', 'Product', 'From', 'To', 'Qty', 'Date', 'By', 'Status']),
                Expanded(child: ListView.builder(
                  itemCount: prov.all.length,
                  itemBuilder: (ctx, i) {
                    final t = prov.all[i];
                    return ATableRow(cells: [
                      Text(t.id, style: const TextStyle(color: ACol.blue, fontSize: 12.5, fontWeight: FontWeight.w600)),
                      Text(t.productName, style: const TextStyle(color: ACol.text1, fontSize: 12.5), overflow: TextOverflow.ellipsis),
                      Row(children: [const Icon(Icons.warehouse_rounded, color: ACol.text3, size: 12), const SizedBox(width: 4), Expanded(child: Text(t.fromLocation, style: const TextStyle(color: ACol.text3, fontSize: 11.5), overflow: TextOverflow.ellipsis))]),
                      Row(children: [const Icon(Icons.store_rounded, color: ACol.purple, size: 12), const SizedBox(width: 4), Expanded(child: Text(t.toLocation, style: const TextStyle(color: ACol.text2, fontSize: 11.5), overflow: TextOverflow.ellipsis))]),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3), decoration: BoxDecoration(color: ACol.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
                          child: Text('${t.quantity}', style: const TextStyle(color: ACol.blue, fontSize: 11.5, fontWeight: FontWeight.w600))),
                      Text(aDate(t.date), style: const TextStyle(color: ACol.text3, fontSize: 11.5)),
                      Text(t.initiatedBy, style: const TextStyle(color: ACol.text2, fontSize: 11.5)),
                      ABadge.status(t.status),
                    ]);
                  },
                )),
              ]),
            )),
          ]),
        ),
      );
    });
  }

  void _showDialog(BuildContext ctx, AdminTransferProvider prov) {
    final products = ctx.read<AdminProductsProvider>().filtered;
    String selProduct = products.isNotEmpty ? products[0].name : '';
    String selFrom = _locations[0], selTo = _locations[1];
    final qtyCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    showDialog(context: ctx, builder: (_) => StatefulBuilder(builder: (dctx, setSt) => Dialog(
      backgroundColor: ACol.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(width: 480, padding: const EdgeInsets.all(26),
        child: Form(key: formKey, child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: const [Icon(Icons.swap_horiz_rounded, color: ACol.blue, size: 20), SizedBox(width: 8), Text('New Stock Transfer', style: TextStyle(color: ACol.text1, fontSize: 15, fontWeight: FontWeight.w700))]),
          const SizedBox(height: 14), const Divider(color: ACol.border), const SizedBox(height: 14),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Product *', style: TextStyle(color: ACol.text2, fontSize: 12, fontWeight: FontWeight.w500)), const SizedBox(height: 5),
            DropdownButtonFormField<String>(
              value: selProduct.isEmpty ? null : selProduct, dropdownColor: ACol.card,
              hint: const Text('Select product', style: TextStyle(color: ACol.text3)),
              style: const TextStyle(color: ACol.text1, fontSize: 13),
              decoration: InputDecoration(filled: true, fillColor: ACol.surface, contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: ACol.border2)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: ACol.border2))),
              items: products.map((p) => DropdownMenuItem(value: p.name, child: Text(p.name, overflow: TextOverflow.ellipsis))).toList(),
              onChanged: (v) => setSt(() => selProduct = v!), validator: (v) => v == null ? 'Required' : null,
            ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('From *', style: TextStyle(color: ACol.text2, fontSize: 12, fontWeight: FontWeight.w500)), const SizedBox(height: 5),
              DropdownButtonFormField<String>(value: selFrom, dropdownColor: ACol.card, style: const TextStyle(color: ACol.text1, fontSize: 13),
                  decoration: InputDecoration(filled: true, fillColor: ACol.surface, contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: ACol.border2)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: ACol.border2))),
                  items: _locations.map((l) => DropdownMenuItem(value: l, child: Text(l, overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: (v) => setSt(() => selFrom = v!)),
            ])),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('To *', style: TextStyle(color: ACol.text2, fontSize: 12, fontWeight: FontWeight.w500)), const SizedBox(height: 5),
              DropdownButtonFormField<String>(value: selTo, dropdownColor: ACol.card, style: const TextStyle(color: ACol.text1, fontSize: 13),
                  decoration: InputDecoration(filled: true, fillColor: ACol.surface, contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: ACol.border2)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: ACol.border2))),
                  items: _locations.map((l) => DropdownMenuItem(value: l, child: Text(l, overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: (v) => setSt(() => selTo = v!)),
            ])),
          ]),
          const SizedBox(height: 12),
          AFormInput(label: 'Quantity *', hint: 'e.g. 500', ctrl: qtyCtrl, keyboardType: TextInputType.number,
              validator: (v) { final n = int.tryParse(v ?? ''); return (n == null || n <= 0) ? 'Enter valid quantity' : null; }),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            TextButton(onPressed: () => Navigator.pop(dctx), child: const Text('Cancel', style: TextStyle(color: ACol.text3))),
            const SizedBox(width: 10),
            APBtn(label: 'Confirm Transfer', icon: Icons.check_rounded, onTap: () async {
              if (!formKey.currentState!.validate()) return;
              if (selFrom == selTo) { ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('From and To cannot be same'))); return; }
              final t = AdminTransfer(
                id: aUniqueId('ST'), productName: selProduct,
                fromLocation: selFrom, toLocation: selTo,
                quantity: int.parse(qtyCtrl.text), date: DateTime.now(),
                initiatedBy: 'Admin', status: 'In Transit',
              );
              Navigator.pop(dctx);
              await prov.add(t);
              if (ctx.mounted) aSuccess(ctx, 'Transfer initiated');
            }),
          ]),
        ])),
      ),
    )));
  }
}

Widget _TStat(String l, String v, Color c, IconData icon) => Expanded(child: Container(
  padding: const EdgeInsets.all(14),
  decoration: BoxDecoration(color: ACol.card, borderRadius: BorderRadius.circular(11), border: Border.all(color: ACol.border2)),
  child: Row(children: [
    Container(width: 34, height: 34, decoration: BoxDecoration(color: c.withOpacity(0.14), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: c, size: 17)),
    const SizedBox(width: 10),
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(v, style: TextStyle(color: c, fontSize: 17, fontWeight: FontWeight.w700)),
      Text(l, style: const TextStyle(color: ACol.text3, fontSize: 10.5)),
    ]),
  ]),
));

// ════════════════════════════════════════════════════════════════════
//  Reports Page
// ════════════════════════════════════════════════════════════════════
class AdminReportsPage extends StatelessWidget {
  const AdminReportsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<AdminDashboardProvider>(builder: (_, dash, __) {
      if (dash.stats == null) return const ALoader();
      final s = dash.stats!;
      final rev = s.monthlyRevenue.map((m) => m.value).toList();
      final cost = s.monthlyCost.map((m) => m.value).toList();
      final profit = List.generate(rev.length, (i) => rev[i] - cost[i]);
      final labels = s.monthlyRevenue.map((m) => m.month).toList();
      final totalRev = rev.fold(0.0, (a, b) => a + b);
      final totalCost = cost.fold(0.0, (a, b) => a + b);

      return Container(color: ACol.bg, child: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Reports & Analytics', style: TextStyle(color: ACol.text1, fontSize: 17, fontWeight: FontWeight.w700)),
            APBtn(label: 'Export PDF', icon: Icons.picture_as_pdf_rounded, onTap: () => aSuccess(context, 'PDF report ready')),
          ]),
          const SizedBox(height: 20),
          Row(children: [
            _RCard('Total Revenue', aCurrency(totalRev), '+12.5%', ACol.blue, Icons.currency_rupee_rounded),
            const SizedBox(width: 14),
            _RCard('Total Cost', aCurrency(totalCost), '+10.2%', ACol.red, Icons.payments_rounded),
            const SizedBox(width: 14),
            _RCard('Net Profit', aCurrency(totalRev - totalCost), '+15.1%', ACol.green, Icons.trending_up_rounded),
            const SizedBox(width: 14),
            _RCard('Margin', '${totalRev == 0 ? 0 : ((totalRev - totalCost) / totalRev * 100).toStringAsFixed(1)}%', '+2.3%', ACol.purple, Icons.percent_rounded),
          ]),
          const SizedBox(height: 20),

          // Bar chart
          ASectionCard(title: 'Monthly Revenue vs Cost (₹)', child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              SizedBox(height: 180, child: CustomPaint(
                painter: _BarP(rev, cost, profit),
                child: const SizedBox(width: double.infinity),
              )),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: labels.map((l) => Text(l, style: const TextStyle(color: ACol.text3, fontSize: 10))).toList()),
            ]),
          )),
          const SizedBox(height: 18),

          // Monthly table
          ASectionCard(title: 'Monthly Summary', child: Column(children: [
            ATableHeader(cols: const ['Month', 'Revenue', 'Cost', 'Profit', 'Margin']),
            ...List.generate(rev.length, (i) {
              final p = rev[i] - cost[i];
              final m = rev[i] == 0 ? 0.0 : p / rev[i] * 100;
              return ATableRow(cells: [
                Text(labels[i], style: const TextStyle(color: ACol.text1, fontSize: 12.5)),
                Text(aCurrency(rev[i]), style: const TextStyle(color: ACol.blue, fontSize: 12.5, fontWeight: FontWeight.w600)),
                Text(aCurrency(cost[i]), style: const TextStyle(color: ACol.red, fontSize: 12.5, fontWeight: FontWeight.w600)),
                Text(aCurrency(p), style: const TextStyle(color: ACol.green, fontSize: 12.5, fontWeight: FontWeight.w600)),
                Text('${m.toStringAsFixed(1)}%', style: const TextStyle(color: ACol.purple, fontSize: 12)),
              ]);
            }),
          ])),
        ]),
      ));
    });
  }
}

Widget _RCard(String l, String v, String ch, Color c, IconData icon) => Expanded(child: Container(
  padding: const EdgeInsets.all(18),
  decoration: BoxDecoration(color: ACol.card, borderRadius: BorderRadius.circular(13), border: Border.all(color: ACol.border2)),
  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Container(width: 34, height: 34, decoration: BoxDecoration(color: c.withOpacity(0.14), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: c, size: 17)),
      Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3), decoration: BoxDecoration(color: ACol.green.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
          child: Text(ch, style: const TextStyle(color: ACol.green, fontSize: 10.5, fontWeight: FontWeight.w600))),
    ]),
    const SizedBox(height: 12),
    Text(v, style: TextStyle(color: c, fontSize: 20, fontWeight: FontWeight.w700)),
    const SizedBox(height: 2),
    Text(l, style: const TextStyle(color: ACol.text3, fontSize: 12)),
  ]),
));

class _BarP extends CustomPainter {
  final List<double> rev, cost, profit;
  _BarP(this.rev, this.cost, this.profit);
  @override
  void paint(Canvas canvas, Size size) {
    final all = [...rev, ...cost];
    final max = all.fold(0.0, (double a, b) => a > b ? a : b);
    final n = rev.length;
    final gW = size.width / n;
    final bW = gW * 0.21;
    final gap = gW * 0.02;
    for (var i = 0; i < n; i++) {
      final x = i * gW + gW * 0.1;
      void bar(double val, Color c, double off) {
        final h = (val / max) * size.height * 0.88;
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x + off, size.height - h, bW, h), const Radius.circular(3)),
            Paint()..color = c.withOpacity(0.8));
      }
      bar(rev[i], ACol.blue, 0);
      bar(cost[i], ACol.red, bW + gap);
      bar(profit[i], ACol.green, (bW + gap) * 2);
    }
  }
  @override bool shouldRepaint(_) => false;
}

// ════════════════════════════════════════════════════════════════════
//  Profile Page
// ════════════════════════════════════════════════════════════════════
class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});
  @override State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  bool _editing = false;
  late TextEditingController _nameCtrl, _emailCtrl;

  @override void initState() {
    super.initState();
    final p = context.read<AdminProfileProvider>();
    _nameCtrl = TextEditingController(text: p.name);
    _emailCtrl = TextEditingController(text: p.email);
  }
  @override void dispose() { _nameCtrl.dispose(); _emailCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProfileProvider>(builder: (_, prof, __) => Container(
      color: ACol.bg,
      child: Center(child: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 580), child: Column(children: [

          // Avatar card
          Container(padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(color: ACol.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: ACol.border2)),
              child: Column(children: [
                Container(width: 80, height: 80,
                    decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [ACol.purple, ACol.blue], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(20)),
                    child: Center(child: Text(prof.name.isNotEmpty ? prof.name[0].toUpperCase() : 'A',
                        style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w700)))),
                const SizedBox(height: 14),
                Text(prof.name, style: const TextStyle(color: ACol.text1, fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(prof.email, style: const TextStyle(color: ACol.text3, fontSize: 13)),
                const SizedBox(height: 10),
                Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(gradient: const LinearGradient(colors: [ACol.blue, ACol.purple]), borderRadius: BorderRadius.circular(20)),
                    child: Text(prof.role, style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600))),
              ])),

          const SizedBox(height: 16),

          // Edit profile card
          Container(
            decoration: BoxDecoration(color: ACol.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: ACol.border2)),
            child: Column(children: [
              Padding(padding: const EdgeInsets.fromLTRB(18, 14, 14, 14), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Profile Information', style: TextStyle(color: ACol.text1, fontSize: 13.5, fontWeight: FontWeight.w600)),
                if (!_editing) AIBtn(icon: Icons.edit_rounded, color: ACol.blue, onTap: () => setState(() => _editing = true)),
              ])),
              const Divider(color: ACol.border, height: 1),
              Padding(padding: const EdgeInsets.all(18), child: _editing
                  ? Column(children: [
                AFormInput(label: 'Full Name', hint: 'Your name', ctrl: _nameCtrl),
                const SizedBox(height: 12),
                AFormInput(label: 'Email', hint: 'Your email', ctrl: _emailCtrl),
                const SizedBox(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  TextButton(onPressed: () => setState(() => _editing = false), child: const Text('Cancel', style: TextStyle(color: ACol.text3))),
                  const SizedBox(width: 10),
                  APBtn(label: 'Save Changes', icon: Icons.save_rounded, onTap: () {
                    prof.updateProfile(name: _nameCtrl.text.trim(), email: _emailCtrl.text.trim());
                    setState(() => _editing = false);
                    aSuccess(context, 'Profile updated');
                  }),
                ]),
              ])
                  : Column(children: [
                _IRow(Icons.person_rounded, 'Name', prof.name),
                const SizedBox(height: 12),
                _IRow(Icons.email_rounded, 'Email', prof.email),
                const SizedBox(height: 12),
                _IRow(Icons.shield_rounded, 'Role', prof.role),
                const SizedBox(height: 12),
                _IRow(Icons.badge_rounded, 'Admin ID', prof.id),
              ]),
              ),
            ]),
          ),

          const SizedBox(height: 16),

          // Logout
          Container(
            decoration: BoxDecoration(color: ACol.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: ACol.red.withOpacity(0.3))),
            child: Padding(padding: const EdgeInsets.all(18), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Sign Out', style: TextStyle(color: ACol.text1, fontSize: 13.5, fontWeight: FontWeight.w600)),
                Text('Return to login screen', style: TextStyle(color: ACol.text3, fontSize: 12)),
              ]),
              ElevatedButton.icon(
                onPressed: () => showDialog(context: context, builder: (_) => AlertDialog(
                  backgroundColor: ACol.card,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                  title: const Text('Sign out?', style: TextStyle(color: ACol.text1, fontSize: 15, fontWeight: FontWeight.w700)),
                  content: const Text('You will be returned to the login screen.', style: TextStyle(color: ACol.text2)),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: ACol.text3))),
                    ElevatedButton(
                      onPressed: () { Navigator.pop(context); Navigator.pushReplacementNamed(context, '/login'); },
                      style: ElevatedButton.styleFrom(backgroundColor: ACol.red, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      child: const Text('Sign Out'),
                    ),
                  ],
                )),
                icon: const Icon(Icons.logout_rounded, size: 15),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ACol.red.withOpacity(0.14), foregroundColor: ACol.red, elevation: 0,
                  side: const BorderSide(color: ACol.red, width: 0.8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                ),
              ),
            ])),
          ),
        ])),
      )),
    ));
  }
}

Widget _IRow(IconData icon, String l, String v) => Row(children: [
  Container(width: 32, height: 32, decoration: BoxDecoration(color: ACol.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, color: ACol.blue, size: 15)),
  const SizedBox(width: 12),
  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(l, style: const TextStyle(color: ACol.text3, fontSize: 10.5)),
    Text(v, style: const TextStyle(color: ACol.text1, fontSize: 13, fontWeight: FontWeight.w500)),
  ]),
]);