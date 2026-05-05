import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geography_geyser/models/privacy_settings_model.dart';
import 'package:geography_geyser/services/api_service.dart';
import 'package:geography_geyser/services/https_service.dart';

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
      final response = await HttpManager.apiRequest(
        url: ApiService.updatePrivacy,
        method: Method.patch,
        body: {
          'old_password': oldPassword,
          'new_password': newPassword,
        },
        name: 'UpdatePrivacy',
        statusCode: 200,
      );

      response.fold(
        (error) {
          _isSuccess = false;
          _message = error;
        },
        (data) {
          _isSuccess = true;
          try {
            final decodedData = jsonDecode(data);
            final result = PasswordUpdateResponse.fromJson(decodedData);
            _message = result.message.isNotEmpty
                ? result.message
                : 'Password updated successfully';
          } catch (_) {
            _message = 'Password updated successfully';
          }
        },
      );
    } catch (e) {
      _isSuccess = false;
      debugPrint('Error updating password: $e');
      _message = 'Error: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }
}
