enum ModelStrategy {
  efficientNetB0Mobile,
  bestMixed,
  manual;

  static ModelStrategy fromManifestString(String val) {
    switch (val.toLowerCase()) {
      case 'efficientnet_b0_mobile':
        return ModelStrategy.efficientNetB0Mobile;
      case 'best_mixed':
        return ModelStrategy.bestMixed;
      case 'manual':
        return ModelStrategy.manual;
      default:
        throw ArgumentError('Unknown model strategy string: $val');
    }
  }

  String toManifestString() {
    switch (this) {
      case ModelStrategy.efficientNetB0Mobile:
        return 'efficientnet_b0_mobile';
      case ModelStrategy.bestMixed:
        return 'best_mixed';
      case ModelStrategy.manual:
        return 'manual';
    }
  }

  String get displayName {
    switch (this) {
      case ModelStrategy.efficientNetB0Mobile:
        return 'EfficientNet-B0 Mobile';
      case ModelStrategy.bestMixed:
        return 'Best Mixed (TFLite + ONNX)';
      case ModelStrategy.manual:
        return 'Manual Selection';
    }
  }
}
