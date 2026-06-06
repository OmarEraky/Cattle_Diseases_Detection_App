import 'dart:io';
import 'dart:ui';
import '../../../core/errors/app_exception.dart';
import '../../model_management/model_file_manager.dart';
import '../../model_management/model_registry.dart';
import '../../model_management/model_strategy.dart';
import '../../model_management/model_format.dart';
import '../models/body_part.dart';
import '../models/crop_type.dart';
import '../models/disease_prediction.dart';
import '../models/health_report.dart';
import '../models/body_part_report_item.dart';
import '../models/segmentation_detection.dart';
import 'crop_service.dart';
import 'inference_service.dart';
import 'onnx_classifier_service.dart';
import 'tflite_classifier_service.dart';
import 'yolo_segmentation_service.dart';

class LocalInferenceService implements InferenceService {
  final ModelFileManager _fileManager;
  final YoloSegmentationService _yoloService;
  final CropService _cropService;
  final TfliteClassifierService _tfliteClassifierService;
  final OnnxClassifierService _onnxClassifierService;
  final ModelRegistry? Function() _getRegistry;

  LocalInferenceService({
    required ModelFileManager fileManager,
    required YoloSegmentationService yoloService,
    required CropService cropService,
    required TfliteClassifierService tfliteClassifierService,
    required OnnxClassifierService onnxClassifierService,
    required ModelRegistry? Function() getRegistry,
  })  : _fileManager = fileManager,
        _yoloService = yoloService,
        _cropService = cropService,
        _tfliteClassifierService = tfliteClassifierService,
        _onnxClassifierService = onnxClassifierService,
        _getRegistry = getRegistry;

  @override
  Future<HealthReport> analyzeFullReport({
    required File imageFile,
    required ModelStrategy strategy,
    double yoloConfidenceThreshold = 0.45,
  }) async {
    final registry = _getRegistry();
    if (registry == null) {
      throw ManifestException('Model registry is not initialized. Please fetch manifest first.');
    }

    // 1. Check if YOLO model file is available
    final yoloConfig = registry.getModelConfig('yolo_body_part_seg');
    if (yoloConfig == null) {
      throw ManifestException('YOLO configuration not found in manifest.');
    }
    
    final yoloModelFile = await _fileManager.getModelFile(yoloConfig.id);

    // 2. Run YOLO locally to detect body parts
    final detections = await _yoloService.detect(
      imageFile: imageFile,
      modelFile: yoloModelFile,
      confidenceThreshold: yoloConfidenceThreshold,
    );

    // 3. Filter detections by threshold (service already filtered, but we verify)
    final filteredDetections = detections
        .where((d) => d.confidence >= yoloConfidenceThreshold)
        .toList();

    final reportItems = <BodyPartReportItem>[];
    final warnings = <String>[];
    int healthyCount = 0;
    int diseasedCount = 0;

    // 4. Run disease classifiers on detected body parts
    for (var detection in filteredDetections) {
      final bodyPart = detection.bodyPart;
      
      // Resolve classifier for this part
      final classifierConfig = registry.getActiveClassifier(bodyPart: bodyPart, strategy: strategy);
      if (classifierConfig == null) {
        warnings.add('No classifier configuration found for $bodyPart.');
        continue;
      }

      // Check format and availability
      final classifierFile = await _fileManager.getModelFile(classifierConfig.id);

      // Crop detected rectangle
      final cropResult = await _cropService.crop(
        originalImageFile: imageFile,
        boundingBox: detection.boundingBox,
        requiredCropType: classifierConfig.cropType ?? CropType.rectangular,
        mask: detection.mask,
      );

      if (cropResult.warning != null) {
        warnings.add('[${bodyPart.displayName}] ${cropResult.warning}');
      }

      // Run disease classifier
      DiseasePrediction prediction;
      if (classifierConfig.preferredFormat == ModelFormat.tflite) {
        prediction = await _tfliteClassifierService.classify(
          imageFile: File(cropResult.cropPath),
          modelFile: classifierFile,
          modelId: classifierConfig.id,
          modelName: classifierConfig.modelName ?? classifierConfig.id,
          bodyPart: bodyPart,
          cropType: cropResult.cropTypeUsed,
          yoloConfidence: detection.confidence,
        );
      } else {
        // ONNX
        prediction = await _onnxClassifierService.classify(
          imageFile: File(cropResult.cropPath),
          modelFile: classifierFile,
          modelId: classifierConfig.id,
          modelName: classifierConfig.modelName ?? classifierConfig.id,
          bodyPart: bodyPart,
          cropType: cropResult.cropTypeUsed,
          yoloConfidence: detection.confidence,
        );
      }

      if (prediction.label == 'Diseased') {
        diseasedCount++;
      } else {
        healthyCount++;
      }

      reportItems.add(BodyPartReportItem(
        detection: detection,
        prediction: prediction,
        cropPath: cropResult.cropPath,
        warning: cropResult.warning,
      ));
    }

    return HealthReport(
      originalImagePath: imageFile.path,
      strategy: strategy,
      items: reportItems,
      healthyCount: healthyCount,
      diseasedCount: diseasedCount,
      warnings: warnings,
    );
  }

  @override
  Future<DiseasePrediction> analyzeSingleBodyPart({
    required File imageFile,
    required BodyPart bodyPart,
    required ModelStrategy strategy,
    double yoloConfidenceThreshold = 0.45,
  }) async {
    final registry = _getRegistry();
    if (registry == null) {
      throw ManifestException('Model registry is not initialized. Please fetch manifest first.');
    }

    // 1. Resolve YOLO and Classifier configuration
    final yoloConfig = registry.getModelConfig('yolo_body_part_seg');
    final classifierConfig = registry.getActiveClassifier(bodyPart: bodyPart, strategy: strategy);

    if (yoloConfig == null) {
      throw ManifestException('YOLO configuration not found in manifest.');
    }
    if (classifierConfig == null) {
      throw ManifestException('No classifier config resolved for body part: ${bodyPart.displayName}.');
    }

    // Get files (throws ModelDownloadException if missing)
    final yoloModelFile = await _fileManager.getModelFile(yoloConfig.id);
    final classifierFile = await _fileManager.getModelFile(classifierConfig.id);

    // 2. Run YOLO segmentation locally
    final detections = await _yoloService.detect(
      imageFile: imageFile,
      modelFile: yoloModelFile,
      confidenceThreshold: yoloConfidenceThreshold,
    );

    // 3. Filter by selected body part and threshold
    final matchingDetections = detections
        .where((d) => d.bodyPart == bodyPart && d.confidence >= yoloConfidenceThreshold)
        .toList();

    if (matchingDetections.isEmpty) {
      throw ImageProcessingException(
        'Could not detect "${bodyPart.displayName}" in this image. Please ensure the image clearly shows a cow with the selected body part visible, or try lowering the confidence threshold.',
      );
    }

    // 4. If multiple detections, select highest-confidence
    matchingDetections.sort((a, b) => b.confidence.compareTo(a.confidence));
    final bestDetection = matchingDetections.first;

    // 5. Crop body part
    final cropResult = await _cropService.crop(
      originalImageFile: imageFile,
      boundingBox: bestDetection.boundingBox,
      requiredCropType: classifierConfig.cropType ?? CropType.rectangular,
      mask: bestDetection.mask,
    );

    // 6. Run disease classifier
    if (classifierConfig.preferredFormat == ModelFormat.tflite) {
      return _tfliteClassifierService.classify(
        imageFile: File(cropResult.cropPath),
        modelFile: classifierFile,
        modelId: classifierConfig.id,
        modelName: classifierConfig.modelName ?? classifierConfig.id,
        bodyPart: bodyPart,
        cropType: cropResult.cropTypeUsed,
        yoloConfidence: bestDetection.confidence,
      );
    } else {
      // ONNX
      return _onnxClassifierService.classify(
        imageFile: File(cropResult.cropPath),
        modelFile: classifierFile,
        modelId: classifierConfig.id,
        modelName: classifierConfig.modelName ?? classifierConfig.id,
        bodyPart: bodyPart,
        cropType: cropResult.cropTypeUsed,
        yoloConfidence: bestDetection.confidence,
      );
    }
  }
}
