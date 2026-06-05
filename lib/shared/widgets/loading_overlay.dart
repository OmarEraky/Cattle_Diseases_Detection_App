import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cattle_disease_app/core/constants/app_constants.dart';

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final String title;
  final String description;
  final Widget child;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    this.title = 'Analyzing Image',
    this.description = 'Running local segmentation and classification models...',
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: GestureDetector(
              onTap: () {}, // Block clicks
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  color: Colors.black.withOpacity(0.4),
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
                      padding: const EdgeInsets.all(AppConstants.paddingLarge),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 15.0,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            height: 60,
                            width: 60,
                            child: CircularProgressIndicator(
                              strokeWidth: 4.0,
                              valueColor: AlwaysStoppedAnimation<Color>(AppConstants.secondaryGreen),
                            ),
                          ),
                          const SizedBox(height: AppConstants.paddingLarge),
                          Text(
                            title,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppConstants.primaryTeal,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppConstants.paddingSmall),
                          Text(
                            description,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
