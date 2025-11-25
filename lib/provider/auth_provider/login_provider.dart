import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geography_geyser/secure_storage/secure_storage_helper.dart';
import 'package:geography_geyser/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        isLoading.value = false;
        throw {'message': 'Google sign-in was canceled'};
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      final User? user = userCredential.user;

      if (user == null) {
        isLoading.value = false;
        throw {'message': 'Failed to sign in with Google'};
      }

      // Get the ID token for your backend
      final String? idToken = await user.getIdToken();

      // Optionally, send the token to your backend API
      // You can integrate this with your existing API service
      try {
        final response = await http.post(
          Uri.parse(
            ApiService.loginUrl,
          ), // Adjust this to your Google login endpoint
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'id_token': idToken,
            'email': user.email,
            'name': user.displayName,
            'photo_url': user.photoURL,
          }),
        );

        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (response.statusCode == 200 || response.statusCode == 201) {
          await _storeLoginData(responseData);
          print('Google Login Successful!');
          isLoading.value = false;
          return responseData;
        } else {
          // If backend integration fails, still store Firebase auth data
          await _storeFirebaseAuthData(user, idToken);
          isLoading.value = false;
          return {
            'access_token': idToken,
            'email': user.email,
            'name': user.displayName,
          };
        }
      } catch (e) {
        // If backend call fails, use Firebase auth directly
        print('Backend integration failed, using Firebase auth: $e');
        await _storeFirebaseAuthData(user, idToken);
        isLoading.value = false;
        return {
          'access_token': idToken,
          'email': user.email,
          'name': user.displayName,
        };
      }
    } catch (e) {
      print("Google Sign-In Error: $e");
      isLoading.value = false;
      rethrow;
    }
  }

  // ---------------- STORE FIREBASE AUTH DATA ----------------
  static Future<void> _storeFirebaseAuthData(User user, String? idToken) async {
    if (idToken != null) {
      await SecureStorageHelper.setToken(idToken);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', user.email ?? '');
    await prefs.setString('user_name', user.displayName ?? '');
    if (user.photoURL != null) {
      await prefs.setString('user_photo_url', user.photoURL!);
    }
  }

  static Future<void> logout() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();

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
