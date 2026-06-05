import 'package:cattle_disease_app/features/inference/models/disease_prediction.dart';

enum InferenceStatus {
  idle,
  loading,
  success,
  failure,
}

class InferenceState {
  final InferenceStatus status;
  final DiseasePrediction? prediction;
  final String? errorMessage;

  const InferenceState({
    this.status = InferenceStatus.idle,
    this.prediction,
    this.errorMessage,
  });

  bool get isIdle => status == InferenceStatus.idle;
  bool get isLoading => status == InferenceStatus.loading;
  bool get isSuccess => status == InferenceStatus.success;
  bool get isFailure => status == InferenceStatus.failure;

  InferenceState copyWith({
    InferenceStatus? status,
    DiseasePrediction? prediction,
    String? errorMessage,
  }) {
    return InferenceState(
      status: status ?? this.status,
      prediction: prediction ?? this.prediction,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
