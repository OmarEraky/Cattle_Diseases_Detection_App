import 'dart:io';
import 'package:flutter/material.dart';

class ImagePreview extends StatelessWidget {
  final File imageFile;
  final double height;
  final Widget? overlay;

  const ImagePreview({
    super.key,
    required this.imageFile,
    this.height = 240,
    this.overlay,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Image.file(
            imageFile,
            width: double.infinity,
            height: height,
            fit: BoxFit.cover,
          ),
          if (overlay != null)
            Positioned.fill(child: overlay!),
        ],
      ),
    );
  }
}
