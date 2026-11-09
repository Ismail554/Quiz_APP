import 'dart:convert';
import 'package:fpdart/fpdart.dart';
import 'package:geography_geyser/core/data/static_curriculum_data.dart';
import 'package:geography_geyser/core/data/static_questions_bank.dart';
import 'package:geography_geyser/core/data/static_youtube_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provides fast, deterministic, persistent responses for all ApiService endpoints
/// while operating in static/local-first mode. Flip [enabled] to false when
/// connecting to the updated live backend.
class StaticBackendResponder {
  StaticBackendResponder._();

  static const bool enabled = true;

  static const String _nameKey = 'v2_static_user_name';
  static const String _emailKey = 'v2_static_user_email';
  static const String _picKey = 'v2_static_user_pic';
  static const String _xpKey = 'v2_static_total_xp';
  static const String _attemptedKey = 'v2_static_quiz_attempted';
  static const String _avgScoreKey = 'v2_static_avg_score';
  static const String _streakKey = 'v2_static_daily_streak';
  static const String _optionalPairsKey = 'v2_static_optional_pairs';

  static Future<Either<String, String>> handleRequest({
    required String url,
    required String method,
    dynamic body,
    Map<String, String>? fields,
  }) async {
    await Future.delayed(const Duration(milliseconds: 120));
    final prefs = await SharedPreferences.getInstance();

    final Map<String, dynamic> bodyMap = _normalizeBody(body, fields);

    // 1. Auth: Login / Google / Apple
    if (url.contains('/auth/login/') ||
        url.contains('/auth/email/') ||
        url.contains('/auth/apple/')) {
      final email = bodyMap['email']?.toString().trim().isNotEmpty == true
          ? bodyMap['email'].toString().trim()
          : (prefs.getString(_emailKey) ?? 'explorer@geographygeyser.com');
      await prefs.setString(_emailKey, email);
      if (!prefs.containsKey(_nameKey)) {
        final inferredName = email.contains('@')
            ? _capitalizeName(email.split('@').first)
            : 'Alex Rivera';
        await prefs.setString(_nameKey, inferredName);
      }

      return right(
        jsonEncode({
          'access_token': 'static_v2_access_token_2026',
          'refresh_token': 'static_v2_refresh_token_2026',
          'email': email,
          'is_optional_module_selected': true,
        }),
      );
    }

    // 2. Auth: Signup / Register
    if (url.contains('/auth/register/')) {
      final email =
          bodyMap['email']?.toString().trim() ?? 'student@geographygeyser.com';
      final fullName =
          bodyMap['full_name']?.toString().trim() ?? 'Geography Explorer';
      await prefs.setString(_emailKey, email);
      await prefs.setString(_nameKey, fullName);

      return right(
        jsonEncode({
          'verificationToken': 'static_v2_verify_token',
          'user': {
            'id': 'usr_v2_01',
            'email': email,
            'full_name': fullName,
          },
        }),
      );
    }

    // 3. Auth: Verify OTP & Forgot Password flows
    if (url.contains('/auth/verify-otp/')) {
      return right(
        jsonEncode({
          'success': true,
          'message': 'Account verified successfully!',
          'access_token': 'static_v2_access_token_2026',
          'refresh_token': 'static_v2_refresh_token_2026',
        }),
      );
    }

    if (url.contains('/auth/forget-password/')) {
      return right(
        jsonEncode({
          'passResetToken': 'static_pass_reset_token',
          'message': 'Verification code sent to your email',
        }),
      );
    }

    if (url.contains('/auth/forget-password-otp-verify/')) {
      return right(
        jsonEncode({
          'passwordResetVerified': 'static_pass_reset_verified_token',
          'message': 'OTP verified successfully',
        }),
      );
    }

    if (url.contains('/auth/forget-password-set/') ||
        url.contains('/auth/password-update/')) {
      return right(
        jsonEncode({
          'message': 'Password updated successfully!',
        }),
      );
    }

    if (url.contains('/auth/delete-account/')) {
      return right(
        jsonEncode({
          'message': 'Account deleted successfully',
        }),
      );
    }

    // 4. Profile GET / PATCH
    if (url.contains('/auth/profile-update/')) {
      if (method.toUpperCase() == 'PATCH' || method.toUpperCase() == 'POST') {
        final newName = bodyMap['full_name']?.toString().trim();
        if (newName != null && newName.isNotEmpty) {
          await prefs.setString(_nameKey, newName);
        }
      }
      final name = prefs.getString(_nameKey) ?? 'Alex Rivera';
      final email =
          prefs.getString(_emailKey) ?? 'alex.rivera@geographygeyser.com';
      final pic = prefs.getString(_picKey) ?? '';

      return right(
        jsonEncode({
          'message': 'Profile updated successfully!',
          'full_name': name,
          'email': email,
          'profile_pic': pic,
          'data': {
            'full_name': name,
            'email': email,
            'profile_pic': pic,
          },
        }),
      );
    }

    // 5. Student State (Dashboard stats)
    if (url.contains('/student/student-state/')) {
      final totalXp = prefs.getInt(_xpKey) ?? 2450;
      final attempted = prefs.getInt(_attemptedKey) ?? 18;
      final avgScore = prefs.getDouble(_avgScoreKey) ?? 84.5;
      final streak = prefs.getInt(_streakKey) ?? 7;

      return right(
        jsonEncode({
          'average_score': avgScore,
          'total_attempted_quizzes': attempted,
          'total_xp': totalXp,
          'daily_streak': streak,
          'last_activity': DateTime.now().toIso8601String(),
          'strongest_module': 'Tectonics',
        }),
      );
    }

    // 6. User Performance (Profile & Subject mastery)
    if (url.contains('/student/user-performance/')) {
      final name = prefs.getString(_nameKey) ?? 'Alex Rivera';
      final pic = prefs.getString(_picKey);
      final totalXp = prefs.getInt(_xpKey) ?? 2450;
      final attempted = prefs.getInt(_attemptedKey) ?? 18;
      final avgScore = prefs.getDouble(_avgScoreKey) ?? 84.5;

      final progresses = <double>[
        88,
        82,
        76,
        79,
        72,
        85,
        64,
        74,
        68,
        81,
        70,
        75,
      ];
      final subjectsJson = <Map<String, dynamic>>[];
      for (var i = 0; i < StaticCurriculumData.allModules.length; i++) {
        final m = StaticCurriculumData.allModules[i];
        final p = progresses[i % progresses.length];
        subjectsJson.add({
          'id': m.id,
          'module_name': m.name,
          'progress': p,
          'quiz_attempted': (i % 4) + 2,
          'average_score': p,
        });
      }

      return right(
        jsonEncode({
          'full_name': name,
          'profile_pic': pic,
          'total_xp': totalXp,
          'quiz_attempted': attempted,
          'average_score': avgScore,
          'subject_covered': StaticCurriculumData.allModules.length,
          'subjects': subjectsJson,
        }),
      );
    }

    // 7. Module List
    if (url.contains('/student/module-list/')) {
      final results = StaticCurriculumData.allModules
          .map((m) => {'id': m.id, 'module_name': m.name})
          .toList();
      return right(jsonEncode({'results': results}));
    }

    // 8. Time List
    if (url.contains('/student/time-list/')) {
      return right(
        jsonEncode({
          'count': 5,
          'next': null,
          'previous': null,
          'results': [
            {'id': 'time_2', 'duration': 2},
            {'id': 'time_5', 'duration': 5},
            {'id': 'time_10', 'duration': 10},
            {'id': 'time_15', 'duration': 15},
            {'id': 'time_20', 'duration': 20},
          ],
        }),
      );
    }

    // 9. Optional Modules (GET & PATCH)
    if (url.contains('/student/optional-module/')) {
      if (method.toUpperCase() == 'PATCH' && bodyMap['selections'] is List) {
        await prefs.setString(_optionalPairsKey, jsonEncode(bodyMap['selections']));
      }
      final savedSelectionsRaw = prefs.getString(_optionalPairsKey);
      final Map<int, String> selectedByPair = {
        1: 'coasts',
        2: 'regenerating_places',
        3: 'hhri',
      };
      if (savedSelectionsRaw != null) {
        try {
          final list = jsonDecode(savedSelectionsRaw) as List<dynamic>;
          for (final item in list) {
            if (item is Map) {
              final p = (item['pair_number'] as num?)?.toInt();
              final s = item['selected_module']?.toString();
              if (p != null && s != null) selectedByPair[p] = s;
            }
          }
        } catch (_) {}
      }

      return right(
        jsonEncode([
          {
            'pair_number': 1,
            'selected_module': selectedByPair[1],
            'modules': [
              {'id': 'coasts', 'module_name': 'Coasts'},
              {'id': 'glaciers', 'module_name': 'Glaciers'},
            ],
          },
          {
            'pair_number': 2,
            'selected_module': selectedByPair[2],
            'modules': [
              {
                'id': 'regenerating_places',
                'module_name': 'Regenerating Places',
              },
              {'id': 'diverse_places', 'module_name': 'Diverse Places'},
            ],
          },
          {
            'pair_number': 3,
            'selected_module': selectedByPair[3],
            'modules': [
              {'id': 'migration', 'module_name': 'Migration'},
              {
                'id': 'hhri',
                'module_name': 'Human Rights & Intervention (HHRI)',
              },
            ],
          },
        ]),
      );
    }

    // 10. Quiz Start & Synoptic Quiz Start
    if (url.contains('/student/quiz-start/') ||
        url.contains('/student/synoptic-quiz-start/')) {
      final isSynoptic = url.contains('synoptic') ||
          bodyMap['module_id']?.toString().toLowerCase() == 'synoptic';
      final requestedId =
          bodyMap['module_id']?.toString() ?? (isSynoptic ? 'synoptic' : 'tectonics');

      // Check if invalid quiz ID was explicitly passed for deep-link error testing
      if (requestedId.toLowerCase() == 'invalid' ||
          requestedId.toLowerCase() == 'not_found') {
        return left('Quiz "$requestedId" is unavailable or could not be found.');
      }

      // 1) Try YouTube Quiz match
      final ytQuiz = StaticYouTubeData.findByQuizId(requestedId);
      if (ytQuiz != null) {
        return right(
          jsonEncode({
            'quiz_id': ytQuiz.quizId,
            'is_synoptic': false,
            'questions': ytQuiz.questions
                .map(
                  (q) => {
                    'id': q.id,
                    'question_text': q.questionText,
                    'options': {
                      'option1': q.options.option1,
                      'option2': q.options.option2,
                      'option3': q.options.option3,
                      'option4': q.options.option4,
                    },
                    'correct_answer': q.correctAnswer,
                  },
                )
                .toList(),
          }),
        );
      }

      // 2) Try Specification Sub-Quiz match
      final subQuiz = StaticCurriculumData.findSubQuizById(requestedId);
      if (subQuiz != null) {
        return right(
          jsonEncode({
            'quiz_id': subQuiz.id,
            'is_synoptic': false,
            'questions': subQuiz.questions
                .map(
                  (q) => {
                    'id': q.id,
                    'question_text': q.questionText,
                    'options': {
                      'option1': q.options.option1,
                      'option2': q.options.option2,
                      'option3': q.options.option3,
                      'option4': q.options.option4,
                    },
                    'correct_answer': q.correctAnswer,
                  },
                )
                .toList(),
          }),
        );
      }

      // 3) Fallback to Module or Synoptic questions
      final questions = StaticQuestionsBank.getQuestionsForTopic(requestedId);
      return right(
        jsonEncode({
          'quiz_id': requestedId,
          'is_synoptic': isSynoptic,
          'questions': questions
              .map(
                (q) => {
                  'id': q.id,
                  'question_text': q.questionText,
                  'options': {
                    'option1': q.options.option1,
                    'option2': q.options.option2,
                    'option3': q.options.option3,
                    'option4': q.options.option4,
                  },
                  'correct_answer': q.correctAnswer,
                },
              )
              .toList(),
        }),
      );
    }

    // 11. Quiz Finish
    if (url.contains('/student/quiz-finish/')) {
      final quizId = bodyMap['quiz_id']?.toString() ?? 'tectonics';
      final correct = (bodyMap['correct'] as num?)?.toInt() ?? 0;
      final attempted = (bodyMap['attempted'] as num?)?.toInt() ?? 5;
      final safeTotal = attempted > 0 ? attempted : 5;
      final scorePercent = ((correct / safeTotal) * 100).round().clamp(0, 100);
      final xpGained = (correct * 25) + 30;
      final grade = _calculateGrade(scorePercent);

      final prevXp = prefs.getInt(_xpKey) ?? 2450;
      final prevAttempted = prefs.getInt(_attemptedKey) ?? 18;
      final prevAvg = prefs.getDouble(_avgScoreKey) ?? 84.5;

      final newAttempted = prevAttempted + 1;
      final newAvg =
          ((prevAvg * prevAttempted) + scorePercent) / newAttempted;

      await prefs.setInt(_xpKey, prevXp + xpGained);
      await prefs.setInt(_attemptedKey, newAttempted);
      await prefs.setDouble(
        _avgScoreKey,
        double.parse(newAvg.toStringAsFixed(1)),
      );

      return right(
        jsonEncode({
          'id': 'res_${DateTime.now().millisecondsSinceEpoch}',
          'total_questions': safeTotal,
          'correct_answers': correct,
          'xp_gained': xpGained,
          'score': scorePercent,
          'grade': grade,
          'created_at': DateTime.now().toIso8601String(),
          'student': prefs.getString(_nameKey) ?? 'Alex Rivera',
          'module': quizId,
          'attend_another_quiz': [
            {'id': 'carbon', 'module_name': 'Carbon'},
            {'id': 'coasts', 'module_name': 'Coasts'},
            {'id': 'superpowers', 'module_name': 'Superpowers'},
          ],
        }),
      );
    }

    // 12. Delete XP (Quiz Quit penalty)
    if (url.contains('/student/delete-xp/')) {
      final prevXp = prefs.getInt(_xpKey) ?? 2450;
      final updatedXp = (prevXp - 200).clamp(0, 999999);
      await prefs.setInt(_xpKey, updatedXp);

      return right(
        jsonEncode({
          'message': '200 XP deducted for cancelling quiz',
          'xp_deducted': 200,
          'remaining_xp': updatedXp,
        }),
      );
    }

    return right(jsonEncode({'status': 'ok', 'message': 'Success'}));
  }

  static Map<String, dynamic> _normalizeBody(
    dynamic body,
    Map<String, String>? fields,
  ) {
    final map = <String, dynamic>{};
    if (fields != null) {
      map.addAll(fields);
    }
    if (body is Map) {
      body.forEach((k, v) => map[k.toString()] = v);
    } else if (body is String && body.isNotEmpty) {
      try {
        final decoded = jsonDecode(body);
        if (decoded is Map) {
          decoded.forEach((k, v) => map[k.toString()] = v);
        }
      } catch (_) {}
    }
    return map;
  }

  static String _calculateGrade(int scorePercent) {
    if (scorePercent >= 90) return 'A*';
    if (scorePercent >= 80) return 'A';
    if (scorePercent >= 70) return 'B';
    if (scorePercent >= 60) return 'C';
    if (scorePercent >= 50) return 'D';
    if (scorePercent >= 40) return 'E';
    return 'U';
  }

  static String _capitalizeName(String raw) {
    final parts = raw.replaceAll('.', ' ').replaceAll('_', ' ').split(' ');
    return parts
        .where((p) => p.isNotEmpty)
        .map((p) => p[0].toUpperCase() + p.substring(1))
        .join(' ');
  }
}
