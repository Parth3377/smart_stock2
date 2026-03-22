// ════════════════════════════════════════════════════════════════════
//  lib/core/theme_manager.dart
// ════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

class ThemeManager extends ChangeNotifier {

  bool _isDark = true;

  bool get isDark => _isDark;

  void toggleTheme(bool value) {
    _isDark = value;
    notifyListeners();
  }

  // ── Color helpers — use these in screens instead of hardcoded colors ──
  // Background colors
  Color get bgPrimary  => _isDark ? const Color(0xFF0F1218) : const Color(0xFFF4F6FA);
  Color get bgSurface  => _isDark ? const Color(0xFF161A22) : Colors.white;
  Color get bgElevated => _isDark ? const Color(0xFF1E2532) : const Color(0xFFEEF2F8);

  // Text colors
  Color get textPrimary   => _isDark ? Colors.white             : const Color(0xFF1A1D26);
  Color get textSecondary => _isDark ? const Color(0xFFA1A6B3)  : const Color(0xFF6B7280);
  Color get textHint      => _isDark ? const Color(0xFF6B7280)  : const Color(0xFF9CA3AF);

  // Border colors
  Color get borderColor   => _isDark ? Colors.white12           : const Color(0xFFE5E7EB);

  // Input field fill
  Color get inputFill     => _isDark ? const Color(0xFF161A22)  : Colors.white;
  Color get inputFillAlt  => _isDark ? const Color(0xFF0F1218)  : const Color(0xFFF9FAFB);

  // Accent (unchanged in both modes)
  static const Color accent = Color(0xFF2E6CF6);
}

// import 'package:flutter/material.dart';
//
// class ThemeManager extends ChangeNotifier {
//
//   bool _isDark = true;
//
//   bool get isDark => _isDark;
//
//   void toggleTheme(bool value) {
//     _isDark = value;
//     notifyListeners();
//   }
// }