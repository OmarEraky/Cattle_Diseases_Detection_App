enum AnalysisMode {
  fullReport,
  singlePart;

  String get displayName {
    switch (this) {
      case AnalysisMode.fullReport:
        return 'Full Cow Health Report';
      case AnalysisMode.singlePart:
        return 'Single Body-Part Analysis';
    }
  }
}
