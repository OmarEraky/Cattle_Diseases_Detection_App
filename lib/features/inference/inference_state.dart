import 'models/disease_prediction.dart';
import 'models/health_report.dart';

class InferenceState {
  final bool isLoading;
  final HealthReport? healthReport;
  final DiseasePrediction? singlePrediction;
  final String? errorMessage;

  InferenceState({
    this.isLoading = false,
    this.healthReport,
    this.singlePrediction,
    this.errorMessage,
  });

  InferenceState copyWith({
    bool? isLoading,
    HealthReport? healthReport,
    DiseasePrediction? singlePrediction,
    String? errorMessage,
  }) {
    return InferenceState(
      isLoading: isLoading ?? this.isLoading,
      healthReport: healthReport ?? this.healthReport,
      singlePrediction: singlePrediction ?? this.singlePrediction,
      errorMessage: errorMessage, // can be set to null
    );
  }
}
