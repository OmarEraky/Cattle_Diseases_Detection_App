import 'dart:io';
import '../../model_management/model_strategy.dart';
import '../models/body_part.dart';
import '../models/disease_prediction.dart';
import '../models/health_report.dart';

abstract class InferenceService {
  Future<HealthReport> analyzeFullReport({
    required File imageFile,
    required ModelStrategy strategy,
    double yoloConfidenceThreshold = 0.45,
  });

  Future<DiseasePrediction> analyzeSingleBodyPart({
    required File imageFile,
    required BodyPart bodyPart,
    required ModelStrategy strategy,
    double yoloConfidenceThreshold = 0.45,
  });
}
