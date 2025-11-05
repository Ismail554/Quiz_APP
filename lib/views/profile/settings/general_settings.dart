import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/core/app_strings.dart';
import 'package:geography_geyser/core/font_manager.dart';
import 'package:geography_geyser/secure_storage/secure_storage_helper.dart';
import 'package:geography_geyser/services/api_service.dart';
import 'package:geography_geyser/views/custom_widgets/buildTextField.dart';
import 'package:geography_geyser/views/custom_widgets/custom_login_button.dart';
import 'package:geography_geyser/views/home/homepage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GeneralSettings_Screen extends StatefulWidget {
  const GeneralSettings_Screen({super.key});

  @override
  State<GeneralSettings_Screen> createState() => _GeneralSettings_ScreenState();
}

class _GeneralSettings_ScreenState extends State<GeneralSettings_Screen> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final token = await SecureStorageHelper.getToken();

      if (token == null || token.isEmpty) {
        throw Exception("Token not found! Please login again.");
      }

      final url = Uri.parse("${ApiService.baseUrl}/auth/profile-update/");
      var request = http.MultipartRequest('PATCH', url);

      //Add Bearer token
      request.headers['Authorization'] = 'Bearer $token';

      // Add text field
      request.fields['full_name'] = _nameController.text.trim();

      // Add image file if selected
      if (_imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('profile_pic', _imageFile!.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Profile updated!')),
        );

        // Optional: navigate to homepage or refresh UI
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (_) => const HomePageScreen()),
        // );
      } else {
        throw Exception(data['message'] ?? 'Update failed!');
      }
    } catch (e) {
      debugPrint("Profile update error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
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

                // 🧍 Name field
                BuildTextField(
                  controller: _nameController,
                  label: AppStrings.nameLabel,
                  hint: AppStrings.nameFieldValue,
                ),
                AppSpacing.h12,

                // ✉️ Email field (read-only)
                BuildTextField(
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
        ),
      ),
    );
  }
}
