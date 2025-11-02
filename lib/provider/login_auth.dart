import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geography_geyser/services/api_endpoints.dart';

class LoginAuthService {
  // 🔧 Dev Mode: Set to true to enable API calls, false to disable (for offline development)
  static const bool isDevMode = false; // Change to false to disable login API

  /// Performs login API call and returns the result
  /// Returns Map with keys: 'success' (bool), 'message' (String), 'data' (Map?)
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    // If dev mode is disabled, return mock success response
    if (!isDevMode) {
      log(
        '⚠️ Dev Mode: Login API is disabled - returning mock response',
        name: 'LOGIN_AUTH',
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', 'dev_mock_token');
      await prefs.setString('refresh_token', 'dev_mock_refresh_token');
      await prefs.setString('user_email', email.trim());

      return {
        'success': true,
        'message': 'Login successful (Dev Mode - API Disabled)',
        'data': {
          'access_token': 'dev_mock_token',
          'refresh_token': 'dev_mock_refresh_token',
        },
      };
    }

    try {
      final url = Uri.parse(ApiEndpoints.loginUrl);
      final body = jsonEncode({'email': email.trim(), 'password': password});

      log('Login attempt for: ${email.trim()}', name: 'LOGIN_AUTH');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
        },
        body: body,
      );

      log('Login response status: ${response.statusCode}', name: 'LOGIN_AUTH');

      // Success response
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        // Store user data in SharedPreferences
        final prefs = await SharedPreferences.getInstance();

        // Store access token
        if (responseData['access_token'] != null) {
          await prefs.setString('access_token', responseData['access_token']);
          log('Access token stored successfully', name: 'LOGIN_AUTH');
        }

        // Store refresh token
        if (responseData['refresh_token'] != null) {
          await prefs.setString('refresh_token', responseData['refresh_token']);
          log('Refresh token stored successfully', name: 'LOGIN_AUTH');
        }

        // Store user ID (if provided in response)
        if (responseData['user'] != null &&
            responseData['user']['id'] != null) {
          await prefs.setString(
            'user_id',
            responseData['user']['id'].toString(),
          );
          log('User ID stored', name: 'LOGIN_AUTH');
        }

        // Store user email
        await prefs.setString('user_email', email.trim());
        log('User email stored', name: 'LOGIN_AUTH');

        return {
          'success': true,
          'message': 'Login successful',
          'data': responseData,
        };
      } else {
        // Error response
        final responseData = jsonDecode(response.body);
        final errorMessage =
            responseData['message'] ??
            responseData['error'] ??
            'Login failed. Please try again.';

        log('Login failed: $errorMessage', name: 'LOGIN_AUTH');

        return {'success': false, 'message': errorMessage, 'data': null};
      }
    } catch (e) {
      // Exception handling
      log('Login exception: $e', name: 'LOGIN_AUTH', error: e);

      return {
        'success': false,
        'message':
            'An error occurred. Please check your connection and try again.',
        'data': null,
      };
    }
  }

  /// Logout and clear stored user data
  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      await prefs.remove('user_id');
      await prefs.remove('user_email');
      log('User logged out and data cleared', name: 'LOGIN_AUTH');
    } catch (e) {
      log('Logout exception: $e', name: 'LOGIN_AUTH', error: e);
    }
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      return token != null && token.isNotEmpty;
    } catch (e) {
      log('isLoggedIn exception: $e', name: 'LOGIN_AUTH', error: e);
      return false;
    }
  }

  /// Get stored access token
  static Future<String?> getAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('access_token');
    } catch (e) {
      log('getAccessToken exception: $e', name: 'LOGIN_AUTH', error: e);
      return null;
    }
  }

  /// Get stored refresh token
  static Future<String?> getRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('refresh_token');
    } catch (e) {
      log('getRefreshToken exception: $e', name: 'LOGIN_AUTH', error: e);
      return null;
    }
  }

  /// Get stored authentication token (alias for backward compatibility)
  static Future<String?> getAuthToken() async {
    return await getAccessToken();
  }

  /// Get stored user ID
  static Future<String?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('user_id');
    } catch (e) {
      log('getUserId exception: $e', name: 'LOGIN_AUTH', error: e);
      return null;
    }
  }

  /// Get stored user email
  static Future<String?> getUserEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('user_email');
    } catch (e) {
      log('getUserEmail exception: $e', name: 'LOGIN_AUTH', error: e);
      return null;
    }
  }
}
