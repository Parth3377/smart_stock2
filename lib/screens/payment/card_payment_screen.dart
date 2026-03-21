// ════════════════════════════════════════════════════════════════════
//  lib/screens/payment/card_payment_screen.dart
// ════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/order_model.dart';
import '../../providers/order_draft_provider.dart';
import '../../providers/notification_provider.dart';
import '../../services/order_service.dart';
import '../../routes/app_routes.dart';

class CardPaymentScreen extends StatefulWidget {
  final OrderModel         order;
  final OrderDraftProvider draft;
  final double             total;

  const CardPaymentScreen({
    super.key,
    required this.order,
    required this.draft,
    required this.total,
  });

  @override
  State<CardPaymentScreen> createState() => _CardPaymentScreenState();
}

class _CardPaymentScreenState extends State<CardPaymentScreen>
    with SingleTickerProviderStateMixin {

  final _cardNumberCtrl = TextEditingController();
  final _holderNameCtrl = TextEditingController();
  final _expiryCtrl     = TextEditingController();
  final _cvvCtrl        = TextEditingController();

  bool _saveCard  = false;
  bool _isPaying  = false;
  bool _showCvv   = false;

  late AnimationController _animCtrl;
  late Animation<double>   _fadeAnim;
  late Animation<double>   _slideAnim;

  // Live card preview helpers
  String get _displayNumber => _cardNumberCtrl.text.isEmpty
      ? 'XXXX  XXXX  XXXX  XXXX'
      : _cardNumberCtrl.text;
  String get _displayName   => _holderNameCtrl.text.isEmpty
      ? 'CARD HOLDER'
      : _holderNameCtrl.text.toUpperCase();
  String get _displayExpiry => _expiryCtrl.text.isEmpty ? 'MM/YY' : _expiryCtrl.text;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim  = Tween(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _slideAnim = Tween(begin: 30.0, end: 0.0)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _cardNumberCtrl.dispose();
    _holderNameCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  void _pay() async {
    if (_cardNumberCtrl.text.trim().isEmpty ||
        _holderNameCtrl.text.trim().isEmpty ||
        _expiryCtrl.text.trim().isEmpty ||
        _cvvCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please fill all card details'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent,
      ));
      return;
    }
    if (_cvvCtrl.text.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('CVV must be 3 digits'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent,
      ));
      return;
    }

    setState(() => _isPaying = true);
    await Future.delayed(const Duration(seconds: 2)); // Simulate processing

    OrderService.addOrder(widget.order);
    try {
      if (mounted) {
        context.read<NotificationProvider>().addNotification(
          title:   '🎉 Order Placed!',
          body:    'Your order ${widget.order.id} has been placed for ₹${widget.order.total.toStringAsFixed(0)}.',
          type:    'order_placed',
          orderId: widget.order.id,
        );
      }
    } catch (_) {}

    widget.draft.clearCart();
    setState(() => _isPaying = false);

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
        context, AppRoutes.orderSuccess, (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1218),

      appBar: AppBar(
        backgroundColor: const Color(0xFF161A22),
        elevation: 0,
        title: const Text('Card Payment'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: AnimatedBuilder(
        animation: _animCtrl,
        builder: (_, child) => Opacity(
          opacity: _fadeAnim.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnim.value),
            child: child,
          ),
        ),
        child: Column(children: [

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(children: [

                // ── Live card preview ────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1565C0), Color(0xFF2E6CF6), Color(0xFF0D47A1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2E6CF6).withOpacity(0.4),
                        blurRadius: 20, offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Card chip + brand row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Chip
                          Container(
                            width: 36, height: 26,
                            decoration: BoxDecoration(
                              color: Colors.amber.shade300,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          // VISA-style text
                          const Text('VISA',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                fontStyle: FontStyle.italic,
                                letterSpacing: 2,
                              )),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Card number
                      Text(
                        _displayNumber,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          letterSpacing: 3,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 18),
                      // Name + expiry
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('CARD HOLDER',
                                    style: TextStyle(color: Colors.white54, fontSize: 9)),
                                const SizedBox(height: 2),
                                Text(_displayName,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 13,
                                        fontWeight: FontWeight.w600)),
                              ]),
                          Column(crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('EXPIRES',
                                    style: TextStyle(color: Colors.white54, fontSize: 9)),
                                const SizedBox(height: 2),
                                Text(_displayExpiry,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 13,
                                        fontWeight: FontWeight.w600)),
                              ]),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Form fields ──────────────────────────────────
                _field('Card Number', _cardNumberCtrl,
                  keyboard: TextInputType.number,
                  icon: Icons.credit_card_outlined,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(16),
                    _CardNumberFormatter(),
                  ],
                  hint: 'XXXX XXXX XXXX XXXX',
                ),
                const SizedBox(height: 14),

                _field('Card Holder Name', _holderNameCtrl,
                  icon: Icons.person_outline,
                  hint: 'Full name as on card',
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 14),

                Row(children: [
                  Expanded(
                    child: _field('Expiry (MM/YY)', _expiryCtrl,
                      keyboard: TextInputType.datetime,
                      icon: Icons.calendar_today_outlined,
                      hint: 'MM/YY',
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                        _ExpiryFormatter(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _field('CVV', _cvvCtrl,
                      keyboard: TextInputType.number,
                      icon: Icons.lock_outline,
                      hint: '•••',
                      obscure: !_showCvv,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      suffix: GestureDetector(
                        onTap: () => setState(() => _showCvv = !_showCvv),
                        child: Icon(
                          _showCvv ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white38, size: 18,
                        ),
                      ),
                    ),
                  ),
                ]),

                const SizedBox(height: 16),

                // ── Save card toggle ─────────────────────────────
                GestureDetector(
                  onTap: () => setState(() => _saveCard = !_saveCard),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161A22),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 20, height: 20,
                        decoration: BoxDecoration(
                          color: _saveCard
                              ? const Color(0xFF2E6CF6)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: _saveCard
                                ? const Color(0xFF2E6CF6)
                                : Colors.white38,
                          ),
                        ),
                        child: _saveCard
                            ? const Icon(Icons.check,
                            color: Colors.white, size: 14)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      const Text('Save card for future payments',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 13)),
                    ]),
                  ),
                ),

                const SizedBox(height: 12),

                // ── Security note ────────────────────────────────
                Row(children: [
                  const Icon(Icons.lock_outline,
                      color: Colors.white38, size: 14),
                  const SizedBox(width: 6),
                  const Text('256-bit SSL secured payment',
                      style: TextStyle(color: Colors.white38, fontSize: 12)),
                  const SizedBox(width: 10),
                  const Icon(Icons.verified_user_outlined,
                      color: Colors.white38, size: 14),
                  const SizedBox(width: 4),
                  const Text('PCI DSS Compliant',
                      style: TextStyle(color: Colors.white38, fontSize: 12)),
                ]),
              ]),
            ),
          ),

          // ── Pay button ───────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: const BoxDecoration(
              color: Color(0xFF161A22),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isPaying ? null : _pay,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E6CF6),
                    disabledBackgroundColor: Colors.white10,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isPaying
                      ? const SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                      : Text(
                    'Pay ₹${widget.total.toStringAsFixed(0)} Securely',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  // ── Input field builder ────────────────────────────────────────────
  Widget _field(String label, TextEditingController ctrl, {
    TextInputType keyboard = TextInputType.text,
    IconData? icon,
    String hint = '',
    bool obscure = false,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    Widget? suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161A22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboard,
        obscureText: obscure,
        textCapitalization: textCapitalization,
        inputFormatters: inputFormatters,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFFA1A6B3), fontSize: 12),
          prefixIcon: icon != null
              ? Icon(icon, color: const Color(0xFF2E6CF6), size: 20)
              : null,
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

// ── Card number formatter: XXXX XXXX XXXX XXXX ────────────────────
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue _, TextEditingValue newVal) {
    final digits = newVal.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write('  ');
      buffer.write(digits[i]);
    }
    final str = buffer.toString();
    return newVal.copyWith(
      text: str,
      selection: TextSelection.collapsed(offset: str.length),
    );
  }
}

// ── Expiry formatter: MM/YY ────────────────────────────────────────
class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue _, TextEditingValue newVal) {
    final digits = newVal.text.replaceAll('/', '');
    if (digits.length >= 3) {
      final str = '${digits.substring(0, 2)}/${digits.substring(2)}';
      return newVal.copyWith(
        text: str,
        selection: TextSelection.collapsed(offset: str.length),
      );
    }
    return newVal;
  }
}