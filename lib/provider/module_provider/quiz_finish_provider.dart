import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geography_geyser/core/app_logger.dart';
import 'package:geography_geyser/models/quiz_finish_model.dart';
import 'package:geography_geyser/services/api_service.dart';
import 'package:geography_geyser/services/https_service.dart';

class QuizFinishProvider extends ChangeNotifier {
  bool isLoading = false;
  QuizFinishModel? quizFinishData;
  String? errorMessage;
  int? attemptedQuestions; // Store attempted questions count

  Future<bool> finishQuiz(
    String quizId,
    int correctAnswers,
    int attempted,
  ) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await HttpManager.apiRequest(
        url: ApiService.quizFinishUrl,
        method: Method.post,
        body: {
          'quiz_id': quizId,
          'correct': correctAnswers,
          'attempted': attempted,
        },
        name: 'QuizFinish',
        statusCode: 200, // or 201
      );

      return response.fold(
        (error) {
          errorMessage = "Failed to finish quiz: $error";
          AppLogger.error('Failed to finish quiz: $error');
          isLoading = false;
          notifyListeners();
          return false;
        },
        (data) {
          final decodedData = json.decode(data);
          quizFinishData = QuizFinishModel.fromJson(decodedData);
          attemptedQuestions = attempted; // Store attempted count
          errorMessage = null;
          isLoading = false;
          notifyListeners();
          return true;
        },
      );
    } catch (e) {
      errorMessage = "Error finishing quiz: $e";
      AppLogger.error('Error finishing quiz', e);
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearQuizFinish() {
    quizFinishData = null;
    errorMessage = null;
    attemptedQuestions = null;
    notifyListeners();
  }
}
