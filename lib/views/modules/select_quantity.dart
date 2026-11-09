import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_strings.dart';
import 'package:geography_geyser/routes/app_routes.dart';
import 'package:geography_geyser/views/custom_widgets/custom_login_button.dart';
import 'package:geography_geyser/views/custom_widgets/stitch_design_widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class SelectQuantityScreen extends StatefulWidget {
  final int? selectedTimeInMinutes;
  final String? moduleId;

  const SelectQuantityScreen({
    super.key,
    this.selectedTimeInMinutes,
    this.moduleId,
  });

  @override
  State<SelectQuantityScreen> createState() => _SelectQuantityScreenState();
}

class _SelectQuantityScreenState extends State<SelectQuantityScreen> {
  int? selectedIndex = 1; // Default to 10 questions

  final List<int> quantityOptions = [5, 10, 15, 20, 25, 30];

  @override
  Widget build(BuildContext context) {
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
          AppStrings.selectQuantity,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.neutralDark,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 20.h),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Question Count',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.neutralDark,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        'Customize the length of your drill to match your revision schedule',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5.sp,
                          color: AppColors.softSlate,
                        ),
                      ),
                      SizedBox(height: 18.h),

                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: quantityOptions.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12.w,
                          mainAxisSpacing: 12.h,
                          childAspectRatio: 2.1,
                        ),
                        itemBuilder: (context, index) {
                          final questions = quantityOptions[index];
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
                                    Icons.help_outline_rounded,
                                    size: 18.sp,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.primaryAzure,
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$questions Questions',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13.5.sp,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.neutralDark,
                                        ),
                                      ),
                                      Text(
                                        questions <= 10
                                            ? 'Quick Drill'
                                            : 'Full Exam Practice',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10.5.sp,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.softSlate,
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
                    ],
                  ),
                ),
              ),

              CustomLoginButton(
                text: AppStrings.continueButton,
                onPressed: () {
                  final selectedQuantity = selectedIndex != null
                      ? quantityOptions[selectedIndex!]
                      : 10;
                  context.push(
                    AppRoutes.quiz,
                    extra: {
                      'totalQuestions': selectedQuantity,
                      'timeInMinutes': widget.selectedTimeInMinutes,
                      'moduleId': widget.moduleId,
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
