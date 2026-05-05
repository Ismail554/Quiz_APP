import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_logger.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/core/app_strings.dart';
import 'package:geography_geyser/core/font_manager.dart';
import 'package:geography_geyser/core/sound_helper.dart';
import 'package:geography_geyser/models/quiz_model.dart';
import 'package:geography_geyser/provider/module_provider/quiz_provider.dart';
import 'package:geography_geyser/provider/module_provider/quiz_finish_provider.dart';
import 'package:geography_geyser/provider/module_provider/delete_xp_provider.dart';
import 'package:geography_geyser/provider/userstats_provider.dart';
import 'package:geography_geyser/provider/user_performance_provider.dart';
import 'package:geography_geyser/views/modules/quiz_result.dart';
import 'package:geography_geyser/views/modules/time_out_dialog.dart';
import 'package:provider/provider.dart';

class QuizScreen extends StatefulWidget {
  final int? totalQuestions;
  final int? timeInMinutes;
  final String? moduleId;
  final String? moduleName;

  const QuizScreen({
    super.key,
    this.totalQuestions,
    this.timeInMinutes,
    this.moduleId,
    this.moduleName,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  // Quiz state variables
  int currentQuestionIndex = 0;
  late int totalQuestions;
  late int timeRemaining;
  int? selectedAnswerIndex;
  Timer? _timer;
  bool showAnswerFeedback = false;
  bool isCorrectAnswer = false;
  int correctAnswersCount = 0;
  bool _isSoundEnabled = true;

  // Animation controllers
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

    if (widget.moduleId != null && widget.moduleId!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final quizProvider = Provider.of<QuizProvider>(context, listen: false);
        final future = widget.moduleId == 'synoptic'
            ? quizProvider.fetchSynopticQuiz()
            : quizProvider.fetchQuiz(widget.moduleId!);
        future.then((_) {
          if (mounted) {
            startTimer();
            _questionAnimController.forward();
            _optionsStaggerController.forward();
          }
        });
      });
    } else {
      startTimer();
    }
  }

  void _initAnimations() {
    // Question card float-in animation
    _questionAnimController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _questionFadeAnim = CurvedAnimation(
      parent: _questionAnimController,
      curve: Curves.easeOut,
    );
    _questionSlideAnim =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _questionAnimController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Timer pulse for urgent state
    _timerPulseController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _timerPulseAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _timerPulseController, curve: Curves.easeInOut),
    );

    // Options stagger
    _optionsStaggerController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  void _initializeQuizSettings() {
    totalQuestions = widget.totalQuestions ?? 10;
    final minutes = widget.timeInMinutes ?? 5;
    timeRemaining = minutes * 60;
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
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeRemaining > 0) {
        setState(() {
          timeRemaining--;
        });
        // Start pulsing when under 30 seconds
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

    final quizId = quizProvider.quizData?.quizId;

    if (quizId != null && quizId.isNotEmpty) {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );
      }

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
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => QuizResult_Screen()),
          (route) => false,
        );
      }
    } else {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => QuizResult_Screen()),
          (route) => false,
        );
      }
    }
  }

  Future<void> _deleteXpAndNavigate() async {
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

    final quizId = quizProvider.quizData?.quizId;

    if (quizId != null && quizId.isNotEmpty) {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
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
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => QuizResult_Screen()),
          (route) => false,
        );
      }
    } else {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => QuizResult_Screen()),
          (route) => false,
        );
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

    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        final provider = Provider.of<QuizProvider>(context, listen: false);
        final questions = provider.quizData?.questions ?? [];
        final actualTotalQuestions = questions.length;

        if (currentQuestionIndex < actualTotalQuestions - 1) {
          setState(() {
            currentQuestionIndex++;
            selectedAnswerIndex = null;
            showAnswerFeedback = false;
            isCorrectAnswer = false;
          });
          _animateToNextQuestion();
        } else {
          _finishQuizAndNavigate();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
          child: Scaffold(
            backgroundColor: AppColors.bgColor,
            body: SafeArea(child: _buildBody(context, provider)),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, QuizProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz_outlined, size: 64.sp, color: Colors.grey),
            AppSpacing.h16,
            const Text('No quiz data available'),
            AppSpacing.h24,
            _GlassButton(
              label: 'Go Back',
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }

    final questions = provider.quizData!.questions;
    final actualTotalQuestions = questions.length;

    if (currentQuestionIndex >= actualTotalQuestions) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _finishQuizAndNavigate();
      });
      return const Center(child: CircularProgressIndicator());
    }

    final currentQuestion = questions[currentQuestionIndex];

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top bar ──────────────────────────────────────────
                _buildTopBar(),
                SizedBox(height: 16.h),

                // ── Progress bar ─────────────────────────────────────
                _buildProgressBar(actualTotalQuestions),
                SizedBox(height: 16.h),

                // ── Timer pill ───────────────────────────────────────
                _buildTimerPill(),
                SizedBox(height: 18.h),

                // ── Question card ────────────────────────────────────
                _buildQuestionCard(currentQuestion),
                SizedBox(height: 16.h),

                // ── Options ──────────────────────────────────────────
                ...List.generate(
                  currentQuestion.optionsList.length,
                  (index) => _buildOptionTile(
                    index,
                    currentQuestion.optionsList[index],
                    currentQuestion,
                    currentQuestion.optionsList.length,
                  ),
                ),
                SizedBox(height: 20.h),

                // ── Stats row ────────────────────────────────────────
                _buildStatsRow(),
                SizedBox(height: 12.h),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Top bar ───────────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Close button
        _CircleIconButton(
          icon: Icons.close_rounded,
          onTap: () => showCancelQuizDialog(context),
        ),

        // Module badge
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6C5CE7), Color(0xFFA78BFA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C6BFF).withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            '🌍  ${widget.moduleName ?? AppStrings.quizTitleMigrations}',
            style: FontManager.buttonTextRegular().copyWith(
              color: Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),

        // Sound toggle
        _CircleIconButton(
          icon: _isSoundEnabled
              ? Icons.volume_up_rounded
              : Icons.volume_off_rounded,
          iconColor: _isSoundEnabled ? AppColors.black : Colors.black38,
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

  // ── Progress bar ──────────────────────────────────────────────────────────
  Widget _buildProgressBar(int total) {
    final progress = (currentQuestionIndex + 1) / total;
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: Container(
              height: 6.h,
              color: Colors.black.withOpacity(0.08),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C6BFF), Color(0xFFA78BFA)],
                    ),
                    borderRadius: BorderRadius.circular(4.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7C6BFF).withOpacity(0.4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Text(
          '${currentQuestionIndex + 1} / $total',
          style: FontManager.bodyText().copyWith(
            color: Colors.black45,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ── Timer pill ────────────────────────────────────────────────────────────
  Widget _buildTimerPill() {
    final urgent = _isTimerUrgent;

    return AnimatedBuilder(
      animation: _timerPulseAnim,
      builder: (context, child) {
        return Transform.scale(
          scale: urgent ? _timerPulseAnim.value : 1.0,
          child: child,
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: urgent
              ? const Color(0xFFFF4D6D).withOpacity(0.08)
              : const Color(0xFFFF6B9D).withOpacity(0.06),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: urgent
                ? const Color(0xFFFF4D6D).withOpacity(0.40)
                : const Color(0xFFFF6B9D).withOpacity(0.30),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  (urgent ? const Color(0xFFFF4D6D) : const Color(0xFFFF6B9D))
                      .withOpacity(0.10),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.timer_rounded,
              color: urgent ? const Color(0xFFFF4D6D) : const Color(0xFFFF6B9D),
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              formattedTime,
              style: FontManager.bodyText().copyWith(
                color: urgent
                    ? const Color(0xFFFF4D6D)
                    : const Color(0xFFFF6B9D),
                fontSize: 28.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: 3,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Question card ─────────────────────────────────────────────────────────
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
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(color: Colors.black.withOpacity(0.07), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label
              Row(
                children: [
                  Container(
                    width: 3.w,
                    height: 14.h,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7C6BFF), Color(0xFFA78BFA)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'QUESTION ${currentQuestionIndex + 1}',
                    style: FontManager.bodyText().copyWith(
                      color: const Color(0xFF7C6BFF),
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.8,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              // Question text
              Text(
                question.questionText,
                style: FontManager.headlineText(
                  fontSize: 17.sp,
                  spacing: 0,
                  height: 1.5,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Option tile ───────────────────────────────────────────────────────────
  Widget _buildOptionTile(
    int index,
    String text,
    QuestionModel question,
    int total,
  ) {
    final isSelected = selectedAnswerIndex == index;
    final isCorrect = index == question.correctAnswerIndex;

    // Determine state colors
    Color bgColor;
    Color borderColor;
    Color letterBg;
    Color letterColor;
    Widget? trailingIcon;

    if (!showAnswerFeedback) {
      bgColor = isSelected
          ? const Color(0xFF7C6BFF).withOpacity(0.10)
          : Colors.white;
      borderColor = isSelected
          ? const Color(0xFF7C6BFF)
          : Colors.black.withOpacity(0.10);
      letterBg = isSelected
          ? const Color(0xFF7C6BFF).withOpacity(0.15)
          : Colors.black.withOpacity(0.05);
      letterColor = isSelected ? const Color(0xFF7C6BFF) : Colors.black54;
      trailingIcon = null;
    } else if (isCorrect) {
      bgColor = const Color(0xFF00C47A).withOpacity(0.10);
      borderColor = const Color(0xFF00C47A);
      letterBg = const Color(0xFF00C47A).withOpacity(0.20);
      letterColor = const Color(0xFF00C47A);
      trailingIcon = Icon(
        Icons.check_circle_rounded,
        color: const Color(0xFF00C47A),
        size: 20.sp,
      );
    } else if (isSelected) {
      bgColor = const Color(0xFFFF4D6D).withOpacity(0.08);
      borderColor = const Color(0xFFFF4D6D);
      letterBg = const Color(0xFFFF4D6D).withOpacity(0.15);
      letterColor = const Color(0xFFFF4D6D);
      trailingIcon = Icon(
        Icons.cancel_rounded,
        color: const Color(0xFFFF4D6D),
        size: 20.sp,
      );
    } else {
      bgColor = Colors.white;
      borderColor = Colors.black.withOpacity(0.08);
      letterBg = Colors.black.withOpacity(0.04);
      letterColor = Colors.black38;
      trailingIcon = null;
    }

    final letters = ['A', 'B', 'C', 'D'];

    // Staggered slide-up per option
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
          offset: Offset(0, (1 - staggerAnim.value) * 20),
          child: Opacity(
            opacity: staggerAnim.value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: 10.h),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: borderColor,
              width: showAnswerFeedback ? 1.5 : 1.2,
            ),
            boxShadow: showAnswerFeedback && (isCorrect || isSelected)
                ? [
                    BoxShadow(
                      color: borderColor.withOpacity(0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16.r),
            child: InkWell(
              borderRadius: BorderRadius.circular(16.r),
              splashColor: const Color(0xFF7C6BFF).withOpacity(0.15),
              highlightColor: Colors.transparent,
              onTap: showAnswerFeedback
                  ? null
                  : () => handleAnswerSelection(index, question),
              child: Padding(
                padding: EdgeInsets.all(14.w),
                child: Row(
                  children: [
                    // Letter badge
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 280),
                      width: 34.r,
                      height: 34.r,
                      decoration: BoxDecoration(
                        color: letterBg,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: borderColor.withOpacity(0.5)),
                      ),
                      child: Center(
                        child: Text(
                          letters[index],
                          style: FontManager.bodyText().copyWith(
                            color: letterColor,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 14.w),
                    // Option text
                    Expanded(
                      child: Text(
                        text,
                        style: FontManager.bodyText().copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.black,
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

  // ── Stats row ─────────────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    final total =
        correctAnswersCount +
        (currentQuestionIndex == 0 && !showAnswerFeedback
            ? 0
            : currentQuestionIndex);
    final wrongCount = total - correctAnswersCount;
    final pct = total > 0 ? (correctAnswersCount / total * 100).round() : 0;

    return Row(
      children: [
        _StatPill(
          label: 'Correct',
          value: '$correctAnswersCount',
          gradient: const [Color(0xFF00E5A0), Color(0xFF00B894)],
        ),
        SizedBox(width: 10.w),
        _StatPill(
          label: 'Wrong',
          value: '$wrongCount',
          gradient: const [Color(0xFFFF4D6D), Color(0xFFFF6B9D)],
        ),
        SizedBox(width: 10.w),
        _StatPill(
          label: 'Score',
          value: '$pct%',
          gradient: const [Color(0xFF7C6BFF), Color(0xFFA78BFA)],
        ),
      ],
    );
  }

  // ── Cancel dialog ─────────────────────────────────────────────────────────
  void showCancelQuizDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ColorFilter.matrix(const [
            0.2126,
            0.7152,
            0.0722,
            0,
            0,
            0.2126,
            0.7152,
            0.0722,
            0,
            0,
            0.2126,
            0.7152,
            0.0722,
            0,
            0,
            0,
            0,
            0,
            1,
            0,
          ]),
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: Colors.black.withOpacity(0.08)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 40,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('⚠️', style: TextStyle(fontSize: 36.sp)),
                  SizedBox(height: 12.h),
                  Text(
                    AppStrings.cancelQuizConfirmationTitle,
                    textAlign: TextAlign.center,
                    style: FontManager.boldHeading(
                      fontSize: 18,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    AppStrings.cancelQuizDeductionMessage,
                    textAlign: TextAlign.center,
                    style: FontManager.bodyText().copyWith(
                      color: AppColors.grey4B,
                      fontSize: 13.sp,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    children: [
                      // Keep playing
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            decoration: BoxDecoration(
                              color: AppColors.black,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: AppColors.blue),
                            ),
                            child: Center(
                              child: Text(
                                AppStrings.cancelButton,
                                style: FontManager.buttonText(),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      // Quit
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                            _deleteXpAndNavigate();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            decoration: BoxDecoration(
                              color: AppColors.red,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Center(
                              child: Text(
                                AppStrings.quitButton,
                                style: FontManager.buttonText().copyWith(
                                  color: AppColors.white,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Reusable sub-widgets ───────────────────────────────────────────────────

/// Glass circle icon button
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
        width: 38.r,
        height: 38.r,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.06),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black.withOpacity(0.10)),
        ),
        child: Icon(icon, color: iconColor ?? Colors.black87, size: 18.sp),
      ),
    );
  }
}

/// Stat pill for the bottom row
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
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: Colors.black.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
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
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                color: Colors.black45,
                fontSize: 9.5.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple glass text button
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
          gradient: const LinearGradient(
            colors: [Color(0xFF7C6BFF), Color(0xFFA78BFA)],
          ),
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C6BFF).withOpacity(0.4),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
