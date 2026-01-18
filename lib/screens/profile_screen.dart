// =============================================================================
// Profile Screen
// Design Version: 1.0.0 (se docs/DESIGN_GUIDELINES.md)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/user_settings_provider.dart';
import '../models/user_settings.dart';
import '../models/enums.dart';
import '../l10n/app_strings.dart';
import '../widgets/common/gender_selector.dart';
import '../widgets/common/year_picker_sheet.dart';

/// Profil skærm med varm, organisk æstetik.
///
/// Design: v1.0.0 - Bruger den valgte tema-farve, bløde kort,
/// og konsistent typografi.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final authState = ref.watch(authProvider);
    final themeState = ref.watch(themeProvider);
    final userSettingsAsync = ref.watch(userSettingsProvider);
    final seedColor = themeState.seedColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = authState.user;

    if (user == null) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF121214) : const Color(0xFFFAFAF8),
        body: CustomScrollView(
          slivers: [
            _ProfileAppBar(seedColor: seedColor, isDark: isDark),
            SliverFillRemaining(
              child: Center(
                child: Text(
                  strings.noUserData,
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121214) : const Color(0xFFFAFAF8),
      body: CustomScrollView(
        slivers: [
          _ProfileAppBar(seedColor: seedColor, isDark: isDark),

          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 8),

                // Profil avatar med kamera-knap
                Center(
                  child: _ProfileAvatar(
                    initials: _getInitials(user.name),
                    seedColor: seedColor,
                    isDark: isDark,
                    onCameraTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(strings.imageUploadComingSoon),
                          backgroundColor: seedColor,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // Brugerens navn centreret
                Center(
                  child: Text(
                    user.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                // Email centreret
                Center(
                  child: Text(
                    user.email,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Personlig information sektion
                _SectionHeader(title: strings.personalInformation, seedColor: seedColor),
                const SizedBox(height: 12),

                _ProfileCard(
                  isDark: isDark,
                  seedColor: seedColor,
                  child: Column(
                    children: [
                      _ProfileInfoRow(
                        icon: Icons.person_outline_rounded,
                        label: strings.name,
                        value: user.name,
                        seedColor: seedColor,
                        isDark: isDark,
                      ),
                      Divider(
                        height: 24,
                        color: isDark ? Colors.white12 : Colors.black.withOpacity(0.06),
                      ),
                      _ProfileInfoRow(
                        icon: Icons.email_outlined,
                        label: strings.email,
                        value: user.email,
                        seedColor: seedColor,
                        isDark: isDark,
                        subtitle: strings.cannotBeChanged,
                      ),
                      Divider(
                        height: 24,
                        color: isDark ? Colors.white12 : Colors.black.withOpacity(0.06),
                      ),
                      // Køn
                      _ProfileInfoRow(
                        icon: Icons.person_outline_rounded,
                        label: strings.gender,
                        value: userSettingsAsync.whenOrNull(
                          data: (settings) => _getGenderDisplayName(settings.gender, strings),
                        ) ?? strings.notSpecified,
                        seedColor: seedColor,
                        isDark: isDark,
                      ),
                      Divider(
                        height: 24,
                        color: isDark ? Colors.white12 : Colors.black.withOpacity(0.06),
                      ),
                      // Fødselsår
                      _ProfileInfoRow(
                        icon: Icons.cake_outlined,
                        label: strings.birthYear,
                        value: userSettingsAsync.whenOrNull(
                          data: (settings) => settings.birthYear?.toString(),
                        ) ?? strings.notSpecified,
                        seedColor: seedColor,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Rediger profil sektion
                _SectionHeader(title: strings.actions, seedColor: seedColor),
                const SizedBox(height: 12),

                _ProfileCard(
                  isDark: isDark,
                  seedColor: seedColor,
                  onTap: () {
                    final currentSettings = userSettingsAsync.valueOrNull;
                    _showEditProfileSheet(
                      context: context,
                      ref: ref,
                      isDark: isDark,
                      seedColor: seedColor,
                      currentGender: currentSettings?.gender,
                      currentBirthYear: currentSettings?.birthYear,
                    );
                  },
                  child: _ActionRow(
                    icon: Icons.edit_outlined,
                    title: strings.editProfile,
                    subtitle: strings.editProfileDescription,
                    seedColor: seedColor,
                    isDark: isDark,
                  ),
                ),

                const SizedBox(height: 12),

                _ProfileCard(
                  isDark: isDark,
                  seedColor: seedColor,
                  onTap: () {
                    Navigator.of(context).pushNamed('/reset-password');
                  },
                  child: _ActionRow(
                    icon: Icons.lock_outline_rounded,
                    title: strings.changePassword,
                    subtitle: strings.changePasswordDescription,
                    seedColor: seedColor,
                    isDark: isDark,
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

  /// Henter initialer fra fuldt navn (f.eks. "John Doe" -> "JD")
  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  /// Konverterer Gender enum til lokaliseret display navn
  String _getGenderDisplayName(Gender? gender, AppStrings strings) {
    if (gender == null) return strings.notSpecified;
    switch (gender) {
      case Gender.MALE:
        return strings.genderMale;
      case Gender.FEMALE:
        return strings.genderFemale;
      case Gender.OTHER:
        return strings.genderOther;
    }
  }

  /// Viser bottom sheet til redigering af profil (køn og fødselsår)
  void _showEditProfileSheet({
    required BuildContext context,
    required WidgetRef ref,
    required bool isDark,
    required Color seedColor,
    required Gender? currentGender,
    required int? currentBirthYear,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E22) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => _EditProfileSheet(
        isDark: isDark,
        seedColor: seedColor,
        currentGender: currentGender,
        currentBirthYear: currentBirthYear,
      ),
    );
  }
}

/// Custom app bar til profil
class _ProfileAppBar extends StatelessWidget {
  final Color seedColor;
  final bool isDark;

  const _ProfileAppBar({required this.seedColor, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
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
          strings.profile,
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

/// Profil avatar med kamera-knap
class _ProfileAvatar extends StatelessWidget {
  final String initials;
  final Color seedColor;
  final bool isDark;
  final VoidCallback onCameraTap;

  const _ProfileAvatar({
    required this.initials,
    required this.seedColor,
    required this.isDark,
    required this.onCameraTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                seedColor.withOpacity(0.8),
                seedColor,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: seedColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 4,
          right: 4,
          child: GestureDetector(
            onTap: onCameraTap,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? const Color(0xFF222226) : Colors.white,
                border: Border.all(
                  color: isDark ? Colors.white12 : Colors.black.withOpacity(0.08),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.camera_alt_rounded,
                size: 18,
                color: seedColor,
              ),
            ),
          ),
        ),
      ],
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

/// Profil kort med blød styling
class _ProfileCard extends StatelessWidget {
  final bool isDark;
  final Color seedColor;
  final Widget child;
  final VoidCallback? onTap;

  const _ProfileCard({
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

/// Info række til profil data
class _ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color seedColor;
  final bool isDark;
  final String? subtitle;

  const _ProfileInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.seedColor,
    required this.isDark,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final labelColor = isDark ? Colors.white54 : Colors.black45;

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
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: labelColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 11,
                    color: labelColor,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Handlings-række med chevron
class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color seedColor;
  final bool isDark;

  const _ActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.seedColor,
    required this.isDark,
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
        Icon(
          Icons.chevron_right_rounded,
          color: isDark ? Colors.white38 : Colors.black26,
        ),
      ],
    );
  }
}

/// Bottom sheet til redigering af køn og fødselsår
class _EditProfileSheet extends ConsumerStatefulWidget {
  final bool isDark;
  final Color seedColor;
  final Gender? currentGender;
  final int? currentBirthYear;

  const _EditProfileSheet({
    required this.isDark,
    required this.seedColor,
    required this.currentGender,
    required this.currentBirthYear,
  });

  @override
  ConsumerState<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<_EditProfileSheet> {
  late Gender? _gender;
  late int? _birthYear;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _gender = widget.currentGender;
    _birthYear = widget.currentBirthYear;
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);

    try {
      await ref.read(userSettingsProvider.notifier).updateSettings(
        UpdateUserSettingsRequest(
          gender: _gender,
          birthYear: _birthYear,
        ),
      );

      if (mounted) {
        final strings = AppStrings.of(context);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.profileUpdated),
            backgroundColor: widget.seedColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final strings = AppStrings.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.failedToUpdateProfile),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final textColor = widget.isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subtitleColor = widget.isDark ? Colors.white54 : Colors.black45;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titel
            Center(
              child: Text(
                strings.editProfile,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                strings.thisHelpsPersonalize,
                style: TextStyle(
                  fontSize: 13,
                  color: subtitleColor,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Køn vælger
            GenderSelector(
              selectedGender: _gender,
              onChanged: (gender) => setState(() => _gender = gender),
              themeColor: widget.seedColor,
            ),

            const SizedBox(height: 20),

            // Fødselsår
            Text(
              strings.birthYear,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: subtitleColor,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                showYearPickerSheet(
                  context: context,
                  selectedYear: _birthYear,
                  seedColor: widget.seedColor,
                  onYearSelected: (year) => setState(() => _birthYear = year),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.isDark
                        ? Colors.white.withValues(alpha: 0.12)
                        : Colors.black.withValues(alpha: 0.12),
                  ),
                  color: widget.isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.02),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.cake_outlined,
                      size: 20,
                      color: _birthYear != null ? widget.seedColor : subtitleColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _birthYear?.toString() ?? strings.selectBirthYear,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: _birthYear != null ? textColor : subtitleColor,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: subtitleColor,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Gem-knap
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.seedColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        strings.save,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
