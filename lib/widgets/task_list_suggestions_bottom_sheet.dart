// Design Version: 1.0.0 (se docs/DESIGN_GUIDELINES.md)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ai_suggestion_provider.dart';
import '../l10n/app_strings.dart';

/// Callback type for when a task list name suggestion is selected
typedef OnTaskListSuggestionSelected = void Function(String suggestion);

/// A Material 3 bottom sheet that displays AI-powered task list name suggestions.
///
/// This widget provides a clean interface for browsing and selecting
/// AI-generated task list name suggestions. It follows the same UX pattern
/// as the task suggestions bottom sheet.
class TaskListSuggestionsBottomSheet extends ConsumerStatefulWidget {
  /// The current text in the task list name field
  final String currentInput;

  /// Callback when a suggestion is selected
  final OnTaskListSuggestionSelected onSuggestionSelected;

  /// Optional theme color to use for accents (from task list)
  final Color? themeColor;

  const TaskListSuggestionsBottomSheet({
    super.key,
    required this.currentInput,
    required this.onSuggestionSelected,
    this.themeColor,
  });

  @override
  ConsumerState<TaskListSuggestionsBottomSheet> createState() =>
      _TaskListSuggestionsBottomSheetState();
}

class _TaskListSuggestionsBottomSheetState
    extends ConsumerState<TaskListSuggestionsBottomSheet> {
  List<String> _suggestions = [];
  bool _isLoading = false;
  bool _showLoadingIndicator = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    _fetchSuggestions();
  }

  /// Fetches suggestions from the AI service
  Future<void> _fetchSuggestions() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Show loading indicator after 500ms to avoid flicker
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && _isLoading) {
        setState(() {
          _showLoadingIndicator = true;
        });
      }
    });

    try {
      final aiService = ref.read(aiSuggestionServiceProvider);
      final response = await aiService.getTaskListSuggestions(
        partialInput: widget.currentInput,
        maxSuggestions: 5,
      );

      if (mounted) {
        setState(() {
          _suggestions = response.suggestions;
          _isLoading = false;
          _showLoadingIndicator = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _suggestions = [];
          _isLoading = false;
          _showLoadingIndicator = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final strings = AppStrings.of(context);
    final effectiveThemeColor = widget.themeColor ?? colorScheme.primary;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 16, 16),
            child: Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: effectiveThemeColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    strings.aiSuggestions,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  tooltip: strings.close,
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Content
          Flexible(
            child: _buildContent(context, theme, colorScheme, strings),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    AppStrings strings,
  ) {
    final effectiveThemeColor = widget.themeColor ?? colorScheme.primary;
    // Loading state with shimmer placeholders
    if (_isLoading && _suggestions.isEmpty) {
      if (_showLoadingIndicator) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: effectiveThemeColor,
                ),
                const SizedBox(height: 16),
                Text(
                  strings.generatingSuggestions,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        // Show shimmer placeholders for fast loading
        return ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.all(16),
          itemCount: 3,
          itemBuilder: (context, index) => _buildShimmerCard(colorScheme),
        );
      }
    }

    // Error state
    if (_errorMessage != null && _suggestions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                strings.failedToFetchSuggestions,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                strings.pleaseTryAgain,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      effectiveThemeColor,
                      effectiveThemeColor.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: effectiveThemeColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _fetchSuggestions,
                  icon: const Icon(Icons.refresh),
                  label: Text(strings.retry),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
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

    // Empty state
    if (_suggestions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 48,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                strings.noSuggestionsAvailable,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                strings.tryEnteringText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Success state with suggestions
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(16),
      itemCount: _suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = _suggestions[index];
        return _buildSuggestionCard(
          context,
          theme,
          colorScheme,
          suggestion,
        );
      },
    );
  }

  Widget _buildSuggestionCard(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    String suggestion,
  ) {
    final effectiveThemeColor = widget.themeColor ?? colorScheme.primary;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      child: InkWell(
        onTap: () => widget.onSuggestionSelected(suggestion),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: effectiveThemeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.list_alt,
                  color: effectiveThemeColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  suggestion,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerCard(ColorScheme colorScheme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                height: 20,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
