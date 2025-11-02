import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geography_geyser/provider/auth_provider.dart';
import 'package:geography_geyser/splash/splash_screen.dart';
import 'package:geography_geyser/views/auth/forgot_pass/congratulations.dart';
import 'package:geography_geyser/views/auth/forgot_pass/verify_screen.dart';
import 'package:geography_geyser/views/auth/login/login.dart';
import 'package:geography_geyser/views/auth/sign_up/geo_sign_up.dart';
import 'package:geography_geyser/views/modules/quiz_complete.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider()),
    ], 
    child: const MyApp(),)
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Geography Geyser',
        theme: ThemeData(),
        home: child,
      ),
      child: SplashScreen(),
    );
  }
}
