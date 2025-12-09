// Design Version: 1.0.0 (se docs/DESIGN_GUIDELINES.md)

import 'package:flutter/material.dart';
import '../../models/task_instance.dart';
import '../../l10n/app_strings.dart';
import '../common/animated_card.dart';

/// Kort til visning af fuldførte og udløbne opgaver i timeline
/// Design: Succes-farve for completed, fejl-farve for expired
class CompletedTaskCard extends StatelessWidget {
  final TaskInstanceResponse taskInstance;
  final bool isDesktop;
  final VoidCallback? onTap;

  // Status farver fra Design Guidelines
  static const Color _successColor = Color(0xFF22C55E);
  static const Color _errorColor = Color(0xFFEF4444);

  const CompletedTaskCard({
    super.key,
    required this.taskInstance,
    this.isDesktop = false,
    this.onTap,
  });

  /// Returnerer true hvis opgaven er expired
  bool get _isExpired => taskInstance.status == TaskInstanceStatus.expired;

  /// Returnerer accent-farven baseret på status
  Color get _accentColor => _isExpired ? _errorColor : _successColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final strings = AppStrings.of(context);

    // Responsive dimensioner
    final iconContainerSize = isDesktop ? 32.0 : 36.0;
    final iconSize = isDesktop ? 16.0 : 18.0;
    final horizontalPadding = isDesktop ? 12.0 : 14.0;
    final verticalPadding = isDesktop ? 10.0 : 12.0;

    // Baggrundsfarve baseret på status
    final backgroundColor = isDark
        ? (_isExpired
            ? const Color(0xFF241E1E) // Mørk med rødt tint
            : const Color(0xFF1E2420)) // Mørk med grønt tint
        : (_isExpired
            ? const Color(0xFFFBF8F8) // Lys med rødt tint
            : const Color(0xFFF8FBF9)); // Lys med grønt tint

    return AnimatedCard(
      onTap: onTap,
      baseElevation: isDesktop ? 1 : 1,
      pressedElevation: isDesktop ? 3 : 2,
      margin: EdgeInsets.only(bottom: isDesktop ? 0 : 6),
      color: backgroundColor,
      borderRadius: isDesktop ? 12 : 14,
      // Accent-farve på venstre kant
      borderSide: BorderSide(
        color: _accentColor.withValues(alpha: 0.4),
        width: 2,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        child: Row(
          children: [
            // Status ikon i cirkel
            Container(
              width: iconContainerSize,
              height: iconContainerSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _accentColor.withValues(alpha: 0.15),
              ),
              child: Icon(
                _isExpired ? Icons.timer_off : Icons.check_circle,
                color: _accentColor,
                size: iconSize,
              ),
            ),
            SizedBox(width: isDesktop ? 10 : 12),
            // Opgave info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Opgavenavn
                  Text(
                    taskInstance.taskName,
                    style: (isDesktop
                            ? theme.textTheme.bodyMedium
                            : theme.textTheme.bodyMedium)
                        ?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                      // Strikethrough for expired tasks
                      decoration:
                          _isExpired ? TextDecoration.lineThrough : null,
                      decorationColor: _errorColor.withValues(alpha: 0.5),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  // Tidspunkt + bruger
                  Row(
                    children: [
                      Icon(
                        _isExpired ? Icons.event_busy : Icons.schedule,
                        size: isDesktop ? 11 : 12,
                        color: _isExpired
                            ? _errorColor.withValues(alpha: 0.7)
                            : colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getTimeText(strings),
                        style: TextStyle(
                          color: _isExpired
                              ? _errorColor.withValues(alpha: 0.7)
                              : colorScheme.onSurfaceVariant,
                          fontSize: isDesktop ? 11 : 12,
                        ),
                      ),
                      // Bruger (kun for completed tasks med userName)
                      if (!_isExpired &&
                          taskInstance.userName != null &&
                          taskInstance.userName!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.person_outline,
                          size: isDesktop ? 11 : 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            taskInstance.userName!,
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: isDesktop ? 11 : 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  // Kommentar (kun for completed tasks)
                  if (!_isExpired &&
                      taskInstance.optionalComment != null &&
                      taskInstance.optionalComment!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 8 : 10,
                          vertical: isDesktop ? 4 : 6,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: isDesktop ? 10 : 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                taskInstance.optionalComment!,
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: isDesktop ? 10 : 11,
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Status badge
            Padding(
              padding: EdgeInsets.only(left: isDesktop ? 8 : 10),
              child: _buildStatusBadge(),
            ),
          ],
        ),
      ),
    );
  }

  /// Bygger status badge (streak for completed, expired label for expired)
  Widget _buildStatusBadge() {
    if (_isExpired) {
      // Expired badge
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 6 : 8,
          vertical: isDesktop ? 3 : 4,
        ),
        decoration: BoxDecoration(
          color: _errorColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _errorColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Icon(
          Icons.close,
          color: _errorColor,
          size: isDesktop ? 12 : 14,
        ),
      );
    } else if (taskInstance.contributedToStreak) {
      // Streak badge for completed tasks
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 6 : 8,
          vertical: isDesktop ? 3 : 4,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF9500), Color(0xFFFFCC00)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.local_fire_department,
          color: Colors.white,
          size: isDesktop ? 12 : 14,
        ),
      );
    }
    return const SizedBox.shrink();
  }

  /// Returnerer tekst for tidspunkt baseret på status
  String _getTimeText(AppStrings strings) {
    if (_isExpired) {
      // For expired tasks, show when it was due
      final dueDate = taskInstance.dueDate ?? taskInstance.completedDateTime;
      return strings.expiredAgo(_formatTimeAgo(dueDate, strings));
    } else {
      // For completed tasks, show when it was completed
      return strings.completedAgo(
          _formatTimeAgo(taskInstance.completedDateTime, strings));
    }
  }

  /// Formaterer tid siden event til menneskeligt læsbar streng
  String _formatTimeAgo(DateTime eventTime, AppStrings strings) {
    final now = DateTime.now();
    final difference = now.difference(eventTime);

    if (difference.inMinutes < 1) {
      return strings.justNow;
    } else if (difference.inMinutes < 60) {
      return strings.minutesAgo(difference.inMinutes);
    } else if (difference.inHours < 24) {
      return strings.hoursAgo(difference.inHours);
    } else {
      return strings.daysAgo(difference.inDays);
    }
  }
}
