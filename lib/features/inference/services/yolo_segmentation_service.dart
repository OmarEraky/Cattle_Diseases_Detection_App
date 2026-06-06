import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/utils/math_utils.dart';
import '../models/body_part.dart';
import '../models/segmentation_detection.dart';
import 'preprocessing_service.dart';

/// Detects cattle body parts from an image using a custom-trained
/// YOLOv8n-seg model with 4 classes: Foot, Head, Torso, Udder.
///
/// TFLite output tensor layout:
///   Output 0: [1, 40, 8400]
///     Row  0..3:  bounding box (cx, cy, w, h) — normalized [0, 1]
///     Row  4..7:  class scores for Foot(0), Head(1), Torso(2), Udder(3)
///     Row  8..39: 32 mask coefficients
///   Output 1: [1, 160, 160, 32] — mask prototypes (NHWC in TFLite)
class YoloSegmentationService {
  final PreprocessingService _preprocessingService;

  /// Number of custom body-part classes
  static const int _numClasses = 4;

  /// Total output attributes per candidate: 4 box + 4 class + 32 mask = 40
  static const int _numAttrs = 40;

  /// Number of candidate anchor positions
  static const int _numCandidates = 8400;

  /// YOLO input resolution
  static const int _inputSize = 640;

  /// Mask prototype spatial resolution
  static const int _protoSize = 160;

  /// Number of mask coefficient channels
  static const int _numMaskCoeffs = 32;

  YoloSegmentationService(this._preprocessingService);

  Future<List<SegmentationDetection>> detect({
    required File imageFile,
    required File modelFile,
    double confidenceThreshold = 0.45,
  }) async {
    Interpreter? interpreter;
    try {
      // 1. Get original image size for scaling bounding boxes
      final originalImage = await _preprocessingService.loadImage(imageFile);
      final double originalW = originalImage.width.toDouble();
      final double originalH = originalImage.height.toDouble();

      // 2. Preprocess image to shape [1, 640, 640, 3] with [0.0, 1.0] float range
      final input = await _preprocessingService.preprocessForYolo(imageFile, size: _inputSize);

      // 3. Load YOLO TFLite model
      interpreter = Interpreter.fromFile(modelFile);

      // 4. Allocate outputs
      // Output 0 (detections): shape [1, 40, 8400]
      var output0 = List.generate(
        1, (_) => List.generate(
          _numAttrs, (_) => List.generate(_numCandidates, (_) => 0.0),
        ),
      );

      // Output 1 (mask prototypes): shape [1, 160, 160, 32] (TFLite NHWC)
      var output1 = List.generate(
        1, (_) => List.generate(
          _protoSize, (_) => List.generate(
            _protoSize, (_) => List.generate(_numMaskCoeffs, (_) => 0.0),
          ),
        ),
      );

      final outputs = {0: output0, 1: output1};

      // 5. Run inference
      interpreter.runForMultipleInputs([input], outputs);

      // 6. Decode output candidates (8400 columns)
      final List<SegmentationDetection> candidates = [];

      for (int col = 0; col < _numCandidates; col++) {
        // Find best class score among Foot(0), Head(1), Torso(2), Udder(3)
        // Class scores are at rows 4, 5, 6, 7
        double maxClassScore = -1.0;
        int bestClassIdx = -1;

        for (int c = 0; c < _numClasses; c++) {
          final score = output0[0][4 + c][col];
          if (score > maxClassScore) {
            maxClassScore = score;
            bestClassIdx = c;
          }
        }

        if (maxClassScore >= confidenceThreshold) {
          // Bounding box: center_x, center_y, width, height (normalized 0-1)
          double cx = output0[0][0][col];
          double cy = output0[0][1][col];
          double w = output0[0][2][col];
          double h = output0[0][3][col];

          // Scale normalized coordinates to 640 input space
          cx *= _inputSize;
          cy *= _inputSize;
          w *= _inputSize;
          h *= _inputSize;

          // Calculate corners in 640x640 space
          final double left640 = cx - (w / 2);
          final double top640 = cy - (h / 2);

          // Scale bounding box to original image resolution
          final double scaleX = originalW / _inputSize;
          final double scaleY = originalH / _inputSize;

          final double leftOrig = max(0.0, left640 * scaleX);
          final double topOrig = max(0.0, top640 * scaleY);
          final double widthOrig = min(originalW - leftOrig, w * scaleX);
          final double heightOrig = min(originalH - topOrig, h * scaleY);

          final boundingBox = Rect.fromLTWH(leftOrig, topOrig, widthOrig, heightOrig);
          final bodyPart = _mapClassIndexToBodyPart(bestClassIdx);

          // Extract 32 mask coefficients (at rows 8..39)
          final coeffs = List.generate(
            _numMaskCoeffs, (i) => output0[0][4 + _numClasses + i][col],
          );

          // Compute 160x160 mask via dot-product of coefficients with prototypes
          // TFLite output1 layout: [1, 160, 160, 32] (NHWC)
          final List<List<double>> mask = List.generate(_protoSize, (my) {
            return List.generate(_protoSize, (mx) {
              double sum = 0.0;
              for (int i = 0; i < _numMaskCoeffs; i++) {
                sum += coeffs[i] * output1[0][my][mx][i];
              }
              return MathUtils.sigmoid(sum);
            });
          });

          candidates.add(SegmentationDetection(
            bodyPart: bodyPart,
            confidence: maxClassScore,
            boundingBox: boundingBox,
            mask: mask,
            originalImageSize: Size(originalW, originalH),
          ));
        }
      }

      // 7. Non-Maximum Suppression (NMS) to eliminate duplicate boxes
      final List<SegmentationDetection> keptDetections = _runNMS(candidates, 0.5);

      return keptDetections;
    } catch (e) {
      throw ModelInferenceException(
        'Failed to run YOLO segmentation detection',
        e.toString(),
      );
    } finally {
      interpreter?.close();
    }
  }

  /// Map YOLO class index to the corresponding BodyPart enum.
  /// Class order as defined in model metadata: {0: Foot, 1: Head, 2: Torso, 3: Udder}
  BodyPart _mapClassIndexToBodyPart(int classIndex) {
    switch (classIndex) {
      case 0:
        return BodyPart.foot;
      case 1:
        return BodyPart.head;
      case 2:
        return BodyPart.torso;
      case 3:
        return BodyPart.udder;
      default:
        throw ArgumentError('Unknown YOLO class index: $classIndex');
    }
  }

  /// Non-Maximum Suppression: eliminates overlapping detections per class.
  List<SegmentationDetection> _runNMS(
    List<SegmentationDetection> detections,
    double iouThreshold,
  ) {
    // Sort by confidence descending
    detections.sort((a, b) => b.confidence.compareTo(a.confidence));

    final List<SegmentationDetection> kept = [];

    for (var det in detections) {
      bool keep = true;
      for (var keptDet in kept) {
        // Only suppress within the same body part class
        if (det.bodyPart == keptDet.bodyPart &&
            _calculateIoU(det.boundingBox, keptDet.boundingBox) >= iouThreshold) {
          keep = false;
          break;
        }
      }
      if (keep) {
        kept.add(det);
      }
    }
    return kept;
  }

  /// Calculate Intersection over Union (IoU) of two Rects.
  double _calculateIoU(Rect a, Rect b) {
    final double left = max(a.left, b.left);
    final double top = max(a.top, b.top);
    final double right = min(a.right, b.right);
    final double bottom = min(a.bottom, b.bottom);

    final double intersectW = right - left;
    final double intersectH = bottom - top;

    if (intersectW <= 0 || intersectH <= 0) return 0.0;

    final double intersectArea = intersectW * intersectH;
    final double unionArea =
        (a.width * a.height) + (b.width * b.height) - intersectArea;

    return intersectArea / unionArea;
  }
}
