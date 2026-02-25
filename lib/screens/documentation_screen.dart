// =============================================================================
// Documentation Screen
// Statisk brugervejledning med sammenklappelige sektioner
// =============================================================================

import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';

/// Dokumentationsskærm med 10 sammenklappelige sektioner.
///
/// Offentlig rute – kræver ingen authentication.
/// Tilgængelig fra både Settings og Login.
class DocumentationScreen extends StatelessWidget {
  const DocumentationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final seedColor = Theme.of(context).colorScheme.primary;
    final strings = AppStrings.of(context);

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: CustomScrollView(
            slivers: [
              _DocAppBar(seedColor: seedColor, isDark: isDark),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Intro
                    _DocParagraph(text: strings.docIntro, isDark: isDark),
                    const SizedBox(height: 8),

                    // 1. Opgavelister
                    _DocSectionCard(
                      icon: Icons.list_alt_rounded,
                      title: strings.docTaskListsTitle,
                      body: strings.docTaskListsBody,
                      seedColor: seedColor,
                      isDark: isDark,
                    ),

                    // 2. Opgaver
                    _DocSectionCard(
                      icon: Icons.task_alt_rounded,
                      title: strings.docTasksTitle,
                      body: strings.docTasksBody,
                      seedColor: seedColor,
                      isDark: isDark,
                    ),

                    // 3. Opgavefuldførelse
                    _DocSectionCard(
                      icon: Icons.check_circle_outline_rounded,
                      title: strings.docCompletionTitle,
                      body: strings.docCompletionBody,
                      seedColor: seedColor,
                      isDark: isDark,
                    ),

                    // 4. Streaks
                    _DocSectionCard(
                      icon: Icons.local_fire_department_rounded,
                      title: strings.docStreaksTitle,
                      body: strings.docStreaksBody,
                      seedColor: seedColor,
                      isDark: isDark,
                    ),

                    // 5. Deling & samarbejde
                    _DocSectionCard(
                      icon: Icons.group_rounded,
                      title: strings.docSharingTitle,
                      body: strings.docSharingBody,
                      seedColor: seedColor,
                      isDark: isDark,
                    ),

                    // 6. Ansvarsfordeling
                    _DocSectionCard(
                      icon: Icons.swap_horiz_rounded,
                      title: strings.docAssignmentTitle,
                      body: strings.docAssignmentBody,
                      seedColor: seedColor,
                      isDark: isDark,
                    ),

                    // 7. Cheers
                    _DocSectionCard(
                      icon: Icons.celebration_rounded,
                      title: strings.docCheersTitle,
                      body: strings.docCheersBody,
                      seedColor: seedColor,
                      isDark: isDark,
                    ),

                    // 8. Push-notifikationer
                    _DocSectionCard(
                      icon: Icons.notifications_outlined,
                      title: strings.docNotificationsTitle,
                      body: strings.docNotificationsBody,
                      seedColor: seedColor,
                      isDark: isDark,
                    ),

                    // 9. Indstillinger
                    _DocSectionCard(
                      icon: Icons.settings_outlined,
                      title: strings.docSettingsTitle,
                      body: strings.docSettingsBody,
                      seedColor: seedColor,
                      isDark: isDark,
                    ),

                    // 10. Konto
                    _DocSectionCard(
                      icon: Icons.account_circle_outlined,
                      title: strings.docAccountTitle,
                      body: strings.docAccountBody,
                      seedColor: seedColor,
                      isDark: isDark,
                    ),

                    // 11. Eksempel
                    _DocSectionCard(
                      icon: Icons.lightbulb_outline_rounded,
                      title: strings.docExampleTitle,
                      body: strings.docExampleBody,
                      seedColor: seedColor,
                      isDark: isDark,
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
}

/// App bar til dokumentationsskærmen
class _DocAppBar extends StatelessWidget {
  final Color seedColor;
  final bool isDark;

  const _DocAppBar({required this.seedColor, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final strings = AppStrings.of(context);

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
          strings.documentation,
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

/// Sammenklappelig sektionskort med ExpansionTile
class _DocSectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final Color seedColor;
  final bool isDark;

  const _DocSectionCard({
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
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            childrenPadding:
                const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: seedColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: seedColor),
            ),
            title: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            iconColor: isDark ? Colors.white38 : Colors.black26,
            collapsedIconColor: isDark ? Colors.white38 : Colors.black26,
            children: [
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
      ),
    );
  }
}

/// Intro-paragraf
class _DocParagraph extends StatelessWidget {
  final String text;
  final bool isDark;

  const _DocParagraph({required this.text, required this.isDark});

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
