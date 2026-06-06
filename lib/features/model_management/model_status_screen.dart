import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/widgets/primary_button.dart';
import '../inference/models/body_part.dart';
import 'model_providers.dart';
import 'model_strategy.dart';
import 'model_selection_screen.dart';

class ModelStatusScreen extends ConsumerWidget {
  const ModelStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manifestAsync = ref.watch(manifestProvider);
    final strategy = ref.watch(selectedStrategyProvider);
    final availability = ref.watch(modelAvailabilityProvider);
    final downloadState = ref.watch(modelDownloadProvider);
    final yoloThreshold = ref.watch(yoloThresholdProvider);
    final theme = Theme.of(context);

    // Listen to download errors
    ref.listen(modelDownloadProvider, (previous, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: theme.colorScheme.error,
          ),
        );
        ref.read(modelDownloadProvider.notifier).clearError();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Model Settings & Status'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Manifest',
            onPressed: () {
              ref.invalidate(manifestProvider);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Refreshing manifest...')),
              );
            },
          ),
        ],
      ),
      body: manifestAsync.when(
        data: (manifest) {
          final requiredModels = ref.watch(modelRegistryProvider)
                  ?.getRequiredModelsForStrategy(strategy) ?? [];
          final requiredModelIds = requiredModels.map((m) => m.id).toSet();

          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                children: [
                  // 1. Model Inference Strategy Section
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.psychology_rounded, color: theme.colorScheme.primary),
                              const SizedBox(width: 8),
                              Text(
                                'Inference Strategy',
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<ModelStrategy>(
                            value: strategy,
                            decoration: InputDecoration(
                              labelText: 'Active Strategy',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            items: ModelStrategy.values.map((s) {
                              return DropdownMenuItem(
                                value: s,
                                child: Text(s.displayName),
                              );
                            }).toList(),
                            onChanged: (newStrategy) {
                              if (newStrategy != null) {
                                ref.read(selectedStrategyProvider.notifier).state = newStrategy;
                                ref.read(modelAvailabilityProvider.notifier).refresh();
                              }
                            },
                          ),
                          if (strategy == ModelStrategy.manual) ...[
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const ModelSelectionScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.settings_suggest_rounded),
                              label: const Text('Configure Manual Selection'),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. YOLO Confidence Threshold
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.tune_rounded, color: theme.colorScheme.primary),
                              const SizedBox(width: 8),
                              Text(
                                'YOLO Detection Threshold',
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Slider(
                                  value: yoloThreshold,
                                  min: 0.1,
                                  max: 0.9,
                                  divisions: 16,
                                  label: yoloThreshold.toStringAsFixed(2),
                                  onChanged: (val) {
                                    ref.read(yoloThresholdProvider.notifier).state = val;
                                  },
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  yoloThreshold.toStringAsFixed(2),
                                  style: TextStyle(
                                    color: theme.colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. Model Availability Status List
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Model Status & Availability',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          final fm = ref.read(modelFileManagerProvider);
                          await fm.deleteAllModels();
                          await ref.read(modelAvailabilityProvider.notifier).refresh();
                          ref.read(modelDownloadProvider.notifier).resetProgress();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('All local model files deleted.')),
                          );
                        },
                        icon: const Icon(Icons.delete_sweep_rounded),
                        label: const Text('Delete All'),
                        style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // YOLO Model Card
                  ...manifest.models.map((m) {
                    final isDownloaded = availability[m.id] ?? false;
                    final progress = downloadState.progressMap[m.id];
                    final isCurrentDownloading = downloadState.activeModelId == m.id;

                    return _buildModelTile(
                      context: context,
                      ref: ref,
                      id: m.id,
                      name: 'YOLO Body Part Detection',
                      format: m.preferredFormat.toManifestString().toUpperCase(),
                      type: 'Object Detector',
                      isDownloaded: isDownloaded,
                      isDownloading: isCurrentDownloading,
                      progress: progress,
                      isRequired: true,
                    );
                  }),

                  // Classifiers
                  ...manifest.classifiers.map((c) {
                    final isDownloaded = availability[c.id] ?? false;
                    final progress = downloadState.progressMap[c.id];
                    final isCurrentDownloading = downloadState.activeModelId == c.id;
                    final isRequired = requiredModelIds.contains(c.id);

                    return _buildModelTile(
                      context: context,
                      ref: ref,
                      id: c.id,
                      name: '${c.bodyPart?.displayName} Classifier (${c.modelName})',
                      format: c.preferredFormat.toManifestString().toUpperCase(),
                      type: 'Crop: ${c.cropType?.toManifestString()}',
                      isDownloaded: isDownloaded,
                      isDownloading: isCurrentDownloading,
                      progress: progress,
                      isRequired: isRequired,
                    );
                  }),
                ],
              ),

              // Bottom Actions Panel
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: downloadState.isDownloading
                              ? null
                              : () async {
                                  try {
                                    await ref
                                        .read(modelDownloadProvider.notifier)
                                        .downloadRequiredModels(strategy);
                                    await ref.read(modelAvailabilityProvider.notifier).refresh();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Required models downloaded successfully!')),
                                    );
                                  } catch (e) {
                                    // Error handled by listener
                                  }
                                },
                          icon: const Icon(Icons.download_done_rounded),
                          label: const Text('Download Required'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: PrimaryButton(
                          text: 'Download All',
                          icon: Icons.downloading_rounded,
                          isLoading: downloadState.isDownloading && downloadState.activeModelId == null,
                          onPressed: downloadState.isDownloading
                              ? null
                              : () async {
                                  try {
                                    await ref
                                        .read(modelDownloadProvider.notifier)
                                        .downloadAllModels();
                                    await ref.read(modelAvailabilityProvider.notifier).refresh();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('All models downloaded successfully!')),
                                    );
                                  } catch (e) {
                                    // Error handled by listener
                                  }
                                },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off_rounded, size: 64, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text(
                'Failed to load models manifest',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(err.toString(), textAlign: TextAlign.center),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(manifestProvider),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry Connection'),
              ),
            ],
          ),
        ),
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('Fetching latest models manifest...'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModelTile({
    required BuildContext context,
    required WidgetRef ref,
    required String id,
    required String name,
    required String format,
    required String type,
    required bool isDownloaded,
    required bool isDownloading,
    required double? progress,
    required bool isRequired,
  }) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isRequired
            ? BorderSide(color: theme.colorScheme.primary.withOpacity(0.4), width: 1.5)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (isRequired)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'REQUIRED',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 8,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            format,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: format == 'TFLITE' ? Colors.green : Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '•  $type',
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Download action indicator
                if (isDownloaded)
                  Icon(Icons.check_circle_rounded, color: Colors.green.shade600)
                else if (isDownloading)
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 3,
                    ),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.download_rounded),
                    color: theme.colorScheme.primary,
                    onPressed: () async {
                      try {
                        await ref.read(modelDownloadProvider.notifier).downloadModel(id);
                        await ref.read(modelAvailabilityProvider.notifier).refresh();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('$id downloaded successfully!')),
                        );
                      } catch (e) {
                        // Error handled by listener
                      }
                    },
                  ),
              ],
            ),
            if (isDownloading && progress != null) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                color: theme.colorScheme.primary,
              ),
            ]
          ],
        ),
      ),
    );
  }
}
