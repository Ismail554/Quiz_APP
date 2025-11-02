import 'package:flutter/material.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/core/app_strings.dart';
import 'package:geography_geyser/core/font_manager.dart';
import 'package:geography_geyser/custom_widgets/custom_q_quantity.dart';
import 'package:geography_geyser/views/custom_widgets/custom_login_button.dart';
import 'package:geography_geyser/views/modules/quiz_screen.dart';

class SelectQuantityScreen extends StatefulWidget {
  final int? selectedTimeInMinutes;

  const SelectQuantityScreen({super.key, this.selectedTimeInMinutes});

  @override
  State<SelectQuantityScreen> createState() => _SelectQuantityScreenState();
}

class _SelectQuantityScreenState extends State<SelectQuantityScreen> {
  int? selectedIndex;

  final List<int> quantityOptions = [5, 10, 15, 20, 25, 30, 35, 40];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        title: Text(AppStrings.selectQuantity, style: FontManager.appBarText()),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      AppSpacing.h16,

                      /// Generate all quantity blocks
                      Column(
                        children: List.generate(quantityOptions.length, (
                          index,
                        ) {
                          final questions = quantityOptions[index];
                          return Padding(
                            padding: EdgeInsets.only(bottom: 8.0),
                            child: Custom_Q_quantity(
                              question: questions,
                              isSelected: selectedIndex == index,
                              onPressed: () {
                                setState(() {
                                  if (selectedIndex == index) {
                                    // again select korle abar deselect(null) kore dibe
                                    selectedIndex = null;
                                  } else {
                                    // Select new index
                                    selectedIndex = index;
                                  }
                                });
                              },
                            ),
                          );
                        }),
                      ),

                      AppSpacing.h16,
                    ],
                  ),
                ),
              ),

              /// Button at the bottom
              CustomLoginButton(
                text: AppStrings.continueButton,
                onPressed: () {
                  // Pass the actual values instead of indices
                  final selectedQuantity = selectedIndex != null
                      ? quantityOptions[selectedIndex!]
                      : null;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizScreen(
                        totalQuestions: selectedQuantity,
                        timeInMinutes: widget.selectedTimeInMinutes,
                      ),
                    ),
                  );
                },
              ),
              AppSpacing.h12,
            ],
          ),
        ),
      ),
    );
  }
}
