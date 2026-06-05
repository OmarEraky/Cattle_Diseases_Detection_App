import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cattle_disease_app/features/inference/models/body_part.dart';
import 'package:cattle_disease_app/features/inference/models/disease_prediction.dart';
import 'package:cattle_disease_app/features/inference/services/inference_service.dart';
import 'package:cattle_disease_app/features/inference/services/yolo_segmentation_service.dart';
import 'package:cattle_disease_app/features/inference/services/disease_classifier_service.dart';
import 'package:cattle_disease_app/core/utils/image_utils.dart';
import 'package:cattle_disease_app/core/errors/app_exception.dart';

class TfliteInferenceService implements InferenceService {
  final YoloSegmentationService _yoloService = YoloSegmentationService();
  final DiseaseClassifierService _classifierService = DiseaseClassifierService();

  @override
  Future<void> loadModels() async {
    try {
      // Load segmentation model
      await _yoloService.loadModel();
      // Classifier models are lazily loaded or can be warmed up.
      // Warm up is skipped for faster app startup but can be called if needed.
    } catch (e) {
      throw ModelLoadException('Error loading TFLite models: $e');
    }
  }

  @override
  Future<DiseasePrediction> predict({
    required File imageFile,
    required BodyPart bodyPart,
  }) async {
    final startTime = DateTime.now();

    try {
      // 1. Run YOLO body part segmentation to localize the selected body part
      final segmentation = await _yoloService.detectBodyPart(
        imageFile: imageFile,
        bodyPart: bodyPart,
      );

      // 2. If selected body part is not found, throw error
      if (segmentation == null) {
        throw InferenceException(
          'Could not detect the selected ${bodyPart.displayName} in this image. Please try taking a clearer, closer photo.',
        );
      }

      debugPrint('Localized body part details: $segmentation');

      // 3. Crop or mask the detected body part region
      final File croppedFile = await ImageUtils.cropBodyPart(
        originalImage: imageFile,
        xPercent: segmentation.x,
        yPercent: segmentation.y,
        widthPercent: segmentation.width,
        heightPercent: segmentation.height,
      );

      // 4. Run binary disease classifier on cropped region
      final result = await _classifierService.classify(
        croppedImageFile: croppedFile,
        bodyPart: bodyPart,
      );

      final isDiseased = result['isDiseased'] as bool;
      final confidence = result['confidence'] as double;
      
      final endTime = DateTime.now();
      final inferenceDuration = endTime.difference(startTime);

      // 5. Return prediction outcome
      return DiseasePrediction(
        bodyPart: bodyPart,
        isDiseased: isDiseased,
        confidence: confidence,
        croppedImagePath: croppedFile.path,
        inferenceTime: inferenceDuration,
        isMock: false,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw InferenceException('Inference pipeline execution error: $e');
    }
  }

  @override
  Future<void> close() async {
    await _yoloService.close();
    await _classifierService.close();
  }
}
