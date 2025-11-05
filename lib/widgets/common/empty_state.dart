import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../constants/spacing.dart';

/// A standardized empty state widget used across the app
/// Displays a friendly ghost animation, title, optional subtitle, and optional action button
///
/// Design principles:
/// - Uses a looping Lottie animation for visual interest and friendliness
/// - Animation is appropriately sized to be noticeable but not overwhelming
/// - Text hierarchy guides the user: title (what's empty) -> subtitle (what to do)
/// - Optional action button provides clear next step
/// - Fully responsive with proper constraints for different screen sizes
/// - Works seamlessly in both light and dark themes
///
/// Usage:
/// ```dart
/// EmptyState(
///   title: 'No tasks yet',
///   subtitle: 'Create your first task to get started',
///   action: ElevatedButton(
///     onPressed: () => showCreateDialog(),
///     child: Text('Create Task'),
///   ),
/// )
/// ```
class EmptyState extends StatelessWidget {
  /// The main title text describing what's empty
  final String title;

  /// Optional subtitle providing additional context or guidance
  final String? subtitle;

  /// Optional action button or widget for the primary call-to-action
  final Widget? action;

  const EmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Spacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie animation with appropriate sizing
            // Constrained to prevent it from being too large on tablets
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 200,
                maxHeight: 200,
              ),
              child: Lottie.asset(
                'assets/animations/empty_ghost.json',
                repeat: true, // Loop continuously for friendly presence
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: Spacing.lg),

            // Title - primary message
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),

            // Subtitle - secondary guidance
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

            // Action button - clear call-to-action
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
