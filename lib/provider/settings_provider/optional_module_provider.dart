import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geography_geyser/core/app_logger.dart';
import 'package:geography_geyser/models/optional_module_model.dart';
import 'package:geography_geyser/services/api_service.dart';
import 'package:geography_geyser/services/https_service.dart';

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
      final response = await HttpManager.apiRequest(
        url: ApiService.optionalModuleUrl,
        method: Method.get,
        name: 'OptionalModules',
        statusCode: 200,
      );

      response.fold(
        (error) {
          _errorMessage = error;
          AppLogger.error('Failed to load optional modules: $error');
        },
        (data) {
          final decodedData = json.decode(data);
          if (decodedData is List) {
            _modulePairs = OptionalModuleResponse.fromJson(decodedData).pairs;
          } else {
            _errorMessage = 'Invalid response format';
          }
        },
      );
    } catch (e) {
      AppLogger.error('Error fetching optional modules', e);
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

      if (selections.isEmpty) {
        _errorMessage = 'Please select at least one module';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final requestBody = UpdateModuleSelectionsRequest(selections: selections);

      final response = await HttpManager.apiRequest(
        url: ApiService.updateOptionalModuleUrl,
        method: Method.patch,
        body: requestBody.toJson(),
        name: 'UpdateOptionalModules',
        statusCode: 200,
      );

      return await response.fold(
        (error) async {
          _errorMessage = error;
          _isLoading = false;
          notifyListeners();
          return false;
        },
        (data) async {
          // Success - refresh data from API to get updated state
          await fetchOptionalModules();
          _isLoading = false;
          notifyListeners();
          return true;
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('Error updating module selections', e, stackTrace);
      _errorMessage = 'Error: ${e.toString()}';
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
