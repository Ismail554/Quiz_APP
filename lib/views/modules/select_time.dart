import 'package:flutter/material.dart';
import 'package:geography_geyser/provider/module_provider/selecttime_provider.dart';
import 'package:geography_geyser/views/modules/quiz_screen.dart';
import 'package:provider/provider.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/core/app_strings.dart';
import 'package:geography_geyser/core/font_manager.dart';
import 'package:geography_geyser/custom_widgets/cutom_timer.dart';
import 'package:geography_geyser/views/custom_widgets/buildTextField.dart';
import 'package:geography_geyser/views/custom_widgets/custom_login_button.dart';

class SelectTime_screen extends StatefulWidget {
  final int? selectedQuantityIndex;
  final String? moduleId;

  const SelectTime_screen({
    super.key,
    this.selectedQuantityIndex,
    this.moduleId,
  });

  @override
  State<SelectTime_screen> createState() => _SelectTime_screenState();
}

class _SelectTime_screenState extends State<SelectTime_screen> {
  int? selectedIndex;
  final TextEditingController _customTimeController = TextEditingController();
  int? customTimeMinutes;

  @override
  void initState() {
    super.initState();
    // Fetch time list
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SelectTimeProvider>(
        context,
        listen: false,
      ).fetchSelectTimes();
    });

    // Listen to custom time field changes
    _customTimeController.addListener(_onCustomTimeChanged);
  }

  @override
  void dispose() {
    _customTimeController.removeListener(_onCustomTimeChanged);
    _customTimeController.dispose();
    super.dispose();
  }

  void _onCustomTimeChanged() {
    final text = _customTimeController.text.trim();
    setState(() {
      if (text.isNotEmpty) {
        // Unselect timer when user types in custom field
        if (selectedIndex != null) {
          selectedIndex = null;
        }

        // Parse the input to extract minutes
        customTimeMinutes = _parseMinutesFromText(text);
      } else {
        customTimeMinutes = null;
      }
    });
  }

  int? _parseMinutesFromText(String text) {
    // Remove common words and extract number
    final cleanedText = text
        .toLowerCase()
        .replaceAll('minutes', '')
        .replaceAll('minute', '')
        .replaceAll('mins', '')
        .replaceAll('min', '')
        .replaceAll('m', '')
        .trim();

    // Try to parse as integer
    final number = int.tryParse(cleanedText);
    return number;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SelectTimeProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        title: Text(
          AppStrings.selectTimeTitle,
          style: FontManager.appBarText(),
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            AppSpacing.h16,

                            /// Generate all timer blocks from API data
                            Column(
                              children: List.generate(provider.timeList.length, (
                                index,
                              ) {
                                final item = provider.timeList[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: CustomModTimer(
                                    minutes: item.duration,
                                    isSelected: selectedIndex == index,
                                    onPressed: () {
                                      setState(() {
                                        final wasSelected =
                                            selectedIndex == index;
                                        selectedIndex = wasSelected
                                            ? null
                                            : index;
                                        // Clear custom time field when timer is selected (not when deselected)
                                        if (!wasSelected &&
                                            selectedIndex != null) {
                                          _customTimeController.clear();
                                          customTimeMinutes = null;
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
                              controller: _customTimeController,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                            ),
                            AppSpacing.h16,
                          ],
                        ),
                      ),
                    ),

                    ///  Continue Button
                    CustomLoginButton(
                      text: AppStrings.continueButton,
                      onPressed: () {
                        // Get selected time from either timer or custom field
                        final selectedTime = selectedIndex != null
                            ? provider.timeList[selectedIndex!].duration
                            : customTimeMinutes;

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuizScreen(
                              moduleId: widget.moduleId,
                              timeInMinutes: selectedTime,
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
