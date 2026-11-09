import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_logger.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/core/app_strings.dart';
import 'package:geography_geyser/models/home_model.dart';
import 'package:geography_geyser/provider/home_provider.dart';
import 'package:geography_geyser/provider/settings_provider/general_settings_provider.dart';
import 'package:geography_geyser/provider/user_performance_provider.dart';
import 'package:geography_geyser/views/custom_widgets/buildTextField.dart';
import 'package:geography_geyser/views/custom_widgets/custom_login_button.dart';
import 'package:geography_geyser/views/custom_widgets/custom_snackbar.dart';
import 'package:geography_geyser/views/custom_widgets/explorer_avatar.dart';
import 'package:geography_geyser/views/custom_widgets/stitch_design_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class GeneralSettings_Screen extends StatefulWidget {
  const GeneralSettings_Screen({super.key});

  @override
  State<GeneralSettings_Screen> createState() => _GeneralSettings_ScreenState();
}

class _GeneralSettings_ScreenState extends State<GeneralSettings_Screen> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    if (_isInitialized) return;
    _isInitialized = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.loadUserDataFromStorage();

      if (mounted &&
          userProvider.userModel == null &&
          !userProvider.isLoading) {
        await userProvider.fetchUserData();
      }

      if (mounted) {
        _populateFields(userProvider.userModel);
      }
    });
  }

  void _populateFields(HomeModel? userModel) {
    if (userModel != null) {
      _nameController.text = userModel.fullName ?? '';
      _emailController.text = userModel.email ?? '';
    }
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      AppLogger.error('${source.name} error', e);
      if (mounted) {
        CustomSnackBar.show(
          context,
          message: 'Unable to access ${source.name}. Please check permissions.',
          isError: true,
        );
      }
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 18.w),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppColors.slateBorder,
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Change Profile Photo',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.neutralDark,
                  ),
                ),
                SizedBox(height: 12.h),
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE0F2FE),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.photo_library_rounded,
                      color: AppColors.primaryAzure,
                      size: 20.sp,
                    ),
                  ),
                  title: Text(
                    'Choose from Gallery',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutralDark,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _pickImageFromSource(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: const BoxDecoration(
                      color: Color(0xFFDCFCE7),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      color: AppColors.emeraldSuccess,
                      size: 20.sp,
                    ),
                  ),
                  title: Text(
                    'Take a Photo',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutralDark,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _pickImageFromSource(ImageSource.camera);
                  },
                ),
                if (_imageFile != null) ...[
                  ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFEE2E2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.errorCoral,
                        size: 20.sp,
                      ),
                    ),
                    title: Text(
                      'Remove Selected Photo',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.errorCoral,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      setState(() {
                        _imageFile = null;
                      });
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _updateProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      CustomSnackBar.show(
        context,
        message: 'Please enter your name',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final profileUpdateProvider = Provider.of<ProfileUpdateProvider>(
        context,
        listen: false,
      );

      final success = await profileUpdateProvider.updateProfile(
        fullName: name,
        profilePic: _imageFile,
      );

      if (!mounted) return;

      if (success) {
        CustomSnackBar.show(
          context,
          message: profileUpdateProvider.message ?? 'Profile updated successfully!',
        );

        final userProvider = Provider.of<UserProvider>(
          context,
          listen: false,
        );
        await userProvider.fetchUserData();

        if (!mounted) return;

        final profileProvider = Provider.of<ProfileProvider>(
          context,
          listen: false,
        );
        await profileProvider.fetchProfile();

        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        CustomSnackBar.show(
          context,
          message: profileUpdateProvider.message ?? 'Update failed',
          isError: true,
        );
      }
    } catch (e) {
      AppLogger.error("Profile update UI error", e);
      if (mounted) {
        CustomSnackBar.show(
          context,
          message: 'An unexpected error occurred.',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile & Account',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.neutralDark,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            final userModel = userProvider.userModel;
            final profilePicUrl = userModel?.profilePic;
            final currentName = _nameController.text.isNotEmpty
                ? _nameController.text
                : (userModel?.fullName ?? 'Geography Explorer');

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
              child: Column(
                children: [
                  // Avatar Section with Signature Glowing Gradient Ring
                  Center(
                    child: Column(
                      children: [
                        if (_imageFile != null)
                          GestureDetector(
                            onTap: _showImagePickerOptions,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 96.r,
                                  height: 96.r,
                                  padding: EdgeInsets.all(3.r),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: AppColors.primaryGradient,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primaryAzure.withValues(
                                          alpha: 0.3,
                                        ),
                                        blurRadius: 18,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                    padding: EdgeInsets.all(2.r),
                                    child: ClipOval(
                                      child: Image.file(
                                        _imageFile!,
                                        width: 96.r,
                                        height: 96.r,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    padding: EdgeInsets.all(7.r),
                                    decoration: BoxDecoration(
                                      gradient: AppColors.primaryGradient,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2.5,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.camera_alt_rounded,
                                      size: 16.sp,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          ExplorerAvatar(
                            imageUrl: profilePicUrl,
                            name: currentName,
                            radius: 46,
                            showEditBadge: true,
                            onTap: _showImagePickerOptions,
                          ),
                        SizedBox(height: 10.h),
                        InkWell(
                          onTap: _showImagePickerOptions,
                          borderRadius: BorderRadius.circular(10.r),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 4.h,
                            ),
                            child: Text(
                              'Change Photo',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryAzure,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Edit Fields Card
                  StitchCard(
                    padding: EdgeInsets.all(20.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Personal Information',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.neutralDark,
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // Name Field
                        BuildTextField(
                          controller: _nameController,
                          label: AppStrings.nameLabel,
                          hint: 'Enter your explorer name',
                          prefixIcon: Icon(
                            Icons.person_outline_rounded,
                            color: AppColors.primaryAzure,
                            size: 20.sp,
                          ),
                        ),
                        AppSpacing.h16,

                        // Email Field (Read-only)
                        BuildTextField(
                          controller: _emailController,
                          isReadOnly: true,
                          label: AppStrings.emailLabel,
                          hint: 'explorer@geographygeyser.com',
                          prefixIcon: Icon(
                            Icons.alternate_email_rounded,
                            color: AppColors.primaryAzure,
                            size: 20.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Save Changes CTA
                  CustomLoginButton(
                    text: _isLoading
                        ? "Saving Changes..."
                        : AppStrings.saveChangesButton,
                    isLoading: _isLoading,
                    onPressed: _isLoading ? null : _updateProfile,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
