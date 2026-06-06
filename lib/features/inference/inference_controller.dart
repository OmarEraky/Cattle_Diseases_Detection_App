import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model_management/model_strategy.dart';
import 'inference_providers.dart';
import 'inference_state.dart';
import 'models/body_part.dart';
import 'services/inference_service.dart';

class InferenceController extends StateNotifier<InferenceState> {
  final InferenceService _inferenceService;

  InferenceController(this._inferenceService) : super(InferenceState());

  Future<void> runFullReport({
    required File imageFile,
    required ModelStrategy strategy,
    required double yoloConfidenceThreshold,
  }) async {
    state = InferenceState(isLoading: true);
    try {
      final report = await _inferenceService.analyzeFullReport(
        imageFile: imageFile,
        strategy: strategy,
        yoloConfidenceThreshold: yoloConfidenceThreshold,
      );
      state = InferenceState(healthReport: report);
    } catch (e) {
      state = InferenceState(errorMessage: e.toString());
    }
  }

  Future<void> runSingleBodyPart({
    required File imageFile,
    required BodyPart bodyPart,
    required ModelStrategy strategy,
    required double yoloConfidenceThreshold,
  }) async {
    state = InferenceState(isLoading: true);
    try {
      final prediction = await _inferenceService.analyzeSingleBodyPart(
        imageFile: imageFile,
        bodyPart: bodyPart,
        strategy: strategy,
        yoloConfidenceThreshold: yoloConfidenceThreshold,
      );
      state = InferenceState(singlePrediction: prediction);
    } catch (e) {
      state = InferenceState(errorMessage: e.toString());
    }
  }

  void reset() {
    state = InferenceState();
  }
}

final inferenceControllerProvider = StateNotifierProvider<InferenceController, InferenceState>((ref) {
  final service = ref.watch(inferenceServiceProvider);
  return InferenceController(service);
});
