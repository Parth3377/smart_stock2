import 'package:flutter/material.dart';
import 'dart:async';

// ═══════════════════════════════════════════════════════════════════
//  Shared Admin Widgets
// ═══════════════════════════════════════════════════════════════════

// ── Colors ──────────────────────────────────────────────────────────
class AC {
  static const bg = Color(0xFF0F1117);
  static const surface = Color(0xFF13161F);
  static const card = Color(0xFF1A1D27);
  static const border = Color(0xFF1E2130);
  static const border2 = Color(0xFF2A2D3E);
  static const blue = Color(0xFF4F8EF7);
  static const purple = Color(0xFF845EF7);
  static const green = Color(0xFF22C55E);
  static const orange = Color(0xFFF59E0B);
  static const red = Color(0xFFEF4444);
  static const text1 = Colors.white;
  static const text2 = Color(0xFF9CA3AF);
  static const text3 = Color(0xFF6B7280);
}

// ── Loading overlay ─────────────────────────────────────────────────
class AdminLoader extends StatelessWidget {
  const AdminLoader({super.key});
  @override
  Widget build(BuildContext context) => const Center(
    child: CircularProgressIndicator(color: AC.blue, strokeWidth: 2),
  );
}

// ── Error state ─────────────────────────────────────────────────────
class AdminError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const AdminError({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.error_outline_rounded, color: AC.red, size: 48),
      const SizedBox(height: 12),
      Text(message, style: const TextStyle(color: AC.text2)),
      const SizedBox(height: 16),
      ElevatedButton(onPressed: onRetry, style: ElevatedButton.styleFrom(backgroundColor: AC.blue), child: const Text('Retry')),
    ]),
  );
}

// ── Empty state ─────────────────────────────────────────────────────
class AdminEmpty extends StatelessWidget {
  final String message;
  final IconData icon;
  const AdminEmpty({super.key, required this.message, this.icon = Icons.inbox_rounded});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: AC.text3, size: 48),
      const SizedBox(height: 12),
      Text(message, style: const TextStyle(color: AC.text3, fontSize: 14)),
    ]),
  );
}

// ── Stat Card ────────────────────────────────────────────────────────
class StatCard extends StatefulWidget {
  final String title, value, change;
  final bool positive;
  final IconData icon;
  final Color accent;
  final VoidCallback? onTap;

  const StatCard({
    super.key, required this.title, required this.value,
    required this.change, required this.positive,
    required this.icon, required this.accent, this.onTap,
  });

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _hovered ? widget.accent.withOpacity(0.08) : AC.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _hovered ? widget.accent.withOpacity(0.4) : AC.border2),
            boxShadow: _hovered ? [BoxShadow(color: widget.accent.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 4))] : [],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: widget.accent.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                child: Icon(widget.icon, color: widget.accent, size: 20),
              ),
              _ChangeBadge(change: widget.change, positive: widget.positive),
            ]),
            const SizedBox(height: 16),
            Text(widget.value, style: const TextStyle(color: AC.text1, fontSize: 24, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(widget.title, style: const TextStyle(color: AC.text3, fontSize: 13)),
            if (widget.onTap != null) ...[
              const SizedBox(height: 8),
              Row(children: [
                Text('View details', style: TextStyle(color: widget.accent, fontSize: 11, fontWeight: FontWeight.w500)),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, color: widget.accent, size: 12),
              ]),
            ],
          ]),
        ),
      ),
    );
  }
}

class _ChangeBadge extends StatelessWidget {
  final String change;
  final bool positive;
  const _ChangeBadge({required this.change, required this.positive});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: (positive ? AC.green : AC.red).withOpacity(0.1),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(positive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, color: positive ? AC.green : AC.red, size: 11),
      const SizedBox(width: 2),
      Text(change, style: TextStyle(color: positive ? AC.green : AC.red, fontSize: 11, fontWeight: FontWeight.w600)),
    ]),
  );
}

// ── Section Card ─────────────────────────────────────────────────────
class SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? action;
  const SectionCard({super.key, required this.title, required this.child, this.action});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: AC.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AC.border2)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(title, style: const TextStyle(color: AC.text1, fontSize: 14, fontWeight: FontWeight.w600)),
          if (action != null) action!,
        ]),
      ),
      const Divider(color: AC.border, height: 1),
      child,
    ]),
  );
}

// ── Status Badge ─────────────────────────────────────────────────────
class SBadge extends StatelessWidget {
  final String label;
  final Color color;
  const SBadge(this.label, this.color, {super.key});

  factory SBadge.fromStatus(String s) {
    switch (s) {
      case 'Delivered': return SBadge(s, AC.green);
      case 'Pending': return SBadge(s, AC.orange);
      case 'Cancelled': return SBadge(s, AC.red);
      case 'In Stock': return SBadge(s, AC.green);
      case 'Low Stock': return SBadge(s, AC.orange);
      case 'Out of Stock': return SBadge(s, AC.red);
      case 'In Transit': return SBadge(s, AC.blue);
      case 'Completed': return SBadge(s, AC.green);
      case 'Active': return SBadge(s, AC.green);
      case 'Inactive': return SBadge(s, AC.red);
      default: return SBadge(s, AC.text3);
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Text(label, style: TextStyle(color: color, fontSize: 11.5, fontWeight: FontWeight.w600)),
  );
}

// ── Table header ─────────────────────────────────────────────────────
class THeader extends StatelessWidget {
  final List<String> cols;
  final String? sortField;
  final bool sortAsc;
  final Function(String)? onSort;

  const THeader({super.key, required this.cols, this.sortField, this.sortAsc = true, this.onSort});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    color: AC.surface,
    child: Row(children: cols.map((c) {
      final key = c.toLowerCase().replaceAll(' ', '_');
      final isSorted = sortField == key;
      return Expanded(child: GestureDetector(
        onTap: onSort != null ? () => onSort!(key) : null,
        child: Row(children: [
          Text(c.toUpperCase(), style: const TextStyle(color: AC.text3, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
          if (isSorted) ...[
            const SizedBox(width: 4),
            Icon(sortAsc ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: AC.blue, size: 14),
          ],
        ]),
      ));
    }).toList()),
  );
}

// ── Table row ────────────────────────────────────────────────────────
class TRow extends StatefulWidget {
  final List<Widget> cells;
  final VoidCallback? onTap;
  const TRow({super.key, required this.cells, this.onTap});

  @override
  State<TRow> createState() => _TRowState();
}

class _TRowState extends State<TRow> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _hov = true),
    onExit: (_) => setState(() => _hov = false),
    child: GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: _hov ? AC.blue.withOpacity(0.04) : Colors.transparent,
          border: const Border(bottom: BorderSide(color: AC.border, width: 0.5)),
        ),
        child: Row(children: widget.cells.map((c) => Expanded(child: c)).toList()),
      ),
    ),
  );
}

// ── Icon Button ──────────────────────────────────────────────────────
class IBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String? tooltip;
  const IBtn({super.key, required this.icon, required this.color, required this.onTap, this.tooltip});

  @override
  Widget build(BuildContext context) {
    final btn = GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30, height: 30,
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(7)),
        child: Icon(icon, color: color, size: 15),
      ),
    );
    if (tooltip != null) return Tooltip(message: tooltip!, child: btn);
    return btn;
  }
}

// ── Primary Action Button ────────────────────────────────────────────
class PBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool primary;
  const PBtn({super.key, required this.label, required this.icon, required this.onTap, this.primary = true});

  @override
  Widget build(BuildContext context) => ElevatedButton.icon(
    onPressed: onTap,
    icon: Icon(icon, size: 16),
    label: Text(label),
    style: ElevatedButton.styleFrom(
      backgroundColor: primary ? AC.blue : AC.card,
      foregroundColor: primary ? Colors.white : AC.text2,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: primary ? BorderSide.none : const BorderSide(color: AC.border2),
      ),
      elevation: 0,
      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
    ),
  );
}

// ── Pagination bar ────────────────────────────────────────────────────
class PaginationBar extends StatelessWidget {
  final int current;
  final int total;
  final Function(int) onChanged;
  const PaginationBar({super.key, required this.current, required this.total, required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    decoration: const BoxDecoration(border: Border(top: BorderSide(color: AC.border))),
    child: Row(children: [
      Text('Page ${current + 1} of $total', style: const TextStyle(color: AC.text3, fontSize: 12)),
      const Spacer(),
      ...[
        (Icons.first_page_rounded, current > 0, () => onChanged(0)),
        (Icons.chevron_left_rounded, current > 0, () => onChanged(current - 1)),
        (Icons.chevron_right_rounded, current < total - 1, () => onChanged(current + 1)),
        (Icons.last_page_rounded, current < total - 1, () => onChanged(total - 1)),
      ].map((e) {
        final (icon, enabled, action) = e;
        return Padding(
          padding: const EdgeInsets.only(left: 4),
          child: GestureDetector(
            onTap: enabled ? action : null,
            child: Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                color: enabled ? AC.surface : AC.border,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: AC.border2),
              ),
              child: Icon(icon, color: enabled ? AC.text1 : AC.text3, size: 16),
            ),
          ),
        );
      }),
    ]),
  );
}

// ── Debounced Search Field ───────────────────────────────────────────
class SearchField extends StatefulWidget {
  final String hint;
  final Function(String) onChanged;
  final double width;

  const SearchField({super.key, required this.hint, required this.onChanged, this.width = 260});

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  Timer? _debounce;
  final _ctrl = TextEditingController();

  void _onChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => widget.onChanged(v));
  }

  @override
  void dispose() { _debounce?.cancel(); _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: widget.width,
    height: 42,
    child: Container(
      decoration: BoxDecoration(
        color: AC.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AC.border2),
      ),
      child: Row(children: [
        const SizedBox(width: 12),
        const Icon(Icons.search_rounded, color: AC.text3, size: 18),
        const SizedBox(width: 8),
        Expanded(child: TextField(
          controller: _ctrl,
          style: const TextStyle(color: AC.text1, fontSize: 13),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(color: AC.text3, fontSize: 13),
            border: InputBorder.none,
          ),
          onChanged: _onChanged,
        )),
        if (_ctrl.text.isNotEmpty)
          GestureDetector(
            onTap: () { _ctrl.clear(); widget.onChanged(''); setState(() {}); },
            child: const Padding(padding: EdgeInsets.only(right: 10), child: Icon(Icons.close_rounded, color: AC.text3, size: 16)),
          ),
      ]),
    ),
  );
}

// ── Form Input Field ─────────────────────────────────────────────────
class FormInput extends StatelessWidget {
  final String label, hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;

  const FormInput({
    super.key, required this.label, required this.hint,
    required this.controller, this.keyboardType, this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(color: AC.text2, fontSize: 12.5, fontWeight: FontWeight.w500)),
    const SizedBox(height: 6),
    TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      style: const TextStyle(color: AC.text1, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AC.text3, fontSize: 13),
        filled: true,
        fillColor: AC.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AC.border2)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AC.border2)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AC.blue)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AC.red)),
      ),
    ),
  ],
  );
}

// ── Dropdown Field ───────────────────────────────────────────────────
class DropdownInput<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> items;
  final String Function(T) itemLabel;
  final Function(T?) onChanged;

  const DropdownInput({
    super.key, required this.label, required this.value,
    required this.items, required this.itemLabel, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(color: AC.text2, fontSize: 12.5, fontWeight: FontWeight.w500)),
    const SizedBox(height: 6),
    DropdownButtonFormField<T>(
      value: value,
      onChanged: onChanged,
      dropdownColor: AC.card,
      style: const TextStyle(color: AC.text1, fontSize: 13),
      decoration: InputDecoration(
        filled: true, fillColor: AC.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AC.border2)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AC.border2)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AC.blue)),
      ),
      items: items.map((i) => DropdownMenuItem(value: i, child: Text(itemLabel(i)))).toList(),
    ),
  ],
  );
}

// ── Confirm Delete Dialog ─────────────────────────────────────────────
Future<bool?> showDeleteDialog(BuildContext context, String name) => showDialog<bool>(
  context: context,
  builder: (_) => AlertDialog(
    backgroundColor: AC.card,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    title: const Text('Confirm Delete', style: TextStyle(color: AC.text1, fontSize: 16, fontWeight: FontWeight.w700)),
    content: Text('Delete "$name"? This action cannot be undone.', style: const TextStyle(color: AC.text2)),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: AC.text3))),
      ElevatedButton(
        onPressed: () => Navigator.pop(context, true),
        style: ElevatedButton.styleFrom(backgroundColor: AC.red, elevation: 0),
        child: const Text('Delete'),
      ),
    ],
  ),
);

// ── Success Snackbar ──────────────────────────────────────────────────
void showSuccess(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Row(children: [
      const Icon(Icons.check_circle_rounded, color: AC.green, size: 18),
      const SizedBox(width: 8),
      Text(msg, style: const TextStyle(color: AC.text1)),
    ]),
    backgroundColor: AC.card,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    duration: const Duration(seconds: 2),
  ));
}

// ── Spark Bar ─────────────────────────────────────────────────────────
class SparkBar extends StatelessWidget {
  final List<double> data;
  final Color color;
  const SparkBar({super.key, required this.data, required this.color});

  @override
  Widget build(BuildContext context) {
    final max = data.fold(0.0, (a, b) => a > b ? a : b);
    return Row(crossAxisAlignment: CrossAxisAlignment.end, children: data.map((v) {
      final pct = max == 0 ? 0.0 : v / max;
      return Padding(
        padding: const EdgeInsets.only(right: 2),
        child: Container(
          width: 6,
          height: (32 * pct).clamp(3.0, 32.0),
          decoration: BoxDecoration(color: color.withOpacity(0.7), borderRadius: BorderRadius.circular(2)),
        ),
      );
    }).toList());
  }
}

// ── Filter Chip ───────────────────────────────────────────────────────
class FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const FilterChip({super.key, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: selected ? AC.blue.withOpacity(0.15) : AC.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: selected ? AC.blue.withOpacity(0.5) : AC.border2),
      ),
      child: Text(label, style: TextStyle(
        color: selected ? AC.blue : AC.text2,
        fontSize: 12.5, fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
      )),
    ),
  );
}

// ── Progress bar ──────────────────────────────────────────────────────
class ProgressBar extends StatelessWidget {
  final double value;
  final Color color;
  final double height;
  const ProgressBar({super.key, required this.value, required this.color, this.height = 5});

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(height),
    child: LinearProgressIndicator(
      value: value.clamp(0.0, 1.0),
      minHeight: height,
      backgroundColor: AC.border2,
      valueColor: AlwaysStoppedAnimation(color),
    ),
  );
}

// ── Helpers ───────────────────────────────────────────────────────────
String fmtCurrency(double v) {
  if (v >= 100000) return '₹${(v / 100000).toStringAsFixed(1)}L';
  if (v >= 1000) return '₹${(v / 1000).toStringAsFixed(1)}k';
  return '₹${v.toStringAsFixed(0)}';
}

String fmtDate(DateTime d) {
  const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  return '${d.day.toString().padLeft(2,'0')} ${months[d.month-1]} ${d.year}';
}

String uniqueId(String prefix) {
  return '$prefix-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
}