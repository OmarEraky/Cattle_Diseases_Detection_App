import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../analysis_mode/analysis_mode.dart';
import '../analysis_mode/analysis_mode_screen.dart';
import '../model_management/model_providers.dart';
import '../model_management/model_status_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strategy = ref.watch(selectedStrategyProvider);
    final availability = ref.watch(modelAvailabilityProvider);
    final registry = ref.watch(modelRegistryProvider);
    final theme = Theme.of(context);

    // Resolve if required models are loaded
    bool isStrategyReady = false;
    if (registry != null) {
      final requiredModels = registry.getRequiredModelsForStrategy(strategy);
      isStrategyReady = requiredModels.every((m) => availability[m.id] == true);
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.analytics_rounded, color: theme.colorScheme.primary, size: 28),
            const SizedBox(width: 8),
            const Text(
              'Cattle Health AI',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ],
        ),
        actions: [
          // Model availability indicator chip
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ModelStatusScreen()),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isStrategyReady
                    ? Colors.green.withOpacity(0.15)
                    : Colors.orange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isStrategyReady ? Colors.green : Colors.orange,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isStrategyReady ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
                    color: isStrategyReady ? Colors.green : Colors.orange,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isStrategyReady ? 'Offline Ready' : 'Setup Required',
                    style: TextStyle(
                      color: isStrategyReady ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            tooltip: 'App Settings',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome header
              Text(
                'Welcome, Breeder',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Diagnose cow diseases locally on-device.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                ),
              ),
              const SizedBox(height: 32),

              // Option 1: Full Health Report Card
              Expanded(
                child: _buildHomeCard(
                  context: context,
                  title: 'Full Cow Health Report',
                  description:
                      'Select a complete cow photo. The AI detects all body parts automatically, performs individual crop classification, and compiles a full diagnostic report.',
                  icon: Icons.assignment_rounded,
                  gradientColors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AnalysisModeScreen(
                          mode: AnalysisMode.fullReport,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Option 2: Single Body-Part Analysis Card
              Expanded(
                child: _buildHomeCard(
                  context: context,
                  title: 'Single Body-Part Analysis',
                  description:
                      'Focus on a specific target: Head, Foot, Torso, or Udder. Select the part, capture the photo, and run targeted disease classification.',
                  icon: Icons.camera_alt_rounded,
                  gradientColors: [
                    theme.colorScheme.tertiary,
                    theme.colorScheme.primary.withRed(150),
                  ],
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AnalysisModeScreen(
                          mode: AnalysisMode.singlePart,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  size: 40,
                  color: Colors.white,
                ),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
