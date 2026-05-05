import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geography_geyser/core/app_logger.dart';
import 'package:geography_geyser/secure_storage/secure_storage_helper.dart';
import 'package:geography_geyser/services/api_service.dart';
import 'package:geography_geyser/services/https_service.dart';

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

      final response = await HttpManager.apiRequest(
        url: ApiService.newPasswordSet,
        method: Method.post,
        body: {
          'passwordResetVerified': passwordResetVerified,
          'new_password': newPassword,
        },
        name: 'SetNewPassword',
        statusCode: 200, // or 201
      );

      return await response.fold(
        (error) async {
          _errorMessage = error;
          _isLoading = false;
          notifyListeners();
          throw {'error': error};
        },
        (data) async {
          final Map<String, dynamic> responseData = jsonDecode(data);
          // Clear reset tokens after successful password reset
          await SecureStorageHelper.setPassResetToken('');
          await SecureStorageHelper.setPasswordResetVerified('');

          _isLoading = false;
          notifyListeners();
          return responseData;
        },
      );
    } catch (e) {
      AppLogger.error('Set New Password Error', e);

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
