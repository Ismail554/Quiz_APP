import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geography_geyser/models/user_performance_model.dart';
import 'package:geography_geyser/services/api_service.dart';
import 'package:geography_geyser/services/https_service.dart';
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
      final response = await HttpManager.apiRequest(
        url: ApiService.userPerformance,
        method: Method.get,
        name: 'UserPerformance',
        statusCode: 200,
      );

      await response.fold(
        (error) async {
          debugPrint('Failed to load user performance: $error');
        },
        (data) async {
          final decodedData = json.decode(data);
          _profileData = ProfileModel.fromJson(decodedData);

          // Save to secure storage
          await _storage.write(key: _storageKey, value: data);
          debugPrint('User performance saved to secure storage');
        },
      );
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
