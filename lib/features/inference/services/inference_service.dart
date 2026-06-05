import 'dart:io';
import 'package:cattle_disease_app/features/inference/models/body_part.dart';
import 'package:cattle_disease_app/features/inference/models/disease_prediction.dart';

abstract class InferenceService {
  /// Loads all bundled models into memory.
  Future<void> loadModels();

  /// Runs the full inference pipeline:
  /// 1. YOLO body part segmentation to localize the selected [bodyPart].
  /// 2. Crop/Mask the detected region.
  /// 3. Run corresponding binary disease classifier.
  /// Returns a [DiseasePrediction] model.
  Future<DiseasePrediction> predict({
    required File imageFile,
    required BodyPart bodyPart,
  });

  /// Releases resources when services are terminated.
  Future<void> close();
}
