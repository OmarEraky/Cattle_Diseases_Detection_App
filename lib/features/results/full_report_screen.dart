import 'dart:io';
import 'package:flutter/material.dart';

import '../../shared/widgets/image_preview.dart';
import '../inference/models/health_report.dart';
import 'widgets/report_card.dart';

class FullReportScreen extends StatelessWidget {
  final HealthReport report;

  const FullReportScreen({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalParts = report.items.length;
    final healthy = report.healthyCount;
    final diseased = report.diseasedCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Full Cow Health Report'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                // Collapsible Image Preview
                ImagePreview(
                  imageFile: File(report.originalImagePath),
                  height: 200,
                ),
                const SizedBox(height: 20),

                // Statistics Summary Row
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context: context,
                        title: 'Total Detected',
                        value: '$totalParts',
                        icon: Icons.grid_view_rounded,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context: context,
                        title: 'Healthy',
                        value: '$healthy',
                        icon: Icons.check_circle_outline_rounded,
                        color: Colors.green.shade600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context: context,
                        title: 'Diseased',
                        value: '$diseased',
                        icon: Icons.warning_amber_rounded,
                        color: Colors.red.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Report cards section
                if (totalParts == 0)
                  _buildNoDetectionsView(theme)
                else ...[
                  Text(
                    'Detected Body Parts Breakdown',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...report.items.map((item) => ReportCard(item: item)),
                ],
                const SizedBox(height: 24),

                // General strategy warnings banner (if any)
                if (report.warnings.isNotEmpty) ...[
                  Text(
                    'Analysis Notes',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...report.warnings.map((w) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline_rounded, size: 18, color: theme.colorScheme.primary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                w,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),

          // Permanent veterinary disclaimer bottom panel
          _buildDisclaimerPanel(theme),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 8.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.hintColor,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDetectionsView(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 36.0),
        child: Column(
          children: [
            Icon(Icons.zoom_out_rounded, size: 52, color: theme.hintColor.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'No body parts were detected clearly. Please try a clearer image or lower the confidence threshold.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
