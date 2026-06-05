import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:cattle_disease_app/core/constants/model_constants.dart';
import 'package:cattle_disease_app/core/errors/app_exception.dart';
import 'package:cattle_disease_app/features/inference/models/body_part.dart';
import 'package:cattle_disease_app/features/inference/models/segmentation_result.dart';
import 'package:cattle_disease_app/core/utils/image_utils.dart';

class YoloSegmentationService {
  Interpreter? _interpreter;
  bool _isModelLoaded = false;

  bool get isModelLoaded => _isModelLoaded;

  /// Loads the YOLO segmentation model from assets.
  Future<void> loadModel() async {
    if (_isModelLoaded) return;
    try {
      // Load interpreter from asset file
      _interpreter = await Interpreter.fromAsset(ModelConstants.yoloSegModelPath);
      _isModelLoaded = true;
      debugPrint('YOLO Segmentation model loaded successfully.');
    } catch (e) {
      throw ModelLoadException('Failed to load YOLO model: $e');
    }
  }

  /// Runs segmentation model to find the selected body part.
  Future<SegmentationResult?> detectBodyPart({
    required File imageFile,
    required BodyPart bodyPart,
  }) async {
    if (!_isModelLoaded || _interpreter == null) {
      await loadModel();
    }

    try {
      // 1. Get input tensor details (typically [1, 640, 640, 3] or similar for YOLO segmentation)
      final inputShape = _interpreter!.getInputTensor(0).shape;
      final int targetWidth = inputShape[1];
      final int targetHeight = inputShape[2];

      // 2. Preprocess original image to Float32List
      final Float32List inputBuffer = await ImageUtils.preprocessForYolo(
        imageFile: imageFile,
        targetWidth: targetWidth,
        targetHeight: targetHeight,
      );

      // Reshape input buffer to match tensor [1, targetHeight, targetWidth, 3]
      // In Dart tflite_flutter, we can pass inputBuffer as a flat list if the structure matches
      // or we can reshape it into a multi-dimensional array.
      final input = inputBuffer.reshape([1, targetHeight, targetWidth, 3]);

      // 3. Prepare outputs map
      // YOLOv8 segmentation models typically output two tensors:
      // Tensor 0: Bounding boxes and confidence scores, shape like [1, 116, 8400] (where 116 = 4 box coords + 32 mask coefficients + 80 class scores)
      // Tensor 1: Proto masks, shape like [1, 32, 160, 160] (32 mask channels, height 160, width 160)
      
      final outputTensors = _interpreter!.getOutputTensors();
      final Map<int, Object> outputs = {};
      
      for (int i = 0; i < outputTensors.length; i++) {
        final shape = outputTensors[i].shape;
        // Allocate space depending on output tensor shape
        if (shape.length == 3) {
          // Box output: [1, attributes, anchor_count]
          outputs[i] = List.generate(
            shape[0],
            (_) => List.generate(
              shape[1],
              (_) => List.filled(shape[2], 0.0),
            ),
          );
        } else if (shape.length == 4) {
          // Proto mask output: [1, channels, height, width]
          outputs[i] = List.generate(
            shape[0],
            (_) => List.generate(
              shape[1],
              (_) => List.generate(
                shape[2],
                (_) => List.filled(shape[3], 0.0),
              ),
            ),
          );
        } else {
          // General fallback
          final int numElements = shape.fold(1, (a, b) => a * b);
          outputs[i] = List.filled(numElements, 0.0);
        }
      }

      // 4. Run model inference
      _interpreter!.runForMultipleInputs([input], outputs);

      // 5. Decode outputs to find the selected body part
      // TODO: Adjust decode logic based on your custom YOLO model output dimensions.
      // Below is a standard YOLOv8 post-processing skeleton:
      
      final boxOutput = outputs[0] as List<List<List<double>>>;
      // final protoOutput = outputs.containsKey(1) ? outputs[1] as List<List<List<List<double>>>> : null;

      final int numAttributes = boxOutput[0].length; // e.g., 116
      final int numAnchors = boxOutput[0][0].length; // e.g., 8400

      double highestConf = 0.0;
      SegmentationResult? bestResult;

      // Extract details for bodyPart.yoloClassIndex
      final int targetClassId = bodyPart.yoloClassIndex;

      // Coordinate scaling parameters: depending on YOLO version, coordinates might be center-x, center-y, width, height
      for (int anchorIdx = 0; anchorIdx < numAnchors; anchorIdx++) {
        // Classes standard index in YOLOv8-seg usually starts at index 4 (0: cx, 1: cy, 2: w, 3: h, 4..7: class scores)
        // Adjust indices if your model outputs other layouts (e.g. 0..3 boxes, 4: confidence, 5..8 class scores)
        final double classScore = boxOutput[0][4 + targetClassId][anchorIdx];

        if (classScore > ModelConstants.detectionConfidenceThreshold && classScore > highestConf) {
          highestConf = classScore;

          // Bounding box values
          double cx = boxOutput[0][0][anchorIdx];
          double cy = boxOutput[0][1][anchorIdx];
          double w = boxOutput[0][2][anchorIdx];
          double h = boxOutput[0][3][anchorIdx];

          // Convert center coordinates to relative top-left [0.0 to 1.0]
          // Assuming model outputs coordinates relative to model size (e.g., 640x640)
          double rx = (cx - w / 2) / targetWidth;
          double ry = (cy - h / 2) / targetHeight;
          double rw = w / targetWidth;
          double rh = h / targetHeight;

          bestResult = SegmentationResult(
            classIndex: targetClassId,
            label: bodyPart.displayName,
            confidence: classScore,
            x: rx.clamp(0.0, 1.0),
            y: ry.clamp(0.0, 1.0),
            width: rw.clamp(0.0, 1.0 - rx),
            height: rh.clamp(0.0, 1.0 - ry),
          );
        }
      }

      return bestResult;
    } catch (e) {
      throw InferenceException('Failed to process YOLO segmentation: $e');
    }
  }

  /// Closes interpreter to free native memory.
  Future<void> close() async {
    _interpreter?.close();
    _interpreter = null;
    _isModelLoaded = false;
  }
}
