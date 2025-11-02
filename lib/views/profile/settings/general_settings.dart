import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/core/app_strings.dart';
import 'package:geography_geyser/core/font_manager.dart';
import 'package:geography_geyser/views/custom_widgets/buildTextField.dart';
import 'package:geography_geyser/views/custom_widgets/custom_login_button.dart';
import 'package:geography_geyser/views/home/homepage.dart';
import 'package:image_picker/image_picker.dart';

class GeneralSettings_Screen extends StatefulWidget {
  const GeneralSettings_Screen({super.key});

  @override
  State<GeneralSettings_Screen> createState() => _GeneralSettings_ScreenState();
}

class _GeneralSettings_ScreenState extends State<GeneralSettings_Screen> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      // Try gallery first
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
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
      debugPrint('Gallery error: $e');

      // If gallery fails, try camera as fallback
      try {
        final XFile? pickedFile = await _picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 80,
        );

        if (pickedFile != null) {
          setState(() {
            _imageFile = File(pickedFile.path);
          });
        }
      } catch (cameraError) {
        debugPrint('Camera error: $cameraError');
        // Show user-friendly error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Unable to access camera or gallery. Please check permissions.',
              ),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'Settings',
                textColor: Colors.white,
                onPressed: () {
                  // You can add navigation to app settings here
                },
              ),
            ),
          );
        }
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
      debugPrint('${source.name} error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Unable to access ${source.name}. Please check permissions.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
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
        child: SingleChildScrollView(
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
                          : const AssetImage("assets/images/man.png")
                                as ImageProvider,
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
                // name field
                BuildTextField(
                  label: AppStrings.nameLabel,
                  hint: AppStrings.nameFieldValue,
                ),
                AppSpacing.h12,
                // email field
                BuildTextField(
                  isReadOnly: true,
                  label: AppStrings.emailLabel,
                  hint: AppStrings.emailFieldValue,
                ),
                AppSpacing.h8,
                Divider(),
                AppSpacing.h6,
                //Enter password field
                BuildTextField(
                  label: AppStrings.enterPassword,
                  hint: AppStrings.currentPasswordEditLabel,
                ),
                AppSpacing.h4,
                Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 12),

                    AppSpacing.w6,
                    Expanded(
                      child: Text(
                        AppStrings.genChangeWarning,
                        style: FontManager.subSubtitleText(),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ],
                ),
                AppSpacing.h32,
                CustomLoginButton(
                  text: AppStrings.saveChangesButton,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomePageScreen()),
                    );
                    debugPrint("Save Changes Pressed");
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
