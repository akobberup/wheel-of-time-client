import 'package:flutter/material.dart';
import '../../models/task_occurrence.dart';
import '../common/animated_card.dart';
import 'task_card_badges.dart';

/// Kompakt kort til future opgaver - minimalistisk design
class CompactTaskCard extends StatelessWidget {
  final UpcomingTaskOccurrenceResponse occurrence;
  final bool isClickable;
  final VoidCallback? onTap;
  final bool isDesktop;

  const CompactTaskCard({
    super.key,
    required this.occurrence,
    required this.isClickable,
    this.onTap,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Responsive dimensioner
    final iconContainerSize = isDesktop ? 30.0 : 36.0;
    final iconSize = isDesktop ? 15.0 : 18.0;
    final horizontalPadding = isDesktop ? 10.0 : 12.0;
    final verticalPadding = isDesktop ? 6.0 : 8.0;

    return AnimatedCard(
      onTap: isClickable ? onTap : null,
      baseElevation: isDesktop ? 2 : 1,
      pressedElevation: isDesktop ? 4 : 3,
      margin: EdgeInsets.only(bottom: isDesktop ? 0 : 4),
      color: colorScheme.surfaceContainerLow,
      borderRadius: isDesktop ? 10 : 12,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        child: Row(
          children: [
            // Lille ikon
            Container(
              width: iconContainerSize,
              height: iconContainerSize,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(isDesktop ? 6 : 8),
              ),
              child: Icon(
                Icons.event_note,
                color: colorScheme.primary,
                size: iconSize,
              ),
            ),
            SizedBox(width: isDesktop ? 8 : 12),
            // Titel og liste
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    occurrence.taskName,
                    style: (isDesktop
                            ? theme.textTheme.labelMedium
                            : theme.textTheme.bodySmall)
                        ?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    occurrence.taskListName,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: isDesktop ? 10 : 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Dato badge
            DueDateBadge(dueDate: occurrence.dueDate, compact: isDesktop),
          ],
        ),
      ),
    );
  }
}
