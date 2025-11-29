import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/task_occurrence.dart';
import '../../config/api_config.dart';
import '../common/animated_card.dart';
import 'task_urgency.dart';
import 'task_card_badges.dart';

/// Medium-kort til tomorrow og this week - moderat størrelse med accent farve
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isTomorrow = urgency == TaskUrgency.tomorrow;
    final accentColor = isTomorrow ? colorScheme.primary : colorScheme.secondary;

    return AnimatedCard(
      onTap: isClickable ? onTap : null,
      baseElevation: isDesktop ? 3 : 2,
      pressedElevation: isDesktop ? 8 : 6,
      margin: EdgeInsets.only(bottom: isDesktop ? 0 : 4),
      borderSide: BorderSide(
        color: accentColor.withValues(alpha: 0.3),
        width: 1,
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Accent-linje på venstre side
            Container(
              width: isDesktop ? 3 : 4,
              color: accentColor,
            ),
            // Lille billede eller ikon
            _buildImageSection(context, accentColor),
            // Indhold
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 10 : 12,
                  vertical: isDesktop ? 6 : 8,
                ),
                child: _buildContent(context, accentColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context, Color accentColor) {
    final imagePath = occurrence.taskImagePath;
    final imageWidth = isDesktop ? 56.0 : 70.0;

    if (imagePath != null && imagePath.isNotEmpty) {
      return SizedBox(
        width: imageWidth,
        child: CachedNetworkImage(
          imageUrl: ApiConfig.getImageUrl(imagePath),
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildPlaceholder(accentColor),
          errorWidget: (context, url, error) => _buildPlaceholder(accentColor),
        ),
      );
    }

    return _buildPlaceholder(accentColor);
  }

  Widget _buildPlaceholder(Color accentColor) {
    final imageWidth = isDesktop ? 56.0 : 70.0;
    final iconSize = isDesktop ? 22.0 : 28.0;

    return Container(
      width: imageWidth,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withValues(alpha: 0.2),
            accentColor.withValues(alpha: 0.1),
          ],
        ),
      ),
      child: Icon(
        Icons.task_alt,
        color: accentColor.withValues(alpha: 0.5),
        size: iconSize,
      ),
    );
  }

  Widget _buildContent(BuildContext context, Color accentColor) {
    final theme = Theme.of(context);
    final titleStyle = isDesktop
        ? theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)
        : theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold);
    final subtitleFontSize = isDesktop ? 11.0 : 12.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header med titel og badge
        Row(
          children: [
            Expanded(
              child: Text(
                occurrence.taskName,
                style: titleStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: isDesktop ? 6 : 8),
            DueDateBadge(dueDate: occurrence.dueDate, compact: isDesktop),
          ],
        ),
        SizedBox(height: isDesktop ? 1 : 2),
        // Task list
        Row(
          children: [
            Icon(
              Icons.list,
              size: isDesktop ? 10 : 12,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            SizedBox(width: isDesktop ? 3 : 4),
            Expanded(
              child: Text(
                occurrence.taskListName,
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: subtitleFontSize,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        // Streak badge hvis aktiv
        if (occurrence.currentStreak != null &&
            occurrence.currentStreak!.isActive) ...[
          SizedBox(height: isDesktop ? 3 : 4),
          AnimatedStreakBadge(
            streakCount: occurrence.currentStreak!.streakCount,
            isAtRisk: false,
            small: true,
          ),
        ],
      ],
    );
  }
}
