import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../shared/widgets/loading_overlay.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/image_preview.dart';
import '../image_input/image_input_controller.dart';
import '../inference/inference_controller.dart';
import '../inference/models/body_part.dart';
import '../model_management/model_providers.dart';
import '../model_management/model_status_screen.dart';
import '../results/full_report_screen.dart';
import '../results/single_result_screen.dart';
import 'analysis_mode.dart';

class AnalysisModeScreen extends ConsumerStatefulWidget {
  final AnalysisMode mode;

  const AnalysisModeScreen({
    super.key,
    required this.mode,
  });

  @override
  ConsumerState<AnalysisModeScreen> createState() => _AnalysisModeScreenState();
}

class _AnalysisModeScreenState extends ConsumerState<AnalysisModeScreen> {
  BodyPart _selectedBodyPart = BodyPart.head;

  @override
  void initState() {
    super.initState();
    // Clear previously picked image on entering
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(imageInputControllerProvider).clear();
      ref.read(inferenceControllerProvider.notifier).reset();
    });
  }

  Future<void> _runInference(File imageFile) async {
    final strategy = ref.read(selectedStrategyProvider);
    final threshold = ref.read(yoloThresholdProvider);
    final controller = ref.read(inferenceControllerProvider.notifier);

    if (widget.mode == AnalysisMode.fullReport) {
      await controller.runFullReport(
        imageFile: imageFile,
        strategy: strategy,
        yoloConfidenceThreshold: threshold,
      );
    } else {
      await controller.runSingleBodyPart(
        imageFile: imageFile,
        bodyPart: _selectedBodyPart,
        strategy: strategy,
        yoloConfidenceThreshold: threshold,
      );
    }

    // Check if prediction completed successfully and navigate
    final state = ref.read(inferenceControllerProvider);
    if (state.errorMessage == null) {
      if (widget.mode == AnalysisMode.fullReport && state.healthReport != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => FullReportScreen(report: state.healthReport!),
          ),
        );
      } else if (widget.mode == AnalysisMode.singlePart && state.singlePrediction != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SingleResultScreen(
              prediction: state.singlePrediction!,
              originalImage: imageFile,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = ref.watch(selectedImageProvider);
    final pickerController = ref.watch(imageInputControllerProvider);
    final inferenceState = ref.watch(inferenceControllerProvider);
    
    final strategy = ref.watch(selectedStrategyProvider);
    final availability = ref.watch(modelAvailabilityProvider);
    final registry = ref.watch(modelRegistryProvider);
    final theme = Theme.of(context);

    // Resolve if required models are loaded
    bool isModelsReady = false;
    List<String> missingModelIds = [];
    if (registry != null) {
      final requiredModels = registry.getRequiredModelsForStrategy(strategy);
      // If single part mode, we only check YOLO and the classifier for the selected part!
      final modelsToCheck = widget.mode == AnalysisMode.fullReport
          ? requiredModels
          : requiredModels.where((m) => m.id == 'yolo_body_part_seg' || m.bodyPart == _selectedBodyPart);

      for (var m in modelsToCheck) {
        if (availability[m.id] != true) {
          missingModelIds.add(m.id);
        }
      }
      isModelsReady = missingModelIds.isEmpty;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mode.displayName),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20.0),
                    children: [
                      // Mode Description
                      Text(
                        widget.mode == AnalysisMode.fullReport
                            ? 'Capture the whole animal from the side view. The model will locate body parts and evaluate them.'
                            : 'Focus the camera on the target body part for a precise individual evaluation.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Part Selection (Single Part mode only)
                      if (widget.mode == AnalysisMode.singlePart) ...[
                        Text(
                          'Select Body Part',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: BodyPart.values.map((part) {
                            final isSelected = _selectedBodyPart == part;
                            return ChoiceChip(
                              label: Text(part.displayName),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _selectedBodyPart = part;
                                  });
                                }
                              },
                              avatar: Icon(
                                _getBodyPartIcon(part),
                                size: 16,
                                color: isSelected
                                    ? theme.colorScheme.onPrimary
                                    : theme.colorScheme.primary,
                              ),
                              selectedColor: theme.colorScheme.primary,
                              backgroundColor: theme.colorScheme.surfaceVariant,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? theme.colorScheme.onPrimary
                                    : theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Image Input Preview / Picker Card
                      Text(
                        'Upload Image',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      if (image == null)
                        _buildImagePickerCard(theme, pickerController)
                      else
                        Column(
                          children: [
                            ImagePreview(imageFile: image, height: 260),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton.icon(
                                  onPressed: () => pickerController.pickImage(ImageSource.camera),
                                  icon: const Icon(Icons.camera_alt_rounded),
                                  label: const Text('Retake'),
                                ),
                                const SizedBox(width: 16),
                                TextButton.icon(
                                  onPressed: () => pickerController.pickImage(ImageSource.gallery),
                                  icon: const Icon(Icons.photo_library_rounded),
                                  label: const Text('Gallery'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      const SizedBox(height: 24),

                      // Models readiness warning card
                      if (!isModelsReady)
                        _buildSetupWarningCard(theme, missingModelIds.length),
                    ],
                  ),
                ),

                // Analyze button bottom panel
                if (image != null)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      border: Border(
                        top: BorderSide(color: theme.dividerColor.withOpacity(0.08)),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (inferenceState.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Text(
                              inferenceState.errorMessage!,
                              style: TextStyle(
                                color: theme.colorScheme.error,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        PrimaryButton(
                          text: 'Analyze Cow Image',
                          icon: Icons.query_stats_rounded,
                          onPressed: !isModelsReady ? null : () => _runInference(image),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          
          // Full-screen loading overlay
          LoadingOverlay(
            isVisible: inferenceState.isLoading,
            message: widget.mode == AnalysisMode.fullReport
                ? 'Running YOLO part detection & disease classification...'
                : 'Locating body part & running disease classification...',
          ),
        ],
      ),
    );
  }

  Widget _buildImagePickerCard(ThemeData theme, ImageInputController picker) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.15),
          style: BorderStyle.values[1], // Dashed border simulated using standard container borders
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () => picker.pickImage(ImageSource.gallery),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_photo_alternate_rounded,
                size: 52,
                color: theme.colorScheme.primary.withOpacity(0.6),
              ),
              const SizedBox(height: 12),
              Text(
                'Select Cow Photo',
                style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => picker.pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_rounded),
                    label: const Text('Camera'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => picker.pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_rounded),
                    label: const Text('Gallery'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSetupWarningCard(ThemeData theme, int missingCount) {
    return Card(
      color: theme.colorScheme.errorContainer.withOpacity(0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.colorScheme.error.withOpacity(0.5), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Missing Required Models',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'You need to download $missingCount model file(s) before analyzing images offline.',
                        style: TextStyle(
                          color: theme.colorScheme.onErrorContainer,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ModelStatusScreen()),
                );
              },
              icon: const Icon(Icons.downloading_rounded),
              label: const Text('Go to Download Manager'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getBodyPartIcon(BodyPart part) {
    switch (part) {
      case BodyPart.head:
        return Icons.face_rounded;
      case BodyPart.foot:
        return Icons.pets_rounded;
      case BodyPart.torso:
        return Icons.cruelty_free_rounded;
      case BodyPart.udder:
        return Icons.opacity_rounded;
    }
  }
}
