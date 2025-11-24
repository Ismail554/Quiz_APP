class ProfileModel {
  final String fullName;
  final String? profilePic;
  final int totalXp;
  final int quizAttempted;
  final double averageScore;
  final List<SubjectModel> subjects;
  final int subjectCovered;

  ProfileModel({
    required this.fullName,
    required this.profilePic,
    required this.totalXp,
    required this.quizAttempted,
    required this.averageScore,
    required this.subjects,
    required this.subjectCovered,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      fullName: json['full_name'] ?? '',
      profilePic: json['profile_pic'],
      totalXp: json['total_xp'] ?? 0,
      quizAttempted: json['quiz_attempted'] ?? 0,
      averageScore: (json['average_score'] ?? 0).toDouble(),
      subjects: json['subjects'] != null && json['subjects'] is List
          ? (json['subjects'] as List<dynamic>)
                .map((item) => SubjectModel.fromJson(item))
                .toList()
          : <SubjectModel>[],
      subjectCovered: json['subject_covered'] ?? 0,
    );
  }
}

class SubjectModel {
  final String id;
  final String moduleName;
  final double progress;
  final int quizAttempted;
  final double averageScore;

  SubjectModel({
    required this.id,
    required this.moduleName,
    required this.progress,
    required this.quizAttempted,
    required this.averageScore,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['id'] ?? '',
      moduleName: json['module_name'] ?? '',
      progress: (json['progress'] ?? 0).toDouble(),
      quizAttempted: json['quiz_attempted'] ?? 0,
      averageScore: (json['average_score'] ?? 0).toDouble(),
    );
  }
}
