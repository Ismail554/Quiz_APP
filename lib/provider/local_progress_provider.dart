import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geography_geyser/core/sound_helper.dart';
import 'package:geography_geyser/models/v2_curriculum_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalProgressProvider extends ChangeNotifier {
  static const bool useStaticFirstMode = true;

  static const String _attemptsKey = 'v2_recent_quiz_attempts';
  static const String _unfinishedKey = 'v2_unfinished_quiz_session';
  static const String _completedScoresKey = 'v2_completed_quiz_scores';
  static const String _themeModeKey = 'v2_theme_mode';
  static const String _notificationsKey = 'v2_notifications_enabled';
  static const String _dailyReminderKey = 'v2_daily_reminder_enabled';
  static const String _hapticsKey = 'v2_haptics_enabled';
  static const String _soundKey = 'v2_sound_enabled';

  List<RecentAttemptItem> _recentAttempts = [];
  UnfinishedQuizSession? _unfinishedSession;
  Map<String, int> _completedBestScores = {};

  ThemeMode _themeMode = ThemeMode.light;
  bool _notificationsEnabled = true;
  bool _dailyReminderEnabled = true;
  bool _hapticsEnabled = true;
  bool _soundEnabled = true;
  bool _initialized = false;

  List<RecentAttemptItem> get recentAttempts => _recentAttempts;
  RecentAttemptItem? get latestAttempt =>
      _recentAttempts.isNotEmpty ? _recentAttempts.first : null;
  UnfinishedQuizSession? get unfinishedSession => _unfinishedSession;
  Map<String, int> get completedBestScores => _completedBestScores;

  ThemeMode get themeMode => _themeMode;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get dailyReminderEnabled => _dailyReminderEnabled;
  bool get hapticsEnabled => _hapticsEnabled;
  bool get soundEnabled => _soundEnabled;
  bool get youtubeAlertsEnabled => _notificationsEnabled;
  Future<void> setYoutubeAlertsEnabled(bool enabled) => setNotificationsEnabled(enabled);
  bool get soundEffectsEnabled => _soundEnabled;
  Future<void> setSoundEffectsEnabled(bool enabled) => setSoundEnabled(enabled);

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Preferences
      final themeStr = prefs.getString(_themeModeKey);
      if (themeStr == 'dark') {
        _themeMode = ThemeMode.dark;
      } else if (themeStr == 'system') {
        _themeMode = ThemeMode.system;
      } else {
        _themeMode = ThemeMode.light;
      }

      _notificationsEnabled = prefs.getBool(_notificationsKey) ?? true;
      _dailyReminderEnabled = prefs.getBool(_dailyReminderKey) ?? true;
      _hapticsEnabled = prefs.getBool(_hapticsKey) ?? true;
      _soundEnabled = prefs.getBool(_soundKey) ?? SoundHelper.isSoundEnabled;
      SoundHelper.setSoundEnabled(_soundEnabled);

      // Completed quiz scores
      final scoresRaw = prefs.getString(_completedScoresKey);
      if (scoresRaw != null && scoresRaw.isNotEmpty) {
        final decoded = jsonDecode(scoresRaw) as Map<String, dynamic>;
        _completedBestScores = decoded.map(
          (k, v) => MapEntry(k, (v as num).toInt()),
        );
      }

      // Unfinished session
      final unfinishedRaw = prefs.getString(_unfinishedKey);
      if (unfinishedRaw != null && unfinishedRaw.isNotEmpty) {
        _unfinishedSession = UnfinishedQuizSession.fromJson(
          jsonDecode(unfinishedRaw) as Map<String, dynamic>,
        );
      } else {
        // Seed a realistic unfinished quiz session on first run for Continue Learning
        _unfinishedSession = UnfinishedQuizSession(
          quizId: 'tectonics_eq2_casestudies',
          quizTitle: 'EQ2 Place-Based Case Studies',
          moduleId: 'tectonics',
          moduleName: 'Tectonics',
          currentQuestionIndex: 2,
          totalQuestions: 6,
          correctAnswersCount: 2,
          timeRemainingSeconds: 210,
          totalTimeMinutes: 5,
          isYouTubeQuiz: false,
          savedAt: DateTime.now().subtract(const Duration(hours: 2)),
        );
      }

      // Recent attempts
      final attemptsRaw = prefs.getString(_attemptsKey);
      if (attemptsRaw != null && attemptsRaw.isNotEmpty) {
        final list = jsonDecode(attemptsRaw) as List<dynamic>;
        _recentAttempts = list
            .map((e) => RecentAttemptItem.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        // Seed realistic initial Edexcel A-Level quiz attempts
        _recentAttempts = [
          RecentAttemptItem(
            quizId: 'tectonics_eq1_foundation',
            quizTitle: 'EQ1 Core Concepts & Terminology',
            moduleId: 'tectonics',
            moduleName: 'Tectonics',
            correctAnswers: 5,
            totalQuestions: 6,
            xpGained: 120,
            grade: 'A',
            completedAt: DateTime.now().subtract(const Duration(hours: 3)),
            isYouTubeQuiz: false,
          ),
          RecentAttemptItem(
            quizId: 'yt_carbon_eq2_energy',
            quizTitle: 'Carbon Cycle EQ2 Energy Essentials',
            moduleId: 'carbon',
            moduleName: 'Carbon',
            correctAnswers: 6,
            totalQuestions: 6,
            xpGained: 150,
            grade: 'A*',
            completedAt: DateTime.now().subtract(const Duration(days: 1)),
            isYouTubeQuiz: true,
          ),
          RecentAttemptItem(
            quizId: 'coasts_eq1_foundation',
            quizTitle: 'EQ1 Littoral Zones & Geology',
            moduleId: 'coasts',
            moduleName: 'Coasts',
            correctAnswers: 4,
            totalQuestions: 5,
            xpGained: 95,
            grade: 'B',
            completedAt: DateTime.now().subtract(const Duration(days: 2)),
            isYouTubeQuiz: false,
          ),
        ];
        _completedBestScores['tectonics_eq1_foundation'] = 83;
        _completedBestScores['yt_carbon_eq2_energy'] = 100;
        _completedBestScores['coasts_eq1_foundation'] = 80;
      }
    } catch (_) {}

    notifyListeners();
  }

  bool isQuizCompleted(String quizId) =>
      _completedBestScores.containsKey(quizId);

  int? getBestScore(String quizId) => _completedBestScores[quizId];

  bool isQuizInProgress(String quizId) =>
      _unfinishedSession != null && _unfinishedSession!.quizId == quizId;

  Future<void> saveUnfinishedSession(UnfinishedQuizSession session) async {
    _unfinishedSession = session;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_unfinishedKey, jsonEncode(session.toJson()));
    } catch (_) {}
  }

  Future<void> clearUnfinishedSession() async => clearUnfinishedSessionIfMatches(null);

  Future<void> clearUnfinishedSessionIfMatches(String? quizId) async {
    if (_unfinishedSession == null) return;
    if (quizId == null ||
        _unfinishedSession!.quizId == quizId ||
        _unfinishedSession!.moduleId == quizId) {
      _unfinishedSession = null;
      notifyListeners();
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_unfinishedKey);
      } catch (_) {}
    }
  }

  Future<void> recordCompletedAttempt(RecentAttemptItem attempt) async {
    _recentAttempts.insert(0, attempt);
    if (_recentAttempts.length > 15) {
      _recentAttempts = _recentAttempts.sublist(0, 15);
    }

    final prevBest = _completedBestScores[attempt.quizId] ?? 0;
    if (attempt.scorePercent >= prevBest) {
      _completedBestScores[attempt.quizId] = attempt.scorePercent;
    }

    if (_unfinishedSession != null &&
        (_unfinishedSession!.quizId == attempt.quizId ||
            _unfinishedSession!.moduleId == attempt.moduleId)) {
      _unfinishedSession = null;
    }

    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _attemptsKey,
        jsonEncode(_recentAttempts.map((e) => e.toJson()).toList()),
      );
      await prefs.setString(
        _completedScoresKey,
        jsonEncode(_completedBestScores),
      );
      if (_unfinishedSession == null) {
        await prefs.remove(_unfinishedKey);
      }
    } catch (_) {}
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = mode == ThemeMode.dark
          ? 'dark'
          : (mode == ThemeMode.system ? 'system' : 'light');
      await prefs.setString(_themeModeKey, str);
    } catch (_) {}
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationsKey, enabled);
    } catch (_) {}
  }

  Future<void> setDailyReminderEnabled(bool enabled) async {
    _dailyReminderEnabled = enabled;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_dailyReminderKey, enabled);
    } catch (_) {}
  }

  Future<void> setHapticsEnabled(bool enabled) async {
    _hapticsEnabled = enabled;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_hapticsKey, enabled);
    } catch (_) {}
  }

  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    SoundHelper.setSoundEnabled(enabled);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_soundKey, enabled);
    } catch (_) {}
  }
}
