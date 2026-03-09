import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const _apiKey = 'AIzaSyCGf3zCB26IIRf6hogYv8MpVxqrVrYiNnc';

  static const _signUpUrl =
      'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$_apiKey';
  static const _signInUrl =
      'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$_apiKey';

  Future<Map<String, dynamic>> signUp(String email, String password) async {
    return _authenticate(email, password, _signUpUrl);
  }

  Future<Map<String, dynamic>> signIn(String email, String password) async {
    return _authenticate(email, password, _signInUrl);
  }

  Future<Map<String, dynamic>> _authenticate(
      String email, String password, String url) async {
    final response = await http.post(
      Uri.parse(url),
      body: json.encode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }),
    );

    final data = json.decode(response.body);

    if (response.statusCode != 200) {
      throw _getErrorMessage(data);
    }

    return data;
  }

  String _getErrorMessage(Map<String, dynamic> data) {
    final error = data['error']?['message'] ?? 'Something went wrong';

    switch (error) {
      case 'EMAIL_EXISTS':
        return 'This email is already registered.';
      case 'INVALID_EMAIL':
        return 'Invalid email address.';
      case 'WEAK_PASSWORD':
        return 'Password is too weak.';
      case 'EMAIL_NOT_FOUND':
        return 'No account found with this email.';
      case 'INVALID_PASSWORD':
        return 'Incorrect password.';
      case 'INVALID_LOGIN_CREDENTIALS':
        return 'Invalid email or password.';
      case 'USER_DISABLED':
        return 'This account has been disabled.';
      default:
        return error;
    }
  }
}
