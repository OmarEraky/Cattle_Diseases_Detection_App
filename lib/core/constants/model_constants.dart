class ModelConstants {
  static const double yoloConfidenceThreshold = 0.45;
  static const double YOLO_CONFIDENCE_THRESHOLD = 0.45; // Exact name required by prompt
  
  static const int classifierInputSize = 224;
  static const int yoloInputSize = 640;
  
  static const List<double> imageNetMean = [0.485, 0.456, 0.406];
  static const List<double> imageNetStd = [0.229, 0.224, 0.225];
}
