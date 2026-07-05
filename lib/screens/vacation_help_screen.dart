// =============================================================================
// Vacation Help Screen
// Forklarer feriekalenderen og de enkelte ferie-tilstande.
// =============================================================================

import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';

/// Hjælpeside der beskriver ferieperioder og de tre ferie-tilstande.
class VacationHelpScreen extends StatelessWidget {
  const VacationHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final seedColor = theme.colorScheme.primary;
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.vacationHelpTitle),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _Paragraph(text: strings.vacationHelpIntro, isDark: isDark),
              const SizedBox(height: 8),

              // Ferieperioder
              _HelpCard(
                icon: Icons.date_range_rounded,
                title: strings.vacationHelpPeriodsTitle,
                body: strings.vacationHelpPeriodsBody,
                seedColor: seedColor,
                isDark: isDark,
              ),

              // Ingen ændring
              _HelpCard(
                icon: Icons.all_inclusive_rounded,
                title: strings.vacationModeNoChange,
                body: strings.vacationHelpNoChangeBody,
                seedColor: seedColor,
                isDark: isDark,
              ),

              // Ikke i ferie
              _HelpCard(
                icon: Icons.work_outline_rounded,
                title: strings.vacationModeNotInVacation,
                body: strings.vacationHelpNotInVacationBody,
                seedColor: seedColor,
                isDark: isDark,
              ),

              // Kun i ferie
              _HelpCard(
                icon: Icons.beach_access_rounded,
                title: strings.vacationModeOnlyInVacation,
                body: strings.vacationHelpOnlyInVacationBody,
                seedColor: seedColor,
                isDark: isDark,
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

/// Intro-paragraf.
class _Paragraph extends StatelessWidget {
  final String text;
  final bool isDark;

  const _Paragraph({required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          height: 1.5,
          color: isDark ? Colors.white70 : Colors.black87,
        ),
      ),
    );
  }
}

/// Kort med ikon, titel og forklaring - matcher dokumentationsskærmens stil.
class _HelpCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final Color seedColor;
  final bool isDark;

  const _HelpCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.seedColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.06),
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: seedColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: seedColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              body,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
