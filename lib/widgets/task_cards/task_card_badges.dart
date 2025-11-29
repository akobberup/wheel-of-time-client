import 'package:flutter/material.dart';
import '../../l10n/app_strings.dart';

/// Badge der viser forfaldsdato med farve baseret på hastverk
class DueDateBadge extends StatelessWidget {
  final DateTime dueDate;
  final bool compact;

  const DueDateBadge({
    super.key,
    required this.dueDate,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final dueDateColor = _getDueDateColor(context);
    final dueDateText = _formatDueDate(strings);

    // Responsive padding og font-størrelse
    final horizontalPadding = compact ? 8.0 : 12.0;
    final verticalPadding = compact ? 4.0 : 6.0;
    final fontSize = compact ? 10.0 : 12.0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: dueDateColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(compact ? 12 : 16),
        border: Border.all(
          color: dueDateColor.withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        dueDateText,
        style: TextStyle(
          color: dueDateColor,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Formaterer forfaldsdato til menneskeligt læsbar streng
  String _formatDueDate(AppStrings strings) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final difference = taskDate.difference(today).inDays;

    if (difference < 0) {
      final daysAgo = difference.abs();
      return daysAgo == 1 ? strings.dueDaysAgo(1) : strings.dueDaysAgo(daysAgo);
    } else if (difference == 0) {
      return strings.dueToday;
    } else if (difference == 1) {
      return strings.dueTomorrow;
    } else {
      return strings.dueInDays(difference);
    }
  }

  /// Returnerer farve for forfaldsdato-badge baseret på hastværk
  Color _getDueDateColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final difference = taskDate.difference(today).inDays;

    if (difference < 0) {
      return colorScheme.error;
    } else if (difference == 0) {
      return colorScheme.tertiary;
    } else if (difference == 1) {
      return colorScheme.primary;
    } else {
      return colorScheme.onSurfaceVariant;
    }
  }
}

/// Streak badge med ild-ikon
class AnimatedStreakBadge extends StatelessWidget {
  final int streakCount;
  final bool isAtRisk;
  final bool small;

  const AnimatedStreakBadge({
    super.key,
    required this.streakCount,
    this.isAtRisk = false,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = small ? 14.0 : 18.0;
    final fontSize = small ? 11.0 : 13.0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 10,
        vertical: small ? 4 : 6,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isAtRisk
              ? [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)]
              : [const Color(0xFFFF9500), const Color(0xFFFFCC00)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isAtRisk ? Colors.red : Colors.orange)
                .withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department,
            color: Colors.white,
            size: size,
          ),
          const SizedBox(width: 4),
          Text(
            '$streakCount',
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Metadata chip til visning af små info-stykker
class MetadataChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool small;

  const MetadataChip({
    super.key,
    required this.icon,
    required this.label,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 8,
        vertical: small ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: small ? 12 : 14, color: Colors.white70),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: small ? 10 : 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Streak advarsel banner
class StreakWarningBanner extends StatelessWidget {
  final int streakCount;

  const StreakWarningBanner({super.key, required this.streakCount});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              strings.streakAtRisk(streakCount),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
