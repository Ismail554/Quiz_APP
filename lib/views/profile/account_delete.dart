import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/core/app_strings.dart';
import 'package:geography_geyser/provider/settings_provider/account_delete_provider.dart';
import 'package:geography_geyser/views/custom_widgets/buildTextField.dart';
import 'package:geography_geyser/views/custom_widgets/custom_login_button.dart';
import 'package:geography_geyser/views/custom_widgets/custom_snackbar.dart';
import 'package:geography_geyser/views/custom_widgets/stitch_design_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AccountDelete extends StatefulWidget {
  const AccountDelete({super.key});

  @override
  State<AccountDelete> createState() => _AccountDeleteState();
}

class _AccountDeleteState extends State<AccountDelete> {
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountDeleteProvider = Provider.of<AccountDeleteProvider>(context);

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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Delete Account",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.neutralDark,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
          child: Column(
            children: [
              StitchCard(
                padding: EdgeInsets.all(20.r),
                borderColor: AppColors.errorCoral.withValues(alpha: 0.3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.r),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFEE2E2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.warning_amber_rounded,
                            color: AppColors.errorCoral,
                            size: 24.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            'Permanent Action',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.errorCoral,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    Text(
                      AppStrings.accountdeleteDescription,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.neutralSlate,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    BuildTextField(
                      controller: _passwordController,
                      label: AppStrings.enterPass,
                      hint: "Enter your password to confirm",
                      obscureText: true,
                      prefixIcon: Icon(
                        Icons.lock_outline_rounded,
                        color: AppColors.errorCoral,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      AppStrings.deletePassWar,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.errorCoral,
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.h32,

              accountDeleteProvider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.errorCoral,
                      ),
                    )
                  : CustomLoginButton(
                      text: "Permanently Delete My Account",
                      backgroundColor: AppColors.errorCoral,
                      onPressed: () {
                        if (_passwordController.text.isNotEmpty) {
                          showAccountDelete(
                            context,
                            _passwordController.text,
                          );
                        } else {
                          CustomSnackBar.show(
                            context,
                            message: "Please enter your password",
                            isError: true,
                          );
                        }
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

void showAccountDelete(BuildContext context, String password) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          AppStrings.areYouSureTitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.neutralDark,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          AppStrings.accountDeleteHint,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.sp,
            color: AppColors.neutralSlate,
          ),
          textAlign: TextAlign.center,
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    side: const BorderSide(color: AppColors.slateBorder),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Text(
                    AppStrings.cancelButton,
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.neutralDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              AppSpacing.w12,
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.of(dialogContext).pop();
                    await Provider.of<AccountDeleteProvider>(
                      context,
                      listen: false,
                    ).deleteAccount(password, context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.errorCoral,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Text(
                    AppStrings.delete,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}
