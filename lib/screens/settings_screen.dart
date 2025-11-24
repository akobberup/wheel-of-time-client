import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../widgets/settings/color_picker_grid.dart';
import 'profile_screen.dart';

/// Indstillings skærm hvor brugeren kan tilpasse app udseende og præferencer.
/// Inkluderer tema farve valg, mørk tilstand toggle, og link til profil.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Indstillinger'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Udseende sektion
          _buildSectionHeader('Udseende'),
          const SizedBox(height: 16),

          // Tema farve valg
          _buildSettingCard(
            context,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tema farve',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Vælg en farve til at tilpasse dit tema',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 24),
                ColorPickerGrid(
                  selectedColor: themeState.seedColor,
                  onColorSelected: (color) {
                    themeNotifier.updateThemeColor(color);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Mørk tilstand
          _buildSettingCard(
            context,
            child: SwitchListTile(
              title: const Text('Mørk tilstand'),
              subtitle: const Text('Skift mellem lys og mørk tema'),
              value: themeState.isDarkMode,
              onChanged: (_) {
                themeNotifier.toggleDarkMode();
              },
              contentPadding: EdgeInsets.zero,
            ),
          ),

          const SizedBox(height: 32),

          // Konto sektion
          _buildSectionHeader('Konto'),
          const SizedBox(height: 16),

          _buildSettingCard(
            context,
            child: ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profil'),
              subtitle: const Text('Rediger din profil information'),
              trailing: const Icon(Icons.chevron_right),
              contentPadding: EdgeInsets.zero,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 32),

          // Om sektion
          _buildSectionHeader('Om'),
          const SizedBox(height: 16),

          _buildSettingCard(
            context,
            child: Column(
              children: [
                _buildInfoTile(
                  context,
                  icon: Icons.info_outline,
                  title: 'Version',
                  value: '1.0.0',
                ),
                const Divider(height: 1),
                _buildInfoTile(
                  context,
                  icon: Icons.language,
                  title: 'Sprog',
                  value: 'Dansk',
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// Bygger en sektion header med styled tekst
  Widget _buildSectionHeader(String title) {
    return Builder(
      builder: (context) => Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
      ),
    );
  }

  /// Bygger et card til at indeholde indstillinger med Material 3 styling
  Widget _buildSettingCard(BuildContext context, {required Widget child}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }

  /// Bygger en info tile med ikon, titel og værdi
  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Text(
        value,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }
}
