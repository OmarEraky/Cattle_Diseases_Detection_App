import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/math_utils.dart';
import '../../model_management/model_format.dart';
import '../models/body_part.dart';
import '../models/crop_type.dart';
import '../models/disease_prediction.dart';
import 'preprocessing_service.dart';

class TfliteClassifierService {
  final PreprocessingService _preprocessingService;

  TfliteClassifierService(this._preprocessingService);

  Future<DiseasePrediction> classify({
    required File imageFile,
    required File modelFile,
    required String modelId,
    required String modelName,
    required BodyPart bodyPart,
    required CropType cropType,
    required double yoloConfidence,
  }) async {
    Interpreter? interpreter;
    try {
      interpreter = Interpreter.fromFile(modelFile);

      // Preprocess image to NHWC [1, 224, 224, 3] with ImageNet normalization
      final input = await _preprocessingService.preprocessForClassifier(imageFile);

      // Allocate output buffer for single logit: shape [1, 1]
      var output = List.generate(1, (_) => List.generate(1, (_) => 0.0));

      // Run inference
      interpreter.run(input, output);

      final double logit = output[0][0];
      final double probability = MathUtils.sigmoid(logit);

      final bool isDiseased = probability >= 0.5;
      final String label = isDiseased ? 'Diseased' : 'Healthy';
      final double confidence = isDiseased ? probability : (1.0 - probability);

      return DiseasePrediction(
        bodyPart: bodyPart,
        label: label,
        diseaseProbability: probability,
        confidence: confidence,
        modelId: modelId,
        modelName: modelName,
        modelFormat: ModelFormat.tflite,
        cropType: cropType,
        cropPath: imageFile.path,
        yoloConfidence: yoloConfidence,
      );
    } catch (e) {
      throw ModelInferenceException(
        'Failed to run TFLite disease classifier for $bodyPart ($modelId)',
        e.toString(),
      );
    } finally {
      interpreter?.close();
    }
  }
}
