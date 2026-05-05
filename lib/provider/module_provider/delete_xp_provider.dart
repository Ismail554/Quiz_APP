import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geography_geyser/core/app_logger.dart';
import 'package:geography_geyser/models/delete_xp_model.dart';
import 'package:geography_geyser/services/api_service.dart';
import 'package:geography_geyser/services/https_service.dart';

class DeleteXpProvider extends ChangeNotifier {
  bool isLoading = false;
  DeleteXpModel? deleteXpData;
  String? errorMessage;

  Future<bool> deleteXp(String quizId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await HttpManager.apiRequest(
        url: ApiService.deleteXpUrl,
        method: Method.post,
        body: {'quiz_id': quizId},
        name: 'DeleteXP',
        statusCode: 200, // or 201
      );

      return response.fold(
        (error) {
          errorMessage = "Failed to delete XP: $error";
          AppLogger.error('Failed to delete XP: $error');
          isLoading = false;
          notifyListeners();
          return false;
        },
        (data) {
          final decodedData = json.decode(data);
          deleteXpData = DeleteXpModel.fromJson(decodedData);
          errorMessage = null;
          isLoading = false;
          notifyListeners();
          return true;
        },
      );
    } catch (e) {
      errorMessage = "Error deleting XP: $e";
      AppLogger.error('Error deleting XP', e);
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearDeleteXp() {
    deleteXpData = null;
    errorMessage = null;
    notifyListeners();
  }
}
