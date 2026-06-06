import '../inference/models/body_part.dart';
import 'model_manifest.dart';
import 'model_strategy.dart';
import 'remote_model_config.dart';

class ModelRegistry {
  final ModelManifest manifest;
  final Map<BodyPart, String> manualSelections; // Maps BodyPart to classifier model ID

  ModelRegistry({
    required this.manifest,
    this.manualSelections = const {},
  });

  // Get model config by model ID (YOLO or classifier)
  RemoteModelConfig? getModelConfig(String modelId) {
    for (var m in manifest.models) {
      if (m.id == modelId) return m;
    }
    for (var c in manifest.classifiers) {
      if (c.id == modelId) return c;
    }
    return null;
  }

  // Get active classifier config for a body part under a strategy
  RemoteModelConfig? getActiveClassifier({
    required BodyPart bodyPart,
    required ModelStrategy strategy,
  }) {
    switch (strategy) {
      case ModelStrategy.efficientNetB0Mobile:
        final strategyKey = 'efficientnet_b0_mobile';
        final modelId = manifest.strategies[strategyKey]?[bodyPart.toManifestString()];
        if (modelId == null) return null;
        return getModelConfig(modelId);

      case ModelStrategy.bestMixed:
        final strategyKey = 'best_mixed';
        final modelId = manifest.strategies[strategyKey]?[bodyPart.toManifestString()];
        if (modelId == null) return null;
        return getModelConfig(modelId);

      case ModelStrategy.manual:
        final modelId = manualSelections[bodyPart];
        if (modelId == null) {
          // Fallback to efficientnet_b0_mobile if no manual selection is chosen yet
          final strategyKey = 'efficientnet_b0_mobile';
          final fbId = manifest.strategies[strategyKey]?[bodyPart.toManifestString()];
          if (fbId == null) return null;
          return getModelConfig(fbId);
        }
        return getModelConfig(modelId);
    }
  }

  // Get all required models (including YOLO) for a strategy
  List<RemoteModelConfig> getRequiredModelsForStrategy(ModelStrategy strategy) {
    final list = <RemoteModelConfig>[];

    // YOLO is always required for both options
    final yolo = manifest.models.firstWhere(
      (m) => m.id == 'yolo_body_part_seg',
      orElse: () => throw StateError('YOLO segmentation model configuration missing in manifest.'),
    );
    list.add(yolo);

    for (var part in BodyPart.values) {
      final config = getActiveClassifier(bodyPart: part, strategy: strategy);
      if (config != null) {
        list.add(config);
      }
    }
    return list;
  }

  // Get classifiers available for a specific body part
  List<RemoteModelConfig> getClassifiersForBodyPart(BodyPart bodyPart) {
    return manifest.classifiers.where((c) => c.bodyPart == bodyPart).toList();
  }

  ModelRegistry copyWith({
    ModelManifest? manifest,
    Map<BodyPart, String>? manualSelections,
  }) {
    return ModelRegistry(
      manifest: manifest ?? this.manifest,
      manualSelections: manualSelections ?? this.manualSelections,
    );
  }
}
