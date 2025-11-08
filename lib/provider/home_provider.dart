import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geography_geyser/models/home_model.dart';
import 'package:geography_geyser/secure_storage/secure_storage_helper.dart';
import 'package:geography_geyser/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserProvider extends ChangeNotifier {
  HomeModel? _userModel;
  bool _isLoading = false;

  final _storage = const FlutterSecureStorage();
  static const _storageKey = 'user_profile_data'; // Storage key name

  HomeModel? get userModel => _userModel;
  bool get isLoading => _isLoading;

  /// Fetch user profile from API and store securely
  Future<void> fetchUserData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await SecureStorageHelper.getToken();

      // Build headers with ngrok skip warning and auth token
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true', // Required for ngrok
      };

      // Add auth token if available
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final getProfile = ApiService.getProfile;
      final response = await http.get(Uri.parse(getProfile), headers: headers);

      debugPrint('Profile API Status: ${response.statusCode}');
      debugPrint('Profile API Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Handle both direct data and nested data structure
        if (data is Map<String, dynamic>) {
          Map<String, dynamic> profileData;

          // Check if data is nested under 'data' key
          if (data.containsKey('data') &&
              data['data'] is Map<String, dynamic>) {
            profileData = data['data'] as Map<String, dynamic>;
          } else {
            // Direct data structure
            profileData = data;
          }

          // Parse and save
          _userModel = HomeModel.fromJson(profileData);

          // Save to secure storage
          await _storage.write(
            key: _storageKey,
            value: jsonEncode(profileData),
          );
          debugPrint('User profile saved to secure storage');
        }
      } else {
        debugPrint('Failed to load user: ${response.statusCode}');
        debugPrint('Error response: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load user profile from Secure Storage (offline use)
  Future<void> loadUserDataFromStorage() async {
    try {
      final storedData = await _storage.read(key: _storageKey);

      if (storedData != null) {
        final data = json.decode(storedData);
        _userModel = HomeModel.fromJson(data);
        debugPrint('Loaded user profile from secure storage');
        notifyListeners();
      } else {
        debugPrint('No stored user profile found');
      }
    } catch (e) {
      debugPrint('Error reading user profile from storage: $e');
    }
  }

  /// 🧹 Optional: Clear stored data (e.g., on logout)
  Future<void> clearUserData() async {
    await _storage.delete(key: _storageKey);
    _userModel = null;
    notifyListeners();
  }
}
