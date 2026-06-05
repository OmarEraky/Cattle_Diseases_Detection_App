import 'package:flutter/material.dart';
import 'package:cattle_disease_app/core/constants/app_constants.dart';

class AppErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String retryText;

  const AppErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.retryText = 'Retry',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      margin: const EdgeInsets.symmetric(vertical: AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppConstants.warningRed.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: AppConstants.warningRed.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppConstants.warningRed,
            size: 48.0,
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Text(
            'Analysis Error',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppConstants.warningRed,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: AppConstants.paddingMedium),
            TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: AppConstants.warningRed,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingMedium,
                  vertical: AppConstants.paddingSmall,
                ),
              ),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: Text(
                retryText,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
