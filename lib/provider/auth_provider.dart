import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geography_geyser/utils/validators.dart';
import 'package:geography_geyser/provider/login_auth.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  String? get emailError => _emailError;
  String? get passwordError => _passwordError;
  String? get confirmPasswordError => _confirmPasswordError;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ✅ Login Validation Logic
  bool validateLoginFields({required String email, required String password}) {
    _emailError = null;
    _passwordError = null;
    _errorMessage = null;

    _emailError = Validators.validateEmail(email);
    _passwordError = Validators.validatePassword(password);

    notifyListeners();
    return _emailError == null && _passwordError == null;
  }

  // ✅ Sign Up Validation Logic
  bool validateFields({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    _emailError = null;
    _passwordError = null;
    _confirmPasswordError = null;

    _emailError = Validators.validateEmail(email);
    _passwordError = Validators.validatePassword(password);
    _confirmPasswordError = Validators.validateConfirmPassword(
      confirmPassword,
      password,
    );

    notifyListeners();
    return _emailError == null &&
        _passwordError == null &&
        _confirmPasswordError == null;
  }

  // ✅ Login using LoginAuthService
  Future<bool> loginUser({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // First validate the fields
    if (!validateLoginFields(email: email, password: password)) {
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Call the login service
    final result = await LoginAuthService.login(
      email: email,
      password: password,
    );

    _isLoading = false;

    if (result['success'] == true) {
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'] as String?;
      notifyListeners();
      return false;
    }
  }

  // ✅ Sign Up API call logic
  Future<bool> registerUser({
    required String fullName,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    final url = Uri.parse(
      "https://dihydric-yael-therianthropic.ngrok-free.dev",
    );
    final body = jsonEncode({
      'email': email,
      'full_name': fullName,
      'password': password,
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', responseData['user']['id']);
        await prefs.setString(
          'verification_token',
          responseData['verificationToken'],
        );

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        debugPrint("Signup failed: ${response.body}");
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint("Error: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Clear errors
  void clearErrors() {
    _emailError = null;
    _passwordError = null;
    _confirmPasswordError = null;
    _errorMessage = null;
    notifyListeners();
  }

  // ✅ Logout user
  Future<void> logout() async {
    await LoginAuthService.logout();
    clearErrors();
    notifyListeners();
  }

  // ✅ Check if user is logged in
  Future<bool> checkLoginStatus() async {
    return await LoginAuthService.isLoggedIn();
  }
}
