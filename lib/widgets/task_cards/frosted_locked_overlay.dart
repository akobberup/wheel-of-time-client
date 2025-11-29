import 'package:flutter/material.dart';
import '../../l10n/app_strings.dart';
import 'task_urgency.dart';

/// Semi-transparent overlay for låste opgaver
class FrostedLockedOverlay extends StatelessWidget {
  final TaskUrgency urgency;

  const FrostedLockedOverlay({super.key, required this.urgency});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final isUrgent = urgency == TaskUrgency.overdue || urgency == TaskUrgency.today;
    final bottomMargin = isUrgent ? 8.0 : 4.0;
    final theme = Theme.of(context);

    return Positioned.fill(
      child: Container(
        margin: EdgeInsets.only(bottom: bottomMargin),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(isUrgent ? 20 : 16),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  strings.completeEarlierTasksFirst,
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
