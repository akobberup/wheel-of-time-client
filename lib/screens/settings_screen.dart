// =============================================================================
// Settings Screen
// Design Version: 1.0.0 (se docs/DESIGN_GUIDELINES.md)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/settings/color_picker_grid.dart';
import '../config/version_config.dart';

/// Indstillings-skærm med varm, organisk æstetik.
///
/// Design: v1.0.0 - Bruger den valgte tema-farve, bløde kort,
/// og konsistent typografi.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final seedColor = themeState.seedColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Custom app bar
          _SettingsAppBar(seedColor: seedColor, isDark: isDark),

          // Indhold
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Udseende sektion
                _SectionHeader(title: 'Udseende', seedColor: seedColor),
                const SizedBox(height: 12),

                // Tema farve
                _SettingsCard(
                  isDark: isDark,
                  seedColor: seedColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CardTitle(
                        icon: Icons.palette_outlined,
                        title: 'Tema farve',
                        seedColor: seedColor,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Vælg en farve til at tilpasse dit tema',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ColorPickerGrid(
                        selectedColor: themeState.seedColor,
                        onColorSelected: (color) {
                          themeNotifier.updateThemeColor(color);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Mørk tilstand
                _SettingsCard(
                  isDark: isDark,
                  seedColor: seedColor,
                  child: _ToggleRow(
                    icon: Icons.dark_mode_outlined,
                    title: 'Mørk tilstand',
                    subtitle: 'Skift mellem lys og mørk tema',
                    value: themeState.isDarkMode,
                    seedColor: seedColor,
                    isDark: isDark,
                    onChanged: (_) => themeNotifier.toggleDarkMode(),
                  ),
                ),

                const SizedBox(height: 28),

                // Konto sektion
                _SectionHeader(title: 'Konto', seedColor: seedColor),
                const SizedBox(height: 12),

                _SettingsCard(
                  isDark: isDark,
                  seedColor: seedColor,
                  onTap: () => context.push('/profile'),
                  child: _NavigationRow(
                    icon: Icons.person_outline_rounded,
                    title: 'Profil',
                    subtitle: 'Rediger din profil information',
                    seedColor: seedColor,
                    isDark: isDark,
                  ),
                ),

                const SizedBox(height: 12),

                _SettingsCard(
                  isDark: isDark,
                  seedColor: seedColor,
                  onTap: () => _showLogoutDialog(context, ref),
                  child: _NavigationRow(
                    icon: Icons.logout_rounded,
                    title: 'Log ud',
                    subtitle: 'Log ud af din konto',
                    seedColor: Colors.red,
                    isDark: isDark,
                    showChevron: false,
                  ),
                ),

                const SizedBox(height: 28),

                // Om sektion
                _SectionHeader(title: 'Om', seedColor: seedColor),
                const SizedBox(height: 12),

                _SettingsCard(
                  isDark: isDark,
                  seedColor: seedColor,
                  child: Column(
                    children: [
                      _InfoRow(
                        icon: Icons.info_outline_rounded,
                        title: 'Version',
                        value: VersionConfig.version,
                        isDark: isDark,
                      ),
                      Divider(
                        height: 24,
                        color: isDark ? Colors.white12 : Colors.black.withOpacity(0.06),
                      ),
                      _InfoRow(
                        icon: Icons.calendar_today_outlined,
                        title: 'Build',
                        value: VersionConfig.buildTime.isNotEmpty 
                            ? VersionConfig.buildTime 
                            : 'Development',
                        isDark: isDark,
                      ),
                      Divider(
                        height: 24,
                        color: isDark ? Colors.white12 : Colors.black.withOpacity(0.06),
                      ),
                      _InfoRow(
                        icon: Icons.language_rounded,
                        title: 'Sprog',
                        value: 'Dansk',
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context, WidgetRef ref) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log ud'),
        content: const Text('Er du sikker på at du vil logge ud?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Annuller',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Log ud',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(authProvider.notifier).logout();
      if (context.mounted) {
        context.go('/login');
      }
    }
  }
}

/// Custom app bar til settings
class _SettingsAppBar extends StatelessWidget {
  final Color seedColor;
  final bool isDark;

  const _SettingsAppBar({required this.seedColor, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);

    return SliverAppBar(
      expandedHeight: 100,
      floating: false,
      pinned: true,
      backgroundColor: isDark ? const Color(0xFF121214) : const Color(0xFFFAFAF8),
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, color: textColor),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 52, bottom: 16),
        title: Text(
          'Indstillinger',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

/// Sektion header
class _SectionHeader extends StatelessWidget {
  final String title;
  final Color seedColor;

  const _SectionHeader({required this.title, required this.seedColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: seedColor,
        ),
      ),
    );
  }
}

/// Settings kort med blød styling
class _SettingsCard extends StatelessWidget {
  final bool isDark;
  final Color seedColor;
  final Widget child;
  final VoidCallback? onTap;

  const _SettingsCard({
    required this.isDark,
    required this.seedColor,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }
}

/// Kort titel med ikon
class _CardTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color seedColor;
  final bool isDark;

  const _CardTitle({
    required this.icon,
    required this.title,
    required this.seedColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);

    return Row(
      children: [
        Icon(icon, size: 20, color: seedColor),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );
  }
}

/// Toggle række med switch
class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final Color seedColor;
  final bool isDark;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.seedColor,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subtitleColor = isDark ? Colors.white54 : Colors.black45;

    return Row(
      children: [
        Icon(icon, size: 22, color: seedColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: subtitleColor,
                ),
              ),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: seedColor,
        ),
      ],
    );
  }
}

/// Navigation række med chevron
class _NavigationRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color seedColor;
  final bool isDark;
  final bool showChevron;

  const _NavigationRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.seedColor,
    required this.isDark,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subtitleColor = isDark ? Colors.white54 : Colors.black45;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: seedColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: seedColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: subtitleColor,
                ),
              ),
            ],
          ),
        ),
        if (showChevron)
          Icon(
            Icons.chevron_right_rounded,
            color: isDark ? Colors.white38 : Colors.black26,
          ),
      ],
    );
  }
}

/// Info række til version osv.
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool isDark;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final valueColor = isDark ? Colors.white54 : Colors.black45;

    return Row(
      children: [
        Icon(icon, size: 20, color: isDark ? Colors.white38 : Colors.black26),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
