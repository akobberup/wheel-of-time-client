// Design Version: 1.0.0 (se docs/DESIGN_GUIDELINES.md)

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/task_occurrence.dart';
import '../../config/api_config.dart';
import '../common/animated_card.dart';
import 'task_urgency.dart';
import 'task_card_badges.dart';

/// Medium-kort til tomorrow og this week - vertikalt design med tema-farver
class MediumTaskCard extends StatelessWidget {
  final UpcomingTaskOccurrenceResponse occurrence;
  final bool isClickable;
  final TaskUrgency urgency;
  final VoidCallback? onTap;
  final bool isDesktop;

  const MediumTaskCard({
    super.key,
    required this.occurrence,
    required this.isClickable,
    required this.urgency,
    this.onTap,
    this.isDesktop = false,
  });

  /// Parser hex color string til Color objekt
  Color _parseHexColor(String? hexString, Color fallback) {
    if (hexString == null || hexString.isEmpty) return fallback;

    final buffer = StringBuffer();
    if (hexString.length == 7) {
      buffer.write('FF');
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

    // Brug task listens tema farve
    final primaryColor = _parseHexColor(
      occurrence.taskListPrimaryColor,
      colorScheme.primary,
    );
    final secondaryColor = _parseHexColor(
      occurrence.taskListSecondaryColor,
      colorScheme.secondary,
    );

    return AnimatedCard(
      onTap: isClickable ? onTap : null,
      baseElevation: isDesktop ? 2 : 2,
      pressedElevation: isDesktop ? 6 : 4,
      margin: EdgeInsets.only(bottom: isDesktop ? 0 : 6),
      borderSide: BorderSide(
        color: primaryColor.withValues(alpha: 0.25),
        width: 1.5,
      ),
      borderRadius: isDesktop ? 14 : 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Billede sektion - kompakt version af hero
          _buildImageSection(context, primaryColor, secondaryColor),
          // Indhold sektion
          _buildContentSection(context, primaryColor),
        ],
      ),
    );
  }

  Widget _buildImageSection(BuildContext context, Color primaryColor, Color secondaryColor) {
    final imagePath = occurrence.taskImagePath;
    final imageHeight = isDesktop ? 90.0 : 110.0;

    // Lysere baggrund baseret på tema farve
    final backgroundColor = Color.lerp(primaryColor, Colors.white, 0.75) ??
        primaryColor.withValues(alpha: 0.2);

    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(isDesktop ? 14 : 16),
        topRight: Radius.circular(isDesktop ? 14 : 16),
      ),
      child: Container(
        height: imageHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              backgroundColor,
              Color.lerp(secondaryColor, Colors.white, 0.8) ?? backgroundColor,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Centreret billede
            if (imagePath != null && imagePath.isNotEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(isDesktop ? 12.0 : 16.0),
                  child: CachedNetworkImage(
                    imageUrl: ApiConfig.getImageUrl(imagePath),
                    fit: BoxFit.contain,
                    placeholder: (context, url) => _buildPlaceholder(primaryColor),
                    errorWidget: (context, url, error) => _buildPlaceholder(primaryColor),
                  ),
                ),
              )
            else
              Center(child: _buildPlaceholder(primaryColor)),

            // Due date badge øverst til højre
            Positioned(
              top: isDesktop ? 8 : 10,
              right: isDesktop ? 8 : 10,
              child: DueDateBadge(dueDate: occurrence.dueDate, compact: true),
            ),

            // Streak badge øverst til venstre
            if (occurrence.currentStreak != null && occurrence.currentStreak!.isActive)
              Positioned(
                top: isDesktop ? 8 : 10,
                left: isDesktop ? 8 : 10,
                child: AnimatedStreakBadge(
                  streakCount: occurrence.currentStreak!.streakCount,
                  isAtRisk: false,
                  small: true,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(Color color) {
    return Icon(
      Icons.task_alt_rounded,
      color: color.withValues(alpha: 0.4),
      size: isDesktop ? 36 : 44,
    );
  }

  Widget _buildContentSection(BuildContext context, Color primaryColor) {
    final theme = Theme.of(context);

    final titleStyle = isDesktop
        ? theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          )
        : theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          );

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 12.0 : 14.0,
        vertical: isDesktop ? 10.0 : 12.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Titel - store bogstaver, centreret
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              occurrence.taskName.toUpperCase(),
              style: titleStyle,
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ),
          SizedBox(height: isDesktop ? 6 : 8),
          // Task list label
          _buildTaskListLabel(context, primaryColor),
        ],
      ),
    );
  }

  Widget _buildTaskListLabel(BuildContext context, Color primaryColor) {
    final theme = Theme.of(context);

    // Brug tema farven til label baggrund
    final labelBackground = Color.lerp(primaryColor, Colors.white, 0.85) ??
        theme.colorScheme.surfaceContainerHigh;
    final labelTextColor = Color.lerp(primaryColor, Colors.black, 0.3) ??
        theme.colorScheme.onSurfaceVariant;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 8 : 10,
        vertical: isDesktop ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: labelBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.folder_outlined,
            size: isDesktop ? 11 : 12,
            color: labelTextColor,
          ),
          SizedBox(width: isDesktop ? 3 : 4),
          Flexible(
            child: Text(
              occurrence.taskListName,
              style: TextStyle(
                color: labelTextColor,
                fontSize: isDesktop ? 10 : 11,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
