import 'package:flutter/material.dart';
import 'dart:async';

// ════════════════════════════════════════════════════════════════════
//  lib/screens/admin/widgets/admin_widgets.dart
//
//  All reusable admin UI components.
//  Colors match your existing app: 0xFF0F1218 bg, 0xFF161A22 surface
// ════════════════════════════════════════════════════════════════════

// ── Color Palette ─────────────────────────────────────────────────────
class ACol {
  // Matches YOUR existing app colors exactly
  static const bg      = Color(0xFF0F1218);
  static const surface = Color(0xFF161A22);
  static const card    = Color(0xFF1C2130);
  static const border  = Color(0xFF1E2535);
  static const border2 = Color(0xFF253045);

  // Accent — uses your app's primary Color(0xFF2E6CF6)
  static const blue    = Color(0xFF2E6CF6);
  static const purple  = Color(0xFF7C3AED);
  static const green   = Color(0xFF10B981);
  static const orange  = Color(0xFFF59E0B);
  static const red     = Color(0xFFEF4444);
  static const cyan    = Color(0xFF06B6D4);

  // Text
  static const text1 = Colors.white;
  static const text2 = Color(0xFF94A3B8);
  static const text3 = Color(0xFF64748B);
}

// ── Loading ───────────────────────────────────────────────────────────
class ALoader extends StatelessWidget {
  const ALoader({super.key});
  @override
  Widget build(BuildContext context) => const Center(
    child: CircularProgressIndicator(
      color: ACol.blue, strokeWidth: 2.5,
    ),
  );
}

// ── Error ─────────────────────────────────────────────────────────────
class AError extends StatelessWidget {
  final String msg;
  final VoidCallback onRetry;
  const AError({super.key, required this.msg, required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Icon(Icons.error_outline_rounded, color: ACol.red, size: 44),
      const SizedBox(height: 12),
      Text(msg, style: const TextStyle(color: ACol.text2, fontSize: 14)),
      const SizedBox(height: 16),
      ElevatedButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh_rounded, size: 16),
        label: const Text('Retry'),
        style: ElevatedButton.styleFrom(
          backgroundColor: ACol.blue, foregroundColor: Colors.white, elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        ),
      ),
    ],
  ));
}

// ── Empty ─────────────────────────────────────────────────────────────
class AEmpty extends StatelessWidget {
  final String msg;
  final IconData icon;
  const AEmpty({super.key, required this.msg, this.icon = Icons.inbox_rounded});
  @override
  Widget build(BuildContext context) => Center(child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: ACol.text3, size: 44),
      const SizedBox(height: 12),
      Text(msg, style: const TextStyle(color: ACol.text3, fontSize: 13)),
    ],
  ));
}

// ── KPI Stat Card (clickable, hover glow) ────────────────────────────
class AStatCard extends StatefulWidget {
  final String title, value, change;
  final bool positive;
  final IconData icon;
  final Color accent;
  final VoidCallback? onTap;

  const AStatCard({
    super.key, required this.title, required this.value,
    required this.change, required this.positive,
    required this.icon, required this.accent, this.onTap,
  });
  @override
  State<AStatCard> createState() => _AStatCardState();
}

class _AStatCardState extends State<AStatCard> {
  bool _hov = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _hov = true),
    onExit: (_) => setState(() => _hov = false),
    cursor: widget.onTap != null
        ? SystemMouseCursors.click : SystemMouseCursors.basic,
    child: GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _hov ? widget.accent.withOpacity(0.07) : ACol.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _hov ? widget.accent.withOpacity(0.35) : ACol.border2,
          ),
          boxShadow: _hov
              ? [BoxShadow(
              color: widget.accent.withOpacity(0.18),
              blurRadius: 22, offset: const Offset(0, 5))]
              : [],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: widget.accent.withOpacity(0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(widget.icon, color: widget.accent, size: 19),
            ),
            _ChangePill(change: widget.change, positive: widget.positive),
          ]),
          const SizedBox(height: 14),
          Text(widget.value, style: const TextStyle(
              color: ACol.text1, fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 3),
          Text(widget.title, style: const TextStyle(color: ACol.text3, fontSize: 12.5)),
          if (widget.onTap != null) ...[
            const SizedBox(height: 8),
            Row(children: [
              Text('View details', style: TextStyle(
                  color: widget.accent, fontSize: 11, fontWeight: FontWeight.w500)),
              const SizedBox(width: 3),
              Icon(Icons.arrow_forward_rounded, color: widget.accent, size: 12),
            ]),
          ],
        ]),
      ),
    ),
  );
}

class _ChangePill extends StatelessWidget {
  final String change;
  final bool positive;
  const _ChangePill({required this.change, required this.positive});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: (positive ? ACol.green : ACol.red).withOpacity(0.12),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(
        positive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
        color: positive ? ACol.green : ACol.red, size: 11,
      ),
      const SizedBox(width: 2),
      Text(change, style: TextStyle(
        color: positive ? ACol.green : ACol.red,
        fontSize: 11, fontWeight: FontWeight.w600,
      )),
    ]),
  );
}

// ── Section Card ──────────────────────────────────────────────────────
class ASectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? action;
  const ASectionCard({super.key, required this.title, required this.child, this.action});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: ACol.card,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: ACol.border2),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(title, style: const TextStyle(
              color: ACol.text1, fontSize: 13.5, fontWeight: FontWeight.w600)),
          if (action != null) action!,
        ]),
      ),
      const Divider(color: ACol.border, height: 1),
      child,
    ]),
  );
}

// ── Status Badge ──────────────────────────────────────────────────────
class ABadge extends StatelessWidget {
  final String label;
  final Color color;
  const ABadge(this.label, this.color, {super.key});

  factory ABadge.status(String s) {
    switch (s) {
      case 'Delivered':    return ABadge(s, ACol.green);
      case 'Pending':      return ABadge(s, ACol.orange);
      case 'Cancelled':    return ABadge(s, ACol.red);
      case 'In Stock':     return ABadge(s, ACol.green);
      case 'Low Stock':    return ABadge(s, ACol.orange);
      case 'Out of Stock': return ABadge(s, ACol.red);
      case 'In Transit':   return ABadge(s, ACol.cyan);
      case 'Completed':    return ABadge(s, ACol.green);
      case 'Active':       return ABadge(s, ACol.green);
      case 'Inactive':     return ABadge(s, ACol.red);
      default:             return ABadge(s, ACol.text3);
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.28)),
    ),
    child: Text(label, style: TextStyle(
        color: color, fontSize: 11, fontWeight: FontWeight.w600)),
  );
}

// ── Table Header ──────────────────────────────────────────────────────
class ATableHeader extends StatelessWidget {
  final List<String> cols;
  final String? sortField;
  final bool sortAsc;
  final Function(String)? onSort;

  const ATableHeader({super.key, required this.cols,
    this.sortField, this.sortAsc = true, this.onSort});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
    color: ACol.surface,
    child: Row(children: cols.map((c) {
      final key = c.toLowerCase().replaceAll(' ', '_');
      final sorted = sortField == key;
      return Expanded(child: GestureDetector(
        onTap: onSort != null ? () => onSort!(key) : null,
        child: Row(children: [
          Text(c.toUpperCase(), style: const TextStyle(
              color: ACol.text3, fontSize: 10.5,
              fontWeight: FontWeight.w600, letterSpacing: 0.7)),
          if (sorted) ...[
            const SizedBox(width: 3),
            Icon(sortAsc ? Icons.keyboard_arrow_up_rounded
                : Icons.keyboard_arrow_down_rounded,
                color: ACol.blue, size: 13),
          ],
        ]),
      ));
    }).toList()),
  );
}

// ── Table Row ─────────────────────────────────────────────────────────
class ATableRow extends StatefulWidget {
  final List<Widget> cells;
  final VoidCallback? onTap;
  const ATableRow({super.key, required this.cells, this.onTap});
  @override
  State<ATableRow> createState() => _ATableRowState();
}

class _ATableRowState extends State<ATableRow> {
  bool _hov = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _hov = true),
    onExit: (_) => setState(() => _hov = false),
    child: GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 130),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        decoration: BoxDecoration(
          color: _hov ? ACol.blue.withOpacity(0.04) : Colors.transparent,
          border: const Border(bottom: BorderSide(color: ACol.border, width: 0.5)),
        ),
        child: Row(children: widget.cells.map((c) => Expanded(child: c)).toList()),
      ),
    ),
  );
}

// ── Primary Button ────────────────────────────────────────────────────
class APBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool primary;
  const APBtn({super.key, required this.label, required this.icon,
    required this.onTap, this.primary = true});
  @override
  Widget build(BuildContext context) => ElevatedButton.icon(
    onPressed: onTap,
    icon: Icon(icon, size: 15),
    label: Text(label),
    style: ElevatedButton.styleFrom(
      backgroundColor: primary ? ACol.blue : ACol.card,
      foregroundColor: primary ? Colors.white : ACol.text2,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(9),
        side: primary ? BorderSide.none : const BorderSide(color: ACol.border2),
      ),
      textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
    ),
  );
}

// ── Icon Button ───────────────────────────────────────────────────────
class AIBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String? tooltip;
  const AIBtn({super.key, required this.icon, required this.color,
    required this.onTap, this.tooltip});
  @override
  Widget build(BuildContext context) {
    final btn = GestureDetector(
      onTap: onTap,
      child: Container(
        width: 29, height: 29,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Icon(icon, color: color, size: 14),
      ),
    );
    return tooltip != null ? Tooltip(message: tooltip!, child: btn) : btn;
  }
}

// ── Pagination ────────────────────────────────────────────────────────
class APagination extends StatelessWidget {
  final int current, total;
  final Function(int) onChanged;
  const APagination({super.key, required this.current,
    required this.total, required this.onChanged});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
    decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: ACol.border))),
    child: Row(children: [
      Text('Page ${current + 1} of $total',
          style: const TextStyle(color: ACol.text3, fontSize: 12)),
      const Spacer(),
      ...[
        (Icons.first_page_rounded,    current > 0,            () => onChanged(0)),
        (Icons.chevron_left_rounded,  current > 0,            () => onChanged(current - 1)),
        (Icons.chevron_right_rounded, current < total - 1,    () => onChanged(current + 1)),
        (Icons.last_page_rounded,     current < total - 1,    () => onChanged(total - 1)),
      ].map((e) {
        final (ic, enabled, fn) = e;
        return Padding(
          padding: const EdgeInsets.only(left: 4),
          child: GestureDetector(
            onTap: enabled ? fn : null,
            child: Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: enabled ? ACol.surface : ACol.border,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: ACol.border2),
              ),
              child: Icon(ic, color: enabled ? ACol.text1 : ACol.text3, size: 15),
            ),
          ),
        );
      }),
    ]),
  );
}

// ── Debounced Search Field ─────────────────────────────────────────────
class ASearchField extends StatefulWidget {
  final String hint;
  final Function(String) onChanged;
  final double width;
  const ASearchField({super.key, required this.hint,
    required this.onChanged, this.width = 260});
  @override
  State<ASearchField> createState() => _ASearchFieldState();
}

class _ASearchFieldState extends State<ASearchField> {
  final _ctrl = TextEditingController();
  Timer? _t;
  @override
  void dispose() { _t?.cancel(); _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => SizedBox(
    width: widget.width, height: 38,
    child: Container(
      decoration: BoxDecoration(
        color: ACol.card,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: ACol.border2),
      ),
      child: Row(children: [
        const SizedBox(width: 10),
        const Icon(Icons.search_rounded, color: ACol.text3, size: 16),
        const SizedBox(width: 7),
        Expanded(child: TextField(
          controller: _ctrl,
          style: const TextStyle(color: ACol.text1, fontSize: 12.5),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(color: ACol.text3, fontSize: 12.5),
            border: InputBorder.none, isDense: true,
          ),
          onChanged: (v) {
            _t?.cancel();
            _t = Timer(const Duration(milliseconds: 320), () => widget.onChanged(v));
            setState(() {});
          },
        )),
        if (_ctrl.text.isNotEmpty)
          GestureDetector(
            onTap: () { _ctrl.clear(); widget.onChanged(''); setState(() {}); },
            child: const Padding(padding: EdgeInsets.only(right: 8),
                child: Icon(Icons.close_rounded, color: ACol.text3, size: 14)),
          ),
      ]),
    ),
  );
}

// ── Form Input ────────────────────────────────────────────────────────
class AFormInput extends StatelessWidget {
  final String label, hint;
  final TextEditingController ctrl;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  const AFormInput({super.key, required this.label, required this.hint,
    required this.ctrl, this.keyboardType, this.validator, this.maxLines = 1});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: ACol.text2, fontSize: 12, fontWeight: FontWeight.w500)),
      const SizedBox(height: 5),
      TextFormField(
        controller: ctrl, keyboardType: keyboardType,
        validator: validator, maxLines: maxLines,
        style: const TextStyle(color: ACol.text1, fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: ACol.text3, fontSize: 12.5),
          filled: true, fillColor: ACol.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: ACol.border2)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: ACol.border2)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: ACol.blue)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: ACol.red)),
        ),
      ),
    ],
  );
}

// ── Filter Chip ───────────────────────────────────────────────────────
class AFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const AFilterChip({super.key, required this.label,
    required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? ACol.blue.withOpacity(0.14) : ACol.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: selected ? ACol.blue.withOpacity(0.45) : ACol.border2,
        ),
      ),
      child: Text(label, style: TextStyle(
        color: selected ? ACol.blue : ACol.text2,
        fontSize: 12, fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
      )),
    ),
  );
}

// ── Progress Bar ──────────────────────────────────────────────────────
class AProgressBar extends StatelessWidget {
  final double value;
  final Color color;
  final double height;
  const AProgressBar({super.key, required this.value, required this.color, this.height = 5});
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(height),
    child: LinearProgressIndicator(
      value: value.clamp(0.0, 1.0),
      minHeight: height,
      backgroundColor: ACol.border2,
      valueColor: AlwaysStoppedAnimation(color),
    ),
  );
}

// ── Spark Bar ─────────────────────────────────────────────────────────
class ASparkBar extends StatelessWidget {
  final List<double> data;
  final Color color;
  const ASparkBar({super.key, required this.data, required this.color});
  @override
  Widget build(BuildContext context) {
    final max = data.fold(0.0, (double a, b) => a > b ? a : b);
    return Row(crossAxisAlignment: CrossAxisAlignment.end, children: data.map((v) {
      final pct = max == 0 ? 0.0 : v / max;
      return Padding(
        padding: const EdgeInsets.only(right: 2),
        child: Container(
          width: 5, height: (28 * pct).clamp(3.0, 28.0),
          decoration: BoxDecoration(
            color: color.withOpacity(0.7),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );
    }).toList());
  }
}

// ── Confirm Delete Dialog ─────────────────────────────────────────────
Future<bool?> aConfirmDelete(BuildContext context, String name) => showDialog<bool>(
  context: context,
  builder: (_) => AlertDialog(
    backgroundColor: ACol.card,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
    title: const Text('Confirm Delete',
        style: TextStyle(color: ACol.text1, fontSize: 15, fontWeight: FontWeight.w700)),
    content: Text('Delete "$name"? This cannot be undone.',
        style: const TextStyle(color: ACol.text2, fontSize: 13)),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: const Text('Cancel', style: TextStyle(color: ACol.text3)),
      ),
      ElevatedButton(
        onPressed: () => Navigator.pop(context, true),
        style: ElevatedButton.styleFrom(backgroundColor: ACol.red, elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        child: const Text('Delete'),
      ),
    ],
  ),
);

// ── Success Snackbar ──────────────────────────────────────────────────
void aSuccess(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Row(children: [
      const Icon(Icons.check_circle_rounded, color: ACol.green, size: 16),
      const SizedBox(width: 8),
      Text(msg, style: const TextStyle(color: ACol.text1, fontSize: 13)),
    ]),
    backgroundColor: ACol.card,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    duration: const Duration(seconds: 2),
    margin: const EdgeInsets.all(16),
  ));
}

// ── Helpers ───────────────────────────────────────────────────────────
String aCurrency(double v) {
  if (v >= 100000) return '₹${(v / 100000).toStringAsFixed(1)}L';
  if (v >= 1000)   return '₹${(v / 1000).toStringAsFixed(1)}k';
  return '₹${v.toStringAsFixed(0)}';
}

String aDate(DateTime d) {
  const m = ['Jan','Feb','Mar','Apr','May','Jun',
    'Jul','Aug','Sep','Oct','Nov','Dec'];
  return '${d.day.toString().padLeft(2,'0')} ${m[d.month-1]} ${d.year}';
}

String aUniqueId(String prefix) =>
    '$prefix${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';