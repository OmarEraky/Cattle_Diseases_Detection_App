import 'package:flutter/material.dart';
import 'package:cattle_disease_app/core/constants/app_constants.dart';
import 'package:cattle_disease_app/features/image_input/image_input_screen.dart';
import 'package:cattle_disease_app/features/settings/settings_screen.dart';
import 'package:cattle_disease_app/shared/widgets/primary_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppConstants.primaryTeal.withOpacity(0.9),
              AppConstants.secondaryGreen.withOpacity(0.8),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Settings top bar button
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(
                      Icons.settings_outlined,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const SettingsScreen()),
                      );
                    },
                  ),
                ),
                const Spacer(),
                
                // App Logo Card
                Container(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/app_logo.png',
                      height: 120,
                      width: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.health_and_safety,
                          size: 100,
                          color: AppConstants.primaryTeal,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.paddingLarge),
                
                // App Title
                Text(
                  AppConstants.appName,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                
                // Subtitle/Motto
                Text(
                  'Offline Cow Health Diagnostics',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: AppConstants.paddingLarge),
                
                // Workflow features card
                Container(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        Icons.wifi_off_rounded,
                        '100% Offline operation',
                        'Runs ML inference locally. No internet needed.',
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),
                      _buildInfoRow(
                        Icons.select_all_rounded,
                        'Targeted analysis',
                        'Select specific body parts for high classification accuracy.',
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),
                      _buildInfoRow(
                        Icons.pets_rounded,
                        'Instant decision support',
                        'Helps detect diseases early in remote agricultural areas.',
                      ),
                    ],
                  ),
                ),
                
                const Spacer(flex: 2),
                
                // Start button
                PrimaryButton(
                  text: 'Start Scan Now',
                  icon: Icons.qr_code_scanner_rounded,
                  backgroundColor: Colors.white,
                  textColor: AppConstants.primaryTeal,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const ImageInputScreen()),
                    );
                  },
                ),
                const SizedBox(height: AppConstants.paddingLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
        const SizedBox(width: AppConstants.paddingMedium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
