import 'package:flutter/material.dart';
import '../model_management/model_status_screen.dart';
import '../model_management/model_selection_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSettingsSection(
            theme: theme,
            title: 'Machine Learning',
            children: [
              _buildSettingsTile(
                icon: Icons.psychology_rounded,
                title: 'Model Configuration & Status',
                subtitle: 'Manage local models download, active strategies, and YOLO thresholds.',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const ModelStatusScreen()),
                  );
                },
              ),
              _buildSettingsTile(
                icon: Icons.settings_suggest_rounded,
                title: 'Manual Model Selection',
                subtitle: 'Select specific classifier models for individual body parts.',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const ModelSelectionScreen()),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettingsSection(
            theme: theme,
            title: 'About App',
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline_rounded),
                title: const Text('Cattle Disease Detection'),
                subtitle: const Text('Version 1.0.0 • Clean Architecture'),
              ),
              ListTile(
                leading: const Icon(Icons.lock_outline_rounded),
                title: const Text('Privacy & Security'),
                subtitle: const Text('Inference runs locally on-device. Your cow photos are never uploaded to any server.'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection({
    required ThemeData theme,
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Text(
            title.toUpperCase(),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 2,
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
