import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geography_geyser/models/quiz_model.dart';
import 'package:geography_geyser/secure_storage/secure_storage_helper.dart';
import 'package:geography_geyser/services/api_service.dart';
import 'package:http/http.dart' as http;

class QuizProvider extends ChangeNotifier {
  bool isLoading = false;
  QuizModel? quizData;
  String? errorMessage;

  Future<void> fetchQuiz(String moduleId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final token = await SecureStorageHelper.getToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true', // Required for ngrok
      };

      // Add auth token if available
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.post(
        Uri.parse(ApiService.quizStartUrl),
        headers: headers,
        body: json.encode({'module_id': moduleId}),
      );

      if (kDebugMode) {
        print("Quiz API Status: ${response.statusCode}");
        print("Quiz API Response: ${response.body}");
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        quizData = QuizModel.fromJson(data);
        errorMessage = null;
      } else {
        errorMessage = "Failed to fetch quiz: ${response.statusCode}";
        if (kDebugMode) {
          print("Response body: ${response.body}");
        }
      }
    } catch (e) {
      errorMessage = "Error fetching quiz: $e";
      if (kDebugMode) {
        print("Error fetching quiz: $e");
      }
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
