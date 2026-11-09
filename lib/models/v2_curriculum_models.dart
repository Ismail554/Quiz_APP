import 'package:flutter/material.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/models/quiz_model.dart';

enum QuizDifficulty {
  easy,
  medium,
  hard;

  String get label {
    switch (this) {
      case QuizDifficulty.easy:
        return 'Foundation';
      case QuizDifficulty.medium:
        return 'Intermediate';
      case QuizDifficulty.hard:
        return 'A* Challenge';
    }
  }

  Color get color {
    switch (this) {
      case QuizDifficulty.easy:
        return AppColors.easyEmerald;
      case QuizDifficulty.medium:
        return AppColors.mediumAmber;
      case QuizDifficulty.hard:
        return AppColors.hardRose;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case QuizDifficulty.easy:
        return AppColors.easyEmeraldBg;
      case QuizDifficulty.medium:
        return AppColors.mediumAmberBg;
      case QuizDifficulty.hard:
        return AppColors.hardRoseBg;
    }
  }
}

enum ModuleGroup {
  groupA,
  groupB,
  synoptic;

  String get title {
    switch (this) {
      case ModuleGroup.groupA:
        return 'Group A — Core Modules (EQ1–EQ3)';
      case ModuleGroup.groupB:
        return 'Group B — Optional Modules (EQ1–EQ4)';
      case ModuleGroup.synoptic:
        return 'Paper 3 — Synoptic Assessment';
    }
  }

  String get shortBadge {
    switch (this) {
      case ModuleGroup.groupA:
        return 'Group A • 3 EQs';
      case ModuleGroup.groupB:
        return 'Group B • 4 EQs';
      case ModuleGroup.synoptic:
        return 'Synoptic';
    }
  }
}

class SpecModuleItem {
  final String id;
  final String name;
  final String shortTitle;
  final String subtitle;
  final String paperLabel;
  final ModuleGroup group;
  final IconData icon;
  final Color accentColor;
  final List<EnquiryQuestionItem> enquiryQuestions;

  const SpecModuleItem({
    required this.id,
    required this.name,
    required this.shortTitle,
    required this.subtitle,
    required this.paperLabel,
    required this.group,
    required this.icon,
    required this.accentColor,
    required this.enquiryQuestions,
  });

  String get title => name;
  int get eqCount => enquiryQuestions.length;

  int get totalSubQuizzes =>
      enquiryQuestions.fold(0, (sum, eq) => sum + eq.subQuizzes.length);
}

class EnquiryQuestionItem {
  final String id;
  final String moduleId;
  final String moduleName;
  final int eqNumber;
  final String title;
  final String keyFocus;
  final List<SubQuizItem> subQuizzes;

  const EnquiryQuestionItem({
    required this.id,
    required this.moduleId,
    required this.moduleName,
    required this.eqNumber,
    required this.title,
    required this.keyFocus,
    required this.subQuizzes,
  });

  String get eqBadge => 'EQ$eqNumber';
}

class SubQuizItem {
  final String id;
  final String moduleId;
  final String moduleName;
  final String eqId;
  final int eqNumber;
  final String title;
  final String topicSummary;
  final QuizDifficulty difficulty;
  final int estimatedMinutes;
  final List<QuestionModel> questions;

  const SubQuizItem({
    required this.id,
    required this.moduleId,
    required this.moduleName,
    required this.eqId,
    required this.eqNumber,
    required this.title,
    required this.topicSummary,
    required this.difficulty,
    required this.estimatedMinutes,
    required this.questions,
  });

  int get questionCount => questions.length;
}

class YouTubeQuizItem {
  final String quizId;
  final String videoId;
  final String title;
  final String subtitle;
  final String moduleId;
  final String moduleName;
  final String eqBadge;
  final QuizDifficulty difficulty;
  final int durationMinutes;
  final String videoDurationLabel;
  final List<QuestionModel> questions;

  const YouTubeQuizItem({
    required this.quizId,
    required this.videoId,
    required this.title,
    required this.subtitle,
    required this.moduleId,
    required this.moduleName,
    required this.eqBadge,
    required this.difficulty,
    required this.durationMinutes,
    required this.videoDurationLabel,
    required this.questions,
  });

  int get questionCount => questions.length;
  int get estimatedMinutes => durationMinutes;

  String get thumbnailUrl => 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
  String get youtubeWatchUrl => 'https://www.youtube.com/@GeographyGeyser';
  String get deepLinkUrl => 'https://geographygeyser.com/quiz/$quizId';
}

class RecentAttemptItem {
  final String quizId;
  final String quizTitle;
  final String moduleId;
  final String moduleName;
  final int correctAnswers;
  final int totalQuestions;
  final int xpGained;
  final String grade;
  final DateTime completedAt;
  final bool isYouTubeQuiz;

  const RecentAttemptItem({
    required this.quizId,
    required this.quizTitle,
    required this.moduleId,
    required this.moduleName,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.xpGained,
    required this.grade,
    required this.completedAt,
    this.isYouTubeQuiz = false,
  });

  int get scorePercent =>
      totalQuestions > 0 ? ((correctAnswers / totalQuestions) * 100).round() : 0;

  Map<String, dynamic> toJson() => {
        'quizId': quizId,
        'quizTitle': quizTitle,
        'moduleId': moduleId,
        'moduleName': moduleName,
        'correctAnswers': correctAnswers,
        'totalQuestions': totalQuestions,
        'xpGained': xpGained,
        'grade': grade,
        'completedAt': completedAt.toIso8601String(),
        'isYouTubeQuiz': isYouTubeQuiz,
      };

  factory RecentAttemptItem.fromJson(Map<String, dynamic> json) {
    return RecentAttemptItem(
      quizId: json['quizId']?.toString() ?? '',
      quizTitle: json['quizTitle']?.toString() ?? 'Geography Quiz',
      moduleId: json['moduleId']?.toString() ?? 'tectonics',
      moduleName: json['moduleName']?.toString() ?? 'Tectonics',
      correctAnswers: (json['correctAnswers'] as num?)?.toInt() ?? 0,
      totalQuestions: (json['totalQuestions'] as num?)?.toInt() ?? 10,
      xpGained: (json['xpGained'] as num?)?.toInt() ?? 50,
      grade: json['grade']?.toString() ?? 'A',
      completedAt: DateTime.tryParse(json['completedAt']?.toString() ?? '') ??
          DateTime.now(),
      isYouTubeQuiz: json['isYouTubeQuiz'] == true,
    );
  }
}

class UnfinishedQuizSession {
  final String quizId;
  final String quizTitle;
  final String moduleId;
  final String moduleName;
  final int currentQuestionIndex;
  final int totalQuestions;
  final int correctAnswersCount;
  final int timeRemainingSeconds;
  final int totalTimeMinutes;
  final bool isYouTubeQuiz;
  final DateTime savedAt;

  const UnfinishedQuizSession({
    required this.quizId,
    required this.quizTitle,
    required this.moduleId,
    required this.moduleName,
    required this.currentQuestionIndex,
    required this.totalQuestions,
    required this.correctAnswersCount,
    required this.timeRemainingSeconds,
    required this.totalTimeMinutes,
    this.isYouTubeQuiz = false,
    required this.savedAt,
  });

  double get progressFraction => totalQuestions > 0
      ? ((currentQuestionIndex) / totalQuestions).clamp(0.05, 0.95)
      : 0.0;

  Map<String, dynamic> toJson() => {
        'quizId': quizId,
        'quizTitle': quizTitle,
        'moduleId': moduleId,
        'moduleName': moduleName,
        'currentQuestionIndex': currentQuestionIndex,
        'totalQuestions': totalQuestions,
        'correctAnswersCount': correctAnswersCount,
        'timeRemainingSeconds': timeRemainingSeconds,
        'totalTimeMinutes': totalTimeMinutes,
        'isYouTubeQuiz': isYouTubeQuiz,
        'savedAt': savedAt.toIso8601String(),
      };

  factory UnfinishedQuizSession.fromJson(Map<String, dynamic> json) {
    return UnfinishedQuizSession(
      quizId: json['quizId']?.toString() ?? '',
      quizTitle: json['quizTitle']?.toString() ?? 'Geography Quiz',
      moduleId: json['moduleId']?.toString() ?? 'tectonics',
      moduleName: json['moduleName']?.toString() ?? 'Tectonics',
      currentQuestionIndex:
          (json['currentQuestionIndex'] as num?)?.toInt() ?? 0,
      totalQuestions: (json['totalQuestions'] as num?)?.toInt() ?? 10,
      correctAnswersCount:
          (json['correctAnswersCount'] as num?)?.toInt() ?? 0,
      timeRemainingSeconds:
          (json['timeRemainingSeconds'] as num?)?.toInt() ?? 300,
      totalTimeMinutes: (json['totalTimeMinutes'] as num?)?.toInt() ?? 5,
      isYouTubeQuiz: json['isYouTubeQuiz'] == true,
      savedAt:
          DateTime.tryParse(json['savedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
