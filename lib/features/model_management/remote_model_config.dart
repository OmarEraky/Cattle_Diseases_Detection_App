import '../inference/models/body_part.dart';
import '../inference/models/crop_type.dart';
import 'model_format.dart';

class RemoteModelConfig {
  final String id;
  final String type; // e.g. "segmentation" or "classifier"
  final BodyPart? bodyPart;
  final String? modelName;
  final CropType? cropType;
  final ModelFormat preferredFormat;
  final String file;
  final String downloadUrl;
  final String? fallbackFile;
  final String? fallbackDownloadUrl;
  final int inputSize;
  final String? output; // e.g. "single_logit"

  RemoteModelConfig({
    required this.id,
    required this.type,
    this.bodyPart,
    this.modelName,
    this.cropType,
    required this.preferredFormat,
    required this.file,
    required this.downloadUrl,
    this.fallbackFile,
    this.fallbackDownloadUrl,
    required this.inputSize,
    this.output,
  });

  factory RemoteModelConfig.fromJson(Map<String, dynamic> json) {
    return RemoteModelConfig(
      id: json['id'] as String,
      type: json['type'] as String,
      bodyPart: json['body_part'] != null
          ? BodyPart.fromManifestString(json['body_part'] as String)
          : null,
      modelName: json['model_name'] as String?,
      cropType: json['crop_type'] != null
          ? CropType.fromManifestString(json['crop_type'] as String)
          : null,
      preferredFormat: ModelFormat.fromManifestString(json['preferred_format'] as String),
      file: json['file'] as String,
      downloadUrl: json['download_url'] as String,
      fallbackFile: json['fallback_file'] as String?,
      fallbackDownloadUrl: json['fallback_download_url'] as String?,
      inputSize: json['input_size'] as int,
      output: json['output'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'body_part': bodyPart?.toManifestString(),
      'model_name': modelName,
      'crop_type': cropType?.toManifestString(),
      'preferred_format': preferredFormat.toManifestString(),
      'file': file,
      'download_url': downloadUrl,
      'fallback_file': fallbackFile,
      'fallback_download_url': fallbackDownloadUrl,
      'input_size': inputSize,
      'output': output,
    };
  }
}
