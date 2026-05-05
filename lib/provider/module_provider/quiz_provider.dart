import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geography_geyser/core/app_logger.dart';
import 'package:geography_geyser/models/quiz_model.dart';
import 'package:geography_geyser/services/api_service.dart';
import 'package:geography_geyser/services/https_service.dart';

class QuizProvider extends ChangeNotifier {
  bool isLoading = false;
  QuizModel? quizData;
  String? errorMessage;

  Future<void> fetchQuiz(String moduleId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await HttpManager.apiRequest(
        url: ApiService.quizStartUrl,
        method: Method.post,
        body: {'module_id': moduleId},
        name: 'QuizStart',
        statusCode: 200,
      );

      response.fold(
        (error) {
          errorMessage = "There is an error. Try again";
          AppLogger.error('Failed to load quiz: $error');
        },
        (data) {
          final decodedData = json.decode(data);
          quizData = QuizModel.fromJson(decodedData);
          errorMessage = null;
        },
      );
    } catch (e) {
      errorMessage = "There is an error. Try again";
      AppLogger.error('Error fetching quiz', e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch synoptic quiz using synoptic API endpoint
  Future<void> fetchSynopticQuiz() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await HttpManager.apiRequest(
        url: ApiService.synopticQuizStartUrl,
        method: Method.post,
        body: {}, // Synoptic quiz doesn't need module_id
        name: 'SynopticQuizStart',
        statusCode: 200,
      );

      response.fold(
        (error) {
          errorMessage = "Failed to fetch synoptic quiz";
          AppLogger.error('Failed to load synoptic quiz: $error');
        },
        (data) {
          final decodedData = json.decode(data);
          quizData = QuizModel.fromJson(decodedData);
          errorMessage = null;
        },
      );
    } catch (e) {
      errorMessage = "Error fetching synoptic quiz: $e";
      AppLogger.error('Error fetching synoptic quiz', e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearQuiz() {
    quizData = null;
    errorMessage = null;
    notifyListeners();
  }
}
