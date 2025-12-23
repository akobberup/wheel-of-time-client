// Design Version: 1.0.0 (se docs/DESIGN_GUIDELINES.md)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ai_suggestion_service.dart';
import '../providers/ai_suggestion_provider.dart';
import '../l10n/app_strings.dart';

/// Callback type for when a suggestion is selected
typedef OnSuggestionSelected = void Function(TaskSuggestion suggestion);

/// A Material 3 bottom sheet that displays AI-powered task suggestions.
///
/// This widget provides a clean, focused interface for browsing and selecting
/// AI-generated task suggestions. It follows Material 3 design principles and
/// provides excellent mobile UX through the bottom sheet pattern.
///
/// Design Features:
/// - Smooth slide-up animation with backdrop scrim
/// - Card-based suggestion layout with clear visual hierarchy
/// - Loading states with shimmer placeholders
/// - Empty and error states with actionable guidance
/// - Drag-to-dismiss and tap-outside-to-dismiss support
/// - Full accessibility with screen reader support
///
/// Usage:
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   isScrollControlled: true,
///   useSafeArea: true,
///   builder: (context) => AiSuggestionsBottomSheet(
///     taskListId: taskListId,
///     currentInput: nameController.text,
///     onSuggestionSelected: (suggestion) {
///       _autoFillFromSuggestion(suggestion);
///       Navigator.pop(context);
///     },
///   ),
/// );
/// ```
class AiSuggestionsBottomSheet extends ConsumerStatefulWidget {
  /// The ID of the task list for context-aware suggestions
  final int taskListId;

  /// The current text in the task name field
  final String currentInput;

  /// Callback when a suggestion is selected
  final OnSuggestionSelected onSuggestionSelected;

  /// Initial cached suggestions to show immediately
  final List<TaskSuggestion>? initialSuggestions;

  /// Optional theme color to use for accents (from task list)
  final Color? themeColor;

  const AiSuggestionsBottomSheet({
    super.key,
    required this.taskListId,
    required this.currentInput,
    required this.onSuggestionSelected,
    this.initialSuggestions,
    this.themeColor,
  });

  @override
  ConsumerState<AiSuggestionsBottomSheet> createState() =>
      _AiSuggestionsBottomSheetState();
}

class _AiSuggestionsBottomSheetState
    extends ConsumerState<AiSuggestionsBottomSheet> {
  List<TaskSuggestion> _suggestions = [];
  bool _isLoading = false;
  bool _showLoadingIndicator = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    // Show initial cached suggestions if available
    if (widget.initialSuggestions != null &&
        widget.initialSuggestions!.isNotEmpty) {
      _suggestions = widget.initialSuggestions!;

      // Only fetch fresh suggestions if user has typed something
      if (widget.currentInput.trim().isNotEmpty) {
        _fetchSuggestions();
      }
    } else {
      // No cache - start loading immediately
      _isLoading = true;
      _fetchSuggestions();
    }
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
      final response = await aiService.getTaskSuggestions(
        taskListId: widget.taskListId,
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
          _isLoading = false;
          _showLoadingIndicator = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  /// Handles suggestion tap
  void _onSuggestionTap(TaskSuggestion suggestion) {
    widget.onSuggestionSelected(suggestion);
  }

  /// Builds a suggestion card
  Widget _buildSuggestionCard(TaskSuggestion suggestion) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveThemeColor = widget.themeColor ?? colorScheme.primary;

    // Format repeat description
    String repeatDescription;
    if (suggestion.repeatDelta == 1) {
      repeatDescription =
          'Repeats every ${suggestion.repeatUnit.toLowerCase().replaceAll('_', ' ')}';
    } else {
      repeatDescription =
          'Repeats every ${suggestion.repeatDelta} ${suggestion.repeatUnit.toLowerCase().replaceAll('_', ' ')}';
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _onSuggestionTap(suggestion),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Leading AI icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: effectiveThemeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  size: 20,
                  color: effectiveThemeColor,
                ),
              ),
              const SizedBox(width: 16),

              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      suggestion.name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      repeatDescription,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Trailing arrow icon
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

  /// Builds a shimmer loading placeholder for suggestions
  Widget _buildShimmerPlaceholder() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Leading icon placeholder
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 16),

            // Text content placeholders
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colorScheme.onSurface.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 120,
                    decoration: BoxDecoration(
                      color: colorScheme.onSurface.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the loading state
  Widget _buildLoadingState() {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveThemeColor = widget.themeColor ?? colorScheme.primary;
    
    if (_showLoadingIndicator) {
      // Show loading indicator after threshold
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: effectiveThemeColor,
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.of(context).loadingSuggestions,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Show shimmer placeholders while loading quickly
      return Column(
        children: List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildShimmerPlaceholder(),
          ),
        ),
      );
    }
  }

  /// Builds the empty state
  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.of(context).noSuggestions,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Try typing a few characters to get suggestions',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the error state
  Widget _buildErrorState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveThemeColor = widget.themeColor ?? colorScheme.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: colorScheme.error.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.of(context).failedToFetchSuggestions,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'An unexpected error occurred',
              style: theme.textTheme.bodySmall?.copyWith(
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
                label: const Text('Retry'),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveThemeColor = widget.themeColor ?? colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 16, 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 24,
                  color: effectiveThemeColor,
                ),
                const SizedBox(width: 12),
                Text(
                  AppStrings.of(context).aiSuggestions,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Close suggestions',
                ),
              ],
            ),
          ),

          // Content
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 500),
              child: _isLoading
                  ? _buildLoadingState()
                  : _errorMessage != null
                      ? _buildErrorState()
                      : _suggestions.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shrinkWrap: true,
                              itemCount: _suggestions.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child:
                                      _buildSuggestionCard(_suggestions[index]),
                                );
                              },
                            ),
            ),
          ),

          // Bottom safe area padding
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}