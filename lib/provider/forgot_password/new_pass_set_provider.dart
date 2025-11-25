import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geography_geyser/secure_storage/secure_storage_helper.dart';
import 'package:geography_geyser/services/api_service.dart';
import 'package:http/http.dart' as http;

class NewPassSetProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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
            responseData['msg'] ??
            responseData['message'] ??
            'Failed to set new password';
        _isLoading = false;
        notifyListeners();
        throw responseData;
      }
    } catch (e) {
      debugPrint('Set New Password Error: $e');

      // Handle different error types
      if (e is Map) {
        _errorMessage =
            e['msg'] ??
            e['error'] ??
            e['message'] ??
            'Failed to set new password';
      } else {
        _errorMessage = e.toString();
      }

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
}
