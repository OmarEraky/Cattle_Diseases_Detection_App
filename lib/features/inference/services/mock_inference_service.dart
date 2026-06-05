import 'dart:io';
import 'dart:math';
import 'package:cattle_disease_app/features/inference/models/body_part.dart';
import 'package:cattle_disease_app/features/inference/models/disease_prediction.dart';
import 'package:cattle_disease_app/features/inference/services/inference_service.dart';
import 'package:cattle_disease_app/core/utils/image_utils.dart';

class MockInferenceService implements InferenceService {
  final Random _random = Random();

  @override
  Future<void> loadModels() async {
    // Simulate model load latency
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<DiseasePrediction> predict({
    required File imageFile,
    required BodyPart bodyPart,
  }) async {
    final startTime = DateTime.now();
    
    // Simulate processing time of segmentation & classification (1.2 - 2.0 seconds)
    final int delayMs = 1200 + _random.nextInt(800);
    await Future.delayed(Duration(milliseconds: delayMs));

    // Crop a central region of the image to simulate YOLO localization cropping
    // This lets us display a real cropped image preview in mock mode!
    String? croppedPath;
    try {
      final croppedFile = await ImageUtils.cropBodyPart(
        originalImage: imageFile,
        xPercent: 0.25,
        yPercent: 0.25,
        widthPercent: 0.50,
        heightPercent: 0.50,
      );
      croppedPath = croppedFile.path;
    } catch (e) {
      // Fallback to original image if cropping fails in mock mode
      croppedPath = imageFile.path;
    }

    // Dynamic mock logic:
    // Generate healthy or diseased result randomly
    final double confidence = 0.65 + (_random.nextDouble() * 0.30); // 65% to 95%
    final bool isDiseased = _random.nextBool();

    final endTime = DateTime.now();
    final inferenceDuration = endTime.difference(startTime);

    return DiseasePrediction(
      bodyPart: bodyPart,
      isDiseased: isDiseased,
      confidence: confidence,
      croppedImagePath: croppedPath,
      inferenceTime: inferenceDuration,
      isMock: true,
    );
  }

  @override
  Future<void> close() async {
    // No-op
  }
}
