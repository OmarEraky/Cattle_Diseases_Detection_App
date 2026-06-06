import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../inference/models/body_part.dart';
import 'model_providers.dart';

class ModelSelectionScreen extends ConsumerWidget {
  const ModelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manifestAsync = ref.watch(manifestProvider);
    final manualSelections = ref.watch(manualSelectionsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual Model Selection'),
      ),
      body: manifestAsync.when(
        data: (manifest) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Card(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Select a specific classifier for each cow body part. These selections are active only when the Active Strategy is set to "Manual Selection".',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ...BodyPart.values.map((bodyPart) {
                // Get classifiers available for this body part
                final classifiers = manifest.classifiers
                    .where((c) => c.bodyPart == bodyPart)
                    .toList();

                // Get current selection or default to first
                final currentSelectionId = manualSelections[bodyPart] ?? classifiers.first.id;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bodyPart.displayName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: currentSelectionId,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: classifiers.map((c) {
                            return DropdownMenuItem(
                              value: c.id,
                              child: Text('${c.modelName} (${c.preferredFormat.toManifestString().toUpperCase()}, ${c.cropType?.toManifestString()})'),
                            );
                          }).toList(),
                          onChanged: (selectedId) {
                            if (selectedId != null) {
                              final updatedSelections = Map<BodyPart, String>.from(manualSelections);
                              updatedSelections[bodyPart] = selectedId;
                              ref.read(manualSelectionsProvider.notifier).state = updatedSelections;
                              // Refresh availability to update required highlight
                              ref.read(modelAvailabilityProvider.notifier).refresh();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        },
        error: (err, _) => Center(
          child: Text('Failed to load classifiers list: $err'),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
