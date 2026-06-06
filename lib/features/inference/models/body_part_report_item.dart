import 'disease_prediction.dart';
import 'segmentation_detection.dart';

class BodyPartReportItem {
  final SegmentationDetection detection;
  final DiseasePrediction prediction;
  final String cropPath;
  final String? warning;

  BodyPartReportItem({
    required this.detection,
    required this.prediction,
    required this.cropPath,
    this.warning,
  });
}
