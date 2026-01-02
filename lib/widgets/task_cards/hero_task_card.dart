// Design Version: 1.0.0 (se docs/DESIGN_GUIDELINES.md)

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/task_occurrence.dart';
import '../../l10n/app_strings.dart';
import '../../config/api_config.dart';
import '../common/animated_card.dart';
import 'task_urgency.dart';
import 'task_card_badges.dart';

/// Hero-kort til overdue og today opgaver - stort, iøjnefaldende design med billede
class HeroTaskCard extends StatelessWidget {
  final UpcomingTaskOccurrenceResponse occurrence;
  final bool isClickable;
  final TaskUrgency urgency;
  final VoidCallback? onTap;
  final bool isDesktop;

  const HeroTaskCard({
    super.key,
    required this.occurrence,
    required this.isClickable,
    required this.urgency,
    this.onTap,
    this.isDesktop = false,
  });

  /// Parser hex color string (f.eks. "#A8D5A2") til Color objekt
  Color _parseHexColor(String? hexString, Color fallback) {
    if (hexString == null || hexString.isEmpty) return fallback;
    
    final buffer = StringBuffer();
    if (hexString.length == 7) {
      buffer.write('FF'); // Tilføj alpha hvis ikke angivet
      buffer.write(hexString.replaceFirst('#', ''));
    } else if (hexString.length == 9) {
      buffer.write(hexString.replaceFirst('#', ''));
    } else {
      return fallback;
    }
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isOverdue = urgency == TaskUrgency.overdue;
    
    // Brug task listens tema farve, eller fallback til standard farver
    final primaryColor = _parseHexColor(
      occurrence.taskListPrimaryColor,
      isOverdue ? colorScheme.error : colorScheme.tertiary,
    );
    final accentColor = isOverdue ? colorScheme.error : primaryColor;

    // Giv kortet en fast aspect ratio for at undgå unbounded constraints
    return AspectRatio(
      aspectRatio: isDesktop ? 2.5 : 1.8,
      child: AnimatedCard(
        onTap: isClickable ? onTap : null,
        baseElevation: isDesktop ? 6 : 4,
        pressedElevation: isDesktop ? 12 : 8,
        margin: EdgeInsets.only(bottom: isDesktop ? 0 : 8),
        borderSide: BorderSide(
          color: accentColor.withValues(alpha: 0.5),
          width: 2,
        ),
        borderRadius: isDesktop ? 16 : 20,
        child: Column(
          children: [
            // Billede sektion - viser illustration centreret
            Expanded(
              flex: 3,
              child: _buildImageSection(context, accentColor),
            ),
            // Titel sektion - store bogstaver, fed, centreret
            _buildTitleSection(context),
            // Beskrivelse sektion (hvis den findes)
            if (occurrence.description != null && occurrence.description!.isNotEmpty)
              _buildDescriptionSection(context),
            // Kontroller/metadata sektion - fast højde, farvet baggrund
            _buildControlsSection(context, accentColor),
          ],
        ),
      ),
    );
  }

  /// Billede sektion med centreret illustration og badges
  Widget _buildImageSection(BuildContext context, Color accentColor) {
    final theme = Theme.of(context);
    final isOverdue = urgency == TaskUrgency.overdue;
    final imagePath = occurrence.taskImagePath;

    // Baggrundsfarve: brug task listens tema farve (lysere variant) eller fallback
    final themeColor = _parseHexColor(
      occurrence.taskListPrimaryColor,
      theme.colorScheme.tertiaryContainer,
    );
    // Lav en lysere version af farven til baggrunden
    final backgroundColor = isOverdue
        ? theme.colorScheme.errorContainer
        : Color.lerp(themeColor, Colors.white, 0.7) ?? themeColor.withValues(alpha: 0.3);

    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(isDesktop ? 16 : 20),
        topRight: Radius.circular(isDesktop ? 16 : 20),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Ensfarvet baggrund
          Container(color: backgroundColor),
          
          // Centreret billede med afrundede hjørner
          if (imagePath != null && imagePath.isNotEmpty)
            Center(
              child: Padding(
                // Padding for at give billedet "åndehul"
                padding: EdgeInsets.all(isDesktop ? 20.0 : 24.0),
                child: ClipRRect(
                  // Afrundet hjørner der matcher kortets design-sprog
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    // Subtil ramme omkring billedet
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11), // 1px mindre for border
                      child: CachedNetworkImage(
                        imageUrl: ApiConfig.getImageUrl(imagePath),
                        fit: BoxFit.contain, // Bevar billedets proportioner
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => Icon(
                          Icons.image_not_supported_outlined,
                          size: isDesktop ? 60 : 80,
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          
          // Streak badge øverst til venstre
          if (occurrence.currentStreak != null && occurrence.currentStreak!.isActive)
            Positioned(
              top: isDesktop ? 12 : 16,
              left: isDesktop ? 12 : 16,
              child: AnimatedStreakBadge(
                streakCount: occurrence.currentStreak!.streakCount,
                isAtRisk: _shouldShowStreakWarning(),
              ),
            ),
          
          // Urgency banner øverst til højre
          if (isOverdue)
            Positioned(
              top: 0,
              right: 0,
              child: _buildUrgencyBanner(context),
            ),
        ],
      ),
    );
  }

  /// Titel sektion - store bogstaver, fed, centreret, skalerer ned hvis nødvendigt
  Widget _buildTitleSection(BuildContext context) {
    final theme = Theme.of(context);
    
    final titleStyle = isDesktop
        ? theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          )
        : theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          );

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 16.0 : 20.0,
        vertical: isDesktop ? 12.0 : 16.0,
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          occurrence.taskName.toUpperCase(),
          style: titleStyle,
          textAlign: TextAlign.center,
          maxLines: 1,
        ),
      ),
    );
  }

  /// Beskrivelse sektion - centreret, subtil farve
  Widget _buildDescriptionSection(BuildContext context) {
    final theme = Theme.of(context);
    
    final descriptionStyle = isDesktop
        ? theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          )
        : theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          );

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 16.0 : 20.0,
      ),
      child: Text(
        occurrence.description!,
        style: descriptionStyle,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// Kontroller/metadata sektion - ingen baggrund, matcher resten af kortet
  Widget _buildControlsSection(BuildContext context, Color accentColor) {
    return Padding(
      padding: EdgeInsets.only(
        left: isDesktop ? 16.0 : 20.0,
        right: isDesktop ? 16.0 : 20.0,
        bottom: isDesktop ? 12.0 : 16.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Opgave-liste og schedule info
          _buildTaskListLabel(context),
          
          // Streak advarsel hvis relevant
          if (_shouldShowStreakWarning())
            Padding(
              padding: EdgeInsets.only(top: isDesktop ? 8 : 10),
              child: StreakWarningBanner(
                streakCount: occurrence.currentStreak!.streakCount,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTaskListLabel(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.list,
            size: 14,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            occurrence.taskListName,
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgencyBanner(BuildContext context) {
    final strings = AppStrings.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_amber, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text(
            strings.overdue,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  bool _shouldShowStreakWarning() {
    if (occurrence.currentStreak == null || !occurrence.currentStreak!.isActive) {
      return false;
    }
    final now = DateTime.now();
    final hoursUntilDue = occurrence.dueDate.difference(now).inHours;
    return hoursUntilDue > 0 && hoursUntilDue <= 6;
  }
}
