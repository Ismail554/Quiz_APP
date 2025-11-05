import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geography_geyser/secure_storage/secure_storage_helper.dart';
import 'package:geography_geyser/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:geography_geyser/models/profile_update_response.dart'; // make sure path correct

class ProfileUpdateProvider with ChangeNotifier {
  bool _isLoading = false;
  ProfileData? _updatedProfile;
  String? _message;

  bool get isLoading => _isLoading;
  ProfileData? get updatedProfile => _updatedProfile;
  String? get message => _message;

  /// PATCH profile update request
  Future<void> updateProfile({
    required String fullName,
    File? profilePic,
    required String token,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await SecureStorageHelper.getToken();
      var request = http.MultipartRequest(
        'PATCH',
        Uri.parse(ApiService.updateProfile),
      );

      // Add Authorization header
     request.headers['Authorization'] = 'Bearer $token';

      // Add text fields
      request.fields['full_name'] = fullName;

      // Add image if selected
      if (profilePic != null) {
        request.files.add(
          await http.MultipartFile.fromPath('profile_pic', profilePic.path),
        );
      }

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      debugPrint("STATUS: ${response.statusCode}");
      debugPrint("BODY: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final profileResponse = ProfileUpdateResponse.fromJson(data);

        _updatedProfile = profileResponse.data;
        _message = profileResponse.message;

        debugPrint("Profile updated: ${_updatedProfile?.fullName}");
      } else {
        debugPrint("Failed to update profile: ${response.statusCode}");
        _message = "Failed to update profile";
      }
    } catch (e) {
      debugPrint("Exception: $e");
      _message = "Something went wrong!";
    }

    _isLoading = false;
    notifyListeners();
  }
}
