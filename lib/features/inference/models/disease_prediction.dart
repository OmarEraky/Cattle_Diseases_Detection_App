import '../../model_management/model_format.dart';
import 'body_part.dart';
import 'crop_type.dart';

class DiseasePrediction {
  final BodyPart bodyPart;
  final String label; // "Healthy" or "Diseased"
  final double diseaseProbability; // Output of sigmoid(logit)
  final double confidence; // Confidence in classification (diseaseProbability if Diseased, 1 - diseaseProbability if Healthy)
  final String modelId;
  final String modelName;
  final ModelFormat modelFormat;
  final CropType cropType;
  final String cropPath;
  final double yoloConfidence;

  DiseasePrediction({
    required this.bodyPart,
    required this.label,
    required this.diseaseProbability,
    required this.confidence,
    required this.modelId,
    required this.modelName,
    required this.modelFormat,
    required this.cropType,
    required this.cropPath,
    required this.yoloConfidence,
  });
}
