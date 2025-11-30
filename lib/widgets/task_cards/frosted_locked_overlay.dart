import 'package:flutter/material.dart';
import '../../l10n/app_strings.dart';
import 'task_urgency.dart';

/// Blød overlay for opgaver der venter på tur
/// Design Version: 1.0.0 (se docs/DESIGN_GUIDELINES.md)
/// Bruger lav opacity og venligt schedule-ikon i stedet for lås
class FrostedLockedOverlay extends StatelessWidget {
  final TaskUrgency urgency;

  const FrostedLockedOverlay({super.key, required this.urgency});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final isUrgent =
        urgency == TaskUrgency.overdue || urgency == TaskUrgency.today;
    final bottomMargin = isUrgent ? 8.0 : 6.0;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Blødere overlay - mindre blokerende, mere "venter på tur"
    final overlayColor = isDark
        ? colorScheme.surface.withValues(alpha: 0.4)
        : colorScheme.surface.withValues(alpha: 0.35);

    return Positioned.fill(
      child: Container(
        margin: EdgeInsets.only(bottom: bottomMargin),
        decoration: BoxDecoration(
          color: overlayColor,
          borderRadius: BorderRadius.circular(isUrgent ? 20 : 14),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              // Gradient badge der matcher hero cards
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        colorScheme.surfaceContainerHighest,
                        colorScheme.surfaceContainerHigh,
                      ]
                    : [
                        colorScheme.surface,
                        colorScheme.surfaceContainerLow,
                      ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Hourglass ikon - venter på sin tur, ikke blokeret
                Icon(
                  Icons.hourglass_empty_rounded,
                  size: 16,
                  color: colorScheme.primary.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 6),
                Text(
                  strings.completeEarlierTasksFirst,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
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
