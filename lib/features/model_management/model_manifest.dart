import 'remote_model_config.dart';

class InputPreprocessing {
  final int classifierInputSize;
  final int yoloInputSize;
  final List<double> mean;
  final List<double> std;
  final String formatTflite;
  final String formatOnnx;

  InputPreprocessing({
    required this.classifierInputSize,
    required this.yoloInputSize,
    required this.mean,
    required this.std,
    required this.formatTflite,
    required this.formatOnnx,
  });

  factory InputPreprocessing.fromJson(Map<String, dynamic> json) {
    return InputPreprocessing(
      classifierInputSize: json['classifier_input_size'] as int,
      yoloInputSize: json['yolo_input_size'] as int,
      mean: (json['normalization']['mean'] as List).map((e) => (e as num).toDouble()).toList(),
      std: (json['normalization']['std'] as List).map((e) => (e as num).toDouble()).toList(),
      formatTflite: json['format_tflite'] as String,
      formatOnnx: json['format_onnx'] as String,
    );
  }
}

class OutputPostprocessing {
  final String type;
  final String activation;
  final double threshold;
  final String label0;
  final String label1;

  OutputPostprocessing({
    required this.type,
    required this.activation,
    required this.threshold,
    required this.label0,
    required this.label1,
  });

  factory OutputPostprocessing.fromJson(Map<String, dynamic> json) {
    return OutputPostprocessing(
      type: json['type'] as String,
      activation: json['activation'] as String,
      threshold: (json['threshold'] as num).toDouble(),
      label0: json['label_0'] as String,
      label1: json['label_1'] as String,
    );
  }
}

class ModelManifest {
  final String version;
  final double yoloConfidenceThreshold;
  final InputPreprocessing inputPreprocessing;
  final OutputPostprocessing outputPostprocessing;
  final List<RemoteModelConfig> models;
  final List<RemoteModelConfig> classifiers;
  final Map<String, Map<String, String>> strategies;

  ModelManifest({
    required this.version,
    required this.yoloConfidenceThreshold,
    required this.inputPreprocessing,
    required this.outputPostprocessing,
    required this.models,
    required this.classifiers,
    required this.strategies,
  });

  factory ModelManifest.fromJson(Map<String, dynamic> json) {
    final modelsList = (json['models'] as List)
        .map((m) => RemoteModelConfig.fromJson(m as Map<String, dynamic>))
        .toList();
    final classifiersList = (json['classifiers'] as List)
        .map((c) => RemoteModelConfig.fromJson(c as Map<String, dynamic>))
        .toList();

    final strategiesMap = <String, Map<String, String>>{};
    if (json['strategies'] != null) {
      final stratJson = json['strategies'] as Map<String, dynamic>;
      stratJson.forEach((key, val) {
        if (val is Map<String, dynamic>) {
          strategiesMap[key] = val.map((k, v) => MapEntry(k, v as String));
        }
      });
    }

    return ModelManifest(
      version: json['version'] as String,
      yoloConfidenceThreshold: (json['yolo_confidence_threshold'] as num).toDouble(),
      inputPreprocessing: InputPreprocessing.fromJson(json['input_preprocessing'] as Map<String, dynamic>),
      outputPostprocessing: OutputPostprocessing.fromJson(json['output_postprocessing'] as Map<String, dynamic>),
      models: modelsList,
      classifiers: classifiersList,
      strategies: strategiesMap,
    );
  }
}
