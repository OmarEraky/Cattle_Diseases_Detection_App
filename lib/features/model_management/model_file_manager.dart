import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';
import 'model_manifest.dart';
import 'model_strategy.dart';
import 'remote_model_config.dart';
import 'model_format.dart';

abstract class ModelFileManager {
  Future<ModelManifest> refreshManifest();
  Future<ModelManifest?> getCachedManifest();
  Future<bool> isModelAvailable(String modelId);
  Future<File> getModelFile(String modelId);
  Future<void> downloadModel(String modelId, {Function(double progress)? onProgress});
  Future<void> downloadRequiredModelsForStrategy(ModelStrategy strategy, {Function(String modelId, double progress)? onProgress});
  Future<void> downloadAllModels({Function(String modelId, double progress)? onProgress});
  Future<Map<String, bool>> getModelAvailabilityStatus();
  Future<void> deleteAllModels();
}

class LocalModelFileManager implements ModelFileManager {
  final http.Client _httpClient;
  ModelManifest? _manifest;

  LocalModelFileManager({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();

  // Return the current manifest or load it
  ModelManifest? get manifest => _manifest;
  set manifest(ModelManifest? m) => _manifest = m;

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _manifestFile async {
    final path = await _localPath;
    return File('$path/models_manifest.json');
  }

  @override
  Future<ModelManifest> refreshManifest() async {
    try {
      final response = await _httpClient.get(Uri.parse(AppConstants.manifestUrl));
      if (response.statusCode == 200) {
        final jsonMap = json.decode(response.body) as Map<String, dynamic>;
        _manifest = ModelManifest.fromJson(jsonMap);
        
        // Cache locally
        final file = await _manifestFile;
        await file.writeAsString(response.body);
        return _manifest!;
      } else {
        throw ManifestException(
          'Failed to download manifest from server',
          'HTTP Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      // Try to load cached manifest
      final cached = await getCachedManifest();
      if (cached != null) {
        _manifest = cached;
        return cached;
      }
      throw ManifestException('Failed to fetch manifest and no local cache found', e.toString());
    }
  }

  @override
  Future<ModelManifest?> getCachedManifest() async {
    try {
      final file = await _manifestFile;
      if (await file.exists()) {
        final content = await file.readAsString();
        final jsonMap = json.decode(content) as Map<String, dynamic>;
        return ModelManifest.fromJson(jsonMap);
      }
    } catch (_) {
      // Fail silently and return null
    }
    return null;
  }

  // Returns true if either the preferred file is downloaded OR the fallback file is downloaded
  @override
  Future<bool> isModelAvailable(String modelId) async {
    if (_manifest == null) {
      _manifest = await getCachedManifest();
      if (_manifest == null) return false;
    }

    final config = _manifest!.models.firstWhere(
      (m) => m.id == modelId,
      orElse: () => _manifest!.classifiers.firstWhere(
        (c) => c.id == modelId,
        orElse: () => throw ManifestException('Model config not found for ID: $modelId'),
      ),
    );

    final localDir = await _localPath;
    
    // Check preferred format file
    final preferredFile = File('$localDir/${config.file}');
    if (await preferredFile.exists()) {
      return true;
    }

    // Check fallback format file
    if (config.fallbackFile != null) {
      final fallbackFile = File('$localDir/${config.fallbackFile}');
      if (await fallbackFile.exists()) {
        return true;
      }
    }

    return false;
  }

  // Gets the actual File that should be loaded.
  // It follows the logic: preferred first, then fallback.
  @override
  Future<File> getModelFile(String modelId) async {
    if (_manifest == null) {
      _manifest = await getCachedManifest();
      if (_manifest == null) {
        throw ManifestException('Manifest is not loaded. Please refresh manifest first.');
      }
    }

    final config = _manifest!.models.firstWhere(
      (m) => m.id == modelId,
      orElse: () => _manifest!.classifiers.firstWhere(
        (c) => c.id == modelId,
        orElse: () => throw ManifestException('Model config not found for ID: $modelId'),
      ),
    );

    final localDir = await _localPath;

    // Check preferred
    final preferredFile = File('$localDir/${config.file}');
    if (await preferredFile.exists()) {
      return preferredFile;
    }

    // Check fallback
    if (config.fallbackFile != null) {
      final fallbackFile = File('$localDir/${config.fallbackFile}');
      if (await fallbackFile.exists()) {
        return fallbackFile;
      }
    }

    throw ModelDownloadException(
      'Model file not found locally. Please download it first.',
      'Model ID: $modelId, Expected file: ${config.file}',
    );
  }

  // Downloads the model file. If preferred format is unsupported (like ONNX) but fallback (like TFLite) is supported,
  // it downloads the fallback. Otherwise, it downloads preferred.
  @override
  Future<void> downloadModel(String modelId, {Function(double progress)? onProgress}) async {
    if (_manifest == null) {
      _manifest = await getCachedManifest();
      if (_manifest == null) {
        throw ManifestException('Manifest is not loaded. Cannot download.');
      }
    }

    final config = _manifest!.models.firstWhere(
      (m) => m.id == modelId,
      orElse: () => _manifest!.classifiers.firstWhere(
        (c) => c.id == modelId,
        orElse: () => throw ManifestException('Model config not found for ID: $modelId'),
      ),
    );

    // Determine which file to download based on platform capabilities
    // Since ONNX is unsupported, if preferred format is ONNX and fallback is TFLite, download fallback.
    final bool useFallback = config.preferredFormat == ModelFormat.onnx &&
        config.fallbackFile != null &&
        config.fallbackDownloadUrl != null;

    final String fileName = useFallback ? config.fallbackFile! : config.file;
    final String downloadUrl = useFallback ? config.fallbackDownloadUrl! : config.downloadUrl;

    final localDir = await _localPath;
    final targetFile = File('$localDir/$fileName');

    // Make sure parent directory exists
    await targetFile.parent.create(recursive: true);

    try {
      final request = http.Request('GET', Uri.parse(downloadUrl));
      final response = await _httpClient.send(request);

      if (response.statusCode != 200) {
        throw ModelDownloadException(
          'Failed to download model file',
          'HTTP Status: ${response.statusCode} for URL: $downloadUrl',
        );
      }

      final contentLength = response.contentLength ?? 0;
      int downloadedBytes = 0;
      final fileSink = targetFile.openWrite();

      await response.stream.forEach((chunk) {
        downloadedBytes += chunk.length;
        fileSink.add(chunk);
        
        if (contentLength > 0 && onProgress != null) {
          final progress = downloadedBytes / contentLength;
          onProgress(progress);
        }
      });

      await fileSink.close();
      if (onProgress != null) {
        onProgress(1.0);
      }
    } catch (e) {
      // Clean up partial downloads
      if (await targetFile.exists()) {
        await targetFile.delete();
      }
      throw ModelDownloadException('Failed to download model $modelId', e.toString());
    }
  }

  @override
  Future<void> downloadRequiredModelsForStrategy(
    ModelStrategy strategy, {
    Function(String modelId, double progress)? onProgress,
  }) async {
    if (_manifest == null) {
      await refreshManifest();
    }

    // YOLO is always required
    final yolo = _manifest!.models.firstWhere((m) => m.id == 'yolo_body_part_seg');
    if (!(await isModelAvailable(yolo.id))) {
      await downloadModel(yolo.id, onProgress: (p) => onProgress?.call(yolo.id, p));
    } else {
      onProgress?.call(yolo.id, 1.0);
    }

    // Classifier models for the strategy
    final strategyKey = strategy == ModelStrategy.efficientNetB0Mobile ? 'efficientnet_b0_mobile' : 'best_mixed';
    final strategyMap = _manifest!.strategies[strategyKey];
    if (strategyMap != null) {
      for (var modelId in strategyMap.values) {
        if (!(await isModelAvailable(modelId))) {
          await downloadModel(modelId, onProgress: (p) => onProgress?.call(modelId, p));
        } else {
          onProgress?.call(modelId, 1.0);
        }
      }
    }
  }

  @override
  Future<void> downloadAllModels({Function(String modelId, double progress)? onProgress}) async {
    if (_manifest == null) {
      await refreshManifest();
    }

    // All segmentation models
    for (var m in _manifest!.models) {
      if (!(await isModelAvailable(m.id))) {
        await downloadModel(m.id, onProgress: (p) => onProgress?.call(m.id, p));
      } else {
        onProgress?.call(m.id, 1.0);
      }
    }

    // All classifiers
    for (var c in _manifest!.classifiers) {
      if (!(await isModelAvailable(c.id))) {
        await downloadModel(c.id, onProgress: (p) => onProgress?.call(c.id, p));
      } else {
        onProgress?.call(c.id, 1.0);
      }
    }
  }

  @override
  Future<Map<String, bool>> getModelAvailabilityStatus() async {
    final status = <String, bool>{};
    if (_manifest == null) {
      _manifest = await getCachedManifest();
      if (_manifest == null) return status;
    }

    for (var m in _manifest!.models) {
      status[m.id] = await isModelAvailable(m.id);
    }
    for (var c in _manifest!.classifiers) {
      status[c.id] = await isModelAvailable(c.id);
    }
    return status;
  }

  @override
  Future<void> deleteAllModels() async {
    if (_manifest == null) {
      _manifest = await getCachedManifest();
      if (_manifest == null) return;
    }

    final localDir = await _localPath;

    // Delete YOLO files
    for (var m in _manifest!.models) {
      final f1 = File('$localDir/${m.file}');
      if (await f1.exists()) await f1.delete();
      if (m.fallbackFile != null) {
        final f2 = File('$localDir/${m.fallbackFile}');
        if (await f2.exists()) await f2.delete();
      }
    }

    // Delete classifier files
    for (var c in _manifest!.classifiers) {
      final f1 = File('$localDir/${c.file}');
      if (await f1.exists()) await f1.delete();
      if (c.fallbackFile != null) {
        final f2 = File('$localDir/${c.fallbackFile}');
        if (await f2.exists()) await f2.delete();
      }
    }
  }
}
