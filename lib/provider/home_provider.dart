import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geography_geyser/models/home_model.dart';
import 'package:geography_geyser/secure_storage/secure_storage_helper.dart';
import 'package:geography_geyser/services/api_service.dart';
import 'package:http/http.dart' as http;

class UserProvider extends ChangeNotifier {
  HomeModel? userModel;
  bool isLoading = false;

  Future<void> fetchUserData() async {
    isLoading = true;
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
          // Check if data is nested under 'data' key
          if (data.containsKey('data') &&
              data['data'] is Map<String, dynamic>) {
            userModel = HomeModel.fromJson(data['data']);
          } else {
            // Direct data structure
            userModel = HomeModel.fromJson(data);
          }
        }
      } else {
        debugPrint('Failed to load user: ${response.statusCode}');
        debugPrint('Error response: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching user: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
