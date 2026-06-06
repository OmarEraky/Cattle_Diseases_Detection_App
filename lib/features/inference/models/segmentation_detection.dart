import 'dart:ui';
import 'body_part.dart';

class SegmentationDetection {
  final BodyPart bodyPart;
  final double confidence;
  final Rect boundingBox;
  final List<List<double>>? mask; // Optional mask representation
  final Size originalImageSize;

  SegmentationDetection({
    required this.bodyPart,
    required this.confidence,
    required this.boundingBox,
    this.mask,
    required this.originalImageSize,
  });
}
