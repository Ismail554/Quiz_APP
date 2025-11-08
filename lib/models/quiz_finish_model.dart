class QuizFinishModel {
  final String id;
  final int totalQuestions;
  final int correctAnswers;
  final int xpGained;
  final int score;
  final String grade;
  final String createdAt;
  final String student;
  final String module;
  final List<AttendAnotherQuiz> attendAnotherQuiz;

  QuizFinishModel({
    required this.id,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.xpGained,
    required this.score,
    required this.grade,
    required this.createdAt,
    required this.student,
    required this.module,
    required this.attendAnotherQuiz,
  });

  factory QuizFinishModel.fromJson(Map<String, dynamic> json) {
    return QuizFinishModel(
      id: json['id'] ?? '',
      totalQuestions: json['total_questions'] ?? 0,
      correctAnswers: json['correct_answers'] ?? 0,
      xpGained: json['xp_gained'] ?? 0,
      score: json['score'] ?? 0,
      grade: json['grade'] ?? '',
      createdAt: json['created_at'] ?? '',
      student: json['student'] ?? '',
      module: json['module'] ?? '',
      attendAnotherQuiz:
          (json['attend_another_quiz'] as List<dynamic>?)
              ?.map((e) => AttendAnotherQuiz.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class AttendAnotherQuiz {
  final String id;
  final String moduleName;

  AttendAnotherQuiz({required this.id, required this.moduleName});

  factory AttendAnotherQuiz.fromJson(Map<String, dynamic> json) {
    return AttendAnotherQuiz(
      id: json['id'] ?? '',
      moduleName: json['module_name'] ?? '',
    );
  }
}
