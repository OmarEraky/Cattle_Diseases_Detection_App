enum ModelFormat {
  tflite,
  onnx;

  static ModelFormat fromManifestString(String val) {
    switch (val.toLowerCase()) {
      case 'tflite':
        return ModelFormat.tflite;
      case 'onnx':
        return ModelFormat.onnx;
      default:
        throw ArgumentError('Unknown model format string: $val');
    }
  }

  String toManifestString() {
    switch (this) {
      case ModelFormat.tflite:
        return 'tflite';
      case ModelFormat.onnx:
        return 'onnx';
    }
  }
}
