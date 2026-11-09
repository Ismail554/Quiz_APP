import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geography_geyser/core/app_logger.dart';
import 'package:geography_geyser/secure_storage/secure_storage_helper.dart';
import 'package:geography_geyser/services/api_service.dart';
import 'package:geography_geyser/services/https_service.dart';

class VerifyProvider extends ChangeNotifier {
  static final ValueNotifier<bool> isLoading = ValueNotifier(false);

  // ---------------- VERIFY OTP (Spec 3.3) ----------------
  static Future<Map<String, dynamic>> verifyOtp(
    String otp,
    BuildContext context,
  ) async {
    isLoading.value = true;
    AppLogger.debug(' Verifying OTP: $otp');

    try {
      // Get verification token from SecureStorage
      final verificationToken =
          await SecureStorageHelper.getVerificationToken();

      if (verificationToken == null || verificationToken.isEmpty) {
        throw {'message': 'Verification token not found. Please signup again.'};
      }

      // API call with dual-key support (Spec Section 3.3)
      final response = await HttpManager.apiRequest(
        url: ApiService.verifyOtpUrl,
        method: Method.post,
        body: {
          'otp': otp,
          'verificationToken': verificationToken,
          'verification_token': verificationToken,
        },
        name: 'VerifyOTP',
        statusCode: 200,
        skipAuth: true,
      );

      final result = response.fold(
        (error) {
          return {
            'success': false,
            'message': error,
          };
        },
        (data) {
          final decodedData = json.decode(data);
          AppLogger.debug("✅ OTP Verification Successful!");
          return {
            'success': true,
            'message': decodedData['message'] ??
                decodedData['detail'] ??
                'OTP verified successfully',
          };
        },
      );
      return result;
    } catch (e) {
      AppLogger.error(" Verify OTP Error", e);
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- RESEND SIGNUP OTP ----------------
  static Future<Map<String, dynamic>> resendSignupOtp(String email) async {
    isLoading.value = true;
    try {
      // Re-trigger registration email dispatch
      final response = await HttpManager.apiRequest(
        url: ApiService.signupUrl,
        method: Method.post,
        body: {'email': email},
        name: 'ResendSignupOTP',
        statusCode: 200,
        skipAuth: true,
      );

      return response.fold(
        (error) => {'success': false, 'message': error},
        (data) {
          final decodedData = json.decode(data);
          final token = decodedData['verificationToken'] ??
              decodedData['verification_token'];
          if (token != null) {
            SecureStorageHelper.setVerificationToken(token.toString());
          }
          return {
            'success': true,
            'message': decodedData['message'] ?? 'OTP code resent successfully',
          };
        },
      );
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    } finally {
      isLoading.value = false;
    }
  }
}
