import 'dart:io';
import '../../../core/errors/app_exception.dart';
import '../models/body_part.dart';
import '../models/crop_type.dart';
import '../models/disease_prediction.dart';

class OnnxClassifierService {
  Future<DiseasePrediction> classify({
    required File imageFile,
    required File modelFile,
    required String modelId,
    required String modelName,
    required BodyPart bodyPart,
    required CropType cropType,
    required double yoloConfidence,
  }) async {
    throw UnsupportedFormatException(
      'ONNX runtime is not supported on this platform.',
      'To perform inference offline, please go to settings and switch your model strategy to '
      '"EfficientNet-B0 Mobile" or manually select TFLite classifiers.',
    );
  }
}
