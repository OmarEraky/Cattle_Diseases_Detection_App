import 'dart:io';
import 'package:flutter/material.dart';

import '../../shared/widgets/image_preview.dart';
import '../inference/models/disease_prediction.dart';

class SingleResultScreen extends StatelessWidget {
  final DiseasePrediction prediction;
  final File originalImage;

  const SingleResultScreen({
    super.key,
    required this.prediction,
    required this.originalImage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final isDiseased = prediction.label == 'Diseased';
    final resultColor = isDiseased ? Colors.red.shade600 : Colors.green.shade600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Single Part Analysis'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                // Original image preview
                ImagePreview(imageFile: originalImage, height: 200),
                const SizedBox(height: 24),

                // Main prediction card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(color: resultColor.withOpacity(0.3), width: 2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text(
                          prediction.bodyPart.displayName.toUpperCase(),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Crop preview inside card
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: theme.dividerColor.withOpacity(0.15), width: 2),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.file(
                            File(prediction.cropPath),
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Outcome labels
                        Text(
                          prediction.label.toUpperCase(),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: resultColor,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Model execution metadata card
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Model Metadata',
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const Divider(height: 20),
                        _buildMetaRow('Model Config ID', prediction.modelId, theme),
                        _buildMetaRow('Model Name', prediction.modelName, theme),
                        _buildMetaRow('Preferred Format', prediction.modelFormat.toManifestString().toUpperCase(), theme),
                        _buildMetaRow('Applied Crop Type', prediction.cropType.toManifestString(), theme),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          
          // Veterinary disclaimer
          _buildDisclaimerPanel(theme),
        ],
      ),
    );
  }

  Widget _buildMetaRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
          Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDisclaimerPanel(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
        border: Border(
          top: BorderSide(color: theme.dividerColor.withOpacity(0.08)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_rounded, color: theme.colorScheme.primary, size: 22),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'This result is AI-assisted and not a veterinary diagnosis. Please consult a veterinarian when possible.',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
