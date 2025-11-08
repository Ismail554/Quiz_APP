import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_strings.dart';
import 'package:geography_geyser/core/font_manager.dart';
import 'package:geography_geyser/custom_widgets/custom_module.dart';
import 'package:geography_geyser/provider/module_provider/subject_provider.dart';
import 'package:geography_geyser/views/home/homepage.dart';
import 'package:geography_geyser/views/modules/select_time.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class ModuleHomeScreen extends StatefulWidget {
  final bool hideback;
  const ModuleHomeScreen({super.key, this.hideback = false});

  @override
  State<ModuleHomeScreen> createState() => _ModuleHomeScreenState();
}

class _ModuleHomeScreenState extends State<ModuleHomeScreen> {
  int? selectedIndex; // Tracks which module is selected
  final ScrollController _scrollController = ScrollController();
  bool _scrollListenerAdded = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // final List<String> moduleOptions = [
  //   AppStrings.tectonicsSubject,
  //   AppStrings.coastsSubject,
  //   AppStrings.waterCycleSubject,
  //   AppStrings.carbonCycleSubject,
  //   AppStrings.globalisationSubject,
  //   AppStrings.moduleSuperpowers,
  //   AppStrings.coastsSubject,
  //   AppStrings.waterCycleSubject,
  //   AppStrings.carbonCycleSubject,
  //   AppStrings.globalisationSubject,
  //   AppStrings.moduleSuperpowers,
  // ];

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
        child: Consumer<SubjectProvider>(
          builder: (context, provider, child) {
            // Fetch modules if list is empty
            if (provider.subjects.isEmpty && !provider.isLoading) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                provider.fetchSubjects().catchError((error) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Failed to load modules: ${error.toString()}',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                });
              });
            }

            // Setup scroll listener for pagination (only once)
            if (!_scrollListenerAdded) {
              _scrollListenerAdded = true;
              _scrollController.addListener(() {
                final currentProvider = Provider.of<SubjectProvider>(
                  context,
                  listen: false,
                );
                if (_scrollController.position.pixels >=
                    _scrollController.position.maxScrollExtent * 0.8) {
                  if (!currentProvider.isLoading && currentProvider.hasMore) {
                    currentProvider.fetchSubjects(isLoadMore: true).catchError((
                      error,
                    ) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to load more modules'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    });
                  }
                }
              });
            }

            if (provider.isLoading && provider.subjects.isEmpty) {
              return _buildShimmerLoading();
            }

            if (provider.subjects.isEmpty) {
              return const Center(child: Text("No modules found"));
            }

            return SingleChildScrollView(
              controller: _scrollController,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ...List.generate(provider.subjects.length, (index) {
                      final subject = provider.subjects[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14.0),
                        child: CustomModule(
                          text: subject.moduleName,
                          isSelected: selectedIndex == index,
                          onPressed: () {
                            setState(() {
                              selectedIndex = index;
                            });

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    SelectTime_screen(moduleId: subject.id),
                              ),
                            );
                          },
                        ),
                      );
                    }),
                    if (provider.isLoading && provider.hasMore)
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: _buildShimmerItem(),
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

  /// Build shimmer loading placeholder for initial load
  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: List.generate(
            10, // Show 6 shimmer items
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 14.0),
              child: _buildShimmerItem(),
            ),
          ),
        ),
      ),
    );
  }

  /// Build a single shimmer item matching CustomModule structure
  Widget _buildShimmerItem() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      period: const Duration(milliseconds: 1200),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: Colors.grey.shade300, width: 1),
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 2,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200.w,
              height: 20.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
