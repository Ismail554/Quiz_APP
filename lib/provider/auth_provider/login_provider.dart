import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    String? userEmail;
    
    try {
      // Initialize GoogleSignIn - standalone mode (no Firebase Auth)
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        forceCodeForRefreshToken: false, // Don't force server-side auth
      );

      GoogleSignInAccount? googleUser;

      // First, try to get previously signed in account silently
      try {
        googleUser = await googleSignIn.signInSilently();
      } catch (e) {
        print('Silent sign-in failed: $e');
      }

      // If no previous account, show sign-in dialog
      if (googleUser == null) {
        try {
          googleUser = await googleSignIn.signIn();
        } on PlatformException catch (signInError) {
          // If signIn fails with PlatformException, try to get the account that was selected
          print('Sign-in failed with PlatformException: ${signInError.code} - ${signInError.message}');
          
          // Try to get the account silently - sometimes the account is still selected
          try {
            googleUser = await googleSignIn.signInSilently();
            if (googleUser != null) {
              print('✅ Got account via silent sign-in after error');
            }
          } catch (e) {
            print('Silent sign-in also failed: $e');
          }
          
          // If we still don't have an account, throw the original error
          if (googleUser == null) {
            isLoading.value = false;
            throw {
              'message': 'Google sign-in failed: ${signInError.message ?? signInError.code}. Please check your Google Cloud Console OAuth configuration.'
            };
          }
        }
      }

      if (googleUser == null) {
        // User canceled the sign-in
        isLoading.value = false;
        throw {'message': 'Google sign-in was canceled'};
      }

      // Extract email immediately - this is all we need
      userEmail = googleUser.email;
      print('📧 Google User Email: $userEmail');

      if (userEmail == null || userEmail.isEmpty) {
        isLoading.value = false;
        throw {'message': 'Failed to get email from Google account'};
      }

      // Sign out from Google after getting email (we only needed the email)
      try {
        await googleSignIn.signOut();
      } catch (e) {
        // Ignore sign-out errors - not critical
        print('Note: Google sign-out: $e');
      }

      // Call API with email from Google Sign-In
      final response = await http.post(
        Uri.parse(ApiService.googleLoginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': userEmail}),
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Add email to response data if not present
        if (!responseData.containsKey('email')) {
          responseData['email'] = userEmail;
        }

        // Show dialog for new users
        if (responseData['is_new_user'] == true) {
          if (context.mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Update Profile'),
                content: const Text(
                  'Update your profile and setup new password in settings.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        }

        // Store API tokens (access_token, refresh_token)
        await _storeLoginData(responseData);
        print('✅ Google Login Successful (via API)');

        isLoading.value = false;
        return responseData;
      } else {
        // API login failed - throw error
        print('❌ API Login failed with status: ${response.statusCode}');
        isLoading.value = false;
        throw responseData;
      }
    } on PlatformException catch (e) {
      // Handle platform-specific errors (like Firebase Auth errors)
      print("Platform Error during Google Sign-In: ${e.code} - ${e.message}");
      isLoading.value = false;
      
      // If we somehow got the email before the error, try to use it
      if (userEmail != null && userEmail.isNotEmpty) {
        print('⚠️ Got email before error, attempting API call with: $userEmail');
        try {
          final response = await http.post(
            Uri.parse(ApiService.googleLoginUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': userEmail}),
          );

          if (response.statusCode == 200 || response.statusCode == 201) {
            final Map<String, dynamic> responseData = jsonDecode(response.body);
            if (!responseData.containsKey('email')) {
              responseData['email'] = userEmail;
            }
            await _storeLoginData(responseData);
            print('✅ API call succeeded despite platform error');
            return responseData;
          }
        } catch (apiError) {
          print('❌ API call also failed: $apiError');
        }
      }
      
      throw {
        'message': 'Google sign-in failed: ${e.message ?? e.code}'
      };
    } catch (e) {
      print("Google Sign-In Error: $e");
      isLoading.value = false;
      if (e is Map) {
        rethrow;
      }
      throw {'message': e.toString()};
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
