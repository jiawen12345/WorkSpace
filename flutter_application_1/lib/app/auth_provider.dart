import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLogin = false;
  String? _token;

  bool get isLogin => _isLogin;
  String? get token => _token;

  void login(String token) {
    _token = token;
    _isLogin = true;
    notifyListeners();
  }

  void logout() {
    _token = null;
    _isLogin = false;
    notifyListeners();
  }
}
