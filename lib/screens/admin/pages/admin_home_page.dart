import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/admin_providers.dart';
import '../widgets/admin_widgets.dart';

// lib/screens/admin/pages/admin_home_page.dart

class AdminHomePage extends StatelessWidget {
  final Function(int) onNavigate;
  const AdminHomePage({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminDashboardProvider>(builder: (_, dash, __) {
      if (dash.state == AdminLoadState.loading || dash.state == AdminLoadState.idle) {
        return const ALoader();
      }
      if (dash.state == AdminLoadState.error) {
        return AError(msg: dash.error ?? 'Failed to load', onRetry: dash.load);
      }

      final s = dash.stats!;

      return Container(
        color: ACol.bg,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // ── Welcome banner ───────────────────────────────────────
            Consumer<AdminProfileProvider>(builder: (_, prof, __) => Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3A5F), Color(0xFF1C2130)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: ACol.border2),
              ),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Good ${_greeting()}, ${prof.name} 👋',
                      style: const TextStyle(color: ACol.text1, fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  const Text('Here\'s what\'s happening with SmartStock today.',
                      style: TextStyle(color: ACol.text2, fontSize: 13)),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: ACol.blue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: ACol.blue.withOpacity(0.3)),
                  ),
                  child: Text(
                    _dateStr(),
                    style: const TextStyle(color: ACol.blue, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
              ]),
            )),

            // ── KPI Cards ────────────────────────────────────────────
            Row(children: [
              Expanded(child: AStatCard(
                title: 'Total Revenue', value: aCurrency(s.totalRevenue),
                change: '${s.revenueChange.abs().toStringAsFixed(1)}%',
                positive: s.revenueChange >= 0,
                icon: Icons.currency_rupee_rounded, accent: ACol.blue,
                onTap: () => onNavigate(2), // → Sales
              )),
              const SizedBox(width: 14),
              Expanded(child: AStatCard(
                title: 'Total Orders', value: s.totalOrders.toString(),
                change: '${s.ordersChange.abs().toStringAsFixed(1)}%',
                positive: s.ordersChange >= 0,
                icon: Icons.shopping_cart_rounded, accent: ACol.purple,
                onTap: () => onNavigate(2), // → Sales
              )),
              const SizedBox(width: 14),
              Expanded(child: AStatCard(
                title: 'Products', value: s.totalProducts.toString(),
                change: '${s.productsChange.abs().toStringAsFixed(1)}%',
                positive: s.productsChange >= 0,
                icon: Icons.inventory_2_rounded, accent: ACol.orange,
                onTap: () => onNavigate(1), // → Products
              )),
              const SizedBox(width: 14),
              Expanded(child: AStatCard(
                title: 'Customers', value: s.totalCustomers.toString(),
                change: '${s.customersChange.abs().toStringAsFixed(1)}%',
                positive: s.customersChange >= 0,
                icon: Icons.people_alt_rounded, accent: ACol.green,
                onTap: () {},
              )),
            ]),

            const SizedBox(height: 22),

            // ── Charts row ───────────────────────────────────────────
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Revenue line chart
              Expanded(flex: 3, child: ASectionCard(
                title: 'Revenue vs Cost',
                action: _PeriodBtn(),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(children: [
                    Row(children: [
                      _Leg(ACol.blue, 'Revenue'),
                      const SizedBox(width: 14),
                      _Leg(ACol.red.withOpacity(0.8), 'Cost'),
                      const SizedBox(width: 14),
                      _Leg(ACol.green, 'Profit'),
                    ]),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 150,
                      child: _RevenueChart(
                        rev: s.monthlyRevenue.map((m) => m.value).toList(),
                        cost: s.monthlyCost.map((m) => m.value).toList(),
                        labels: s.monthlyRevenue.map((m) => m.month).toList(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: s.monthlyRevenue.map((m) =>
                          Text(m.month, style: const TextStyle(color: ACol.text3, fontSize: 9.5))
                      ).toList(),
                    ),
                  ]),
                ),
              )),

              const SizedBox(width: 16),

              // Category donut
              Expanded(flex: 2, child: ASectionCard(
                title: 'By Category',
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(children: [
                    _DonutChart(data: s.categoryData.map((c) => c.percentage).toList()),
                    const SizedBox(height: 14),
                    ...s.categoryData.asMap().entries.map((e) {
                      const colors = [ACol.blue, ACol.purple, ACol.green, ACol.orange, ACol.red];
                      final color = colors[e.key % colors.length];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 7),
                        child: Row(children: [
                          Container(width: 9, height: 9, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                          const SizedBox(width: 7),
                          Expanded(child: Text(e.value.name, style: const TextStyle(color: ACol.text2, fontSize: 11.5))),
                          Text('${e.value.percentage.toStringAsFixed(0)}%',
                              style: const TextStyle(color: ACol.text1, fontSize: 11.5, fontWeight: FontWeight.w600)),
                        ]),
                      );
                    }),
                  ]),
                ),
              )),
            ]),

            const SizedBox(height: 22),

            // ── Recent Orders + Low Stock ─────────────────────────────
            Consumer2<AdminOrdersProvider, AdminProductsProvider>(
              builder: (_, orders, prods, __) => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: ASectionCard(
                    title: 'Recent Orders',
                    action: TextButton(
                      onPressed: () => onNavigate(2),
                      child: const Text('View All →', style: TextStyle(color: ACol.blue, fontSize: 12)),
                    ),
                    child: Column(children: [
                      ATableHeader(cols: const ['Order ID', 'Customer', 'Amount', 'Date', 'Status']),
                      ...orders.allOrders.take(5).map((o) => ATableRow(cells: [
                        Text(o.id, style: const TextStyle(color: ACol.blue, fontSize: 12.5, fontWeight: FontWeight.w600)),
                        Text(o.customerName, style: const TextStyle(color: ACol.text1, fontSize: 12.5)),
                        Text(aCurrency(o.totalAmount), style: const TextStyle(color: ACol.text1, fontSize: 12.5, fontWeight: FontWeight.w600)),
                        Text(aDate(o.date), style: const TextStyle(color: ACol.text3, fontSize: 11.5)),
                        ABadge.status(o.status),
                      ])),
                    ]),
                  )),

                  const SizedBox(width: 16),

                  Expanded(flex: 2, child: ASectionCard(
                    title: '⚠️ Low Stock',
                    action: TextButton(
                      onPressed: () => onNavigate(1),
                      child: const Text('View All →', style: TextStyle(color: ACol.blue, fontSize: 12)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: prods.lowStockItems.isEmpty
                          ? const AEmpty(msg: 'All stock levels healthy', icon: Icons.check_circle_rounded)
                          : Column(
                        children: prods.lowStockItems.take(4).map((p) =>
                            _LowStockTile(name: p.name, sku: p.sku, stock: p.stock, minStock: p.minStock)
                        ).toList(),
                      ),
                    ),
                  )),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // ── Quick stats row ───────────────────────────────────────
            Consumer<AdminOrdersProvider>(builder: (_, orders, __) {
              final now = DateTime.now();
              final todaySales = orders.allOrders
                  .where((o) => o.date.day == now.day && o.status == 'Delivered')
                  .fold(0.0, (double s, o) => s + o.totalAmount);
              final pending = orders.allOrders.where((o) => o.status == 'Pending').length;

              return Consumer<AdminProductsProvider>(builder: (_, prods, __) => Row(children: [
                Expanded(child: _MiniStat('Today\'s Sales', aCurrency(todaySales), [3,5,4,7,6,9,8], ACol.blue)),
                const SizedBox(width: 14),
                Expanded(child: _MiniStat('Pending Orders', '$pending', [6,8,7,5,4,3,2], ACol.orange)),
                const SizedBox(width: 14),
                Expanded(child: _MiniStat('Low Stock Items', '${prods.lowStockItems.length}', [1,2,1,3,2,1,2], ACol.red)),
                const SizedBox(width: 14),
                Expanded(child: _MiniStat('Out of Stock', '${prods.outOfStockItems.length}', [2,1,2,3,1,2,1], ACol.red)),
              ]));
            }),

          ]),
        ),
      );
    });
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Morning';
    if (h < 17) return 'Afternoon';
    return 'Evening';
  }

  String _dateStr() {
    final d = DateTime.now();
    const days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${days[d.weekday-1]}, ${d.day} ${months[d.month-1]} ${d.year}';
  }
}

// ── Local widgets ─────────────────────────────────────────────────────

class _PeriodBtn extends StatefulWidget {
  @override State<_PeriodBtn> createState() => _PeriodBtnState();
}
class _PeriodBtnState extends State<_PeriodBtn> {
  String _v = 'This Month';
  @override
  Widget build(BuildContext context) => DropdownButton<String>(
    value: _v, dropdownColor: ACol.card,
    style: const TextStyle(color: ACol.text2, fontSize: 12),
    underline: const SizedBox(),
    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: ACol.text3, size: 15),
    items: ['Today','This Week','This Month','This Year']
        .map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
    onChanged: (v) => setState(() => _v = v!),
  );
}

class _Leg extends StatelessWidget {
  final Color c; final String l;
  const _Leg(this.c, this.l);
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 9, height: 9, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 5),
    Text(l, style: const TextStyle(color: ACol.text3, fontSize: 10.5)),
  ]);
}

// Interactive Line Chart
class _RevenueChart extends StatefulWidget {
  final List<double> rev, cost;
  final List<String> labels;
  const _RevenueChart({required this.rev, required this.cost, required this.labels});
  @override State<_RevenueChart> createState() => _RevenueChartState();
}
class _RevenueChartState extends State<_RevenueChart> {
  int? _hov;
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (ctx, box) => MouseRegion(
    onHover: (e) => setState(() =>
    _hov = ((e.localPosition.dx / box.maxWidth) * widget.rev.length)
        .floor().clamp(0, widget.rev.length - 1)),
    onExit: (_) => setState(() => _hov = null),
    child: Stack(children: [
      CustomPaint(
        painter: _LinePainter(widget.rev, widget.cost, _hov),
        child: const SizedBox(width: double.infinity, height: double.infinity),
      ),
      if (_hov != null)
        Positioned(
          left: (_hov! / (widget.rev.length - 1)) * (box.maxWidth - 155),
          top: 0,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ACol.surface,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: ACol.border2),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 14)],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.labels[_hov!], style: const TextStyle(color: ACol.text1, fontSize: 11, fontWeight: FontWeight.w700)),
              const SizedBox(height: 5),
              _TR(ACol.blue,   'Revenue', aCurrency(widget.rev[_hov!])),
              _TR(ACol.red,    'Cost',    aCurrency(widget.cost[_hov!])),
              _TR(ACol.green,  'Profit',  aCurrency(widget.rev[_hov!] - widget.cost[_hov!])),
            ]),
          ),
        ),
    ]),
  ));
}

class _TR extends StatelessWidget {
  final Color c; final String l, v;
  const _TR(this.c, this.l, this.v);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 2),
    child: Row(children: [
      Container(width: 6, height: 6, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
      const SizedBox(width: 5),
      Text('$l: ', style: const TextStyle(color: ACol.text3, fontSize: 10)),
      Text(v, style: TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.w600)),
    ]),
  );
}

class _LinePainter extends CustomPainter {
  final List<double> rev, cost; final int? hov;
  _LinePainter(this.rev, this.cost, this.hov);
  @override
  void paint(Canvas canvas, Size size) {
    final max = [...rev, ...cost].fold(0.0, (double a, b) => a > b ? a : b);
    if (max == 0) return;
    void draw(List<double> data, Color color) {
      final pts = List.generate(data.length, (i) => Offset(
        i * size.width / (data.length - 1),
        size.height * (1 - data[i] / max * 0.9),
      ));
      final path = Path()..moveTo(pts[0].dx, pts[0].dy);
      for (var i = 1; i < pts.length; i++) {
        final mid = (pts[i-1].dx + pts[i].dx) / 2;
        path.cubicTo(mid, pts[i-1].dy, mid, pts[i].dy, pts[i].dx, pts[i].dy);
      }
      final fill = Path.from(path)..lineTo(size.width, size.height)..lineTo(0, size.height)..close();
      canvas.drawPath(fill, Paint()
        ..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [color.withOpacity(0.2), color.withOpacity(0)])
            .createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..style = PaintingStyle.fill);
      canvas.drawPath(path, Paint()..color = color..strokeWidth = 2.2..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);
      if (hov != null && hov! < pts.length) {
        canvas.drawCircle(pts[hov!], 4.5, Paint()..color = color);
        canvas.drawCircle(pts[hov!], 4.5, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 1.8);
      }
    }
    draw(rev, ACol.blue);
    draw(cost, const Color(0xFFEF4444));
  }
  @override bool shouldRepaint(covariant _LinePainter old) => old.hov != hov;
}

class _DonutChart extends StatelessWidget {
  final List<double> data;
  const _DonutChart({required this.data});
  static const _colors = [ACol.blue, ACol.purple, ACol.green, ACol.orange, ACol.red];
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 100,
    child: CustomPaint(painter: _DonutP(data, _colors)),
  );
}
class _DonutP extends CustomPainter {
  final List<double> data; final List<Color> colors;
  _DonutP(this.data, this.colors);
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.height * 0.43;
    final p = Paint()..style = PaintingStyle.stroke..strokeWidth = 13..strokeCap = StrokeCap.round;
    double start = -1.57;
    for (var i = 0; i < data.length; i++) {
      p.color = colors[i % colors.length];
      final sweep = 6.28 * (data[i] / 100) - 0.05;
      canvas.drawArc(Rect.fromCircle(center: c, radius: r), start, sweep, false, p);
      start += 6.28 * (data[i] / 100);
    }
  }
  @override bool shouldRepaint(_) => false;
}

class _LowStockTile extends StatelessWidget {
  final String name, sku; final int stock, minStock;
  const _LowStockTile({required this.name, required this.sku, required this.stock, required this.minStock});
  @override
  Widget build(BuildContext context) {
    final pct = (stock / minStock).clamp(0.0, 1.0);
    final isOut = stock == 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(color: ACol.surface, borderRadius: BorderRadius.circular(9), border: Border.all(color: ACol.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Text(name, style: const TextStyle(color: ACol.text1, fontSize: 12, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
          Text('$stock left', style: TextStyle(color: isOut ? ACol.red : ACol.orange, fontSize: 11.5, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 2),
        Text(sku, style: const TextStyle(color: ACol.text3, fontSize: 10.5)),
        const SizedBox(height: 6),
        AProgressBar(value: pct, color: isOut ? ACol.red : ACol.orange),
      ]),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String l, v; final List<int> data; final Color c;
  const _MiniStat(this.l, this.v, this.data, this.c);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: ACol.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: ACol.border2)),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(v, style: const TextStyle(color: ACol.text1, fontSize: 19, fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(l, style: const TextStyle(color: ACol.text3, fontSize: 11.5)),
      ]),
      ASparkBar(data: data.map((e) => e.toDouble()).toList(), color: c),
    ]),
  );
}