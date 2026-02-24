// Design Version: 1.0.0 (se docs/DESIGN_GUIDELINES.md)

import 'package:flutter/material.dart';
import '../../l10n/app_strings.dart';

/// Bottom sheet til valg af fødselsår.
///
/// Viser en scrollbar liste af år fra 1920 til (nuværende år - 13).
/// Auto-scroller til det valgte år og inkluderer en clear-knap.
class YearPickerSheet extends StatefulWidget {
  /// Det aktuelt valgte år (null hvis intet er valgt)
  final int? selectedYear;

  /// Tema-farve til styling
  final Color seedColor;

  /// Callback når et år vælges
  final ValueChanged<int?> onYearSelected;

  const YearPickerSheet({
    super.key,
    required this.selectedYear,
    required this.seedColor,
    required this.onYearSelected,
  });

  @override
  State<YearPickerSheet> createState() => _YearPickerSheetState();
}

class _YearPickerSheetState extends State<YearPickerSheet> {
  late final ScrollController _scrollController;
  late final int _minYear;
  late final int _maxYear;
  late final List<int> _years;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Beregn år-intervallet: 1920 til nuværende år - 6
    final currentYear = DateTime.now().year;
    _minYear = 1920;
    _maxYear = currentYear - 6;
    _years = List.generate(_maxYear - _minYear + 1, (i) => _maxYear - i);

    // Scroll til valgt år efter første frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedYear();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelectedYear() {
    if (widget.selectedYear == null) return;

    final index = _years.indexOf(widget.selectedYear!);
    if (index == -1) return;

    // Beregn position (56 er højden af hver år-række)
    const itemHeight = 56.0;
    final targetOffset = index * itemHeight;

    // Scroll med animation
    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header med titel og clear-knap
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 16, 16),
            child: Row(
              children: [
                Text(
                  strings.selectBirthYear,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
                const Spacer(),
                if (widget.selectedYear != null)
                  TextButton(
                    onPressed: () {
                      widget.onYearSelected(null);
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      strings.clear,
                      style: TextStyle(
                        color: widget.seedColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // År-liste
          SizedBox(
            height: 300,
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _years.length,
                itemExtent: 56,
                itemBuilder: (context, index) {
                  final year = _years[index];
                  final isSelected = year == widget.selectedYear;

                  return _YearOption(
                    year: year,
                    isSelected: isSelected,
                    isDark: isDark,
                    seedColor: widget.seedColor,
                    onTap: () {
                      widget.onYearSelected(year);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// En enkelt år-mulighed i år-vælgeren.
class _YearOption extends StatelessWidget {
  final int year;
  final bool isSelected;
  final bool isDark;
  final Color seedColor;
  final VoidCallback onTap;

  const _YearOption({
    required this.year,
    required this.isSelected,
    required this.isDark,
    required this.seedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final backgroundColor = isSelected
        ? seedColor.withValues(alpha: 0.12)
        : Colors.transparent;

    return InkWell(
      onTap: onTap,
      child: Container(
        color: backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                year.toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? seedColor : textColor,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_rounded,
                color: seedColor,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}

/// Helper funktion til at vise YearPickerSheet som modal bottom sheet.
Future<void> showYearPickerSheet({
  required BuildContext context,
  required int? selectedYear,
  required Color seedColor,
  required ValueChanged<int?> onYearSelected,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return showModalBottomSheet(
    context: context,
    backgroundColor: isDark ? const Color(0xFF1E1E22) : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    isScrollControlled: true,
    builder: (context) => YearPickerSheet(
      selectedYear: selectedYear,
      seedColor: seedColor,
      onYearSelected: onYearSelected,
    ),
  );
}
