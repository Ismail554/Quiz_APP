import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geography_geyser/secure_storage/secure_storage_helper.dart';
import 'package:geography_geyser/services/api_service.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  String? _passResetToken; // Store token in memory

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get passResetToken => _passResetToken;

  /// Send forgot password request with email
  /// Returns passResetToken on success
  Future<Map<String, dynamic>> sendForgotPasswordRequest(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(ApiService.forgotPassUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({'email': email}),
      );

      debugPrint('Forgot Password API Status: ${response.statusCode}');
      debugPrint('Forgot Password API Response: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Store passResetToken in memory and secure storage if present in response
        if (responseData.containsKey('passResetToken')) {
          _passResetToken = responseData['passResetToken'];
          await SecureStorageHelper.setPassResetToken(_passResetToken!);
          debugPrint('Pass Reset Token stored successfully');
        }

        // Store email for later use (from response or input)
        final userEmail = responseData['user']?['email'] ?? email;
        await SecureStorageHelper.setResetPasswordEmail(userEmail);

        _isLoading = false;
        notifyListeners();
        return responseData;
      } else {
        _errorMessage =
            responseData['error'] ??
            responseData['message'] ??
            'Failed to send reset password request';
        _isLoading = false;
        notifyListeners();
        throw responseData;
      }
    } catch (e) {
      debugPrint('Forgot Password Error: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Verify OTP for forgot password
  /// Requires passResetToken and otp, returns passwordResetVerified
  Future<Map<String, dynamic>> verifyForgotPasswordOtp(String otp) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Use in-memory token first, fallback to storage
      final passResetToken =
          _passResetToken ?? await SecureStorageHelper.getPassResetToken();

      if (passResetToken == null || passResetToken.isEmpty) {
        throw {
          'error':
              'Pass reset token not found. Please request password reset again.',
        };
      }

      final response = await http.post(
        Uri.parse(ApiService.verifyForgotPassOtpUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({'passResetToken': passResetToken, 'otp': otp}),
      );

      debugPrint('Verify OTP API Status: ${response.statusCode}');
      debugPrint('Verify OTP API Response: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Store passwordResetVerified if present in response
        if (responseData.containsKey('passwordResetVerified')) {
          await SecureStorageHelper.setPasswordResetVerified(
            responseData['passwordResetVerified'],
          );
          debugPrint('Password Reset Verified stored successfully');
        }

        _isLoading = false;
        notifyListeners();
        return responseData;
      } else {
        _errorMessage =
            responseData['error'] ??
            responseData['message'] ??
            'Failed to verify OTP';
        _isLoading = false;
        notifyListeners();
        throw responseData;
      }
    } catch (e) {
      debugPrint('Verify OTP Error: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Resend OTP for forgot password
  /// Requires passResetToken
  Future<Map<String, dynamic>> resendForgotPasswordOtp() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Use in-memory token first, fallback to storage
      final passResetToken =
          _passResetToken ?? await SecureStorageHelper.getPassResetToken();

      if (passResetToken == null || passResetToken.isEmpty) {
        throw {
          'error':
              'Pass reset token not found. Please request password reset again.',
        };
      }

      final response = await http.post(
        Uri.parse(ApiService.resendOtpUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({'passResetToken': passResetToken}),
      );

      debugPrint('Resend OTP API Status: ${response.statusCode}');
      debugPrint('Resend OTP API Response: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _isLoading = false;
        notifyListeners();
        return responseData;
      } else {
        _errorMessage =
            responseData['error'] ??
            responseData['message'] ??
            'Failed to resend OTP';
        _isLoading = false;
        notifyListeners();
        throw responseData;
      }
    } catch (e) {
      debugPrint('Resend OTP Error: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Set new password
  /// Requires passwordResetVerified and new_password
  Future<Map<String, dynamic>> setNewPassword(String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final passwordResetVerified =
          await SecureStorageHelper.getPasswordResetVerified();

      if (passwordResetVerified == null || passwordResetVerified.isEmpty) {
        throw {
          'error':
              'Password reset verification not found. Please verify OTP again.',
        };
      }

      final response = await http.post(
        Uri.parse(ApiService.newPasswordSet),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({
          'passwordResetVerified': passwordResetVerified,
          'new_password': newPassword,
        }),
      );

      debugPrint('Set New Password API Status: ${response.statusCode}');
      debugPrint('Set New Password API Response: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Clear reset tokens after successful password reset
        await SecureStorageHelper.setPassResetToken('');
        await SecureStorageHelper.setPasswordResetVerified('');

        _isLoading = false;
        notifyListeners();
        return responseData;
      } else {
        _errorMessage =
            responseData['error'] ??
            responseData['message'] ??
            'Failed to set new password';
        _isLoading = false;
        notifyListeners();
        throw responseData;
      }
    } catch (e) {
      debugPrint('Set New Password Error: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear passResetToken (call when user goes back)
  void clearPassResetToken() {
    _passResetToken = null;
    notifyListeners();
  }
}
