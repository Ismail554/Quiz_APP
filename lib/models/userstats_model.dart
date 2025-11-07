class UserStatsModel {
  final double averageScore;
  final int totalAttemptedQuizzes;
  final int totalXp;
  final int dailyStreak;
  final DateTime lastActivity;
  final String strongestModule;

  UserStatsModel({
    required this.averageScore,
    required this.totalAttemptedQuizzes,
    required this.totalXp,
    required this.dailyStreak,
    required this.lastActivity,
    required this.strongestModule,
  });

  factory UserStatsModel.fromJson(Map<String, dynamic> json) {
    return UserStatsModel(
      averageScore: (json['average_score'] ?? 0).toDouble(),
      totalAttemptedQuizzes: json['total_attempted_quizzes'] ?? 0,
      totalXp: json['total_xp'] ?? 0,
      dailyStreak: json['daily_streak'] ?? 0,
      lastActivity: DateTime.parse(
        json['last_activity'] ?? DateTime.now().toString(),
      ),
      strongestModule: json['strongest_module'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'average_score': averageScore,
      'total_attempted_quizzes': totalAttemptedQuizzes,
      'total_xp': totalXp,
      'daily_streak': dailyStreak,
      'last_activity': lastActivity.toIso8601String(),
      'strongest_module': strongestModule,
    };
  }
}
