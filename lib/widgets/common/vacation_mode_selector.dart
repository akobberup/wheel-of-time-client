// Design Version: 1.0.0 (se docs/DESIGN_GUIDELINES.md)

import 'package:flutter/material.dart';
import '../../models/enums.dart';
import '../../l10n/app_strings.dart';

/// Widget til at vælge ferie-tilstand for en opgave med SegmentedButton.
///
/// Tre muligheder:
/// - Ingen ændring (opgaven påvirkes ikke af ferie)
/// - Ikke i ferie (opgaven laves kun når en ansvarlig IKKE har ferie)
/// - Kun i ferie (opgaven laves kun når en ansvarlig HAR ferie)
class VacationModeSelector extends StatelessWidget {
  /// Den aktuelt valgte ferie-tilstand
  final VacationMode selectedMode;

  /// Callback når tilstanden ændres
  final ValueChanged<VacationMode> onChanged;

  /// Valgfri tema-farve til styling
  final Color? themeColor;

  /// Om widget'en er aktiveret
  final bool enabled;

  const VacationModeSelector({
    super.key,
    required this.selectedMode,
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
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Text(
            strings.vacationModeLabel,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            strings.vacationModeDescription,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<VacationMode>(
            segments: [
              ButtonSegment(
                value: VacationMode.NO_CHANGE,
                label: Text(strings.vacationModeNoChange),
              ),
              ButtonSegment(
                value: VacationMode.NOT_IN_VACATION,
                label: Text(strings.vacationModeNotInVacation),
              ),
              ButtonSegment(
                value: VacationMode.ONLY_IN_VACATION,
                label: Text(strings.vacationModeOnlyInVacation),
              ),
            ],
            selected: {selectedMode},
            onSelectionChanged: enabled
                ? (Set<VacationMode> selection) {
                    if (selection.isNotEmpty) {
                      onChanged(selection.first);
                    }
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
