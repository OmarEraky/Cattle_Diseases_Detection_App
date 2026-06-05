import 'package:flutter/material.dart';
import 'package:cattle_disease_app/core/constants/app_constants.dart';
import 'package:cattle_disease_app/features/inference/models/disease_prediction.dart';
import 'package:cattle_disease_app/features/results/result_card.dart';
import 'package:cattle_disease_app/shared/widgets/primary_button.dart';

class ResultScreen extends StatelessWidget {
  final DiseasePrediction prediction;

  const ResultScreen({
    super.key,
    required this.prediction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Examination Result'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppConstants.primaryTeal,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              // Action to share result or export to report (placeholder)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Report sharing is coming soon!')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Result Card
              ResultCard(prediction: prediction),
              
              const SizedBox(height: AppConstants.paddingLarge),

              // Veterinary Disclaimer Panel
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  border: Border.all(
                    color: theme.colorScheme.error.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: theme.colorScheme.error,
                      size: 24,
                    ),
                    const SizedBox(width: AppConstants.paddingMedium),
                    Expanded(
                      child: Text(
                        AppConstants.veterinaryDisclaimer,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onErrorContainer,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppConstants.paddingLarge * 1.5),

              // CTA to return to main flow
              PrimaryButton(
                text: 'Start New Examination',
                icon: Icons.add_photo_alternate_outlined,
                onPressed: () {
                  // Pop back to the input/start screen
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
              const SizedBox(height: AppConstants.paddingLarge),
            ],
          ),
        ),
      ),
    );
  }
}
