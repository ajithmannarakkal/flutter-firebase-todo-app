import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final _authService = AuthService();
  final _storage = const FlutterSecureStorage();

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

  // try to auto-login from saved token
  Future<bool> tryAutoLogin() async {
    final savedToken = await _storage.read(key: 'token');
    final savedUserId = await _storage.read(key: 'userId');
    final savedExpiry = await _storage.read(key: 'expiryDate');

    if (savedToken == null || savedUserId == null || savedExpiry == null) {
      return false;
    }

    final expiry = DateTime.tryParse(savedExpiry);
    if (expiry == null || expiry.isBefore(DateTime.now())) {
      await _clearStorage();
      return false;
    }

    _token = savedToken;
    _userId = savedUserId;
    _expiryDate = expiry;
    notifyListeners();
    return true;
  }

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

      // save to secure storage
      await _storage.write(key: 'token', value: _token);
      await _storage.write(key: 'userId', value: _userId);
      await _storage.write(key: 'expiryDate', value: _expiryDate!.toIso8601String());

      return true;
    } catch (e) {
      _errorMsg = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    _errorMsg = null;
    await _clearStorage();
    notifyListeners();
  }

  Future<void> _clearStorage() async {
    await _storage.delete(key: 'token');
    await _storage.delete(key: 'userId');
    await _storage.delete(key: 'expiryDate');
  }

  void clearError() {
    _errorMsg = null;
    notifyListeners();
  }
}
