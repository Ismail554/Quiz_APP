import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_logger.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/core/app_strings.dart';
import 'package:geography_geyser/provider/settings_provider/optional_module_provider.dart';
import 'package:geography_geyser/routes/app_routes.dart';
import 'package:geography_geyser/services/pending_deep_link_service.dart';
import 'package:geography_geyser/views/custom_widgets/custom_login_button.dart';
import 'package:geography_geyser/views/custom_widgets/custom_snackbar.dart';
import 'package:geography_geyser/views/custom_widgets/custom_toggle_button.dart';
import 'package:geography_geyser/views/custom_widgets/stitch_design_widgets.dart';

class OptionalModuleSettings extends StatefulWidget {
  final bool isFirstLogin;

  const OptionalModuleSettings({super.key, this.isFirstLogin = false});

  @override
  State<OptionalModuleSettings> createState() => _OptionalModuleSettingsState();
}

class _OptionalModuleSettingsState extends State<OptionalModuleSettings> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<OptionalModuleProvider>(
          context,
          listen: false,
        ).fetchOptionalModules();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StitchAmbientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: !widget.isFirstLogin,
        leading: widget.isFirstLogin
            ? null
            : IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18.sp,
                  color: AppColors.neutralDark,
                ),
                onPressed: () => context.pop(),
              ),
        title: Text(
          widget.isFirstLogin
              ? AppStrings.altModSettOption
              : AppStrings.moduleSettingTitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.neutralDark,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StitchCard(
                      padding: EdgeInsets.all(18.r),
                      backgroundColor: const Color(0xFFE0F2FE),
                      borderColor: AppColors.primaryAzure.withValues(
                        alpha: 0.3,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.school_rounded,
                            color: AppColors.primaryAzure,
                            size: 28.sp,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppStrings.selectOptionalModuleInstruction,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.neutralDark,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  widget.isFirstLogin
                                      ? AppStrings.firstLoginModule
                                      : 'Choose your Edexcel Group B optional topic pairs to tailor your dashboard and quizzes.',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.deepOcean,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.h24,

                    Consumer<OptionalModuleProvider>(
                      builder: (context, provider, child) {
                        if (provider.isLoading) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(40.0),
                              child: CircularProgressIndicator(
                                color: AppColors.primaryAzure,
                              ),
                            ),
                          );
                        }

                        if (provider.errorMessage != null) {
                          return StitchCard(
                            borderColor: AppColors.errorCoral,
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: AppColors.errorCoral,
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    AppLogger.getSafeErrorMessage(
                                      provider.errorMessage!,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return Column(
                          children: provider.modulePairs.map((pair) {
                            if (pair.modules.length < 2) {
                              return const SizedBox.shrink();
                            }
                            final module1 = pair.modules[0];
                            final module2 = pair.modules[1];

                            String? initialSelection;
                            final selectedModuleId = pair.selectedModule
                                ?.trim();
                            if (selectedModuleId != null &&
                                selectedModuleId.isNotEmpty) {
                              if (selectedModuleId == module1.id.trim()) {
                                initialSelection = module1.moduleName;
                              } else if (selectedModuleId ==
                                  module2.id.trim()) {
                                initialSelection = module2.moduleName;
                              }
                            }

                            return Padding(
                              padding: EdgeInsets.only(bottom: 14.h),
                              child: CustomToggleButton(
                                option1: module1.moduleName,
                                option2: module2.moduleName,
                                initialSelection: initialSelection,
                                onChanged: (selectedModuleName) {
                                  String? selectedId;
                                  if (selectedModuleName ==
                                      module1.moduleName) {
                                    selectedId = module1.id;
                                  } else if (selectedModuleName ==
                                      module2.moduleName) {
                                    selectedId = module2.id;
                                  }
                                  if (selectedId != null &&
                                      selectedId.isNotEmpty) {
                                    provider.updateSelectedModule(
                                      pair.pairNumber,
                                      selectedId,
                                    );
                                  }
                                },
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: Consumer<OptionalModuleProvider>(
                builder: (context, provider, child) {
                  return CustomLoginButton(
                    onPressed: provider.isLoading
                        ? null
                        : () async {
                            final success = await provider
                                .updateModuleSelections();

                            if (!context.mounted) return;
                            if (success) {
                              CustomSnackBar.show(
                                context,
                                message:
                                    'Module selections saved successfully!',
                              );
                              final pendingRoute =
                                  await PendingDeepLinkService.consumePendingRoute();
                              if (!context.mounted) return;
                              if (pendingRoute != null &&
                                  pendingRoute.isNotEmpty) {
                                context.go(pendingRoute);
                              } else {
                                context.go(AppRoutes.home);
                              }
                            } else if (provider.errorMessage != null) {
                              CustomSnackBar.show(
                                context,
                                message: AppLogger.getSafeErrorMessage(
                                  provider.errorMessage!,
                                ),
                                isError: true,
                              );
                            }
                          },
                    text: provider.isLoading ? 'Saving...' : AppStrings.goHome,
                  );
                },
              ),
            ),
            AppSpacing.h16,
          ],
        ),
      ),
    );
  }
}
