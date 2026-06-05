import 'package:cattle_disease_app/core/constants/model_constants.dart';

enum BodyPart {
  head(
    displayName: 'Head',
    yoloClassIndex: 0,
    modelAssetPath: ModelConstants.headClassifierPath,
  ),
  foot(
    displayName: 'Foot / Leg',
    yoloClassIndex: 1,
    modelAssetPath: ModelConstants.footClassifierPath,
  ),
  torso(
    displayName: 'Torso / Skin',
    yoloClassIndex: 2,
    modelAssetPath: ModelConstants.torsoClassifierPath,
  ),
  udder(
    displayName: 'Udder',
    yoloClassIndex: 3,
    modelAssetPath: ModelConstants.udderClassifierPath,
  );

  final String displayName;
  final int yoloClassIndex; // Matching class ID in YOLO segmentation output
  final String modelAssetPath; // Path of the classifier tflite model file

  const BodyPart({
    required this.displayName,
    required this.yoloClassIndex,
    required this.modelAssetPath,
  });

  /// Maps string to BodyPart
  static BodyPart fromString(String value) {
    return BodyPart.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase() || e.displayName.toLowerCase() == value.toLowerCase(),
      orElse: () => BodyPart.head,
    );
  }
}
