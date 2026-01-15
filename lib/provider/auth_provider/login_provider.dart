import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geography_geyser/secure_storage/secure_storage_helper.dart';
import 'package:geography_geyser/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  // ---------------- GOOGLE SIGN IN ----------------
  static Future<Map<String, dynamic>> signInWithGoogle(
    BuildContext context,
  ) async {
    isLoading.value = true;

    try {
      // ১. Google Sign-In client তৈরি
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      // ২. User কে sign-in করতে বলা (popup দেখাবে)
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      // User যদি cancel করে
      if (googleUser == null) {
        throw {'message': 'Google sign-in was canceled'};
      }

      // ৩. শুধু email নিবো
      final String? email = googleUser.email;
      if (email == null || email.isEmpty) {
        throw {'message': 'Failed to get email from Google'};
      }

      print('📧 Got email: $email');

      // ৪. তোমার API-তে পাঠাচ্ছি
      final response = await http.post(
        Uri.parse(ApiService.googleLoginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      print('API Status: ${response.statusCode}');
      print('API Body: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      // ৫. Success case
      if (response.statusCode == 200 || response.statusCode == 201) {
        // email response-এ না থাকলে add করে দিচ্ছি (optional)
        responseData['email'] = email;

        // token গুলো save
        await _storeLoginData(responseData);

        // নতুন user হলে dialog (যেটা আগে ছিল)
        if (responseData['is_new_user'] == true && context.mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Update Profile'),
              content: const Text(
                'Please update your profile and set a password in settings.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }

        print('🎉 Google Login Successful!');
        return responseData;
      } else {
        // API error
        throw responseData;
      }
    } catch (e) {
      print('Google Login Error: $e');

      String message = 'Google login failed';

      if (e is Map && e['message'] != null) {
        message = e['message'].toString();
      } else if (e.toString().contains('network')) {
        message = 'Please check your internet connection';
      }

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }

      rethrow; // যাতে button-এর try-catch ধরতে পারে
    } finally {
      isLoading.value = false;
    }
  }

  static Future<void> logout() async {
    // Sign out from Google Sign-In
    await GoogleSignIn().signOut();

    // Clear all stored data
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    final storage = const FlutterSecureStorage();
    await storage.deleteAll();

    print("🚪 All login data cleared (both Secure + Shared).");
  }

  static Future<void> printAllStorageData() async {
    print("========== Checking Stored Data ==========");

    final secureStorage = const FlutterSecureStorage();
    final secureData = await secureStorage.readAll();
    print("🔐 Secure Storage:");
    if (secureData.isEmpty) {
      print("  (empty)");
    } else {
      secureData.forEach((key, value) {
        print("  $key : $value");
      });
    }

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
