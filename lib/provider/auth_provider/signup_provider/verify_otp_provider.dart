import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geography_geyser/core/app_logger.dart';
import 'package:geography_geyser/secure_storage/secure_storage_helper.dart';
import 'package:geography_geyser/services/api_service.dart';
import 'package:geography_geyser/services/https_service.dart';

class VerifyProvider extends ChangeNotifier {
  static final ValueNotifier<bool> isLoading = ValueNotifier(false);

  // ---------------- VERIFY OTP ----------------
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

      // API call
      final response = await HttpManager.apiRequest(
        url: ApiService.verifyOtpUrl,
        method: Method.post,
        body: {'otp': otp, 'verificationToken': verificationToken},
        name: 'VerifyOTP',
        statusCode: 200,
      );

      return response.fold(
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
            'message': decodedData['message'] ?? 'OTP verified successfully',
          };
        },
      );
    } catch (e) {
      AppLogger.error(" Verify OTP Error", e);
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}
