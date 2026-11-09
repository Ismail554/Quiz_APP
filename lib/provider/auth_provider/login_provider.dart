import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geography_geyser/core/app_logger.dart';
import 'package:geography_geyser/secure_storage/secure_storage_helper.dart';
import 'package:geography_geyser/services/api_service.dart';
import 'package:geography_geyser/services/https_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LoginProvider extends ChangeNotifier {
  static final ValueNotifier<bool> isLoading = ValueNotifier(false);

  // ---------------- LOGIN (Spec 3.1) ----------------
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    isLoading.value = true;
    AppLogger.debug('Trying login with: $email');

    try {
      final response = await HttpManager.apiRequest(
        url: ApiService.loginUrl,
        method: Method.post,
        body: {'email': email, 'password': password},
        name: 'Login',
        statusCode: 200,
        skipAuth: true,
      );

      return await response.fold(
        (error) {
          throw error;
        },
        (data) async {
          final Map<String, dynamic> responseData = jsonDecode(data);
          await _storeLoginData(responseData);

          AppLogger.debug('Login Successful!');
          return responseData;
        },
      );
    } catch (e) {
      AppLogger.error("Login Error", e);
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- STORE DATA (Spec Dual Token Compatibility) ----------------
  static Future<void> _storeLoginData(Map<String, dynamic> data) async {
    final accessToken = data['access_token'] ?? data['access'];
    if (accessToken != null && accessToken.toString().isNotEmpty) {
      await SecureStorageHelper.setToken(accessToken.toString());
    }

    final refreshToken = data['refresh_token'] ?? data['refresh'];
    if (refreshToken != null && refreshToken.toString().isNotEmpty) {
      await SecureStorageHelper.setRefreshToken(refreshToken.toString());
    }

    final prefs = await SharedPreferences.getInstance();
    final userEmail = data['email'] ?? data['user']?['email'] ?? '';
    if (userEmail.isNotEmpty) {
      await prefs.setString('user_email', userEmail.toString());
    }

    if (data['user'] is Map) {
      final userMap = data['user'] as Map<String, dynamic>;
      if (userMap['id'] != null) {
        await prefs.setString('user_id', userMap['id'].toString());
      }
      if (userMap['full_name'] != null) {
        await prefs.setString('user_full_name', userMap['full_name'].toString());
      }
    }
  }

  // ---------------- GOOGLE SIGN IN (Spec 3.8) ----------------
  static Future<Map<String, dynamic>> signInWithGoogle() async {
    isLoading.value = true;

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: dotenv.env['GOOGLE_SERVER_CLIENT_ID'],
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

      AppLogger.debug('📧 Got Google email: $email');

      final response = await HttpManager.apiRequest(
        url: ApiService.googleLoginUrl,
        method: Method.post,
        body: {'email': email},
        name: 'GoogleLogin',
        statusCode: 200,
        skipAuth: true,
      );

      return await response.fold(
        (error) {
          throw error;
        },
        (data) async {
          final Map<String, dynamic> responseData = jsonDecode(data);
          responseData['email'] = email;
          await _storeLoginData(responseData);
          AppLogger.debug('🎉 Google Login Successful!');
          return responseData;
        },
      );
    } catch (e) {
      AppLogger.error('Google Login Error', e);
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- APPLE SIGN IN (Spec 3.9) ----------------
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

      AppLogger.debug('📧 Got Apple credential. Email: $email');

      Map<String, dynamic> body = {
        "id_token": idToken,
        "user": {
          "name": {
            "givenName": (credential.givenName ?? "").trim(),
            "familyName": (credential.familyName ?? "").trim(),
          },
        },
      };

      final response = await HttpManager.apiRequest(
        url: ApiService.appleLoginUrl,
        method: Method.post,
        body: body,
        name: 'AppleLogin',
        statusCode: 200,
        skipAuth: true,
      );

      return await response.fold(
        (error) {
          throw error;
        },
        (data) async {
          final Map<String, dynamic> responseData = jsonDecode(data);
          if (email != null && email.isNotEmpty) {
            responseData['email'] = email;
          }
          await _storeLoginData(responseData);
          AppLogger.debug('🎉 Apple Login Successful!');
          return responseData;
        },
      );
    } catch (e) {
      AppLogger.error('Apple Login Error', e);
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- FETCH CURRENT USER (Spec 3.10) ----------------
  static Future<Map<String, dynamic>?> fetchCurrentUser() async {
    try {
      final response = await HttpManager.apiRequest(
        url: ApiService.meUrl,
        method: Method.get,
        name: 'CurrentUserProfile',
        statusCode: 200,
        skipAuth: false,
      );

      return response.fold(
        (error) {
          AppLogger.error('Fetch Current User Error', error);
          return null;
        },
        (data) {
          final Map<String, dynamic> profile = jsonDecode(data);
          return profile;
        },
      );
    } catch (e) {
      AppLogger.error('Fetch Current User Exception', e);
      return null;
    }
  }

  // ---------------- LOGOUT (Spec 3.12) ----------------
  static Future<void> logout() async {
    try {
      final refreshToken = await SecureStorageHelper.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await HttpManager.apiRequest(
          url: ApiService.logoutUrl,
          method: Method.post,
          body: {
            'refresh_token': refreshToken,
            'refresh': refreshToken,
          },
          name: 'Logout',
          statusCode: 204,
          skipAuth: false,
        );
      }
    } catch (e) {
      AppLogger.error("Backend logout revocation notice (ignored during cleanup)", e);
    } finally {
      try {
        await GoogleSignIn().signOut();
      } catch (_) {}

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      final storage = const FlutterSecureStorage();
      await storage.deleteAll();

      AppLogger.log("🚪 All login data cleared (Secure + Shared).");
    }
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
