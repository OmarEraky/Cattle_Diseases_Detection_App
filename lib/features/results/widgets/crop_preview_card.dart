import 'dart:io';
import 'package:flutter/material.dart';

class CropPreviewCard extends StatelessWidget {
  final String cropPath;
  final double size;

  const CropPreviewCard({
    super.key,
    required this.cropPath,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.file(
        File(cropPath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(Icons.broken_image_rounded, color: Colors.grey),
          );
        },
      ),
    );
  }
}
