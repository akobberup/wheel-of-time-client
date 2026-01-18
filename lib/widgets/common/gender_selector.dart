// Design Version: 1.0.0 (se docs/DESIGN_GUIDELINES.md)

import 'package:flutter/material.dart';
import '../../models/enums.dart';
import '../../l10n/app_strings.dart';

/// Widget til at vælge køn med SegmentedButton.
///
/// Viser tre muligheder: Kvinde, Mand, Andet.
/// Følger Material 3 design med tema-farve support.
class GenderSelector extends StatelessWidget {
  /// Det aktuelt valgte køn (null hvis intet er valgt)
  final Gender? selectedGender;

  /// Callback når køn ændres
  final ValueChanged<Gender?> onChanged;

  /// Valgfri tema-farve til styling
  final Color? themeColor;

  /// Om widget'en er aktiveret
  final bool enabled;

  const GenderSelector({
    super.key,
    required this.selectedGender,
    required this.onChanged,
    this.themeColor,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final strings = AppStrings.of(context);
    final primaryColor = themeColor ?? colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            strings.gender,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Segmented button
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<Gender>(
            segments: [
              ButtonSegment(
                value: Gender.FEMALE,
                label: Text(strings.genderFemale),
                icon: const Icon(Icons.female, size: 18),
              ),
              ButtonSegment(
                value: Gender.MALE,
                label: Text(strings.genderMale),
                icon: const Icon(Icons.male, size: 18),
              ),
              ButtonSegment(
                value: Gender.OTHER,
                label: Text(strings.genderOther),
                icon: const Icon(Icons.transgender, size: 18),
              ),
            ],
            selected: selectedGender != null ? {selectedGender!} : {},
            emptySelectionAllowed: true,
            onSelectionChanged: enabled
                ? (Set<Gender> selection) {
                    onChanged(selection.isEmpty ? null : selection.first);
                  }
                : null,
            showSelectedIcon: false,
            style: ButtonStyle(
              visualDensity: VisualDensity.comfortable,
              tapTargetSize: MaterialTapTargetSize.padded,
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return primaryColor.withValues(alpha: 0.15);
                }
                return null;
              }),
              foregroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return primaryColor;
                }
                return null;
              }),
            ),
          ),
        ),
      ],
    );
  }
}
