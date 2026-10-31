import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geography_geyser/core/app_logger.dart';
import 'package:geography_geyser/services/api_service.dart';
import 'package:geography_geyser/services/https_service.dart';
import 'package:geography_geyser/models/profile_update_response.dart';
import 'package:dio/dio.dart';

class ProfileUpdateProvider with ChangeNotifier {
  bool _isLoading = false;
  ProfileData? _updatedProfile;
  String? _message;

  bool get isLoading => _isLoading;
  ProfileData? get updatedProfile => _updatedProfile;
  String? get message => _message;

  /// PATCH profile update request
  Future<bool> updateProfile({
    required String fullName,
    File? profilePic,
  }) async {
    _isLoading = true;
    _message = null;
    notifyListeners();

    try {
      final fields = {
        'full_name': fullName,
      };

      final List<MultipartFile> files = [];
      if (profilePic != null) {
        files.add(
          await MultipartFile.fromFile(
            profilePic.path,
            filename: profilePic.path.split(Platform.pathSeparator).last,
          ),
        );
      }

      final response = await HttpManager.multipartRequest(
        url: ApiService.updateProfile,
        method: Method.patch,
        fields: fields,
        files: files,
        name: 'UpdateProfile',
        statusCode: 200,
      );

      final isSuccess = response.fold(
        (error) {
          _message = error;
          return false;
        },
        (data) {
          final decodedData = jsonDecode(data);
          final profileResponse = ProfileUpdateResponse.fromJson(decodedData);

          _updatedProfile = profileResponse.data;
          _message = profileResponse.message;

          AppLogger.debug("Profile updated: ${_updatedProfile?.fullName}");
          return true;
        },
      );
      return isSuccess;
    } catch (e) {
      AppLogger.error("ProfileUpdateProvider Error", e);
      _message = "Something went wrong!";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
