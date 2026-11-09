import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_logger.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/core/app_strings.dart';
import 'package:geography_geyser/core/font_manager.dart';
import 'package:geography_geyser/core/sound_helper.dart';
import 'package:geography_geyser/models/quiz_model.dart';
import 'package:geography_geyser/models/v2_curriculum_models.dart';
import 'package:geography_geyser/provider/local_progress_provider.dart';
import 'package:geography_geyser/provider/module_provider/quiz_provider.dart';
import 'package:geography_geyser/provider/module_provider/quiz_finish_provider.dart';
import 'package:geography_geyser/provider/module_provider/delete_xp_provider.dart';
import 'package:geography_geyser/provider/userstats_provider.dart';
import 'package:geography_geyser/provider/user_performance_provider.dart';
import 'package:geography_geyser/routes/app_routes.dart';
import 'package:geography_geyser/views/custom_widgets/stitch_design_widgets.dart';
import 'package:geography_geyser/views/modules/time_out_dialog.dart';
import 'package:provider/provider.dart';

class QuizScreen extends StatefulWidget {
  final int? totalQuestions;
  final int? timeInMinutes;
  final String? moduleId;
  final String? moduleName;
  final int? initialQuestionIndex;
  final int? initialCorrectCount;
  final int? initialTimeRemainingSeconds;
  final bool isInvalidQuizId;

  const QuizScreen({
    super.key,
    this.totalQuestions,
    this.timeInMinutes,
    this.moduleId,
    this.moduleName,
    this.initialQuestionIndex,
    this.initialCorrectCount,
    this.initialTimeRemainingSeconds,
    this.isInvalidQuizId = false,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  int currentQuestionIndex = 0;
  late int totalQuestions;
  late int timeRemaining;
  int? selectedAnswerIndex;
  Timer? _timer;
  bool showAnswerFeedback = false;
  bool isCorrectAnswer = false;
  int correctAnswersCount = 0;
  bool _isSoundEnabled = true;

  late AnimationController _questionAnimController;
  late Animation<double> _questionFadeAnim;
  late Animation<Offset> _questionSlideAnim;

  late AnimationController _timerPulseController;
  late Animation<double> _timerPulseAnim;

  late AnimationController _optionsStaggerController;

  @override
  void initState() {
    super.initState();
    _isSoundEnabled = SoundHelper.isSoundEnabled;
    _initializeQuizSettings();
    _initAnimations();

    if (widget.isInvalidQuizId) {
      return;
    }

    if (widget.moduleId != null && widget.moduleId!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final quizProvider = Provider.of<QuizProvider>(context, listen: false);
        final future = widget.moduleId!.toLowerCase() == 'synoptic'
            ? quizProvider.fetchSynopticQuiz()
            : quizProvider.fetchQuiz(widget.moduleId!);
        future.then((_) {
          if (mounted) {
            startTimer();
            _questionAnimController.forward();
            _optionsStaggerController.forward();
            _saveInProgressSession();
          }
        });
      });
    } else {
      startTimer();
    }
  }

  void _initAnimations() {
    _questionAnimController = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );
    _questionFadeAnim = CurvedAnimation(
      parent: _questionAnimController,
      curve: Curves.easeOut,
    );
    _questionSlideAnim =
        Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _questionAnimController,
            curve: Curves.easeOutCubic,
          ),
        );

    _timerPulseController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _timerPulseAnim = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _timerPulseController, curve: Curves.easeInOut),
    );

    _optionsStaggerController = AnimationController(
      duration: const Duration(milliseconds: 520),
      vsync: this,
    );
  }

  void _initializeQuizSettings() {
    currentQuestionIndex = widget.initialQuestionIndex ?? 0;
    correctAnswersCount = widget.initialCorrectCount ?? 0;
    totalQuestions = widget.totalQuestions ?? 10;
    final minutes = widget.timeInMinutes ?? 8;
    timeRemaining = widget.initialTimeRemainingSeconds ?? (minutes * 60);
  }

  Future<void> _saveInProgressSession() async {
    if (!mounted || widget.isInvalidQuizId) return;
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    final questions = quizProvider.quizData?.questions ?? [];
    if (questions.isEmpty) return;

    final effectiveTotal = questions.length > totalQuestions
        ? totalQuestions
        : questions.length;
    final progressProvider = Provider.of<LocalProgressProvider>(
      context,
      listen: false,
    );

    await progressProvider.saveUnfinishedSession(
      UnfinishedQuizSession(
        quizId: widget.moduleId ?? quizProvider.quizData?.quizId ?? 'tectonics',
        quizTitle:
            widget.moduleName ??
            quizProvider.quizData?.subjectName ??
            'Geography Quiz',
        moduleName: quizProvider.quizData?.subjectName ?? 'Geography',
        currentQuestionIndex: currentQuestionIndex,
        totalQuestions: effectiveTotal,
        correctAnswersSoFar: correctAnswersCount,
        timeRemainingSeconds: timeRemaining,
        updatedAt: DateTime.now(),
        isYouTubeQuiz: (widget.moduleId ?? '').toLowerCase().startsWith('yt-'),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _questionAnimController.dispose();
    _timerPulseController.dispose();
    _optionsStaggerController.dispose();
    super.dispose();
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeRemaining > 0) {
        setState(() {
          timeRemaining--;
        });
        if (timeRemaining <= 30 && !_timerPulseController.isAnimating) {
          _timerPulseController.repeat(reverse: true);
        }
      } else {
        timer.cancel();
        _timerPulseController.stop();
        if (mounted) {
          TimeoutDialog.show(
            context,
            onOkPressed: () {
              Navigator.of(context).pop();
              _finishQuizAndNavigate();
            },
          );
        }
      }
    });
  }

  void _animateToNextQuestion() {
    _questionAnimController.reset();
    _optionsStaggerController.reset();
    _questionAnimController.forward();
    _optionsStaggerController.forward();
  }

  String get formattedTime {
    final minutes = timeRemaining ~/ 60;
    final seconds = timeRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  bool get _isTimerUrgent => timeRemaining <= 30;

  Future<void> _finishQuizAndNavigate() async {
    _timer?.cancel();
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    final quizFinishProvider = Provider.of<QuizFinishProvider>(
      context,
      listen: false,
    );
    final statsProvider = Provider.of<UserStatsProvider>(
      context,
      listen: false,
    );
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );
    final progressProvider = Provider.of<LocalProgressProvider>(
      context,
      listen: false,
    );

    final quizId = widget.moduleId ?? quizProvider.quizData?.quizId;
    final questions = quizProvider.quizData?.questions ?? [];
    final effectiveTotal = questions.isEmpty
        ? totalQuestions
        : (questions.length > totalQuestions
              ? totalQuestions
              : questions.length);
    final attemptedQuestions = (currentQuestionIndex + 1).clamp(
      1,
      effectiveTotal,
    );

    await progressProvider.recordCompletedAttempt(
      quizId: quizId ?? 'tectonics',
      quizTitle:
          widget.moduleName ??
          quizProvider.quizData?.subjectName ??
          'Geography Quiz',
      moduleName: quizProvider.quizData?.subjectName ?? 'Geography',
      correctAnswers: correctAnswersCount,
      totalQuestions: attemptedQuestions,
      isYouTubeQuiz: (quizId ?? '').toLowerCase().startsWith('yt-'),
    );

    if (quizId != null && quizId.isNotEmpty) {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryAzure),
          ),
        );
      }

      await quizFinishProvider.finishQuiz(
        quizId,
        correctAnswersCount,
        attemptedQuestions,
      );

      statsProvider.fetchUserStats();
      profileProvider.fetchProfile();

      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        context.go(AppRoutes.quizResult);
      }
    } else {
      if (mounted) {
        context.go(AppRoutes.quizResult);
      }
    }
  }

  Future<void> _deleteXpAndNavigate() async {
    _timer?.cancel();
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    final deleteXpProvider = Provider.of<DeleteXpProvider>(
      context,
      listen: false,
    );
    final quizFinishProvider = Provider.of<QuizFinishProvider>(
      context,
      listen: false,
    );
    final statsProvider = Provider.of<UserStatsProvider>(
      context,
      listen: false,
    );
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );
    final progressProvider = Provider.of<LocalProgressProvider>(
      context,
      listen: false,
    );

    await progressProvider.clearUnfinishedSession();

    final quizId = widget.moduleId ?? quizProvider.quizData?.quizId;

    if (quizId != null && quizId.isNotEmpty) {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryAzure),
          ),
        );
      }

      await deleteXpProvider.deleteXp(quizId);

      final attemptedQuestions = currentQuestionIndex + 1;
      await quizFinishProvider.finishQuiz(
        quizId,
        correctAnswersCount,
        attemptedQuestions,
      );

      statsProvider.fetchUserStats();
      profileProvider.fetchProfile();

      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        context.go(AppRoutes.quizResult);
      }
    } else {
      if (mounted) {
        context.go(AppRoutes.quizResult);
      }
    }
  }

  void handleAnswerSelection(int selectedIndex, QuestionModel question) {
    if (showAnswerFeedback) return;

    final isCorrect = selectedIndex == question.correctAnswerIndex;
    if (isCorrect) {
      SoundHelper.playCorrect();
    } else {
      SoundHelper.playWrong();
    }

    setState(() {
      selectedAnswerIndex = selectedIndex;
      showAnswerFeedback = true;
      isCorrectAnswer = isCorrect;
      if (isCorrect) correctAnswersCount++;
    });

    Timer(const Duration(milliseconds: 1400), () {
      if (mounted) {
        final provider = Provider.of<QuizProvider>(context, listen: false);
        final questions = provider.quizData?.questions ?? [];
        final actualTotalQuestions = questions.length > totalQuestions
            ? totalQuestions
            : questions.length;

        if (currentQuestionIndex < actualTotalQuestions - 1) {
          setState(() {
            currentQuestionIndex++;
            selectedAnswerIndex = null;
            showAnswerFeedback = false;
            isCorrectAnswer = false;
          });
          _saveInProgressSession();
          _animateToNextQuestion();
        } else {
          _finishQuizAndNavigate();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isInvalidQuizId) {
      return StitchAmbientScaffold(body: SafeArea(child: _buildInvalidQuizUI()));
    }

    return Consumer<QuizProvider>(
      builder: (context, provider, child) {
        final bool canPopAutomatically =
            !provider.isLoading &&
            provider.errorMessage == null &&
            (provider.quizData == null || provider.quizData!.questions.isEmpty);

        return PopScope(
          canPop: canPopAutomatically,
          onPopInvokedWithResult: (bool didPop, dynamic result) async {
            if (didPop) return;
            showCancelQuizDialog(context);
          },
          child: StitchAmbientScaffold(
            body: SafeArea(child: _buildBody(context, provider)),
          ),
        );
      },
    );
  }

  Widget _buildInvalidQuizUI() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: StitchCard(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.link_off_rounded,
                  size: 40.sp,
                  color: const Color(0xFFD97706),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Quiz Not Available',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.neutralDark,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'The quiz ID "${widget.moduleId ?? 'unknown'}" could not be found or has been updated. Explore our Edexcel Specification or YouTube lessons below!',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.neutralSlate,
                  height: 1.45,
                ),
              ),
              SizedBox(height: 22.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.go(AppRoutes.youtubeQuizzes),
                  icon: const Icon(Icons.ondemand_video_rounded),
                  label: const Text('Browse YouTube Quizzes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 13.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.go(AppRoutes.home),
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('Back to Home Dashboard'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryAzure,
                    side: const BorderSide(color: AppColors.primaryAzure),
                    padding: EdgeInsets.symmetric(vertical: 13.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, QuizProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryAzure),
      );
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64.sp, color: AppColors.red),
              AppSpacing.h16,
              Text(
                AppLogger.getSafeErrorMessage(provider.errorMessage!),
                style: FontManager.bodyText(),
                textAlign: TextAlign.center,
              ),
              AppSpacing.h24,
              _GlassButton(
                label: 'Retry',
                onTap: () {
                  if (widget.moduleId != null) {
                    if (widget.moduleId == 'synoptic') {
                      provider.fetchSynopticQuiz();
                    } else {
                      provider.fetchQuiz(widget.moduleId!);
                    }
                  }
                },
              ),
            ],
          ),
        ),
      );
    }

    if (provider.quizData == null || provider.quizData!.questions.isEmpty) {
      return _buildInvalidQuizUI();
    }

    final questions = provider.quizData!.questions;
    final actualTotalQuestions = questions.length > totalQuestions
        ? totalQuestions
        : questions.length;

    if (currentQuestionIndex >= actualTotalQuestions) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _finishQuizAndNavigate();
      });
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryAzure),
      );
    }

    final currentQuestion = questions[currentQuestionIndex];

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(),
                SizedBox(height: 16.h),
                _buildProgressBar(actualTotalQuestions),
                SizedBox(height: 14.h),
                _buildTimerPill(),
                SizedBox(height: 16.h),
                _buildQuestionCard(currentQuestion),
                SizedBox(height: 16.h),
                ...List.generate(
                  currentQuestion.optionsList.length,
                  (index) => _buildOptionTile(
                    index,
                    currentQuestion.optionsList[index],
                    currentQuestion,
                    currentQuestion.optionsList.length,
                  ),
                ),
                SizedBox(height: 18.h),
                _buildStatsRow(),
                SizedBox(height: 12.h),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        _CircleIconButton(
          icon: Icons.close_rounded,
          onTap: () => showCancelQuizDialog(context),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
              gradient: AppColors.primaryButtonGradient,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryAzure.withValues(alpha: 0.28),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.public_rounded, color: Colors.white, size: 15.sp),
                SizedBox(width: 6.w),
                Flexible(
                  child: Text(
                    widget.moduleName ?? AppStrings.quizTitleMigrations,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 10.w),
        _CircleIconButton(
          icon: _isSoundEnabled
              ? Icons.volume_up_rounded
              : Icons.volume_off_rounded,
          iconColor: _isSoundEnabled
              ? AppColors.primaryAzure
              : AppColors.neutralMuted,
          onTap: () {
            setState(() {
              _isSoundEnabled = !_isSoundEnabled;
              SoundHelper.setSoundEnabled(_isSoundEnabled);
            });
          },
        ),
      ],
    );
  }

  Widget _buildProgressBar(int total) {
    final progress = (currentQuestionIndex + 1) / total;
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999.r),
            child: Container(
              height: 8.h,
              color: Colors.white,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress.clamp(0.0, 1.0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryButtonGradient,
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999.r),
            border: Border.all(color: AppColors.azureBorder),
          ),
          child: Text(
            '${currentQuestionIndex + 1} / $total',
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.neutralDark,
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimerPill() {
    final urgent = _isTimerUrgent;
    final pillColor = urgent ? AppColors.errorCoral : AppColors.primaryAzure;

    return AnimatedBuilder(
      animation: _timerPulseAnim,
      builder: (context, child) {
        return Transform.scale(
          scale: urgent ? _timerPulseAnim.value : 1.0,
          child: child,
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 11.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: pillColor.withValues(alpha: 0.35),
            width: 1.3,
          ),
          boxShadow: [
            BoxShadow(
              color: pillColor.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.timer_rounded, color: pillColor, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              formattedTime,
              style: GoogleFonts.plusJakartaSans(
                color: pillColor,
                fontSize: 24.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.5,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(QuestionModel question) {
    return FadeTransition(
      opacity: _questionFadeAnim,
      child: SlideTransition(
        position: _questionSlideAnim,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: AppColors.azureBorder, width: 1.3),
            boxShadow: [
              BoxShadow(
                color: AppColors.neutralDark.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4.w,
                    height: 16.h,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryButtonGradient,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'ENQUIRY QUESTION ${currentQuestionIndex + 1}',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.primaryAzure,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                question.questionText,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16.5.sp,
                  fontWeight: FontWeight.w700,
                  height: 1.45,
                  color: AppColors.neutralDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    int index,
    String text,
    QuestionModel question,
    int total,
  ) {
    final isSelected = selectedAnswerIndex == index;
    final isCorrect = index == question.correctAnswerIndex;

    Color bgColor;
    Color borderColor;
    Color letterBg;
    Color letterColor;
    Widget? trailingIcon;

    if (!showAnswerFeedback) {
      bgColor = isSelected ? const Color(0xFFE0F2FE) : Colors.white;
      borderColor = isSelected
          ? AppColors.primaryAzure
          : AppColors.slateBorder.withValues(alpha: 0.9);
      letterBg = isSelected ? AppColors.primaryAzure : AppColors.softSky;
      letterColor = isSelected ? Colors.white : AppColors.primaryAzure;
      trailingIcon = null;
    } else if (isCorrect) {
      bgColor = const Color(0xFFDCFCE7);
      borderColor = AppColors.emeraldSuccess;
      letterBg = AppColors.emeraldSuccess;
      letterColor = Colors.white;
      trailingIcon = Icon(
        Icons.check_circle_rounded,
        color: AppColors.emeraldSuccess,
        size: 22.sp,
      );
    } else if (isSelected) {
      bgColor = const Color(0xFFFEE2E2);
      borderColor = AppColors.errorCoral;
      letterBg = AppColors.errorCoral;
      letterColor = Colors.white;
      trailingIcon = Icon(
        Icons.cancel_rounded,
        color: AppColors.errorCoral,
        size: 22.sp,
      );
    } else {
      bgColor = Colors.white;
      borderColor = AppColors.slateBorder;
      letterBg = const Color(0xFFF1F5F9);
      letterColor = AppColors.neutralMuted;
      trailingIcon = null;
    }

    final letters = ['A', 'B', 'C', 'D'];
    final staggerDelay = index / total;
    final staggerAnim = CurvedAnimation(
      parent: _optionsStaggerController,
      curve: Interval(
        staggerDelay * 0.5,
        staggerDelay * 0.5 + 0.6,
        curve: Curves.easeOutCubic,
      ),
    );

    return AnimatedBuilder(
      animation: staggerAnim,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - staggerAnim.value) * 18),
          child: Opacity(
            opacity: staggerAnim.value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: 10.h),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: borderColor,
              width: showAnswerFeedback ? 1.6 : 1.2,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(18.r),
            child: InkWell(
              borderRadius: BorderRadius.circular(18.r),
              onTap: showAnswerFeedback
                  ? null
                  : () => handleAnswerSelection(index, question),
              child: Padding(
                padding: EdgeInsets.all(14.w),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 240),
                      width: 34.r,
                      height: 34.r,
                      decoration: BoxDecoration(
                        color: letterBg,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Center(
                        child: Text(
                          letters[index % letters.length],
                          style: GoogleFonts.plusJakartaSans(
                            color: letterColor,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Text(
                        text,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600,
                          color: AppColors.neutralDark,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                    if (trailingIcon != null) ...[
                      SizedBox(width: 8.w),
                      trailingIcon,
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    final total =
        correctAnswersCount +
        (currentQuestionIndex == 0 && !showAnswerFeedback
            ? 0
            : currentQuestionIndex);
    final wrongCount = (total - correctAnswersCount).clamp(0, 999);

    return Row(
      children: [
        _StatPill(
          label: 'Correct',
          value: '$correctAnswersCount',
          gradient: const [Color(0xFF10B981), Color(0xFF059669)],
        ),
        SizedBox(width: 10.w),
        _StatPill(
          label: 'Incorrect',
          value: '$wrongCount',
          gradient: const [Color(0xFFEF4444), Color(0xFFDC2626)],
        ),
      ],
    );
  }

  void showCancelQuizDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: AppColors.azureBorder),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neutralDark.withValues(alpha: 0.15),
                  blurRadius: 32,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(14.r),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEF3C7),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.pause_circle_filled_rounded,
                    color: AppColors.accentGoldDark,
                    size: 32.sp,
                  ),
                ),
                SizedBox(height: 14.h),
                Text(
                  'Pause or Exit Quiz?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.neutralDark,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'You can pause and save your progress to resume from the Home Dashboard, or quit now (-5 XP).',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.neutralSlate,
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.45,
                  ),
                ),
                SizedBox(height: 20.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await _saveInProgressSession();
                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop();
                      }
                      if (context.mounted) {
                        context.go(AppRoutes.home);
                      }
                    },
                    icon: const Icon(Icons.bookmark_added_rounded),
                    label: const Text('Save & Resume Later'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryAzure,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 13.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.neutralDark,
                          side: const BorderSide(color: AppColors.slateBorder),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          'Keep Playing',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          _deleteXpAndNavigate();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.errorCoral,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          AppStrings.quitButton,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.r,
        height: 40.r,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.azureBorder),
        ),
        child: Icon(
          icon,
          color: iconColor ?? AppColors.neutralDark,
          size: 19.sp,
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final List<Color> gradient;

  const _StatPill({
    required this.label,
    required this.value,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.azureBorder),
        ),
        child: Column(
          children: [
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              label.toUpperCase(),
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.neutralSlate,
                fontSize: 9.5.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _GlassButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 14.h),
        decoration: BoxDecoration(
          gradient: AppColors.primaryButtonGradient,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
