import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geography_geyser/secure_storage/secure_storage_helper.dart';
import 'package:geography_geyser/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SignupProvider extends ChangeNotifier {
  static final ValueNotifier<bool> isLoading = ValueNotifier(false);

  // ---------------- SIGNUP ----------------
  static Future<Map<String, dynamic>> signup(
    String email,
    String fullName,
    String password,
    BuildContext context,
  ) async {
    isLoading.value = true;
    print('📝 Trying signup with: $email / $fullName / $password');

    try {
      final response = await http.post(
        Uri.parse(ApiService.signupUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'full_name': fullName,
          'password': password,
        }),
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _storeSignupData(responseData);
        return responseData;
      } else {
        throw responseData;
      }
    } catch (e) {
      print("Signup Error: $e");
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- STORE SIGNUP DATA ----------------
  static Future<void> _storeSignupData(Map<String, dynamic> data) async {
    final storage = FlutterSecureStorage();

    // 🧠 Save verification token securely (for OTP verify)
    if (data.containsKey('verificationToken')) {
      await SecureStorageHelper.setVerificationToken(
        data['verificationToken'],
      );
      print("✅ Verification Token Saved Securely!");
    }

    // 🧠 Optional: save email and user id for later use
    final prefs = await SharedPreferences.getInstance();
    if (data['user'] != null) {
      await prefs.setString('signup_user_id', data['user']['id'] ?? '');
      await prefs.setString('signup_email', data['user']['email'] ?? '');
    }
  }

  // ---------------- PRINT ALL DATA (DEBUG) ----------------
  static Future<void> printAllStorageData() async {
    final secure = FlutterSecureStorage();
    final prefs = await SharedPreferences.getInstance();

    print("========== 🧠 Signup Storage Data ==========");
    print("🔐 Secure Storage:");
    (await secure.readAll()).forEach((k, v) => print("  $k : $v"));

    print("📦 Shared Preferences:");
    prefs.getKeys().forEach((k) => print("  $k : ${prefs.get(k)}"));
    print("===========================================");
  }
}
