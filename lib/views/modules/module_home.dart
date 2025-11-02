import 'package:flutter/material.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_strings.dart';
import 'package:geography_geyser/core/font_manager.dart';
import 'package:geography_geyser/custom_widgets/custom_module.dart';
import 'package:geography_geyser/views/home/homepage.dart';
import 'package:geography_geyser/views/modules/select_time.dart';

class ModuleHome_screen extends StatefulWidget {
  final bool hideback;
  const ModuleHome_screen({super.key, this.hideback = false});

  @override
  State<ModuleHome_screen> createState() => _ModuleHome_screenState();
}

class _ModuleHome_screenState extends State<ModuleHome_screen> {
  int? selectedIndex; // Tracks which module is selected

  final List<String> moduleOptions = [
    AppStrings.tectonicsSubject,
    AppStrings.coastsSubject,
    AppStrings.waterCycleSubject,
    AppStrings.carbonCycleSubject,
    AppStrings.globalisationSubject,
    AppStrings.moduleSuperpowers,
    AppStrings.coastsSubject,
    AppStrings.waterCycleSubject,
    AppStrings.carbonCycleSubject,
    AppStrings.globalisationSubject,
    AppStrings.moduleSuperpowers,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        leading: widget.hideback
            ? IconButton(
                icon: InkWell(child: Icon(Icons.arrow_back)),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HomePageScreen(),
                    ),
                    (route) => false,
                  );
                },
              )
            : null,
        title: Text(
          AppStrings.selectModuleTitle,
          style: FontManager.boldHeading(color: AppColors.black),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: List.generate(moduleOptions.length, (index) {
                final moduleText = moduleOptions[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14.0),
                  child: CustomModule(
                    text: moduleText,
                    isSelected: selectedIndex == index,
                    onPressed: () {
                      setState(() {
                        selectedIndex = index;
                      });

                      // 👇 Navigate to next screen (for all modules)
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SelectTime_screen(),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
