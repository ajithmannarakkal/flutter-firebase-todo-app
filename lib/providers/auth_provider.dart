import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final _authService = AuthService();

  String? _token;
  String? _userId;
  DateTime? _expiryDate;
  bool _isLoading = false;
  String? _errorMsg;

  String? get token {
    if (_token != null &&
        _expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now())) {
      return _token;
    }
    return null;
  }

  bool get isAuth => token != null;
  String? get userId => _userId;
  bool get isLoading => _isLoading;
  String? get error => _errorMsg;

  Future<bool> signUp(String email, String password) async {
    return _handleAuth(() => _authService.signUp(email, password));
  }

  Future<bool> signIn(String email, String password) async {
    return _handleAuth(() => _authService.signIn(email, password));
  }

  Future<bool> _handleAuth(
      Future<Map<String, dynamic>> Function() authFn) async {
    _isLoading = true;
    _errorMsg = null;
    notifyListeners();

    try {
      final data = await authFn();
      _token = data['idToken'];
      _userId = data['localId'];
      _expiryDate = DateTime.now().add(
        Duration(seconds: int.parse(data['expiresIn'])),
      );
      return true;
    } catch (e) {
      _errorMsg = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _token = null;
    _userId = null;
    _expiryDate = null;
    _errorMsg = null;
    notifyListeners();
  }

  void clearError() {
    _errorMsg = null;
    notifyListeners();
  }
}
