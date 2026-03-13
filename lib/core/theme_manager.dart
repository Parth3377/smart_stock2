import 'package:flutter/material.dart';

class ThemeManager extends ChangeNotifier {

  bool _isDark = true;

  bool get isDark => _isDark;

  void toggleTheme(bool value) {
    _isDark = value;
    notifyListeners();
  }
}