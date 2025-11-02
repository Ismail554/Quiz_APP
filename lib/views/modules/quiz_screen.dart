import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/core/app_strings.dart';
import 'package:geography_geyser/core/font_manager.dart';
import 'package:geography_geyser/views/home/homepage.dart';
import 'package:geography_geyser/views/modules/quiz_result.dart';
import 'package:geography_geyser/views/modules/time_out_dialog.dart';

class QuizScreen extends StatefulWidget {
  final int? totalQuestions;
  final int? timeInMinutes;

  const QuizScreen({super.key, this.totalQuestions, this.timeInMinutes});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  // Quiz state variables
  int currentQuestionIndex = 0;
  late int totalQuestions;
  late int timeRemaining;
  int? selectedAnswerIndex;
  Timer? _timer;
  bool showAnswerFeedback = false;
  bool isCorrectAnswer = false;

  // Fake quiz data for testing
  final List<Map<String, dynamic>> quizData = [
    {
      'question': 'What is migration?',
      'options': [
        'Water Cycle',
        'Movement of People',
        'Rock Breaking',
        'Plant Process',
      ],
      'correctAnswer': 1, // Index of correct answer
    },
    {
      'question': 'What causes earthquakes?',
      'options': [
        'Tectonic Plates',
        'Weather Changes',
        'Ocean Currents',
        'Solar Activity',
      ],
      'correctAnswer': 0,
    },
    {
      'question': 'Which is the largest ocean?',
      'options': ['Atlantic', 'Pacific', 'Indian', 'Arctic'],
      'correctAnswer': 1,
    },
    {
      'question': 'What is the capital of Australia?',
      'options': ['Sydney', 'Melbourne', 'Canberra', 'Perth'],
      'correctAnswer': 2,
    },
    {
      'question': 'Which continent has the most countries?',
      'options': ['Asia', 'Africa', 'Europe', 'North America'],
      'correctAnswer': 1,
    },
    {
      'question': 'What is the longest river in the world?',
      'options': ['Amazon', 'Nile', 'Mississippi', 'Yangtze'],
      'correctAnswer': 1,
    },
    {
      'question': 'Which country has the largest population?',
      'options': ['India', 'China', 'USA', 'Brazil'],
      'correctAnswer': 1,
    },
    {
      'question': 'What is the smallest country in the world?',
      'options': ['Monaco', 'Vatican City', 'Liechtenstein', 'San Marino'],
      'correctAnswer': 1,
    },
    {
      'question': 'Which mountain range is the longest?',
      'options': ['Himalayas', 'Andes', 'Rockies', 'Alps'],
      'correctAnswer': 1,
    },
    {
      'question': 'What is the largest desert in the world?',
      'options': ['Sahara', 'Arabian', 'Gobi', 'Kalahari'],
      'correctAnswer': 0,
    },
  ];

  @override
  void initState() {
    super.initState();
    // Initialize total questions and time based on selected options
    _initializeQuizSettings();
    startTimer();
  }

  void _initializeQuizSettings() {
    // Set total questions from passed value
    totalQuestions = widget.totalQuestions ?? 10; // Default value

    // Set time from passed value (convert minutes to seconds)
    final minutes = widget.timeInMinutes ?? 5; // Default 5 minutes
    timeRemaining = minutes * 60;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (timeRemaining > 0) {
        setState(() {
          timeRemaining--;
        });
      } else {
        timer.cancel();
        // Handle time up - show timeout dialog
        if (mounted) {
          TimeoutDialog.show(
            context,
            onOkPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => QuizResult_Screen()),
                (route) => false,
              );
            },
          );
        }
      }
    });
  }

  String get formattedTime {
    final minutes = timeRemaining ~/ 60;
    final seconds = timeRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void handleAnswerSelection(int selectedIndex) {
    if (showAnswerFeedback) return; // Prevent multiple selections

    setState(() {
      selectedAnswerIndex = selectedIndex;
      showAnswerFeedback = true;
      isCorrectAnswer =
          selectedIndex == quizData[currentQuestionIndex]['correctAnswer'];
    });

    // Auto-progress after 3 seconds
    Timer(Duration(seconds: 2), () {
      if (mounted) {
        if (currentQuestionIndex < totalQuestions - 1) {
          setState(() {
            currentQuestionIndex++;
            selectedAnswerIndex = null;
            showAnswerFeedback = false;
            isCorrectAnswer = false;
          });
        } else {
          // Quiz completed, navigate to results
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => QuizResult_Screen()),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top section (close button + quiz info)
                    IconButton(
                      icon: Icon(Icons.close, color: AppColors.black),
                      onPressed: () {
                        showCancelQuizDialog(context);
                      },
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        AppStrings.quizTitleMigrations,
                        style: FontManager.buttonTextRegular().copyWith(
                          color: AppColors.white,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                    AppSpacing.h12,

                    // Question info row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Question ${currentQuestionIndex + 1} of $totalQuestions',
                          style: FontManager.bodyText(),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: AppColors.blue,
                              size: 16.sp,
                            ),
                            AppSpacing.w4,
                            Text(
                              formattedTime,
                              style: FontManager.bodyText().copyWith(
                                color: AppColors.blue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            AppSpacing.w16,
                            Text(
                              'Left: ${totalQuestions - currentQuestionIndex}',
                              style: FontManager.bodyText().copyWith(
                                color: AppColors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    AppSpacing.h20,

                    // Question text
                    Text(
                      quizData[currentQuestionIndex]['question'],
                      style: FontManager.boldHeading(
                        fontSize: 20,
                        color: AppColors.black,
                      ),
                    ),
                    AppSpacing.h24,

                    // Options
                    ...List.generate(
                      quizData[currentQuestionIndex]['options'].length,
                      (index) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: Custom_Q_choice(
                            quizData[currentQuestionIndex]['options'][index],
                            AppColors.white,
                            index,
                          ),
                        );
                      },
                    ),
                    AppSpacing.h20,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showCancelQuizDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: AlertDialog(
            backgroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            title: Text(
              AppStrings.cancelQuizConfirmationTitle,
              textAlign: TextAlign.center,
              style: FontManager.boldHeading(
                fontSize: 18,
                color: AppColors.black,
              ),
            ),
            content: Text(
              AppStrings.cancelQuizDeductionMessage,
              textAlign: TextAlign.center,
              style: FontManager.bodyText().copyWith(color: AppColors.grey4B),
            ),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close dialog
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.black,
                        foregroundColor: AppColors.black,
                        side: BorderSide(color: AppColors.blue),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        AppStrings.cancelButton,
                        style: FontManager.buttonText(),
                      ),
                    ),
                  ),
                  AppSpacing.w12,
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close dialog
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuizResult_Screen(),
                          ),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.red,
                        foregroundColor: AppColors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        AppStrings.quitButton,
                        textAlign: TextAlign.center,
                        style: FontManager.buttonText().copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget Custom_Q_choice(String text, Color backgroundColor, int optionIndex) {
    final isSelected = selectedAnswerIndex == optionIndex;
    final isCorrectAnswer =
        optionIndex == quizData[currentQuestionIndex]['correctAnswer'];

    Color getAnswerColor() {
      if (!showAnswerFeedback) {
        return isSelected ? const Color(0xFFE8F4FF) : backgroundColor;
      }

      if (isCorrectAnswer) {
        return Colors.green.withOpacity(0.2); // Light green for correct
      } else if (isSelected) {
        return Colors.red.withOpacity(0.2); // Light red for incorrect
      }
      return backgroundColor;
    }

    Color getBorderColor() {
      if (!showAnswerFeedback) {
        return isSelected ? Colors.blueAccent : AppColors.borderColor;
      }

      if (isCorrectAnswer) {
        return Colors.green; // Green border for correct
      } else if (isSelected) {
        return Colors.red; // Red border for incorrect
      }
      return AppColors.borderColor;
    }

    return InkWell(
      onTap: () {
        handleAnswerSelection(optionIndex);
      },
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: getAnswerColor(),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: getBorderColor(),
            width: showAnswerFeedback ? 2 : (isSelected ? 2 : 1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: FontManager.bodyText().copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.black,
                ),
              ),
            ),
            if (showAnswerFeedback && isCorrectAnswer)
              Icon(Icons.check_circle, color: Colors.green, size: 20.sp),
            if (showAnswerFeedback && isSelected && !isCorrectAnswer)
              Icon(Icons.cancel, color: Colors.red, size: 20.sp),
          ],
        ),
      ),
    );
  }
}
