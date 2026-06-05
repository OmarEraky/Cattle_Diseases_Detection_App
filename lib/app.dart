import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cattle_disease_app/core/constants/app_constants.dart';
import 'package:cattle_disease_app/features/home/home_screen.dart';
import 'package:cattle_disease_app/features/image_input/image_input_controller.dart';
import 'package:cattle_disease_app/features/inference/inference_controller.dart';

class CattleDiseaseApp extends StatelessWidget {
  const CattleDiseaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ImageInputController>(
          create: (_) => ImageInputController(),
        ),
        ChangeNotifierProvider<InferenceController>(
          create: (_) => InferenceController(),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.light, // Configurable, default to clean light theme
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppConstants.primaryTeal,
            primary: AppConstants.primaryTeal,
            secondary: AppConstants.secondaryGreen,
            tertiary: AppConstants.accentLightGreen,
            background: AppConstants.lightBackground,
            surface: AppConstants.lightSurfaceColor,
            error: AppConstants.warningRed,
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppConstants.primaryTeal,
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shadowColor: Colors.black.withOpacity(0.08),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
            ),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
