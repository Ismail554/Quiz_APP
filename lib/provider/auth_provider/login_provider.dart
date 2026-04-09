import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geography_geyser/secure_storage/secure_storage_helper.dart';
import 'package:geography_geyser/services/api_service.dart';
import 'package:geography_geyser/services/https_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginProvider extends ChangeNotifier {
  static final ValueNotifier<bool> isLoading = ValueNotifier(false);

  // ---------------- LOGIN ----------------
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    isLoading.value = true;
    debugPrint('Trying login with: $email / $password');

    try {
      final response = await HttpManager.apiRequest(
        url: ApiService.loginUrl,
        method: Method.post,
        body: {'email': email, 'password': password},
        name: 'Login',
        statusCode: 200,
      );

      return response.fold(
        (error) {
          throw error;
        },
        (data) async {
          final Map<String, dynamic> responseData = jsonDecode(data);
          await _storeLoginData(responseData);

          debugPrint('Login Successful!');
          if (responseData.containsKey('access_token')) {
            debugPrint('Access Token: ${responseData['access_token']}');
          }
          if (responseData.containsKey('refresh_token')) {
            debugPrint('Refresh Token: ${responseData['refresh_token']}');
          }

          return responseData;
        },
      );
    } catch (e) {
      debugPrint("Login Error: $e");
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- STORE DATA ----------------
  static Future<void> _storeLoginData(Map<String, dynamic> data) async {
    if (data['access_token'] != null) {
      await SecureStorageHelper.setToken(data['access_token'].toString());
    }
    if (data['refresh_token'] != null) {
      await SecureStorageHelper.setRefreshToken(data['refresh_token'].toString());
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', data['email'] ?? '');
  }

  // ---------------- GOOGLE SIGN IN ----------------
  static Future<Map<String, dynamic>> signInWithGoogle() async {
    isLoading.value = true;

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId:
            '581080373754-tvili4mkiqts4rjeacgoti52h2i39fld.apps.googleusercontent.com',
        scopes: ['email', 'profile'],
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        throw {'message': 'Google sign-in was canceled'};
      }

      final String email = googleUser.email;
      if (email.isEmpty) {
        throw {'message': 'Failed to get email from Google'};
      }

      debugPrint('📧 Got email: $email');

      final response = await HttpManager.apiRequest(
        url: ApiService.googleLoginUrl,
        method: Method.post,
        body: {'email': email},
        name: 'GoogleLogin',
        statusCode: 200,
      );

      return response.fold(
        (error) {
          throw error;
        },
        (data) async {
          final Map<String, dynamic> responseData = jsonDecode(data);
          responseData['email'] = email;
          await _storeLoginData(responseData);
          debugPrint('🎉 Google Login Successful!');
          return responseData;
        },
      );
    } catch (e) {
      debugPrint('Google Login Error: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- APPLE SIGN IN ----------------
  static Future<Map<String, dynamic>> signInWithApple() async {
    isLoading.value = true;

    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final String? email = credential.email;
      final String idToken = credential.identityToken ?? "";

      debugPrint('📧 Got Apple credential. Email: $email');

      Map<String, dynamic> body = {
        "id_token": idToken,
        "user": {
          "name": {
            "givenName": (credential.givenName ?? "").trim(),
            "familyName": (credential.familyName ?? "").trim(),
          },
        },
      };

      // if (email != null && email.isNotEmpty) {
      //   body["email"] = email;
      // }

      final response = await HttpManager.apiRequest(
        url: ApiService.appleLoginUrl,
        method: Method.post,
        body: body,
        name: 'AppleLogin',
        statusCode: 200,
      );

      return response.fold(
        (error) {
          throw error;
        },
        (data) async {
          final Map<String, dynamic> responseData = jsonDecode(data);
          if (email != null && email.isNotEmpty) {
            responseData['email'] = email;
          }
          await _storeLoginData(responseData);
          debugPrint('🎉 Apple Login Successful!');
          return responseData;
        },
      );
    } catch (e) {
      debugPrint('Apple Login Error: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  static Future<void> logout() async {
    await GoogleSignIn().signOut();

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    final storage = const FlutterSecureStorage();
    await storage.deleteAll();

    debugPrint("🚪 All login data cleared (both Secure + Shared).");
  }

  static Future<void> printAllStorageData() async {
    debugPrint("========== Checking Stored Data ==========");

    final secureStorage = const FlutterSecureStorage();
    final secureData = await secureStorage.readAll();
    debugPrint("🔐 Secure Storage:");
    if (secureData.isEmpty) {
      debugPrint("  (empty)");
    } else {
      secureData.forEach((key, value) {
        debugPrint("  $key : $value");
      });
    }

    final prefs = await SharedPreferences.getInstance();
    final prefKeys = prefs.getKeys();
    debugPrint("📦 Shared Preferences:");
    if (prefKeys.isEmpty) {
      debugPrint("  (empty)");
    } else {
      for (String key in prefKeys) {
        debugPrint("  $key : ${prefs.get(key)}");
      }
    }

    debugPrint("============================================");
  }
}
