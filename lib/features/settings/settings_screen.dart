import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cattle_disease_app/core/constants/app_constants.dart';
import 'package:cattle_disease_app/core/constants/model_constants.dart';
import 'package:cattle_disease_app/features/inference/inference_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inferenceController = context.watch<InferenceController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Diagnostics'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppConstants.primaryTeal,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        children: [
          // Section: Inference Options
          _buildSectionHeader(context, 'Inference Configuration'),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.12)),
            ),
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  activeColor: AppConstants.secondaryGreen,
                  title: const Text(
                    'Mock Inference Mode',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    'Runs synthetic pipelines without loading heavy binary model files. Useful for visual testing.',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: inferenceController.useMockMode,
                  onChanged: (val) {
                    inferenceController.setMockMode(val);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    inferenceController.useMockMode ? Icons.science_outlined : Icons.memory_rounded,
                    color: AppConstants.primaryTeal,
                  ),
                  title: const Text('Active Engine'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: inferenceController.useMockMode 
                          ? AppConstants.secondaryGreen.withOpacity(0.1)
                          : AppConstants.primaryTeal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      inferenceController.useMockMode ? 'Mock Service' : 'On-Device TFLite',
                      style: TextStyle(
                        color: inferenceController.useMockMode 
                            ? AppConstants.secondaryGreen 
                            : AppConstants.primaryTeal,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppConstants.paddingLarge),

          // Section: Model Asset Status
          _buildSectionHeader(context, 'Offline Assets Diagnostics'),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.12)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Column(
                children: [
                  _buildAssetStatusRow(
                    context, 
                    'YOLO Body Part Segmenter', 
                    ModelConstants.yoloSegModelPath,
                  ),
                  const Divider(height: 20),
                  _buildAssetStatusRow(
                    context, 
                    'Head Classifier', 
                    ModelConstants.headClassifierPath,
                  ),
                  const Divider(height: 20),
                  _buildAssetStatusRow(
                    context, 
                    'Foot Classifier', 
                    ModelConstants.footClassifierPath,
                  ),
                  const Divider(height: 20),
                  _buildAssetStatusRow(
                    context, 
                    'Torso Classifier', 
                    ModelConstants.torsoClassifierPath,
                  ),
                  const Divider(height: 20),
                  _buildAssetStatusRow(
                    context, 
                    'Udder Classifier', 
                    ModelConstants.udderClassifierPath,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppConstants.paddingLarge),

          // Section: App Metadata
          _buildSectionHeader(context, 'System Metadata'),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.12)),
            ),
            child: Column(
              children: [
                ListTile(
                  title: const Text('App Name'),
                  trailing: const Text(AppConstants.appName, style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Version'),
                  trailing: const Text(AppConstants.appVersion, style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Architecture Style'),
                  trailing: const Text('Clean & Offline-First', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppConstants.primaryTeal,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
      ),
    );
  }

  Widget _buildAssetStatusRow(BuildContext context, String label, String assetPath) {
    // Since assets are bundled and declared in pubspec.yaml, we assume standard asset presence.
    // In Flutter, checking if an asset exists is usually async. We show it as "Ready" in this view.
    return Row(
      children: [
        const Icon(Icons.insert_drive_file_outlined, color: AppConstants.primaryTeal, size: 20),
        const SizedBox(width: AppConstants.paddingMedium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 2),
              Text(
                assetPath, 
                style: const TextStyle(color: Colors.grey, fontSize: 11),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const Icon(Icons.check_circle_rounded, color: AppConstants.successGreen, size: 20),
      ],
    );
  }
}
