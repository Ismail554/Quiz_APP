import 'dart:io';
import 'package:geography_geyser/models/home_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_logger.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/core/app_strings.dart';
import 'package:geography_geyser/core/font_manager.dart';
import 'package:geography_geyser/provider/home_provider.dart';
import 'package:geography_geyser/provider/user_performance_provider.dart';
import 'package:geography_geyser/provider/settings_provider/general_settings_provider.dart';
import 'package:geography_geyser/services/api_service.dart';
import 'package:geography_geyser/views/custom_widgets/buildTextField.dart';
import 'package:geography_geyser/views/custom_widgets/custom_login_button.dart';
import 'package:geography_geyser/views/custom_widgets/custom_snackbar.dart';
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

      // Load from storage first
      await userProvider.loadUserDataFromStorage();

      // If no data in storage, fetch from API
      if (mounted &&
          userProvider.userModel == null &&
          !userProvider.isLoading) {
        await userProvider.fetchUserData();
      }

      // Populate fields with user data
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

  String _buildImageUrl(String? profilePicUrl) {
    if (profilePicUrl == null || profilePicUrl.isEmpty) {
      return '';
    }

    if (profilePicUrl.startsWith('http://') ||
        profilePicUrl.startsWith('https://')) {
      return profilePicUrl;
    }

    // Handle relative URLs by prepending base URL
    final cleanUrl = profilePicUrl.startsWith('/')
        ? profilePicUrl.substring(1)
        : profilePicUrl;
    return '${ApiService.baseUrl}/$cleanUrl';
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
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
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromSource(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromSource(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _updateProfile() async {
    if (_nameController.text.trim().isEmpty) {
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
        fullName: _nameController.text.trim(),
        profilePic: _imageFile,
      );

      if (!mounted) return;

      if (success) {
        CustomSnackBar.show(
          context,
          message: profileUpdateProvider.message ?? 'Profile updated!',
        );

        // Refresh user data after successful update
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
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        title: Text(AppStrings.generalSetting, style: FontManager.titleText()),
      ),
      body: SafeArea(
        child: Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            final userModel = userProvider.userModel;
            final profilePicUrl = userModel?.profilePic;

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 50.r,
                          backgroundImage: _imageFile != null
                              ? FileImage(_imageFile!)
                              : (profilePicUrl != null &&
                                            profilePicUrl.isNotEmpty
                                        ? NetworkImage(
                                            _buildImageUrl(profilePicUrl),
                                          )
                                        : const AssetImage(
                                            "assets/images/man.png",
                                          ))
                                    as ImageProvider,
                          onBackgroundImageError: (exception, stackTrace) {
                            // Handle network image error
                          },
                        ),
                        Positioned(
                          bottom: 0,
                          right: 4,
                          child: GestureDetector(
                            onTap: _showImagePickerOptions,
                            child: CircleAvatar(
                              radius: 16.r,
                              backgroundColor: AppColors.buttonColor,
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 18.sp,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.h8,
                    Text(
                      AppStrings.choosePhoto,
                      style: FontManager.titleText(color: AppColors.blue),
                    ),
                    AppSpacing.h40,

                    // 🧍 Name field
                    BuildTextField(
                      controller: _nameController,
                      label: AppStrings.nameLabel,
                      hint: AppStrings.nameFieldValue,
                    ),
                    AppSpacing.h12,

                    // ✉️ Email field (read-only)
                    BuildTextField(
                      controller: _emailController,
                      isReadOnly: true,

                      label: AppStrings.emailLabel,
                      hint: AppStrings.emailFieldValue,
                    ),

                    AppSpacing.h32,

                    // 💾 Save Changes Button
                    CustomLoginButton(
                      text: _isLoading
                          ? "Saving..."
                          : AppStrings.saveChangesButton,
                      isLoading: _isLoading,
                      onPressed: _isLoading ? null : _updateProfile,
                    ),
                  ],
                ),
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
