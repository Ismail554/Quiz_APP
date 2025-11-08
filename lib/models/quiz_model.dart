class QuizModel {
  final String quizId;
  final List<QuestionModel> questions;

  QuizModel({required this.quizId, required this.questions});

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      quizId: json['quiz_id'] ?? '',
      questions:
          (json['questions'] as List<dynamic>?)
              ?.map((e) => QuestionModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class QuestionModel {
  final String id;
  final String questionText;
  final QuestionOptions options;
  final String correctAnswer;

  QuestionModel({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctAnswer,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] ?? '',
      questionText: json['question_text'] ?? '',
      options: QuestionOptions.fromJson(json['options'] ?? {}),
      correctAnswer: json['correct_answer'] ?? '',
    );
  }

  // Helper method to get options as a list for UI
  List<String> get optionsList => [
    options.option1,
    options.option2,
    options.option3,
    options.option4,
  ];

  // Helper method to get the index of correct answer
  int get correctAnswerIndex {
    switch (correctAnswer.toLowerCase()) {
      case 'option1':
        return 0;
      case 'option2':
        return 1;
      case 'option3':
        return 2;
      case 'option4':
        return 3;
      default:
        return 0;
    }
  }
}

class QuestionOptions {
  final String option1;
  final String option2;
  final String option3;
  final String option4;

  QuestionOptions({
    required this.option1,
    required this.option2,
    required this.option3,
    required this.option4,
  });

  factory QuestionOptions.fromJson(Map<String, dynamic> json) {
    return QuestionOptions(
      option1: json['option1'] ?? '',
      option2: json['option2'] ?? '',
      option3: json['option3'] ?? '',
      option4: json['option4'] ?? '',
    );
  }
}
