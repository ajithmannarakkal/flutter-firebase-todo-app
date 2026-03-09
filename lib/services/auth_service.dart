import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // Replace with your Firebase Web API Key
  static const String _apiKey = 'AIzaSyCGf3zCB26IIRf6hogYv8MpVxqrVrYiNnc';

  static const String _signUpUrl =
      'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$_apiKey';
  static const String _signInUrl =
      'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$_apiKey';

  Future<Map<String, dynamic>> signUp(String email, String password) async {
    final response = await http.post(
      Uri.parse(_signUpUrl),
      body: json.encode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }),
    );

    final responseData = json.decode(response.body);

    if (response.statusCode != 200) {
      throw _handleError(responseData);
    }

    return responseData;
  }

  Future<Map<String, dynamic>> signIn(String email, String password) async {
    final response = await http.post(
      Uri.parse(_signInUrl),
      body: json.encode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }),
    );

    final responseData = json.decode(response.body);

    if (response.statusCode != 200) {
      throw _handleError(responseData);
    }

    return responseData;
  }

  String _handleError(Map<String, dynamic> responseData) {
    final errorMessage =
        responseData['error']?['message'] ?? 'An error occurred';

    switch (errorMessage) {
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
        return errorMessage;
    }
  }
}
