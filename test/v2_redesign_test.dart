import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geography_geyser/core/data/static_backend_responder.dart';
import 'package:geography_geyser/core/data/static_curriculum_data.dart';
import 'package:geography_geyser/core/data/static_youtube_data.dart';
import 'package:geography_geyser/models/v2_curriculum_models.dart';
import 'package:geography_geyser/routes/app_routes.dart';
import 'package:geography_geyser/services/pending_deep_link_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Specification Quiz Hierarchy (Option A)', () {
    test('Group A modules contain 5 topics each with 3 Enquiry Questions', () {
      final groupA = StaticCurriculumData.groupAModules;
      expect(groupA.length, 5);
      expect(
        groupA.map((m) => m.title).toList(),
        containsAll([
          'Tectonics',
          'Carbon',
          'Water',
          'Globalisation',
          'Superpowers',
        ]),
      );

      for (final module in groupA) {
        expect(module.group, ModuleGroup.groupA);
        expect(module.eqCount, 3);
        expect(module.enquiryQuestions.length, 3);
        for (final eq in module.enquiryQuestions) {
          expect(eq.subQuizzes.isNotEmpty, true);
        }
      }
    });

    test('Group B modules contain 7 topics each with 4 Enquiry Questions', () {
      final groupB = StaticCurriculumData.groupBModules;
      expect(groupB.length, 7);
      expect(
        groupB.map((m) => m.title).toList(),
        containsAll([
          'Coasts',
          'Glaciers',
          'Regenerating Places',
          'Diverse Places',
          'Migration',
          'Health',
          'Human Rights & Intervention (HHRI)',
        ]),
      );

      for (final module in groupB) {
        expect(module.group, ModuleGroup.groupB);
        expect(module.eqCount, 4);
        expect(module.enquiryQuestions.length, 4);
        for (final eq in module.enquiryQuestions) {
          expect(eq.subQuizzes.isNotEmpty, true);
        }
      }
    });

    test('findSubQuizById resolves nested EQ sub-quizzes accurately', () {
      final subQuiz = StaticCurriculumData.findSubQuizById('tectonics-eq1-q1');
      expect(subQuiz, isNotNull);
      expect(subQuiz!.moduleId, 'tectonics');
      expect(subQuiz.eqNumber, 1);
    });
  });

  group('YouTube Quiz Discovery & Deep Linking (Option B)', () {
    test('Curated @GeographyGeyser YouTube quizzes map to valid quiz IDs', () {
      final videos = StaticYouTubeData.videos;
      expect(videos.isNotEmpty, true);

      final tectonicsVideo = StaticYouTubeData.findByQuizId(
        'yt-tectonics-plates',
      );
      expect(tectonicsVideo, isNotNull);
      expect(tectonicsVideo!.moduleId, 'tectonics');
      expect(tectonicsVideo.deepLinkUrl, contains('/quiz/yt-tectonics-plates'));
    });

    test('PendingDeepLinkService preserves and consumes deep links across auth', () async {
      expect(await PendingDeepLinkService.peekPendingRoute(), isNull);

      await PendingDeepLinkService.setPendingRoute('/quiz/yt-tectonics-plates');
      expect(
        await PendingDeepLinkService.peekPendingRoute(),
        '/quiz/yt-tectonics-plates',
      );

      final consumed = await PendingDeepLinkService.consumePendingRoute();
      expect(consumed, '/quiz/yt-tectonics-plates');
      expect(await PendingDeepLinkService.peekPendingRoute(), isNull);
    });

    test('AppRoutes.quizByIdPath builds canonical /quiz/{quizId} paths', () {
      final path = AppRoutes.quizByIdPath('yt-carbon-cycle');
      expect(path, '/quiz/yt-carbon-cycle');
    });
  });

  group('StaticBackendResponder Production Safety', () {
    test('Resolves quiz questions and finish payload locally without network', () async {
      final quizResp = await StaticBackendResponder.handleRequest(
        url: 'https://api.geographygeyser.com/quiz/all-questions/yt-tectonics-plates/',
        method: 'GET',
      );
      final decodedQuiz = jsonDecode(quizResp.body) as Map<String, dynamic>;
      expect(decodedQuiz['questions'], isA<List>());
      expect((decodedQuiz['questions'] as List).isNotEmpty, true);

      final finishResp = await StaticBackendResponder.handleRequest(
        url: 'https://api.geographygeyser.com/quiz/finish/yt-tectonics-plates/',
        method: 'POST',
        body: {'correct_answers': 8, 'total_questions': 10},
      );
      final decodedFinish = jsonDecode(finishResp.body) as Map<String, dynamic>;
      expect(decodedFinish['score'], 80);
      expect(decodedFinish['grade'], 'A');
      expect(decodedFinish['xp_gained'], greaterThan(0));
    });
  });
}
