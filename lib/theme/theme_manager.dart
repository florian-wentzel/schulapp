import 'package:flutter/material.dart';

///singelton damit es immer nur eine instanz gibt
class ThemeManager with ChangeNotifier {
  static final ThemeManager _instance = ThemeManager._privateConstructor();
  ThemeManager._privateConstructor();

  factory ThemeManager() {
    return _instance;
  }

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}
