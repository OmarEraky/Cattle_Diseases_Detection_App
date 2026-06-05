import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cattle_disease_app/core/constants/app_constants.dart';
import 'package:cattle_disease_app/features/image_input/image_input_controller.dart';
import 'package:cattle_disease_app/features/inference/inference_controller.dart';
import 'package:cattle_disease_app/features/body_part_selection/body_part_selection_widget.dart';
import 'package:cattle_disease_app/features/inference/inference_screen.dart';
import 'package:cattle_disease_app/shared/widgets/image_preview.dart';
import 'package:cattle_disease_app/shared/widgets/primary_button.dart';

class ImageInputScreen extends StatefulWidget {
  const ImageInputScreen({super.key});

  @override
  State<ImageInputScreen> createState() => _ImageInputScreenState();
}

class _ImageInputScreenState extends State<ImageInputScreen> {
  @override
  void initState() {
    super.initState();
    // Reset selection when landing back on this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InferenceController>().resetSelection();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inputController = context.watch<ImageInputController>();
    final inferenceController = context.watch<InferenceController>();

    final hasImage = inputController.selectedImage != null;
    final hasPart = inferenceController.selectedBodyPart != null;
    final isReadyToAnalyze = hasImage && hasPart;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Health Examination'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppConstants.primaryTeal,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Mock Mode Banner Indicator
              if (inferenceController.useMockMode)
                Container(
                  margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingMedium,
                    vertical: AppConstants.paddingSmall,
                  ),
                  decoration: BoxDecoration(
                    color: AppConstants.secondaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    border: Border.all(
                      color: AppConstants.secondaryGreen.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.science_outlined,
                        color: AppConstants.secondaryGreen,
                        size: 20,
                      ),
                      const SizedBox(width: AppConstants.paddingSmall),
                      Expanded(
                        child: Text(
                          'Mock Mode Active (No real TFLite files required)',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppConstants.primaryTeal,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Image Preview
              ImagePreview(
                imageFile: inputController.selectedImage,
                onClear: inputController.clearImage,
              ),
              const SizedBox(height: AppConstants.paddingMedium),

              // Source Selectors
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                        ),
                      ),
                      onPressed: inputController.isPicking
                          ? null
                          : () => inputController.pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Take Photo'),
                    ),
                  ),
                  const SizedBox(width: AppConstants.paddingMedium),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                        ),
                      ),
                      onPressed: inputController.isPicking
                          ? null
                          : () => inputController.pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('From Gallery'),
                    ),
                  ),
                ],
              ),
              
              if (inputController.errorMessage != null) ...[
                const SizedBox(height: AppConstants.paddingMedium),
                Text(
                  inputController.errorMessage!,
                  style: const TextStyle(
                    color: AppConstants.warningRed,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              
              const SizedBox(height: AppConstants.paddingLarge),

              // Body Part Selector Widget
              BodyPartSelectionWidget(
                selectedPart: inferenceController.selectedBodyPart,
                onPartSelected: (part) {
                  inferenceController.selectBodyPart(part);
                },
              ),

              const SizedBox(height: AppConstants.paddingLarge * 1.5),

              // CTA Action Button
              PrimaryButton(
                text: 'Analyze Cow Health',
                icon: Icons.analytics_outlined,
                onPressed: isReadyToAnalyze
                    ? () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => InferenceScreen(
                              imageFile: inputController.selectedImage!,
                            ),
                          ),
                        );
                      }
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
