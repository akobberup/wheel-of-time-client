import 'package:flutter/material.dart';
import '../../providers/theme_provider.dart';

/// Et grid widget til valg af tema farve fra preset farver.
/// Viser farverne i et 3x4 grid med en selection indikator på den valgte farve.
class ColorPickerGrid extends StatelessWidget {
  final Color selectedColor;
  final Function(Color) onColorSelected;

  const ColorPickerGrid({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: presetThemeColors.length,
      itemBuilder: (context, index) {
        final color = presetThemeColors[index];
        final isSelected = color.value == selectedColor.value;

        return _ColorCircle(
          color: color,
          isSelected: isSelected,
          onTap: () => onColorSelected(color),
        );
      },
    );
  }
}

/// En cirkulær farve vælger med selection indikator.
class _ColorCircle extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorCircle({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: isSelected
              ? Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 4,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isSelected
            ? Icon(
                Icons.check,
                color: _getContrastingColor(color),
                size: 32,
              )
            : null,
      ),
    );
  }

  /// Returnerer hvid eller sort baseret på farvens lyshed for god kontrast.
  Color _getContrastingColor(Color backgroundColor) {
    // Beregn relative luminance for at bestemme om vi skal bruge hvid eller sort tekst
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
