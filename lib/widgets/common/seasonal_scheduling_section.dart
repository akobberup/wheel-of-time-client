// Design Version: 1.0.0 (se docs/DESIGN_GUIDELINES.md)

import 'package:flutter/material.dart';
import '../../l10n/app_strings.dart';
import '../../models/enums.dart';

/// Sektion til sæsonbaseret scheduling med aktive måneder.
///
/// Viser en ExpansionTile der er collapsed som default.
/// Indeholder preset-chips (Sommer, Vinter, Vækstsæson, Hele året)
/// og et 4x3 grid af måneds-chips.
class SeasonalSchedulingSection extends StatelessWidget {
  /// De valgte aktive måneder. Null eller tom = hele året.
  final Set<Month>? selectedMonths;

  /// Callback når valgte måneder ændres.
  final ValueChanged<Set<Month>?> onChanged;

  /// Om sektionen skal være expanded som default.
  final bool initiallyExpanded;

  /// Optional theme color from task list for visual consistency
  final Color? themeColor;

  const SeasonalSchedulingSection({
    super.key,
    required this.selectedMonths,
    required this.onChanged,
    this.initiallyExpanded = false,
    this.themeColor,
  });

  /// Preset definitioner for hurtig udvælgelse.
  static const Map<String, Set<Month>> _presets = {
    'summer': {Month.JUNE, Month.JULY, Month.AUGUST},
    'winter': {Month.DECEMBER, Month.JANUARY, Month.FEBRUARY},
    'growingSeason': {
      Month.APRIL,
      Month.MAY,
      Month.JUNE,
      Month.JULY,
      Month.AUGUST,
      Month.SEPTEMBER,
      Month.OCTOBER,
    },
  };

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Brug tema-farve hvis tilgængelig
    final primaryColor = themeColor ?? colorScheme.primary;

    return ExpansionTile(
      initiallyExpanded: initiallyExpanded,
      iconColor: primaryColor,
      collapsedIconColor: colorScheme.onSurfaceVariant,
      leading: Icon(
        Icons.calendar_month_outlined,
        color: primaryColor,
      ),
      title: Text(
        strings.activeMonths,
        style: theme.textTheme.bodyLarge,
      ),
      subtitle: Text(
        _getSummary(strings),
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Presets
              _buildPresetChips(context, strings, primaryColor),
              const SizedBox(height: 12),

              // Divider med tekst
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      strings.orSelectManually,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 12),

              // Måneds-grid
              _buildMonthGrid(context, strings, primaryColor),
            ],
          ),
        ),
      ],
    );
  }

  /// Bygger preset chips rækken.
  Widget _buildPresetChips(BuildContext context, AppStrings strings, Color primaryColor) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildPresetChip(
          context,
          label: strings.summer,
          presetKey: 'summer',
          primaryColor: primaryColor,
        ),
        _buildPresetChip(
          context,
          label: strings.winter,
          presetKey: 'winter',
          primaryColor: primaryColor,
        ),
        _buildPresetChip(
          context,
          label: strings.growingSeason,
          presetKey: 'growingSeason',
          primaryColor: primaryColor,
        ),
        _buildPresetChip(
          context,
          label: strings.allYear,
          presetKey: null, // null = hele året
          primaryColor: primaryColor,
        ),
      ],
    );
  }

  /// Bygger en enkelt preset chip.
  Widget _buildPresetChip(
    BuildContext context, {
    required String label,
    required String? presetKey,
    required Color primaryColor,
  }) {
    final isSelected = _isPresetSelected(presetKey);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => _selectPreset(presetKey),
      selectedColor: primaryColor.withValues(alpha: 0.2),
      checkmarkColor: primaryColor,
    );
  }

  /// Tjekker om en preset er valgt.
  bool _isPresetSelected(String? presetKey) {
    if (presetKey == null) {
      // "Hele året" er valgt hvis ingen måneder er valgt
      return selectedMonths == null || selectedMonths!.isEmpty;
    }

    final preset = _presets[presetKey];
    if (preset == null) return false;

    return selectedMonths != null &&
        selectedMonths!.length == preset.length &&
        selectedMonths!.containsAll(preset);
  }

  /// Vælger en preset.
  void _selectPreset(String? presetKey) {
    if (presetKey == null) {
      // "Hele året" - ryd alle måneder
      onChanged(null);
    } else {
      final preset = _presets[presetKey];
      if (preset != null) {
        onChanged(Set.from(preset));
      }
    }
  }

  /// Bygger 4x3 måneds-grid.
  Widget _buildMonthGrid(BuildContext context, AppStrings strings, Color primaryColor) {
    final monthNames = _getMonthNames(strings);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: Month.values.map((month) {
        final isSelected =
            selectedMonths != null && selectedMonths!.contains(month);

        return FilterChip(
          label: Text(monthNames[month.index]),
          selected: isSelected,
          onSelected: (_) => _toggleMonth(month),
          visualDensity: VisualDensity.compact,
          selectedColor: primaryColor.withValues(alpha: 0.2),
          checkmarkColor: primaryColor,
        );
      }).toList(),
    );
  }

  /// Toggler en måneds selection.
  void _toggleMonth(Month month) {
    final current = selectedMonths ?? <Month>{};
    final newSet = Set<Month>.from(current);

    if (newSet.contains(month)) {
      newSet.remove(month);
    } else {
      newSet.add(month);
    }

    // Hvis alle måneder er fjernet, send null (hele året)
    onChanged(newSet.isEmpty ? null : newSet);
  }

  /// Genererer summary tekst til subtitle.
  String _getSummary(AppStrings strings) {
    if (selectedMonths == null || selectedMonths!.isEmpty) {
      return strings.yearRound;
    }

    final count = selectedMonths!.length;

    // Tjek om det er en sammenhængende periode
    final sortedMonths = selectedMonths!.toList()
      ..sort((a, b) => a.index.compareTo(b.index));

    if (_isConsecutive(sortedMonths)) {
      final shortNames = _getShortMonthNames(strings);
      final first = shortNames[sortedMonths.first.index];
      final last = shortNames[sortedMonths.last.index];
      return strings.monthRange(first, last);
    }

    return strings.monthsSelected(count);
  }

  /// Tjekker om månederne er sammenhængende.
  bool _isConsecutive(List<Month> sortedMonths) {
    if (sortedMonths.length <= 1) return true;

    for (int i = 1; i < sortedMonths.length; i++) {
      if (sortedMonths[i].index != sortedMonths[i - 1].index + 1) {
        return false;
      }
    }
    return true;
  }

  /// Returnerer korte måneds navne (3 bogstaver).
  List<String> _getShortMonthNames(AppStrings strings) {
    return [
      strings.januaryShort,
      strings.februaryShort,
      strings.marchShort,
      strings.aprilShort,
      strings.mayShort,
      strings.juneShort,
      strings.julyShort,
      strings.augustShort,
      strings.septemberShort,
      strings.octoberShort,
      strings.novemberShort,
      strings.decemberShort,
    ];
  }

  /// Returnerer korte måneds navne til grid.
  List<String> _getMonthNames(AppStrings strings) {
    return _getShortMonthNames(strings);
  }
}
