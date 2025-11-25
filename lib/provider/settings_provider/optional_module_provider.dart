import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geography_geyser/models/optional_module_model.dart';
import 'package:geography_geyser/secure_storage/secure_storage_helper.dart';
import 'package:geography_geyser/services/api_service.dart';
import 'package:http/http.dart' as http;

class OptionalModuleProvider extends ChangeNotifier {
  List<ModulePair> _modulePairs = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ModulePair> get modulePairs => _modulePairs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetch optional modules from API
  Future<void> fetchOptionalModules() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await SecureStorageHelper.getToken();

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      };

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        Uri.parse(ApiService.optionalModuleUrl),
        headers: headers,
      );

      debugPrint('Optional Module API Status: ${response.statusCode}');
      debugPrint('Optional Module API Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          _modulePairs = OptionalModuleResponse.fromJson(data).pairs;
        } else {
          _errorMessage = 'Invalid response format';
        }
      } else {
        _errorMessage = 'Failed to load optional modules';
        debugPrint('Failed to load optional modules: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching optional modules: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update selected module for a pair
  void updateSelectedModule(int pairNumber, String? moduleId) {
    final pairIndex = _modulePairs.indexWhere(
      (pair) => pair.pairNumber == pairNumber,
    );

    if (pairIndex != -1) {
      _modulePairs[pairIndex] = ModulePair(
        pairNumber: _modulePairs[pairIndex].pairNumber,
        modules: _modulePairs[pairIndex].modules,
        selectedModule: moduleId,
      );
      notifyListeners();
    }
  }

  /// Get selected module ID for a pair
  String? getSelectedModuleId(int pairNumber) {
    final pair = _modulePairs.firstWhere(
      (p) => p.pairNumber == pairNumber,
      orElse: () => ModulePair(pairNumber: pairNumber, modules: []),
    );
    return pair.selectedModule;
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
