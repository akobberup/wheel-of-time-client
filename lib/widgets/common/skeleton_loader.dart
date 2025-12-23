import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Design Version: 1.0.0
///
/// Skeleton loader widget der viser en shimmer-effekt mens indhold loader.
/// Giver en bedre brugeroplevelse end en simpel spinner ved at vise layout-strukturen.
///
/// Design guidelines:
/// - Bruger tema-aware farver (ikke hardcoded grå)
/// - Understøtter dark mode
/// - Border radius følger guidelines (12px minimum for cards)
/// - Optional themeColor parameter for subtil theming
class SkeletonListLoader extends StatelessWidget {
  /// Antal skeleton items der skal vises
  final int itemCount;

  /// Optional tema-farve for subtil accent (bruges til shimmer highlight)
  final Color? themeColor;

  const SkeletonListLoader({
    super.key,
    this.itemCount = 5,
    this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    // Tema-aware shimmer farver
    final baseColor = isDark
        ? colorScheme.surface.withOpacity(0.3)
        : colorScheme.surfaceContainerHighest.withOpacity(0.3);

    final highlightColor = themeColor != null
        ? themeColor!.withOpacity(0.1)
        : (isDark
            ? colorScheme.surface.withOpacity(0.5)
            : Colors.white.withOpacity(0.8));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: (context, index) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: isDark ? 0 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Cards: 16-20px per guidelines
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Row(
              children: [
                // Thumbnail skeleton med cirkulær form
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12), // Små elementer: 8-12px
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titel skeleton
                      Container(
                        height: 16,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Beskrivelse skeleton
                      Container(
                        height: 12,
                        width: 200,
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
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
