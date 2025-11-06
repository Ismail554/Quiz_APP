import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geography_geyser/models/privacy_settings_model.dart';
import 'package:geography_geyser/secure_storage/secure_storage_helper.dart';
import 'package:geography_geyser/services/api_service.dart';
import 'package:http/http.dart' as http;

class PrivacySettingsProvider with ChangeNotifier {
  bool _isLoading = false;
  String _message = '';
  bool _isSuccess = false;

  bool get isLoading => _isLoading;
  String get message => _message;
  bool get isSuccess => _isSuccess;

  Future<void> updatePassword(String oldPassword, String newPassword) async {
    _isLoading = true;
    _isSuccess = false;
    _message = '';
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

      debugPrint('Password update URL: ${ApiService.updatePrivacy}');
      debugPrint('Headers: $headers');

      final response = await http.patch(
        Uri.parse(ApiService.updatePrivacy),
        headers: headers,
        body: jsonEncode({
          'old_password': oldPassword,
          'new_password': newPassword,
        }),
      );

      debugPrint('Response Status: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Success response (200-299)
        _isSuccess = true;
        try {
          final data = jsonDecode(response.body);
          final result = PasswordUpdateResponse.fromJson(data);
          _message = result.message.isNotEmpty
              ? result.message
              : 'Password updated successfully';
        } catch (_) {
          _message = 'Password updated successfully';
        }
      } else {
        // Error response - try to parse error message
        _isSuccess = false;
        try {
          final errorData = jsonDecode(response.body);
          // Handle different error formats
          if (errorData is Map) {
            _message =
                errorData['message'] ??
                errorData['error'] ??
                errorData['detail'] ??
                errorData['old_password']?.toString() ??
                errorData['new_password']?.toString() ??
                'Failed to update password';
          } else {
            _message = 'Failed to update password';
          }
        } catch (_) {
          _message =
              'Failed to update password. Status: ${response.statusCode}';
        }
      }
    } catch (e) {
      _isSuccess = false;
      debugPrint('Error updating password: $e');
      _message = 'Error: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }
}
