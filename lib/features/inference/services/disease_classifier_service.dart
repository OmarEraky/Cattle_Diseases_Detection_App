import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:cattle_disease_app/core/constants/model_constants.dart';
import 'package:cattle_disease_app/core/errors/app_exception.dart';
import 'package:cattle_disease_app/features/inference/models/body_part.dart';
import 'package:cattle_disease_app/core/utils/image_utils.dart';
import 'dart:math' as math;

class DiseaseClassifierService {
  // Cache for body part interpreters to avoid reloading models on successive runs
  final Map<BodyPart, Interpreter> _interpreters = {};

  /// Loads the specific classifier model for a given body part.
  Future<Interpreter> _getInterpreterFor(BodyPart bodyPart) async {
    if (_interpreters.containsKey(bodyPart)) {
      return _interpreters[bodyPart]!;
    }
    
    try {
      final interpreter = await Interpreter.fromAsset(bodyPart.modelAssetPath);
      _interpreters[bodyPart] = interpreter;
      debugPrint('Classifier model for ${bodyPart.displayName} loaded successfully.');
      return interpreter;
    } catch (e) {
      throw ModelLoadException('Failed to load classifier model for ${bodyPart.displayName}: $e');
    }
  }

  /// Warm up all models to optimize offline startup performance.
  Future<void> warmUpAllModels() async {
    for (var part in BodyPart.values) {
      await _getInterpreterFor(part);
    }
  }

  /// Classifies whether a cropped image of a body part shows signs of disease.
  Future<Map<String, dynamic>> classify({
    required File croppedImageFile,
    required BodyPart bodyPart,
  }) async {
    final interpreter = await _getInterpreterFor(bodyPart);

    try {
      // 1. Get input tensor details (typically [1, 224, 224, 3])
      final inputShape = interpreter.getInputTensor(0).shape;
      final int targetWidth = inputShape[1];
      final int targetHeight = inputShape[2];

      // 2. Preprocess cropped image to Float32List
      final Float32List inputBuffer = await ImageUtils.preprocessForClassifier(
        imageFile: croppedImageFile,
        targetWidth: targetWidth,
        targetHeight: targetHeight,
      );

      final input = inputBuffer.reshape([1, targetHeight, targetWidth, 3]);

      // 3. Prepare output tensor (Support both single value sigmoid or double values softmax outputs)
      final outputShape = interpreter.getOutputTensor(0).shape;
      
      bool isDiseased = false;
      double confidence = 0.0;

      if (outputShape[1] == 1) {
        // Output format: Single float logit or probability, shape: [1, 1]
        final output = List.generate(1, (_) => List.filled(1, 0.0));
        interpreter.run(input, output);

        double rawVal = output[0][0];
        
        // If the value is outside [0.0, 1.0], apply sigmoid activation
        double prob = rawVal;
        if (rawVal < 0.0 || rawVal > 1.0) {
          prob = 1.0 / (1.0 + math.exp(-rawVal));
        }

        isDiseased = prob >= ModelConstants.diseaseThreshold;
        confidence = isDiseased ? prob : (1.0 - prob);
      } else if (outputShape[1] == 2) {
        // Output format: Two floats, shape: [1, 2] -> index 0: Healthy, index 1: Diseased
        final output = List.generate(1, (_) => List.filled(2, 0.0));
        interpreter.run(input, output);

        double val0 = output[0][0]; // Healthy logit
        double val1 = output[0][1]; // Diseased logit

        // Apply Softmax activation if the sum is not roughly 1.0
        double sum = val0 + val1;
        double prob0 = val0;
        double prob1 = val1;
        if ((sum - 1.0).abs() > 0.01) {
          double exp0 = math.exp(val0);
          double exp1 = math.exp(val1);
          double expSum = exp0 + exp1;
          prob0 = exp0 / expSum;
          prob1 = exp1 / expSum;
        }

        isDiseased = prob1 >= ModelConstants.diseaseThreshold;
        confidence = isDiseased ? prob1 : prob0;
      } else {
        throw InferenceException('Unsupported classifier output shape: ${outputShape.toString()}');
      }

      return {
        'isDiseased': isDiseased,
        'confidence': confidence,
      };
    } catch (e) {
      throw InferenceException('Classification model failed to run: $e');
    }
  }

  /// Closes all interpreters to release native resources.
  Future<void> close() async {
    for (var interpreter in _interpreters.values) {
      interpreter.close();
    }
    _interpreters.clear();
  }
}
