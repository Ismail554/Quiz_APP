import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geography_geyser/models/user_performance_model.dart';
import 'package:geography_geyser/secure_storage/secure_storage_helper.dart';
import 'package:geography_geyser/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileModel? _profileData;
  bool _isLoading = false;

  final _storage = const FlutterSecureStorage();
  static const _storageKey = 'user_performance_data'; // Storage key name

  ProfileModel? get profileData => _profileData;
  bool get isLoading => _isLoading;

  /// Fetch user performance from API and store securely
  Future<void> fetchProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await SecureStorageHelper.getToken();
      final fetchPerformance = ApiService.userPerformance;

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

      final response = await http.get(
        Uri.parse(fetchPerformance),
        headers: headers,
      );

      debugPrint('User Performance API Status: ${response.statusCode}');
      debugPrint('User Performance API Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _profileData = ProfileModel.fromJson(data);

        // Save to secure storage
        await _storage.write(key: _storageKey, value: jsonEncode(data));
        debugPrint('User performance saved to secure storage');
      } else {
        debugPrint('Failed to load user performance: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching user performance: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load from Secure Storage (offline use)
  Future<void> loadProfileFromStorage() async {
    try {
      final storedData = await _storage.read(key: _storageKey);

      if (storedData != null) {
        final data = json.decode(storedData);
        _profileData = ProfileModel.fromJson(data);
        debugPrint('Loaded user performance from secure storage');
        notifyListeners();
      } else {
        debugPrint('No stored user performance found');
      }
    } catch (e) {
      debugPrint('Error reading user performance from storage: $e');
    }
  }

  /// 🧹 Optional: Clear stored data (e.g., on logout)
  Future<void> clearProfileData() async {
    await _storage.delete(key: _storageKey);
    _profileData = null;
    notifyListeners();
  }
}
