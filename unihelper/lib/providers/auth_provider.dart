// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userName;
  String? _userEmail;

  bool get isAuthenticated => _isAuthenticated;
  String? get userName => _userName;
  String? get userEmail => _userEmail;

  // Mock login
  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // simulate delay
    if (email == 'test@uni.com' && password == '123456') {
      _isAuthenticated = true;
      _userEmail = email;
      _userName = "Test User";
      notifyListeners();
      return true;
    }
    return false;
  }

  // Mock register
  Future<bool> register(String name, String email, String phone, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    _isAuthenticated = true;
    _userEmail = email;
    _userName = name;
    notifyListeners();
    return true;
  }

  void logout() {
    _isAuthenticated = false;
    _userEmail = null;
    _userName = null;
    notifyListeners();
  }
}
