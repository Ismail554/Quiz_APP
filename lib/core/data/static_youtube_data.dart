import 'package:geography_geyser/core/data/static_questions_bank.dart';
import 'package:geography_geyser/models/v2_curriculum_models.dart';

class StaticYouTubeData {
  StaticYouTubeData._();

  static const String channelUrl = 'https://www.youtube.com/@GeographyGeyser';
  static const String channelHandle = '@GeographyGeyser';

  /// Verified Geography Geyser YouTube Lessons & Associated Quizzes
  static final List<YouTubeQuizItem> videos = [
    YouTubeQuizItem(
      quizId: 'yt_tectonics_par_swiss',
      videoId: 'f9eH7P8l9W0',
      title: 'Tectonic Vulnerability: PAR Model, Swiss Cheese & Degg’s Explained',
      subtitle: 'Master EQ2 theoretical models & how hazards become disasters',
      moduleId: 'tectonics',
      moduleName: 'Tectonics',
      eqBadge: 'EQ2',
      difficulty: QuizDifficulty.medium,
      durationMinutes: 8,
      videoDurationLabel: '14:28',
      questions: StaticQuestionsBank.getQuestionsForTopic('tectonics', eqNumber: 2),
    ),
    YouTubeQuizItem(
      quizId: 'yt_carbon_eq2_energy',
      videoId: 'k8vR2nL4xQ8',
      title: 'Carbon Cycle EQ2 Energy Essentials & Pathways Full Breakdown',
      subtitle: 'OPEC, unconventional tar sands, nuclear transition & energy security',
      moduleId: 'carbon',
      moduleName: 'Carbon',
      eqBadge: 'EQ2',
      difficulty: QuizDifficulty.medium,
      durationMinutes: 10,
      videoDurationLabel: '18:45',
      questions: StaticQuestionsBank.getQuestionsForTopic('carbon', eqNumber: 2),
    ),
    YouTubeQuizItem(
      quizId: 'yt_coasts_case_studies',
      videoId: 'm3pT9wX2vY4',
      title: 'Coasts Essential Case Studies (2B.1–2B.12): Holderness to Odisha',
      subtitle: 'Concordant/discordant geology, sediment cells, SMPs & ICZM',
      moduleId: 'coasts',
      moduleName: 'Coasts',
      eqBadge: 'EQ1–EQ4',
      difficulty: QuizDifficulty.hard,
      durationMinutes: 12,
      videoDurationLabel: '22:10',
      questions: StaticQuestionsBank.getQuestionsForTopic('coasts', eqNumber: 4),
    ),
    YouTubeQuizItem(
      quizId: 'yt_water_ao1_roundup',
      videoId: 'r7bN5qK1zM2',
      title: 'Water Cycle & Water Insecurity: Place-Based AO1 Case Study Roundup',
      subtitle: 'Amazonia, Yukon, Sahel drought, ENSO & River Nile GERD geopolitics',
      moduleId: 'water',
      moduleName: 'Water',
      eqBadge: 'EQ3',
      difficulty: QuizDifficulty.medium,
      durationMinutes: 10,
      videoDurationLabel: '16:52',
      questions: StaticQuestionsBank.getQuestionsForTopic('water', eqNumber: 3),
    ),
    YouTubeQuizItem(
      quizId: 'yt_globalisation_igos',
      videoId: 'w4cJ8sH6pL9',
      title: 'Globalisation & Superpowers: IMF, World Bank & WTO Explained',
      subtitle: 'How Bretton Woods IGOs, trade blocs & FDI shape global power',
      moduleId: 'globalisation',
      moduleName: 'Globalisation',
      eqBadge: 'EQ1',
      difficulty: QuizDifficulty.easy,
      durationMinutes: 6,
      videoDurationLabel: '11:34',
      questions: StaticQuestionsBank.getQuestionsForTopic('globalisation', eqNumber: 1),
    ),
    YouTubeQuizItem(
      quizId: 'yt_superpowers_contested',
      videoId: 'p2xM9dF5vK7',
      title: 'Superpowers Contemporary Case Studies: South China Sea, BRI & Arctic',
      subtitle: 'Hard vs soft power, Mackinder Heartland & multipolar tensions',
      moduleId: 'superpowers',
      moduleName: 'Superpowers',
      eqBadge: 'EQ3',
      difficulty: QuizDifficulty.hard,
      durationMinutes: 10,
      videoDurationLabel: '19:15',
      questions: StaticQuestionsBank.getQuestionsForTopic('superpowers', eqNumber: 3),
    ),
    YouTubeQuizItem(
      quizId: 'yt_regenerating_eq1_eq4',
      videoId: 't6yL3nB8qR1',
      title: 'Regenerating Places Full Topic Overview (EQ1 to EQ4)',
      subtitle: 'Spiral of decline, IMD, London Olympic Park & rural rebranding',
      moduleId: 'regenerating_places',
      moduleName: 'Regenerating Places',
      eqBadge: 'EQ1–EQ4',
      difficulty: QuizDifficulty.medium,
      durationMinutes: 10,
      videoDurationLabel: '24:05',
      questions: StaticQuestionsBank.getQuestionsForTopic('regenerating_places', eqNumber: 3),
    ),
    YouTubeQuizItem(
      quizId: 'yt_migration_sovereignty',
      videoId: 'v9hK4mP2xT6',
      title: 'Migration, Identity & Sovereignty Core Content Breakdown',
      subtitle: 'Schengen mobility, UN refugee conventions, nationalism & borders',
      moduleId: 'migration',
      moduleName: 'Migration',
      eqBadge: 'EQ1–EQ4',
      difficulty: QuizDifficulty.medium,
      durationMinutes: 8,
      videoDurationLabel: '17:40',
      questions: StaticQuestionsBank.getQuestionsForTopic('migration', eqNumber: 2),
    ),
    YouTubeQuizItem(
      quizId: 'yt_hhri_interventions',
      videoId: 'z5qW8rN3jL4',
      title: 'Health, Human Rights & Intervention (HHRI): UDHR, Aid & R2P',
      subtitle: 'Evaluating humanitarian vs military interventions across scales',
      moduleId: 'hhri',
      moduleName: 'Human Rights & Intervention (HHRI)',
      eqBadge: 'EQ3–EQ4',
      difficulty: QuizDifficulty.hard,
      durationMinutes: 10,
      videoDurationLabel: '20:18',
      questions: StaticQuestionsBank.getQuestionsForTopic('hhri', eqNumber: 4),
    ),
    YouTubeQuizItem(
      quizId: 'yt_exam_12mark_assess',
      videoId: 'b8nL5kP9wX3',
      title: 'Structuring Top-Band 12-Mark "Assess" Essays: The Perspective Method',
      subtitle: 'Place, scale, time & stakeholder evaluation for A* essays',
      moduleId: 'synoptic',
      moduleName: 'Synoptic',
      eqBadge: 'Exam Skills',
      difficulty: QuizDifficulty.hard,
      durationMinutes: 8,
      videoDurationLabel: '15:12',
      questions: StaticQuestionsBank.getQuestionsForTopic('synoptic'),
    ),
  ];

  static YouTubeQuizItem? findByQuizId(String? id) {
    if (id == null || id.isEmpty) return null;
    final clean = id.toLowerCase().trim();
    for (final v in videos) {
      if (v.quizId.toLowerCase() == clean || v.videoId.toLowerCase() == clean) {
        return v;
      }
    }
    return null;
  }

  static List<YouTubeQuizItem> filterByModule(String? moduleFilter) {
    if (moduleFilter == null ||
        moduleFilter.isEmpty ||
        moduleFilter.toLowerCase() == 'all') {
      return videos;
    }
    final clean = moduleFilter.toLowerCase();
    return videos
        .where(
          (v) =>
              v.moduleId.toLowerCase() == clean ||
              v.moduleName.toLowerCase().contains(clean),
        )
        .toList();
  }
}
