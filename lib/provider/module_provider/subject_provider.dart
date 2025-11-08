import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geography_geyser/models/module_model.dart';
import 'package:geography_geyser/services/api_service.dart';
import 'package:geography_geyser/secure_storage/secure_storage_helper.dart';
import 'package:http/http.dart' as http;

class SubjectProvider extends ChangeNotifier {
  // Subject list
  List<ModuleModel> _subjects = [];
  List<ModuleModel> get subjects => _subjects;

  // Pagination states
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;

  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  // -------- FETCH SUBJECT LIST -------------
  Future<void> fetchSubjects({bool isLoadMore = false}) async {
    if (_isLoading || (!_hasMore && isLoadMore)) return;

    // Reset pagination if this is a fresh load
    if (!isLoadMore) {
      _currentPage = 1;
      _hasMore = true;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Get authentication token if available
      final token = await SecureStorageHelper.getToken();

      // Build headers with ngrok skip warning and auth token
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      // Add auth token if available
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      // Build URL with proper query parameters
      final url = Uri.parse(
        ApiService.moduleListUrl,
      ).replace(queryParameters: {'page': _currentPage.toString()});

      final response = await http.get(url, headers: headers);

      debugPrint('Response Status:==== ${response.statusCode}');
      debugPrint('Response Body:==== ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['results'] != null) {
          List<dynamic> results = data['results'];
          final newSubjects = results
              .map((e) => ModuleModel.fromJson(e))
              .toList();

          if (isLoadMore) {
            _subjects.addAll(newSubjects);
          } else {
            _subjects = newSubjects;
          }

          debugPrint(
            'Loaded ${newSubjects.length} modules. Total: ${_subjects.length}',
          );

          // Check pagination
          if (data['next'] == null) {
            _hasMore = false;
            debugPrint('No more pages available');
          } else {
            _currentPage++;
            _hasMore = true;
            debugPrint('More pages available. Next page: $_currentPage');
          }
        } else {
          debugPrint('No results field in response');
          throw Exception("Invalid response format: missing 'results' field");
        }
      } else {
        final errorBody = response.body;
        debugPrint('API Error (${response.statusCode}): $errorBody');
        throw Exception("Failed to load subjects: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching subjects: $e");
      // Re-throw to let UI handle it
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Optional: for refresh
  Future<void> refreshSubjects() async {
    _currentPage = 1;
    _hasMore = true;
    _subjects.clear();
    await fetchSubjects();
  }
}
