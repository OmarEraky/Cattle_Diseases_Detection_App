import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'model_file_manager.dart';
import 'model_strategy.dart';

class ModelDownloadState {
  final Map<String, double> progressMap; // modelId -> progress (0.0 to 1.0)
  final bool isDownloading;
  final String? activeModelId;
  final String? errorMessage;

  ModelDownloadState({
    this.progressMap = const {},
    this.isDownloading = false,
    this.activeModelId,
    this.errorMessage,
  });

  ModelDownloadState copyWith({
    Map<String, double>? progressMap,
    bool? isDownloading,
    String? activeModelId,
    String? errorMessage,
  }) {
    return ModelDownloadState(
      progressMap: progressMap ?? this.progressMap,
      isDownloading: isDownloading ?? this.isDownloading,
      activeModelId: activeModelId, // can be set to null
      errorMessage: errorMessage, // can be set to null
    );
  }
}

class ModelDownloadNotifier extends StateNotifier<ModelDownloadState> {
  final ModelFileManager _fileManager;

  ModelDownloadNotifier(this._fileManager) : super(ModelDownloadState());

  void _updateProgress(String modelId, double progress) {
    final updatedMap = Map<String, double>.from(state.progressMap);
    updatedMap[modelId] = progress;
    state = state.copyWith(
      progressMap: updatedMap,
      activeModelId: progress < 1.0 ? modelId : null,
    );
  }

  Future<void> downloadModel(String modelId) async {
    state = state.copyWith(isDownloading: true, errorMessage: null);
    try {
      await _fileManager.downloadModel(
        modelId,
        onProgress: (p) => _updateProgress(modelId, p),
      );
      state = state.copyWith(isDownloading: false);
    } catch (e) {
      state = state.copyWith(isDownloading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> downloadRequiredModels(ModelStrategy strategy) async {
    state = state.copyWith(isDownloading: true, errorMessage: null);
    try {
      await _fileManager.downloadRequiredModelsForStrategy(
        strategy,
        onProgress: (modelId, p) => _updateProgress(modelId, p),
      );
      state = state.copyWith(isDownloading: false);
    } catch (e) {
      state = state.copyWith(isDownloading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> downloadAllModels() async {
    state = state.copyWith(isDownloading: true, errorMessage: null);
    try {
      await _fileManager.downloadAllModels(
        onProgress: (modelId, p) => _updateProgress(modelId, p),
      );
      state = state.copyWith(isDownloading: false);
    } catch (e) {
      state = state.copyWith(isDownloading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void resetProgress() {
    state = ModelDownloadState();
  }
}
