import 'package:cattle_disease_app/features/inference/models/body_part.dart';

class DiseasePrediction {
  final BodyPart bodyPart;
  final bool isDiseased;
  final double confidence; // Confidence score (0.0 to 1.0)
  final String? croppedImagePath; // Path to saved crop file
  final Duration inferenceTime; // Duration taken by inference
  final bool isMock; // If the prediction was run in Mock mode

  const DiseasePrediction({
    required this.bodyPart,
    required this.isDiseased,
    required this.confidence,
    this.croppedImagePath,
    required this.inferenceTime,
    required this.isMock,
  });

  String get label => isDiseased ? 'Diseased' : 'Healthy';

  double get confidencePercentage => confidence * 100.0;
}
