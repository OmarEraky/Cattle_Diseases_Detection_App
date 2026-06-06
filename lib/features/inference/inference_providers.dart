import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model_management/model_providers.dart';
import 'services/crop_service.dart';
import 'services/inference_service.dart';
import 'services/local_inference_service.dart';
import 'services/onnx_classifier_service.dart';
import 'services/preprocessing_service.dart';
import 'services/tflite_classifier_service.dart';
import 'services/yolo_segmentation_service.dart';

// Preprocessing Service
final preprocessingServiceProvider = Provider<PreprocessingService>((ref) {
  return PreprocessingService();
});

// Crop Service
final cropServiceProvider = Provider<CropService>((ref) {
  return CropService();
});

// TFLite Classifier Service
final tfliteClassifierServiceProvider = Provider<TfliteClassifierService>((ref) {
  final preprocess = ref.watch(preprocessingServiceProvider);
  return TfliteClassifierService(preprocess);
});

// ONNX Classifier Service
final onnxClassifierServiceProvider = Provider<OnnxClassifierService>((ref) {
  return OnnxClassifierService();
});

// YOLO Segmentation Service
final yoloSegmentationServiceProvider = Provider<YoloSegmentationService>((ref) {
  final preprocess = ref.watch(preprocessingServiceProvider);
  return YoloSegmentationService(preprocess);
});

// Inference Service orchestrator
final inferenceServiceProvider = Provider<InferenceService>((ref) {
  final fileManager = ref.watch(modelFileManagerProvider);
  final yolo = ref.watch(yoloSegmentationServiceProvider);
  final crop = ref.watch(cropServiceProvider);
  final tflite = ref.watch(tfliteClassifierServiceProvider);
  final onnx = ref.watch(onnxClassifierServiceProvider);

  return LocalInferenceService(
    fileManager: fileManager,
    yoloService: yolo,
    cropService: crop,
    tfliteClassifierService: tflite,
    onnxClassifierService: onnx,
    getRegistry: () => ref.read(modelRegistryProvider),
  );
});
