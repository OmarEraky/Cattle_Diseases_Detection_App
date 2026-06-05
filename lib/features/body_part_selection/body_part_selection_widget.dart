import 'package:flutter/material.dart';
import 'package:cattle_disease_app/core/constants/app_constants.dart';
import 'package:cattle_disease_app/features/inference/models/body_part.dart';

class BodyPartSelectionWidget extends StatelessWidget {
  final BodyPart? selectedPart;
  final ValueChanged<BodyPart> onPartSelected;

  const BodyPartSelectionWidget({
    super.key,
    required this.selectedPart,
    required this.onPartSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Target Body Part',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppConstants.primaryTeal,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Select the specific body part area you want the AI to localize & examine:',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: AppConstants.paddingMedium,
            mainAxisSpacing: AppConstants.paddingMedium,
          ),
          itemCount: BodyPart.values.length,
          itemBuilder: (context, index) {
            final part = BodyPart.values[index];
            final isSelected = selectedPart == part;

            return GestureDetector(
              onTap: () => onPartSelected(part),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppConstants.primaryTeal
                      : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  border: Border.all(
                    color: isSelected
                        ? AppConstants.secondaryGreen
                        : theme.colorScheme.outline.withOpacity(0.4),
                    width: isSelected ? 2.0 : 1.0,
                  ),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: AppConstants.primaryTeal.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    else
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getIconForBodyPart(part),
                      color: isSelected ? Colors.white : AppConstants.primaryTeal,
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      part.displayName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  IconData _getIconForBodyPart(BodyPart part) {
    switch (part) {
      case BodyPart.head:
        return Icons.face_retouching_natural_rounded;
      case BodyPart.foot:
        return Icons.pest_control_rodent_rounded; // Foot/leg style
      case BodyPart.torso:
        return Icons.texture_rounded; // Torso/Skin style
      case BodyPart.udder:
        return Icons.opacity_rounded; // Udder/Milk style
    }
  }
}
