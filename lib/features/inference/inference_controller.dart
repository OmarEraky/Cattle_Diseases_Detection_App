import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cattle_disease_app/core/constants/app_constants.dart';
import 'package:cattle_disease_app/core/errors/app_exception.dart';
import 'package:cattle_disease_app/features/inference/models/body_part.dart';
import 'package:cattle_disease_app/features/inference/models/disease_prediction.dart';
import 'package:cattle_disease_app/features/inference/services/inference_service.dart';
import 'package:cattle_disease_app/features/inference/services/mock_inference_service.dart';
import 'package:cattle_disease_app/features/inference/services/tflite_inference_service.dart';
import 'package:cattle_disease_app/features/inference/inference_state.dart';

class InferenceController extends ChangeNotifier {
  final MockInferenceService _mockService = MockInferenceService();
  final TfliteInferenceService _tfliteService = TfliteInferenceService();

  InferenceState _state = const InferenceState();
  bool _useMockMode = true; // Default to true so app runs without models instantly
  BodyPart? _selectedBodyPart;

  InferenceState get state => _state;
  bool get useMockMode => _useMockMode;
  BodyPart? get selectedBodyPart => _selectedBodyPart;

  InferenceService get _activeService => _useMockMode ? _mockService : _tfliteService;

  InferenceController() {
    _initialize();
  }

  Future<void> _initialize() async {
    // We could load settings from SharedPreferences here.
    // For now, load default state.
    await loadModels();
  }

  /// Sets whether the app uses mock mode or real on-device TFLite models.
  void setMockMode(bool useMock) {
    if (_useMockMode == useMock) return;
    _useMockMode = useMock;
    notifyListeners();
    loadModels();
  }

  /// Sets the active body part to analyze.
  void selectBodyPart(BodyPart bodyPart) {
    _selectedBodyPart = bodyPart;
    notifyListeners();
  }

  /// Resets the body part selection.
  void resetSelection() {
    _selectedBodyPart = null;
    _state = const InferenceState();
    notifyListeners();
  }

  /// Warm up or load models for the active service.
  Future<void> loadModels() async {
    try {
      await _activeService.loadModels();
    } catch (e) {
      debugPrint('Error preloading models: $e');
    }
  }

  /// Executes prediction pipeline for the selected image.
  Future<DiseasePrediction?> analyzeImage(File imageFile) async {
    if (_selectedBodyPart == null) {
      _state = _state.copyWith(
        status: InferenceStatus.failure,
        errorMessage: 'Please select a body part to analyze.',
      );
      notifyListeners();
      return null;
    }

    _state = _state.copyWith(status: InferenceStatus.loading);
    notifyListeners();

    try {
      final prediction = await _activeService.predict(
        imageFile: imageFile,
        bodyPart: _selectedBodyPart!,
      );

      _state = _state.copyWith(
        status: InferenceStatus.success,
        prediction: prediction,
      );
      notifyListeners();
      return prediction;
    } on AppException catch (e) {
      _state = _state.copyWith(
        status: InferenceStatus.failure,
        errorMessage: e.message,
      );
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(
        status: InferenceStatus.failure,
        errorMessage: 'An unexpected inference failure occurred: $e',
      );
      notifyListeners();
    }
    return null;
  }

  @override
  void dispose() {
    _mockService.close();
    _tfliteService.close();
    super.dispose();
  }
}
