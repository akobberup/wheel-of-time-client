import 'package:flutter/material.dart';

/// A reusable error state widget used across the app
/// Displays an error icon, message, and retry button
class ErrorStateWidget extends StatelessWidget {
  /// The error message to display
  final String message;

  /// Callback function when retry button is pressed
  final VoidCallback onRetry;

  /// Optional label for the retry button (defaults to "Retry")
  final String? retryLabel;

  const ErrorStateWidget({
    super.key,
    required this.message,
    required this.onRetry,
    this.retryLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(retryLabel ?? 'Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
