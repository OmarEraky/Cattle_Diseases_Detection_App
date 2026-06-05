import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Cattle Disease Detection';
  static const String appVersion = '1.0.0';
  
  // Storage/Settings keys
  static const String keyUseMockInference = 'use_mock_inference';
  
  // Custom Harmony Color Palette (HSL based styling values mapped to Color)
  static const Color primaryTeal = Color(0xFF0F4C5C);      // Dark Teal
  static const Color secondaryGreen = Color(0xFF00A896);    // Premium Teal/Green
  static const Color accentLightGreen = Color(0xFF02C39A);  // Light Accent Green
  static const Color darkBackground = Color(0xFF121212);    // Dark Mode background
  static const Color surfaceColor = Color(0xFF1E1E1E);      // Dark Mode surface card
  static const Color lightBackground = Color(0xFFF7F9FB);   // Light mode background
  static const Color lightSurfaceColor = Color(0xFFFFFFFF); // Light mode surface card
  static const Color warningRed = Color(0xFFE63946);        // Warning/Diseased red
  static const Color successGreen = Color(0xFF2A9D8F);      // Healthy green
  
  // Padding & Border Radius
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double borderRadius = 16.0;
  
  // Shared text constants
  static const String mockModeWarning = 'Using mock inference engine. Real TFLite predictions are disabled.';
  static const String veterinaryDisclaimer = 
      'This result is AI-assisted and not a veterinary diagnosis. Please consult a veterinarian when possible.';
}
