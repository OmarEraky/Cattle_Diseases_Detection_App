import 'package:flutter/material.dart';
import 'features/home/home_screen.dart';

class CattleDiseaseApp extends StatelessWidget {
  const CattleDiseaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Premium agricultural color scheme using deep greens, warm accents, and slate shades
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1E5631), // Deep Forest Green
      primary: const Color(0xFF1E5631),
      secondary: const Color(0xFF4C9A2A), // Vibrant Foliage Green
      tertiary: const Color(0xFFD4AF37), // Warm Straw Gold
      surface: const Color(0xFFF9FBF9),
      background: const Color(0xFFF4F7F4),
      error: const Color(0xFFBA1A1A),
    );

    return MaterialApp(
      title: 'Cattle Health AI',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system, // Adapt dynamically to user OS preference
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        fontFamily: 'Inter', // Sleek modern typography
        scaffoldBackgroundColor: colorScheme.background,
        cardTheme: CardThemeData(
          color: colorScheme.surface,
          elevation: 2,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            color: Color(0xFF1B1D1B),
          ),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: colorScheme.primary,
          inactiveTrackColor: colorScheme.primary.withOpacity(0.15),
          thumbColor: colorScheme.primary,
          overlayColor: colorScheme.primary.withOpacity(0.12),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E5631),
          brightness: Brightness.dark,
        ),
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
