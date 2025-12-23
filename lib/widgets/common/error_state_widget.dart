import 'package:flutter/material.dart';

/// Design Version: 1.0.0
///
/// En genbrugelig error state widget brugt på tværs af appen.
/// Viser et fejl-ikon, besked og retry-knap.
///
/// Design guidelines:
/// - Bruger tema-farve til retry-knap i stedet for error-farve (mere indbydende)
/// - Knap stylet med gradient og shadow per guidelines
/// - Optional themeColor parameter for konsistent theming
class ErrorStateWidget extends StatelessWidget {
  /// Fejlbesked der skal vises
  final String message;

  /// Callback funktion når retry-knappen trykkes
  final VoidCallback onRetry;

  /// Optional label til retry-knappen (default: "Retry")
  final String? retryLabel;

  /// Optional tema-farve til retry-knappen (hvis ikke angivet, bruges primary farve)
  final Color? themeColor;

  const ErrorStateWidget({
    super.key,
    required this.message,
    required this.onRetry,
    this.retryLabel,
    this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final buttonColor = themeColor ?? colorScheme.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Fejl-ikon med error farve
            Icon(
              Icons.error_outline,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            // Fejlbesked
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            // Retry-knap med tema-farve, gradient og shadow per guidelines
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14), // Knap radius: 14-16px
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    buttonColor,
                    HSLColor.fromColor(buttonColor)
                        .withLightness(
                          (HSLColor.fromColor(buttonColor).lightness - 0.1)
                              .clamp(0.0, 1.0),
                        )
                        .toColor(),
                  ],
                ),
                // Shadow med tema-farve og opacity 0.3
                boxShadow: [
                  BoxShadow(
                    color: buttonColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryLabel ?? 'Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  minimumSize: const Size(140, 52), // Højde: 52-56px
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
