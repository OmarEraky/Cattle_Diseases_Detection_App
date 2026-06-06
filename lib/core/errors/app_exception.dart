abstract class AppException implements Exception {
  final String message;
  final String? details;

  AppException(this.message, [this.details]);

  @override
  String toString() {
    if (details != null) {
      return '$message: $details';
    }
    return message;
  }
}

class ManifestException extends AppException {
  ManifestException(String message, [String? details]) : super(message, details);
}

class ModelDownloadException extends AppException {
  ModelDownloadException(String message, [String? details]) : super(message, details);
}

class ModelInferenceException extends AppException {
  ModelInferenceException(String message, [String? details]) : super(message, details);
}

class UnsupportedFormatException extends AppException {
  UnsupportedFormatException(String message, [String? details]) : super(message, details);
}

class ImageProcessingException extends AppException {
  ImageProcessingException(String message, [String? details]) : super(message, details);
}
