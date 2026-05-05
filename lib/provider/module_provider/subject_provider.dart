import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geography_geyser/core/app_logger.dart';
import 'package:geography_geyser/models/module_model.dart';
import 'package:geography_geyser/services/api_service.dart';
import 'package:geography_geyser/services/https_service.dart';

class SubjectProvider extends ChangeNotifier {
  List<ModuleModel> _subjects = [];
  List<ModuleModel> get subjects => _subjects;

  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastFetchTime;
  static const _cacheDuration = Duration(minutes: 5);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Check if cached data is still valid
  bool get _hasValidCache {
    if (_subjects.isEmpty) return false;
    if (_lastFetchTime == null) return false;
    return DateTime.now().difference(_lastFetchTime!) < _cacheDuration;
  }

  Future<void> fetchSubjects({bool forceRefresh = false}) async {
    // Return early if already loading
    if (_isLoading) return;

    // Return cached data if valid and not forcing refresh
    if (!forceRefresh && _hasValidCache) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await HttpManager.apiRequest(
        url: ApiService.moduleListUrl,
        method: Method.get,
        name: 'FetchSubjects',
        statusCode: 200,
      );

      await response.fold(
        (error) async {
          _errorMessage = error;
          _subjects = [];
        },
        (data) async {
          final newSubjects = await compute<String, List<ModuleModel>>(parseModules, data.toString());
          
          if (newSubjects.isEmpty) {
            _errorMessage = "No modules available at this moment.";
            _subjects = [];
          } else {
            // Only update and notify if data actually changed
            final hasChanged = !_listEquals(_subjects, newSubjects);
            if (hasChanged) {
              _subjects = newSubjects;
            }
            _errorMessage = null;
          }
        },
      );
      
      _lastFetchTime = DateTime.now();
    } catch (e) {
      AppLogger.error("SubjectProvider Error", e);
      _errorMessage = "Something went wrong. Please try again.";
      _subjects = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Helper to compare lists efficiently
  bool _listEquals(List<ModuleModel> a, List<ModuleModel> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id || a[i].moduleName != b[i].moduleName) {
        return false;
      }
    }
    return true;
  }

  Future<void> refreshSubjects() async {
    await fetchSubjects(forceRefresh: true);
  }
}

// TOP-LEVEL FUNCTION (Compute needs this)
List<ModuleModel> parseModules(String responseBody) {
  final data = json.decode(responseBody);
  final results = data["results"] as List;
  return results.map((e) => ModuleModel.fromJson(e)).toList();
}
