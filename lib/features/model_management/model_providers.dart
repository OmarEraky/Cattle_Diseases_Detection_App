import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/model_constants.dart';
import '../inference/models/body_part.dart';
import 'model_download_service.dart';
import 'model_file_manager.dart';
import 'model_manifest.dart';
import 'model_registry.dart';
import 'model_strategy.dart';

// HTTP Client provider
final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(() => client.close());
  return client;
});

// ModelFileManager provider
final modelFileManagerProvider = Provider<ModelFileManager>((ref) {
  final httpClient = ref.watch(httpClientProvider);
  return LocalModelFileManager(httpClient: httpClient);
});

// Manifest FutureProvider
final manifestProvider = FutureProvider<ModelManifest>((ref) async {
  final fileManager = ref.watch(modelFileManagerProvider);
  
  // Try to load cached manifest first so UI loads quickly
  final cached = await fileManager.getCachedManifest();
  if (cached != null) {
    // Refresh manifest in the background without blocking
    fileManager.refreshManifest().then((_) {
      // Invalidate if different, but for now we just return cached and update the provider state.
      ref.invalidateSelf();
    }).catchError((_) {});
    return cached;
  }

  // If no cache, fetch from network
  return fileManager.refreshManifest();
});

// Selected Model Strategy
final selectedStrategyProvider = StateProvider<ModelStrategy>((ref) {
  return ModelStrategy.efficientNetB0Mobile;
});

// Manual classifier selections for each body part
final manualSelectionsProvider = StateProvider<Map<BodyPart, String>>((ref) {
  return const {};
});

// ModelRegistry provider
final modelRegistryProvider = Provider<ModelRegistry?>((ref) {
  final manifestAsync = ref.watch(manifestProvider);
  return manifestAsync.when(
    data: (manifest) {
      final manualSelections = ref.watch(manualSelectionsProvider);
      return ModelRegistry(manifest: manifest, manualSelections: manualSelections);
    },
    error: (_, __) => null,
    loading: () => null,
  );
});

// Model Download Progress Notifier Provider
final modelDownloadProvider = StateNotifierProvider<ModelDownloadNotifier, ModelDownloadState>((ref) {
  final fileManager = ref.watch(modelFileManagerProvider);
  return ModelDownloadNotifier(fileManager);
});

// Model Availability notifier
class ModelAvailabilityNotifier extends StateNotifier<Map<String, bool>> {
  final ModelFileManager _fileManager;
  ModelAvailabilityNotifier(this._fileManager) : super(const {});

  Future<void> refresh() async {
    state = await _fileManager.getModelAvailabilityStatus();
  }
}

final modelAvailabilityProvider = StateNotifierProvider<ModelAvailabilityNotifier, Map<String, bool>>((ref) {
  final fileManager = ref.watch(modelFileManagerProvider);
  final notifier = ModelAvailabilityNotifier(fileManager);
  
  // Refresh availability when manifest updates
  ref.listen(manifestProvider, (_, __) {
    notifier.refresh();
  });
  
  // Refresh initially
  notifier.refresh();
  return notifier;
});

// YOLO Confidence Threshold Provider
final yoloThresholdProvider = StateProvider<double>((ref) {
  return ModelConstants.yoloConfidenceThreshold;
});
