import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cattle_disease_app/core/constants/app_constants.dart';
import 'package:cattle_disease_app/features/inference/models/disease_prediction.dart';

class ResultCard extends StatelessWidget {
  final DiseasePrediction prediction;

  const ResultCard({
    super.key,
    required this.prediction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHealthy = !prediction.isDiseased;
    final statusColor = isHealthy ? AppConstants.successGreen : AppConstants.warningRed;
    final statusBgColor = statusColor.withOpacity(0.08);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        side: BorderSide(
          color: statusColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Header Badge
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: statusBgColor,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius / 2),
                border: Border.all(color: statusColor.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isHealthy ? Icons.check_circle_rounded : Icons.cancel_rounded,
                    color: statusColor,
                    size: 28,
                  ),
                  const SizedBox(width: AppConstants.paddingSmall),
                  Text(
                    prediction.label.toUpperCase(),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.paddingLarge),

            // Cropped body part preview
            if (prediction.croppedImagePath != null) ...[
              Text(
                'Localized Segment Preview:',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryTeal,
                ),
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              Container(
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  child: Image.file(
                    File(prediction.croppedImagePath!),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: theme.colorScheme.surfaceVariant,
                        child: const Icon(Icons.broken_image, size: 48),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.paddingLarge),
            ],

            // Details section
            _buildDetailRow(
              context,
              'Examined Anatomy',
              prediction.bodyPart.displayName,
              icon: Icons.pets_rounded,
            ),
            const Divider(height: 24),
            
            // Confidence metric
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'AI Confidence Score',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      '${prediction.confidencePercentage.toStringAsFixed(1)}%',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: prediction.confidence,
                    minHeight: 8,
                    backgroundColor: theme.colorScheme.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            _buildDetailRow(
              context,
              'Offline Execution Time',
              '${prediction.inferenceTime.inMilliseconds} ms',
              icon: Icons.timer_outlined,
            ),
            const Divider(height: 24),

            _buildDetailRow(
              context,
              'Inference Engine',
              prediction.isMock ? 'Mock Fallback Engine' : 'On-Device TFLite (GPU/NPU)',
              icon: Icons.developer_board_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: AppConstants.primaryTeal.withOpacity(0.8)),
        const SizedBox(width: AppConstants.paddingSmall),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
