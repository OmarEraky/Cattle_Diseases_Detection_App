class ModelConstants {
  // Asset paths
  static const String yoloSegModelPath = 'assets/models/yolo_body_part_seg.tflite';
  static const String headClassifierPath = 'assets/models/head_classifier.tflite';
  static const String footClassifierPath = 'assets/models/foot_classifier.tflite';
  static const String torsoClassifierPath = 'assets/models/torso_classifier.tflite';
  static const String udderClassifierPath = 'assets/models/udder_classifier.tflite';

  // Image Input sizes for classifier
  static const int classifierInputSize = 224; // 224x224 RGB
  
  // Model thresholds
  static const double detectionConfidenceThreshold = 0.45;
  static const double diseaseThreshold = 0.50; // Prob >= 0.5 means Diseased

  // YOLO classes
  static const List<String> yoloClasses = [
    'Head',
    'Foot',
    'Torso',
    'Udder',
  ];
}
