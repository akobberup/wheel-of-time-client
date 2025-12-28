// Design Version: 1.0.0 (se docs/DESIGN_GUIDELINES.md)

import 'package:flutter/material.dart';
import '../models/visual_theme.dart';
import '../l10n/app_strings.dart';

/// Widget til valg af visuelt tema med farveforhåndsvisning
/// Viser en grid af tema-kort med farver og navn
class ThemeSelector extends StatelessWidget {
  final List<VisualThemeResponse> themes;
  final int? selectedThemeId;
  final ValueChanged<VisualThemeResponse> onThemeSelected;
  final bool isDarkMode;

  const ThemeSelector({
    super.key,
    required this.themes,
    required this.onThemeSelected,
    this.selectedThemeId,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.5,
      ),
      itemCount: themes.length,
      itemBuilder: (context, index) {
        final theme = themes[index];
        final isSelected = theme.id == selectedThemeId;
        
        return _ThemeCard(
          theme: theme,
          isSelected: isSelected,
          isDarkMode: isDarkMode,
          onTap: () => onThemeSelected(theme),
        );
      },
    );
  }
}

/// Enkelt tema-kort der viser farver og navn
class _ThemeCard extends StatelessWidget {
  final VisualThemeResponse theme;
  final bool isSelected;
  final bool isDarkMode;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.theme,
    required this.isSelected,
    required this.isDarkMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = _parseHexColor(theme.primaryColor);
    final secondaryColor = _parseHexColor(theme.secondaryColor);
    
    final cardColor = isDarkMode 
        ? const Color(0xFF2A2A2E) 
        : const Color(0xFFF5F5F5);
    
    final borderColor = isSelected 
        ? primaryColor 
        : (isDarkMode ? const Color(0xFF3A3A3E) : const Color(0xFFE0E0E0));

    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 2.5 : 1,
            ),
          ),
          child: Row(
            children: [
              // Farve forhåndsvisning med gradient
              Container(
                width: 60,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(11),
                    bottomLeft: Radius.circular(11),
                  ),
                  gradient: LinearGradient(
                    colors: [primaryColor, secondaryColor],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: isSelected
                    ? const Center(
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 24,
                        ),
                      )
                    : null,
              ),
              // Tema navn
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    theme.displayName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isDarkMode
                          ? const Color(0xFFF5F5F5)
                          : const Color(0xFF1A1A1A),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Parser hex color string (f.eks. "#A8D5A2") til Color objekt
  Color _parseHexColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 7) {
      buffer.write('FF'); // Tilføj alpha hvis ikke angivet
      buffer.write(hexString.replaceFirst('#', ''));
    } else if (hexString.length == 9) {
      buffer.write(hexString.replaceFirst('#', ''));
    } else {
      // Fallback til grå hvis format er ugyldigt
      return Colors.grey;
    }
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

/// Kompakt tema-vælger med dropdown-stil
/// Viser kun det valgte tema og åbner en modal bottom sheet ved klik
class CompactThemeSelector extends StatelessWidget {
  final VisualThemeResponse? currentTheme;
  final List<VisualThemeResponse> availableThemes;
  final ValueChanged<VisualThemeResponse> onThemeSelected;
  final bool isDarkMode;

  const CompactThemeSelector({
    super.key,
    required this.currentTheme,
    required this.availableThemes,
    required this.onThemeSelected,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDarkMode 
        ? const Color(0xFF2A2A2E) 
        : const Color(0xFFF5F5F5);
    
    final borderColor = isDarkMode 
        ? const Color(0xFF3A3A3E) 
        : const Color(0xFFE0E0E0);

    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => _showThemeSelector(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              if (currentTheme != null) ...[
                // Farve forhåndsvisning
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(
                      colors: [
                        _parseHexColor(currentTheme!.primaryColor),
                        _parseHexColor(currentTheme!.secondaryColor),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppStrings.of(context).theme,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDarkMode
                              ? const Color(0xFFA0A0A0)
                              : const Color(0xFF6B6B6B),
                        ),
                      ),
                      Text(
                        currentTheme!.displayName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode
                              ? const Color(0xFFF5F5F5)
                              : const Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Expanded(
                  child: Text(
                    AppStrings.of(context).selectTheme,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode
                          ? const Color(0xFFA0A0A0)
                          : const Color(0xFF6B6B6B),
                    ),
                  ),
                ),
              ],
              Icon(
                Icons.expand_more,
                color: isDarkMode
                    ? const Color(0xFFA0A0A0)
                    : const Color(0xFF6B6B6B),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showThemeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ThemeSelectorBottomSheet(
        themes: availableThemes,
        selectedThemeId: currentTheme?.id,
        onThemeSelected: (theme) {
          onThemeSelected(theme);
          Navigator.of(context).pop();
        },
        isDarkMode: isDarkMode,
      ),
    );
  }

  /// Parser hex color string (f.eks. "#A8D5A2") til Color objekt
  Color _parseHexColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 7) {
      buffer.write('FF');
      buffer.write(hexString.replaceFirst('#', ''));
    } else if (hexString.length == 9) {
      buffer.write(hexString.replaceFirst('#', ''));
    } else {
      return Colors.grey;
    }
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

/// Bottom sheet med tema-vælger
class _ThemeSelectorBottomSheet extends StatelessWidget {
  final List<VisualThemeResponse> themes;
  final int? selectedThemeId;
  final ValueChanged<VisualThemeResponse> onThemeSelected;
  final bool isDarkMode;

  const _ThemeSelectorBottomSheet({
    required this.themes,
    required this.onThemeSelected,
    this.selectedThemeId,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDarkMode 
        ? const Color(0xFF222226) 
        : const Color(0xFFFFFFFF);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? const Color(0xFF3A3A3E)
                  : const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Titel
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Text(
                  AppStrings.of(context).selectTheme,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode
                        ? const Color(0xFFF5F5F5)
                        : const Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Tema grid
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: ThemeSelector(
                themes: themes,
                selectedThemeId: selectedThemeId,
                onThemeSelected: onThemeSelected,
                isDarkMode: isDarkMode,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
