import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geography_geyser/models/userstats_model.dart';
import 'package:geography_geyser/services/api_service.dart';
import 'package:geography_geyser/services/https_service.dart';
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
      final response = await HttpManager.apiRequest(
        url: ApiService.userState,
        method: Method.get,
        name: 'UserStats',
        statusCode: 200,
      );

      await response.fold(
        (error) async {
          debugPrint('Failed to load user stats: $error');
        },
        (data) async {
          final decodedData = json.decode(data);
          _userStats = UserStatsModel.fromJson(decodedData);

          // Save to secure storage
          await _storage.write(key: _storageKey, value: data);
          debugPrint('User stats saved to secure storage');
        },
      );
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
