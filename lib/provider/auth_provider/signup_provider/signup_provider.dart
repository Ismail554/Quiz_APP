import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geography_geyser/core/app_logger.dart';
import 'package:geography_geyser/secure_storage/secure_storage_helper.dart';
import 'package:geography_geyser/services/api_service.dart';
import 'package:geography_geyser/services/https_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupProvider extends ChangeNotifier {
  static final ValueNotifier<bool> isLoading = ValueNotifier(false);

  // ---------------- SIGNUP (Spec 3.2) ----------------
  static Future<Map<String, dynamic>> signup(
    String email,
    String fullName,
    String password,
    BuildContext context,
  ) async {
    isLoading.value = true;
    AppLogger.debug('🔵 Trying signup with: $email / $fullName');

    try {
      final requestBody = {
        'email': email,
        'full_name': fullName,
        'password': password,
      };

      final response = await HttpManager.apiRequest(
        url: ApiService.signupUrl,
        method: Method.post,
        body: requestBody,
        name: 'Signup',
        statusCode: 201,
        skipAuth: true,
      );

      return await response.fold(
        (error) {
          throw {
            'success': false,
            'message': error,
          };
        },
        (data) async {
          final responseData = jsonDecode(data) as Map<String, dynamic>;
          AppLogger.debug('✅ Signup successful!');
          await _storeSignupData(responseData);
          return responseData;
        },
      );
    } catch (e) {
      AppLogger.error('Signup Error', e);
      if (e is Map<String, dynamic>) {
        rethrow;
      }
      throw {
        'success': false,
        'message': 'An unexpected error occurred. Please try again.',
        'error': e.toString(),
      };
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- STORE SIGNUP DATA ----------------
  static Future<void> _storeSignupData(Map<String, dynamic> data) async {
    // Save verification token securely (supports camelCase and snake_case)
    final verificationToken =
        data['verificationToken'] ?? data['verification_token'];
    if (verificationToken != null && verificationToken.toString().isNotEmpty) {
      await SecureStorageHelper.setVerificationToken(
          verificationToken.toString());
      AppLogger.debug("✅ Verification Token Saved Securely!");
    }

    // Optional: save email and user id for later use
    final prefs = await SharedPreferences.getInstance();
    if (data['user'] != null && data['user'] is Map) {
      final userMap = data['user'] as Map<String, dynamic>;
      if (userMap['id'] != null) {
        await prefs.setString('signup_user_id', userMap['id'].toString());
      }
      if (userMap['email'] != null) {
        await prefs.setString('signup_email', userMap['email'].toString());
      }
    }
  }

  // ---------------- PRINT ALL DATA (DEBUG) ----------------
  static Future<void> printAllStorageData() async {
    final secure = FlutterSecureStorage();
    final prefs = await SharedPreferences.getInstance();

    debugPrint("========== 🧠 Signup Storage Data ==========");
    debugPrint("🔐 Secure Storage:");
    (await secure.readAll()).forEach((k, v) => debugPrint("  $k : $v"));

    debugPrint("📦 Shared Preferences:");
    prefs.getKeys().forEach((k) => debugPrint("  $k : ${prefs.get(k)}"));
    debugPrint("===========================================");
  }
}
