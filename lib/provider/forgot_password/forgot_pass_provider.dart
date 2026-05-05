import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geography_geyser/core/app_logger.dart';
import 'package:geography_geyser/secure_storage/secure_storage_helper.dart';
import 'package:geography_geyser/services/api_service.dart';
import 'package:geography_geyser/services/https_service.dart';

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
      final response = await HttpManager.apiRequest(
        url: ApiService.forgotPassUrl,
        method: Method.post,
        body: {'email': email},
        name: 'ForgotPasswordRequest',
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
          // Store passResetToken in memory and secure storage if present in response
          if (responseData.containsKey('passResetToken')) {
            _passResetToken = responseData['passResetToken'];
            await SecureStorageHelper.setPassResetToken(_passResetToken!);
            AppLogger.debug('Pass Reset Token stored successfully');
          }

          // Store email for later use (from response or input)
          final userEmail = responseData['user']?['email'] ?? email;
          await SecureStorageHelper.setResetPasswordEmail(userEmail);

          _isLoading = false;
          notifyListeners();
          return responseData;
        },
      );
    } catch (e) {
      AppLogger.error('Forgot Password Error', e);
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

      final response = await HttpManager.apiRequest(
        url: ApiService.verifyForgotPassOtpUrl,
        method: Method.post,
        body: {'passResetToken': passResetToken, 'otp': otp},
        name: 'VerifyForgotPassOtp',
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
          // Store passwordResetVerified if present in response
          if (responseData.containsKey('passwordResetVerified')) {
            await SecureStorageHelper.setPasswordResetVerified(
              responseData['passwordResetVerified'],
            );
            AppLogger.debug('Password Reset Verified stored successfully');
          }

          _isLoading = false;
          notifyListeners();
          return responseData;
        },
      );
    } catch (e) {
      AppLogger.error('Verify OTP Error', e);

      // Handle different error types
      if (e is Map) {
        _errorMessage =
            e['msg'] ?? e['error'] ?? e['message'] ?? 'Failed to verify OTP';
      } else {
        _errorMessage = e.toString();
      }

      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Resend OTP for forgot password
  /// Requires email
  Future<Map<String, dynamic>> resendForgotPasswordOtp(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await HttpManager.apiRequest(
        url: ApiService.forgotPassUrl,
        method: Method.post,
        body: {'email': email},
        name: 'ResendForgotPasswordOtp',
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
          // Update stored token if present
          if (responseData.containsKey('passResetToken')) {
            _passResetToken = responseData['passResetToken'];
            await SecureStorageHelper.setPassResetToken(_passResetToken!);
          }

          _isLoading = false;
          notifyListeners();
          return responseData;
        },
      );
    } catch (e) {
      AppLogger.error('Resend OTP Error', e);
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
