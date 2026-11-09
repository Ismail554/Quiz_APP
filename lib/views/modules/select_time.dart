import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/core/app_strings.dart';
import 'package:geography_geyser/provider/module_provider/selecttime_provider.dart';
import 'package:geography_geyser/routes/app_routes.dart';
import 'package:geography_geyser/views/custom_widgets/buildTextField.dart';
import 'package:geography_geyser/views/custom_widgets/custom_login_button.dart';
import 'package:geography_geyser/views/custom_widgets/stitch_design_widgets.dart';

class SelectTime_screen extends StatefulWidget {
  final int? selectedQuantityIndex;
  final String? moduleId;
  final String? moduleName;

  const SelectTime_screen({
    super.key,
    this.selectedQuantityIndex,
    this.moduleId,
    this.moduleName,
  });

  @override
  State<SelectTime_screen> createState() => _SelectTime_screenState();
}

class _SelectTime_screenState extends State<SelectTime_screen> {
  int? selectedIndex = 1; // Default to 10 minutes
  int _selectedQuestionCount = 10;
  final TextEditingController _customTimeController = TextEditingController();
  int? customTimeMinutes;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SelectTimeProvider>(
        context,
        listen: false,
      ).fetchSelectTimes();
    });
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
        selectedIndex = null;
        customTimeMinutes = _parseMinutesFromText(text);
      } else {
        customTimeMinutes = null;
      }
    });
  }

  int? _parseMinutesFromText(String text) {
    final cleanedText = text
        .toLowerCase()
        .replaceAll('minutes', '')
        .replaceAll('minute', '')
        .replaceAll('mins', '')
        .replaceAll('min', '')
        .replaceAll('m', '')
        .trim();
    return int.tryParse(cleanedText);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SelectTimeProvider>(context);
    final timeOptions = provider.timeList;

    return StitchAmbientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.azureBorder),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16.sp,
              color: AppColors.neutralDark,
            ),
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          AppStrings.selectTimeTitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.neutralDark,
          ),
        ),
      ),
      body: provider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryAzure),
            )
          : SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 20.h),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Selected Quiz Banner
                            FadeInDown(
                              duration: const Duration(milliseconds: 380),
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(18.r),
                                decoration: BoxDecoration(
                                  gradient: AppColors.oceanHeaderGradient,
                                  borderRadius: BorderRadius.circular(22.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryAzure.withValues(
                                        alpha: 0.22,
                                      ),
                                      blurRadius: 18,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(12.r),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.16,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          16.r,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.timer_outlined,
                                        color: Colors.white,
                                        size: 26.sp,
                                      ),
                                    ),
                                    SizedBox(width: 14.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'QUIZ CONFIGURATION',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.w800,
                                              color: const Color(0xFFBAE6FD),
                                              letterSpacing: 0.9,
                                            ),
                                          ),
                                          SizedBox(height: 4.h),
                                          Text(
                                            widget.moduleName ??
                                                'Geography Geyser Quiz',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 22.h),

                            // Question Count Selector
                            Text(
                              'Number of Questions',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.neutralDark,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Row(
                              children: [5, 8, 10, 15].map((count) {
                                final isSelected =
                                    _selectedQuestionCount == count;
                                return Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      right: count == 15 ? 0 : 8.w,
                                    ),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedQuestionCount = count;
                                        });
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          vertical: 12.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.primaryAzure
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            14.r,
                                          ),
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColors.primaryAzure
                                                : AppColors.azureBorder,
                                            width: 1.4,
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              '$count',
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                    fontSize: 16.sp,
                                                    fontWeight: FontWeight.w800,
                                                    color: isSelected
                                                        ? Colors.white
                                                        : AppColors.neutralDark,
                                                  ),
                                            ),
                                            Text(
                                              'Qs',
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                    fontSize: 10.5.sp,
                                                    fontWeight: FontWeight.w600,
                                                    color: isSelected
                                                        ? Colors.white
                                                              .withValues(
                                                                alpha: 0.85,
                                                              )
                                                        : AppColors
                                                              .neutralSlate,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            SizedBox(height: 22.h),

                            // Time Presets
                            Text(
                              'Select Timer Duration',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.neutralDark,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: timeOptions.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12.w,
                                    mainAxisSpacing: 12.h,
                                    childAspectRatio: 2.35,
                                  ),
                              itemBuilder: (context, index) {
                                final item = timeOptions[index];
                                final isSelected = selectedIndex == index;
                                return StitchCard(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 14.w,
                                    vertical: 10.h,
                                  ),
                                  backgroundColor: isSelected
                                      ? const Color(0xFFE0F2FE)
                                      : Colors.white,
                                  borderColor: isSelected
                                      ? AppColors.primaryAzure
                                      : AppColors.azureBorder,
                                  onTap: () {
                                    setState(() {
                                      selectedIndex = isSelected ? null : index;
                                      if (selectedIndex != null) {
                                        _customTimeController.clear();
                                        customTimeMinutes = null;
                                      }
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(8.r),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.primaryAzure
                                              : AppColors.softSky,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.timer_rounded,
                                          size: 18.sp,
                                          color: isSelected
                                              ? Colors.white
                                              : AppColors.primaryAzure,
                                        ),
                                      ),
                                      SizedBox(width: 10.w),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${item.duration} Mins',
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.w800,
                                                    color:
                                                        AppColors.neutralDark,
                                                  ),
                                            ),
                                            Text(
                                              item.duration <= 5
                                                  ? 'Speed Drill'
                                                  : item.duration <= 10
                                                  ? 'Standard Pace'
                                                  : 'Extended Exam',
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                    fontSize: 10.5.sp,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        AppColors.neutralSlate,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            AppSpacing.h18,

                            // Custom time field
                            BuildTextField(
                              label: AppStrings.customizeTimeLabel,
                              hint: "e.g. 12 Minutes",
                              bgcolor: AppColors.white,
                              controller: _customTimeController,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              prefixIcon: Icon(
                                Icons.edit_calendar_rounded,
                                color: AppColors.primaryAzure,
                                size: 20.sp,
                              ),
                            ),
                            AppSpacing.h16,
                          ],
                        ),
                      ),
                    ),

                    // Start Quiz Button
                    CustomLoginButton(
                      text: "Launch Quiz 🚀",
                      onPressed: () {
                        final selectedTime =
                            (selectedIndex != null &&
                                selectedIndex! < timeOptions.length)
                            ? timeOptions[selectedIndex!].duration
                            : (customTimeMinutes ?? 10);

                        context.pushReplacement(
                          AppRoutes.quiz,
                          extra: {
                            'moduleId': widget.moduleId,
                            'moduleName': widget.moduleName,
                            'timeInMinutes': selectedTime,
                            'totalQuestions': _selectedQuestionCount,
                          },
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
