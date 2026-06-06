import 'package:flutter/material.dart';

class ConfidenceBadge extends StatelessWidget {
  final double confidence;
  final String label;

  const ConfidenceBadge({
    super.key,
    required this.confidence,
    this.label = 'Confidence',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = (confidence * 100).toStringAsFixed(0);

    Color badgeColor;
    Color textColor;

    if (confidence >= 0.8) {
      badgeColor = Colors.green.withOpacity(0.12);
      textColor = Colors.green.shade700;
    } else if (confidence >= 0.5) {
      badgeColor = Colors.orange.withOpacity(0.12);
      textColor = Colors.orange.shade700;
    } else {
      badgeColor = Colors.red.withOpacity(0.12);
      textColor = Colors.red.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withOpacity(0.2), width: 1),
      ),
      child: Text(
        '$label: $percentage%',
        style: theme.textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
