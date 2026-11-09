import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/provider/local_progress_provider.dart';
import 'package:geography_geyser/routes/app_router.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.select<LocalProgressProvider, ThemeMode>(
      (p) => p.themeMode,
    );

    return ScreenUtilInit(
      designSize: const Size(402, 874),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => MaterialApp.router(
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
        title: 'Geography Geyser',
        themeMode: themeMode,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.softSky,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primaryAzure,
            primary: AppColors.primaryAzure,
            secondary: AppColors.accentGold,
            surface: Colors.white,
          ),
          textTheme: GoogleFonts.plusJakartaSansTextTheme(),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AppColors.softSky,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primaryAzure,
            brightness: Brightness.dark,
            primary: AppColors.primarySky,
            secondary: AppColors.accentGold,
          ),
          textTheme: GoogleFonts.plusJakartaSansTextTheme(),
        ),
      ),
    );
  }
}
