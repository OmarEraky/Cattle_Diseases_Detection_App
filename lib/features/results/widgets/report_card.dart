import 'package:flutter/material.dart';

import '../../inference/models/body_part.dart';
import '../../inference/models/body_part_report_item.dart';
import 'crop_preview_card.dart';

class ReportCard extends StatelessWidget {
  final BodyPartReportItem item;

  const ReportCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final prediction = item.prediction;
    
    final isDiseased = prediction.label == 'Diseased';
    final resultColor = isDiseased ? Colors.red.shade600 : Colors.green.shade600;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: resultColor.withOpacity(0.25),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Body part title and healthy/diseased indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _getBodyPartIcon(prediction.bodyPart),
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      prediction.bodyPart.displayName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: resultColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: resultColor.withOpacity(0.3), width: 1.5),
                  ),
                  child: Text(
                    prediction.label.toUpperCase(),
                    style: TextStyle(
                      color: resultColor,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1),

            // Content details row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CropPreviewCard(cropPath: item.cropPath, size: 84),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Model: ${prediction.modelName}',
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Crop Type: ${prediction.cropType.toManifestString()}',
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Warning Banner
            if (item.warning != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.shade700.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.amber.shade800, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.warning!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.amber.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
