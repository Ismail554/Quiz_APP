import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geography_geyser/secure_storage/secure_storage_helper.dart';
import 'package:geography_geyser/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginProvider extends ChangeNotifier {
  static final ValueNotifier<bool> isLoading = ValueNotifier(false);

  // ---------------- LOGIN ----------------
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
    BuildContext context,
  ) async {
    isLoading.value = true;
    print('Trying login with: $email / $password');

    try {
      final response = await http.post(
        Uri.parse(ApiService.loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await _storeLoginData(responseData);

        // Print tokens after successful login
        print('Login Successful!');
        if (responseData.containsKey('access_token')) {
          print('Access Token: ${responseData['access_token']}');
        }
        if (responseData.containsKey('refresh_token')) {
          print('Refresh Token: ${responseData['refresh_token']}');
        }

        return responseData;
      } else {
        // throw API error message
        throw responseData;
      }
    } catch (e) {
      print("Login Error: $e");
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- STORE DATA ----------------
  static Future<void> _storeLoginData(Map<String, dynamic> data) async {
    if (data.containsKey('access_token')) {
      await SecureStorageHelper.setToken(data['access_token']);
     // print(' Access Token stored in FlutterSecureStorage');
    }
    if (data.containsKey('refresh_token')) {
      await SecureStorageHelper.setRefreshToken(data['refresh_token']);
      // print(' Refresh Token stored in FlutterSecureStorage');
    }

    // Example extra: store user email in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', data['email'] ?? '');
  }

  // ---------------- LOGOUT ----------------
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    const storage = FlutterSecureStorage();
    await storage.deleteAll();

    print("🚪 All login data cleared (both Secure + Shared).");
  }

  // ---------------- PRINT ALL STORED DATA ----------------
  static Future<void> printAllStorageData() async {
    print("========== Checking Stored Data ==========");

    // Secure Storage
    final secureStorage = FlutterSecureStorage();
    final secureData = await secureStorage.readAll();
    print("🔐 Secure Storage:");
    if (secureData.isEmpty) {
      print("  (empty)");
    } else {
      secureData.forEach((key, value) {
        print("  $key : $value");
      });
    }

    // Shared Preferences
    final prefs = await SharedPreferences.getInstance();
    final prefKeys = prefs.getKeys();
    print("📦 Shared Preferences:");
    if (prefKeys.isEmpty) {
      print("  (empty)");
    } else {
      for (String key in prefKeys) {
        print("  $key : ${prefs.get(key)}");
      }
    }

    print("============================================");
  }
}
