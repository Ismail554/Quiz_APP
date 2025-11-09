// user_stats_provider.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geography_geyser/models/userstats_model.dart';
import 'package:geography_geyser/secure_storage/secure_storage_helper.dart';
import 'package:geography_geyser/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserStatsProvider extends ChangeNotifier {
  UserStatsModel? _userStats;
  bool _isLoading = false;

  final _storage = const FlutterSecureStorage();
  static const _storageKey = 'user_stats_data'; //  Key name

  UserStatsModel? get userStats => _userStats;
  bool get isLoading => _isLoading;

  /// Fetch stats from API and store securely
  Future<void> fetchUserStats() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await SecureStorageHelper.getToken();
      final fetchStats = ApiService.userState;

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

      final response = await http.get(Uri.parse(fetchStats), headers: headers);

      debugPrint('User Stats API Status: ${response.statusCode}');
      debugPrint('User Stats API Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _userStats = UserStatsModel.fromJson(data);

        // Save to secure storage
        await _storage.write(key: _storageKey, value: jsonEncode(data));
      } else {
        debugPrint('Failed to load user stats: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching stats: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load from Secure Storage (offline use)
  Future<void> loadUserStatsFromStorage() async {
    try {
      final storedData = await _storage.read(key: _storageKey);

      if (storedData != null) {
        final data = json.decode(storedData);
        _userStats = UserStatsModel.fromJson(data);
        debugPrint('Loaded user stats from secure storage');
        notifyListeners();
      } else {
        debugPrint('No stored user stats found');
      }
    } catch (e) {
      debugPrint('Error reading from storage: $e');
    }
  }

  /// 🧹 Optional: Clear stored data (e.g., on logout)
  Future<void> clearUserStats() async {
    await _storage.delete(key: _storageKey);
    _userStats = null;
    notifyListeners();
  }
}
