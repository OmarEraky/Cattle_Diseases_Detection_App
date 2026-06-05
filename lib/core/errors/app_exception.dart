abstract class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, [this.code]);

  @override
  String toString() => '[$code] $message';
}

class ModelLoadException extends AppException {
  ModelLoadException(String message) : super(message, 'MODEL_LOAD_ERROR');
}

class InferenceException extends AppException {
  InferenceException(String message) : super(message, 'INFERENCE_ERROR');
}

class ImageProcessingException extends AppException {
  ImageProcessingException(String message) : super(message, 'IMAGE_PROCESSING_ERROR');
}

class PermissionException extends AppException {
  PermissionException(String message) : super(message, 'PERMISSION_DENIED');
}
