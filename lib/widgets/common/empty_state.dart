import 'package:flutter/material.dart';
import '../../constants/spacing.dart';
import '../../constants/sizes.dart';

/// A standardized empty state widget used across the app
/// Displays an icon, title, optional subtitle, and optional action button
class EmptyState extends StatelessWidget {
  /// The icon to display
  final IconData icon;

  /// The main title text
  final String title;

  /// Optional subtitle for additional context
  final String? subtitle;

  /// Optional action button or widget
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: IconSizes.emptyState,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
            ),
            const SizedBox(height: Spacing.lg),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: Spacing.sm),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: Spacing.xl),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
