import 'package:flutter/material.dart';

/// Genererer en gradient baggrund baseret på en streng
/// Bruges til at give kort uden billede en unik visuel identitet
class GradientBackground extends StatelessWidget {
  /// Tekst der bruges til at generere gradienten
  final String seed;

  /// Højde på baggrunden
  final double height;

  /// Bredde på baggrunden (null = fyld tilgængelig plads)
  final double? width;

  /// Border radius for baggrunden
  final BorderRadius? borderRadius;

  /// Child widget der vises ovenpå gradienten
  final Widget? child;

  /// Om der skal vises en gradient overlay for bedre tekstlæsbarhed
  final bool showOverlay;

  const GradientBackground({
    super.key,
    required this.seed,
    this.height = 120,
    this.width,
    this.borderRadius,
    this.child,
    this.showOverlay = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _generateGradientColors(seed);

    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: showOverlay
          ? Stack(
              children: [
                // Gradient overlay for tekstlæsbarhed
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: borderRadius,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.4),
                        ],
                        stops: const [0.4, 1.0],
                      ),
                    ),
                  ),
                ),
                if (child != null) child!,
              ],
            )
          : child,
    );
  }

  /// Genererer gradient farver baseret på seed string
  List<Color> _generateGradientColors(String seed) {
    final hash = seed.hashCode;
    final colorIndex = hash.abs() % _gradientPalettes.length;
    return _gradientPalettes[colorIndex];
  }
}

/// Foruddefinerede gradient paletter i Material 3 stil
const List<List<Color>> _gradientPalettes = [
  // Lilla til indigo
  [Color(0xFF7C3AED), Color(0xFF4F46E5)],
  // Blå til cyan
  [Color(0xFF2563EB), Color(0xFF0891B2)],
  // Grøn til teal
  [Color(0xFF059669), Color(0xFF0D9488)],
  // Orange til pink
  [Color(0xFFF97316), Color(0xFFEC4899)],
  // Rose til lilla
  [Color(0xFFF43F5E), Color(0xFF8B5CF6)],
  // Amber til orange
  [Color(0xFFF59E0B), Color(0xFFEA580C)],
  // Indigo til blå
  [Color(0xFF6366F1), Color(0xFF3B82F6)],
  // Teal til grøn
  [Color(0xFF14B8A6), Color(0xFF22C55E)],
];

/// Widget der viser et hero billede med gradient overlay
class HeroImageContainer extends StatelessWidget {
  /// Billede widget der vises
  final Widget image;

  /// Højde på containeren
  final double height;

  /// Border radius for containeren
  final BorderRadius? borderRadius;

  /// Child widget der vises over billedet (f.eks. titel)
  final Widget? child;

  /// Position af child widget
  final Alignment childAlignment;

  /// Padding omkring child widget
  final EdgeInsetsGeometry childPadding;

  const HeroImageContainer({
    super.key,
    required this.image,
    this.height = 120,
    this.borderRadius,
    this.child,
    this.childAlignment = Alignment.bottomLeft,
    this.childPadding = const EdgeInsets.all(12),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            image,
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.6),
                  ],
                  stops: const [0.3, 1.0],
                ),
              ),
            ),
            // Child widget
            if (child != null)
              Align(
                alignment: childAlignment,
                child: Padding(
                  padding: childPadding,
                  child: child,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
