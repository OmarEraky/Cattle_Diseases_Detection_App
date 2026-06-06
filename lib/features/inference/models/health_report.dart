import '../../model_management/model_strategy.dart';
import 'body_part_report_item.dart';

class HealthReport {
  final String originalImagePath;
  final ModelStrategy strategy;
  final List<BodyPartReportItem> items;
  final int healthyCount;
  final int diseasedCount;
  final List<String> warnings;

  HealthReport({
    required this.originalImagePath,
    required this.strategy,
    required this.items,
    required this.healthyCount,
    required this.diseasedCount,
    required this.warnings,
  });
}
