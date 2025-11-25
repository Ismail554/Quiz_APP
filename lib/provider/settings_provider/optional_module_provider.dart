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

  /// Update optional module selections via PATCH request
  Future<bool> updateModuleSelections() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Build selections list - only include pairs with selected modules
      final selections = _modulePairs
          .where(
            (pair) =>
                pair.selectedModule != null && pair.selectedModule!.isNotEmpty,
          )
          .map(
            (pair) => ModuleSelection(
              pairNumber: pair.pairNumber,
              selectedModule: pair.selectedModule!,
            ),
          )
          .toList();

      debugPrint('Total module pairs: ${_modulePairs.length}');
      debugPrint('Pairs with selections: ${selections.length}');
      for (var pair in _modulePairs) {
        debugPrint(
          'Pair ${pair.pairNumber}: selectedModule = ${pair.selectedModule}',
        );
      }

      if (selections.isEmpty) {
        _errorMessage = 'Please select at least one module';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final token = await SecureStorageHelper.getToken();

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      };

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      } else {
        _errorMessage = 'Authentication token not found. Please login again.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final requestBody = UpdateModuleSelectionsRequest(selections: selections);

      debugPrint(
        'Update Optional Module API URL: ${ApiService.updateOptionalModuleUrl}',
      );
      debugPrint(
        'Update Optional Module Request Body: ${jsonEncode(requestBody.toJson())}',
      );

      final response = await http.patch(
        Uri.parse(ApiService.updateOptionalModuleUrl),
        headers: headers,
        body: jsonEncode(requestBody.toJson()),
      );

      debugPrint('Update Optional Module API Status: ${response.statusCode}');
      debugPrint('Update Optional Module API Response: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Success - refresh data from API to get updated state
        await fetchOptionalModules();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // Try to parse error response
        try {
          final errorData = json.decode(response.body);
          _errorMessage =
              errorData['message'] ??
              errorData['error'] ??
              errorData['detail'] ??
              'Failed to update module selections';
        } catch (_) {
          // If response body is not JSON, use status code message
          final statusMsg =
              'Failed to update module selections. Status: ${response.statusCode}';
          _errorMessage = response.body.isNotEmpty
              ? '$statusMsg\nResponse: ${response.body}'
              : statusMsg;
        }
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint('Error updating module selections: $e');
      debugPrint('Stack trace: $stackTrace');

      // Handle different error types
      if (e is FormatException) {
        _errorMessage = 'Invalid response format from server';
      } else {
        _errorMessage = 'Error: ${e.toString()}';
      }

      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear module pairs data (e.g., on logout)
  void clearModulePairs() {
    _modulePairs = [];
    _errorMessage = null;
    notifyListeners();
  }
}
