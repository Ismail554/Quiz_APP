import 'package:flutter/material.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/core/app_strings.dart';
import 'package:geography_geyser/core/font_manager.dart';
import 'package:geography_geyser/custom_widgets/cutom_timer.dart';
import 'package:geography_geyser/views/custom_widgets/buildTextField.dart';
import 'package:geography_geyser/views/custom_widgets/custom_login_button.dart';
import 'package:geography_geyser/views/modules/select_quantity.dart';

class SelectTime_screen extends StatefulWidget {
  final int? selectedQuantityIndex;

  const SelectTime_screen({super.key, this.selectedQuantityIndex});

  @override
  State<SelectTime_screen> createState() => _SelectTime_screenState();
}

class _SelectTime_screenState extends State<SelectTime_screen> {
  int? selectedIndex; //  Tracks which timer is selected

  final List<int> timeOptions = [1, 2, 3, 4, 5, 10, 15, 20, 25, 30];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        title: Text(
          AppStrings.selectTimeTitle,
          style: FontManager.appBarText(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      AppSpacing.h16,

                      /// Generate all timer blocks
                      Column(
                        children: List.generate(timeOptions.length, (index) {
                          final minutes = timeOptions[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: CustomModTimer(
                              minutes: minutes,
                              isSelected: selectedIndex == index,
                              onPressed: () {
                                setState(() {
                                  if (selectedIndex == index) {
                                    // Deselect if same is tapped again
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

                      AppSpacing.h12,

                      ///  Custom time field
                      BuildTextField(
                        label: AppStrings.customizeTimeLabel,
                        hint: "EX: 12 Minutes",
                        bgcolor: AppColors.white,
                      ),

                      AppSpacing.h16,
                    ],
                  ),
                ),
              ),

              ///  Button at bottom
              CustomLoginButton(
                text: AppStrings.continueButton,
                onPressed: () {
                  // Pass the actual time value (in minutes) instead of index
                  final selectedTime = selectedIndex != null
                      ? timeOptions[selectedIndex!]
                      : null;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SelectQuantityScreen(
                        selectedTimeInMinutes: selectedTime,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
