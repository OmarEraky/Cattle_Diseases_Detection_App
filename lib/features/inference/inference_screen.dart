import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cattle_disease_app/core/constants/app_constants.dart';
import 'package:cattle_disease_app/features/inference/inference_controller.dart';
import 'package:cattle_disease_app/features/inference/inference_state.dart';
import 'package:cattle_disease_app/features/results/result_screen.dart';
import 'package:cattle_disease_app/shared/widgets/app_error_widget.dart';
import 'package:cattle_disease_app/shared/widgets/loading_overlay.dart';

class InferenceScreen extends StatefulWidget {
  final File imageFile;

  const InferenceScreen({
    super.key,
    required this.imageFile,
  });

  @override
  State<InferenceScreen> createState() => _InferenceScreenState();
}

class _InferenceScreenState extends State<InferenceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runAnalysis();
    });
  }

  Future<void> _runAnalysis() async {
    final controller = context.read<InferenceController>();
    final result = await controller.analyzeImage(widget.imageFile);
    
    if (mounted && result != null) {
      // Navigate to results screen, replacing the loading screen in the backstack
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ResultScreen(prediction: result),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inferenceState = context.watch<InferenceController>().state;
    final selectedPartName = context.read<InferenceController>().selectedBodyPart?.displayName ?? 'Body Part';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analyzing Health'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppConstants.primaryTeal,
      ),
      body: LoadingOverlay(
        isLoading: inferenceState.isLoading,
        title: 'Running Offline AI',
        description: 'Localizing $selectedPartName segment & classifying health state...',
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (inferenceState.isFailure) ...[
                  AppErrorWidget(
                    message: inferenceState.errorMessage ?? 'An unexpected error occurred.',
                    onRetry: _runAnalysis,
                  ),
                  const SizedBox(height: AppConstants.paddingLarge),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Go Back'),
                  ),
                ] else if (inferenceState.isIdle) ...[
                  const Center(
                    child: Text('Preparing analysis pipeline...'),
                  ),
                ] else ...[
                  // Visual status card during loading transitions
                  Card(
                    elevation: 0,
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(AppConstants.paddingLarge),
                      child: Column(
                        children: [
                          Icon(
                            Icons.memory_rounded,
                            size: 64,
                            color: AppConstants.primaryTeal,
                          ),
                          SizedBox(height: AppConstants.paddingMedium),
                          Text(
                            'Executing On-Device Models',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.primaryTeal,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Model inference utilizes device CPU/GPU and operates 100% offline.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
