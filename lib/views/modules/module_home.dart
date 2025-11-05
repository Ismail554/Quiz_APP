import 'package:flutter/material.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_strings.dart';
import 'package:geography_geyser/core/font_manager.dart';
import 'package:geography_geyser/custom_widgets/custom_module.dart';
import 'package:geography_geyser/provider/module_provider/subject_provider.dart';
import 'package:geography_geyser/views/home/homepage.dart';
import 'package:geography_geyser/views/modules/select_time.dart';
import 'package:provider/provider.dart';

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
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.subjects.isEmpty) {
              return const Center(child: Text("No modules found 😢"));
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
                                builder: (context) => const SelectTime_screen(),
                              ),
                            );
                          },
                        ),
                      );
                    }),
                    if (provider.isLoading && provider.hasMore)
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(),
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
}
