// =============================================================================
// Settings Screen
// Design Version: 1.0.0 (se docs/DESIGN_GUIDELINES.md)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../widgets/settings/color_picker_grid.dart';
import '../config/version_config.dart';
import '../l10n/app_strings.dart';

/// Indstillings-skærm med varm, organisk æstetik.
///
/// Design: v1.0.0 - Bruger den valgte tema-farve, bløde kort,
/// og konsistent typografi.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final seedColor = themeState.seedColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: CustomScrollView(
            slivers: [
              // Custom app bar
              _SettingsAppBar(seedColor: seedColor, isDark: isDark),

              // Indhold
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Udseende sektion
                    _SectionHeader(
                        title: strings.appearance, seedColor: seedColor),
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
                            title: strings.themeColor,
                            seedColor: seedColor,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            strings.chooseThemeColor,
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
                        title: strings.darkMode,
                        subtitle: strings.darkModeDescription,
                        value: themeState.isDarkMode,
                        seedColor: seedColor,
                        isDark: isDark,
                        onChanged: (_) => themeNotifier.toggleDarkMode(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Sprog
                    _LanguageSelector(
                      seedColor: seedColor,
                      isDark: isDark,
                    ),

                    const SizedBox(height: 28),

                    // Konto sektion
                    _SectionHeader(
                        title: strings.account, seedColor: seedColor),
                    const SizedBox(height: 12),

                    _SettingsCard(
                      isDark: isDark,
                      seedColor: seedColor,
                      onTap: () => context.push('/profile'),
                      child: _NavigationRow(
                        icon: Icons.person_outline_rounded,
                        title: strings.profile,
                        subtitle: strings.editProfileInfo,
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
                        title: strings.logout,
                        subtitle: strings.logoutDescription,
                        seedColor: Colors.red,
                        isDark: isDark,
                        showChevron: false,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Support & Juridisk sektion
                    _SectionHeader(
                        title: 'Support & juridisk', seedColor: seedColor),
                    const SizedBox(height: 12),

                    _SettingsCard(
                      isDark: isDark,
                      seedColor: seedColor,
                      onTap: () => context.push('/support'),
                      child: _NavigationRow(
                        icon: Icons.help_outline_rounded,
                        title: 'Support',
                        subtitle: 'Hjælp, fejlrapporter og forslag',
                        seedColor: seedColor,
                        isDark: isDark,
                      ),
                    ),

                    const SizedBox(height: 12),

                    _SettingsCard(
                      isDark: isDark,
                      seedColor: seedColor,
                      onTap: () => context.push('/privacy-policy'),
                      child: _NavigationRow(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privatlivspolitik',
                        subtitle: 'Sådan håndterer vi dine data',
                        seedColor: seedColor,
                        isDark: isDark,
                      ),
                    ),

                    const SizedBox(height: 12),

                    _SettingsCard(
                      isDark: isDark,
                      seedColor: seedColor,
                      onTap: () => context.push('/security'),
                      child: _NavigationRow(
                        icon: Icons.security_outlined,
                        title: 'Sikkerhed',
                        subtitle: 'Rapporter sikkerhedsproblemer',
                        seedColor: seedColor,
                        isDark: isDark,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Farezone sektion
                    _SectionHeader(
                        title: strings.dangerZone, seedColor: Colors.red),
                    const SizedBox(height: 12),

                    _SettingsCard(
                      isDark: isDark,
                      seedColor: Colors.red,
                      onTap: () => _showDeleteAccountDialog(context, ref),
                      child: _NavigationRow(
                        icon: Icons.delete_forever_rounded,
                        title: strings.deleteAccount,
                        subtitle: strings.deleteAccountWarning,
                        seedColor: Colors.red,
                        isDark: isDark,
                        showChevron: false,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Om sektion
                    _SectionHeader(title: strings.about, seedColor: seedColor),
                    const SizedBox(height: 12),

                    _SettingsCard(
                      isDark: isDark,
                      seedColor: seedColor,
                      child: Column(
                        children: [
                          _InfoRow(
                            icon: Icons.info_outline_rounded,
                            title: strings.version,
                            value: VersionConfig.version,
                            isDark: isDark,
                          ),
                          Divider(
                            height: 24,
                            color: isDark
                                ? Colors.white12
                                : Colors.black.withOpacity(0.06),
                          ),
                          _InfoRow(
                            icon: Icons.calendar_today_outlined,
                            title: strings.build,
                            value: VersionConfig.buildTime.isNotEmpty
                                ? VersionConfig.buildTime
                                : strings.development,
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
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context, WidgetRef ref) async {
    final strings = AppStrings.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final dialogStrings = AppStrings.of(context);
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(dialogStrings.logoutConfirmTitle),
          content: Text(dialogStrings.logoutConfirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                dialogStrings.cancel,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                dialogStrings.logout,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      await ref.read(authProvider.notifier).logout();
      if (context.mounted) {
        context.go('/login');
      }
    }
  }

  /// Viser dialog til bekræftelse af kontosletning
  Future<void> _showDeleteAccountDialog(
      BuildContext context, WidgetRef ref) async {
    final strings = AppStrings.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final dialogStrings = AppStrings.of(context);
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(dialogStrings.deleteAccountTitle),
          content: Text(dialogStrings.deleteAccountWarning),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                dialogStrings.cancel,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                dialogStrings.deleteAccountConfirm,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      await _requestAccountDeletion(context, ref);
    }
  }

  /// Sender anmodning om kontosletning via API
  Future<void> _requestAccountDeletion(
      BuildContext context, WidgetRef ref) async {
    final strings = AppStrings.of(context);
    final apiService = ref.read(apiServiceProvider);
    final authState = ref.read(authProvider);

    try {
      // Kald API for at anmode om kontosletning
      await apiService.requestAccountDeletion();

      // Vis success dialog med brugerens email
      if (context.mounted) {
        final userEmail = authState.user?.email ?? '';
        await showDialog(
          context: context,
          builder: (context) {
            final dialogStrings = AppStrings.of(context);
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title:
                  const Icon(Icons.mail_outline, size: 48, color: Colors.green),
              content: Text(
                dialogStrings.deleteAccountEmailSent(userEmail),
                textAlign: TextAlign.center,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(dialogStrings.ok),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Vis fejl dialog
      if (context.mounted) {
        await showDialog(
          context: context,
          builder: (context) {
            final dialogStrings = AppStrings.of(context);
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Text(dialogStrings.error),
              content: Text(dialogStrings.deleteAccountError),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(dialogStrings.ok),
                ),
              ],
            );
          },
        );
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
    final strings = AppStrings.of(context);
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);

    return SliverAppBar(
      expandedHeight: 100,
      floating: false,
      pinned: true,
      backgroundColor:
          isDark ? const Color(0xFF121214) : const Color(0xFFFAFAF8),
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, color: textColor),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 52, bottom: 16),
        title: Text(
          strings.settings,
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
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.06),
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

/// Widget til valg af app-sprog med flag-ikoner.
///
/// Viser det aktuelt valgte sprog med et tilhørende flag-ikon.
/// Ved tryk åbnes en bottom sheet hvor brugeren kan vælge mellem
/// tilgængelige sprog (dansk/engelsk). Valget gemmes automatisk
/// via [LocaleNotifier] og synkroniseres på tværs af appen.
class _LanguageSelector extends ConsumerWidget {
  final Color seedColor;
  final bool isDark;

  const _LanguageSelector({
    required this.seedColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final currentLocale = ref.watch(localeProvider);
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subtitleColor = isDark ? Colors.white54 : Colors.black45;

    // Bestem flag baseret på aktuel locale
    final currentFlag = currentLocale.languageCode == 'da' ? '🇩🇰' : '🇬🇧';

    return _SettingsCard(
      isDark: isDark,
      seedColor: seedColor,
      onTap: () => _showLanguagePicker(
        context: context,
        ref: ref,
        seedColor: seedColor,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: seedColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.translate_rounded, size: 20, color: seedColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.language,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  strings.chooseLanguage,
                  style: TextStyle(
                    fontSize: 13,
                    color: subtitleColor,
                  ),
                ),
              ],
            ),
          ),
          Text(
            currentFlag,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.chevron_right_rounded,
            color: isDark ? Colors.white38 : Colors.black26,
          ),
        ],
      ),
    );
  }

  /// Viser bottom sheet med sprogvalg.
  void _showLanguagePicker({
    required BuildContext context,
    required WidgetRef ref,
    required Color seedColor,
  }) {
    final currentLocale = ref.read(localeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _LanguagePickerSheet(
        currentLocale: currentLocale,
        seedColor: seedColor,
        onLanguageSelected: (locale) {
          ref.read(localeProvider.notifier).setLocale(locale);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

/// Bottom sheet til valg af sprog.
///
/// Viser en liste af tilgængelige sprog med flag-ikoner og
/// markerer det aktuelt valgte sprog med en checkmark.
class _LanguagePickerSheet extends StatelessWidget {
  final Locale currentLocale;
  final Color seedColor;
  final ValueChanged<Locale> onLanguageSelected;

  const _LanguagePickerSheet({
    required this.currentLocale,
    required this.seedColor,
    required this.onLanguageSelected,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Titel
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                strings.language,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                ),
              ),
            ),
            // Dansk
            _LanguageOption(
              flag: '🇩🇰',
              name: strings.danish,
              isSelected: currentLocale.languageCode == 'da',
              isDark: isDark,
              seedColor: seedColor,
              onTap: () => onLanguageSelected(const Locale('da')),
            ),
            Divider(
              height: 1,
              indent: 56,
              color: isDark ? Colors.white12 : Colors.black.withOpacity(0.06),
            ),
            // Engelsk
            _LanguageOption(
              flag: '🇬🇧',
              name: strings.english,
              isSelected: currentLocale.languageCode == 'en',
              isDark: isDark,
              seedColor: seedColor,
              onTap: () => onLanguageSelected(const Locale('en')),
            ),
          ],
        ),
      ),
    );
  }
}

/// En enkelt sprogmulighed i sprogvælgeren.
///
/// Viser et flag-ikon, sprogets navn, og en checkmark hvis sproget
/// er det aktuelt valgte. Håndterer tap-events for at skifte sprog.
class _LanguageOption extends StatelessWidget {
  final String flag;
  final String name;
  final bool isSelected;
  final bool isDark;
  final Color seedColor;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.flag,
    required this.name,
    required this.isSelected,
    required this.isDark,
    required this.seedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            Text(
              flag,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: textColor,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_rounded,
                color: seedColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
