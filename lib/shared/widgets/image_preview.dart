import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cattle_disease_app/core/constants/app_constants.dart';

class ImagePreview extends StatelessWidget {
  final File? imageFile;
  final VoidCallback? onClear;
  final double height;

  const ImagePreview({
    super.key,
    required this.imageFile,
    this.onClear,
    this.height = 280.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (imageFile == null) {
      return Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          border: Border.all(
            color: theme.colorScheme.onSurface.withOpacity(0.12),
            style: BorderStyle.solid,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              'No Cow Image Selected',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              'Capture a photo or upload from gallery to start analysis',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            child: Image.file(
              imageFile!,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          // Gradient shadow at top
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 60,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppConstants.borderRadius),
                  topRight: Radius.circular(AppConstants.borderRadius),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Clear Button
          if (onClear != null)
            Positioned(
              top: AppConstants.paddingSmall,
              right: AppConstants.paddingSmall,
              child: ClipOval(
                child: Material(
                  color: Colors.black.withOpacity(0.6),
                  child: InkWell(
                    onTap: onClear,
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
