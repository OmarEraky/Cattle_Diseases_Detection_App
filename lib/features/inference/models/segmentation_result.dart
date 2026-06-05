class SegmentationResult {
  final int classIndex;
  final String label;
  final double confidence;
  
  // Bounding box dimensions (relative scale: 0.0 to 1.0)
  final double x;
  final double y;
  final double width;
  final double height;
  
  // Optional polygon coordinates or binary mask representation for pixel-level segmentation
  final List<List<double>>? maskPoints;

  const SegmentationResult({
    required this.classIndex,
    required this.label,
    required this.confidence,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.maskPoints,
  });

  @override
  String toString() {
    return 'SegmentationResult($label, confidence: ${(confidence * 100).toStringAsFixed(1)}%, box: [$x, $y, $width, $height])';
  }
}
