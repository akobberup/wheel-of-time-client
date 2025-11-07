import 'package:flutter/material.dart';
import 'dart:async';
import '../../l10n/app_strings.dart';

/// Callback type for when a suggestion is selected in the search view
typedef SearchSuggestionCallback<T> = void Function(T suggestion);

/// Callback type for fetching suggestions based on user input
typedef SearchFetchSuggestionsCallback<T> = Future<List<T>> Function(String input);

/// Function type to extract display text from a suggestion object
typedef SearchSuggestionDisplayExtractor<T> = String Function(T suggestion);

/// A Material 3 SearchAnchor-based field that opens a full-screen search view
/// when tapped. Styled to look like a tappable search trigger, NOT an editable text field.
///
/// Design Philosophy:
/// This widget solves the "affordance mismatch" problem where a TextFormField with
/// readOnly=true looks editable but behaves differently. Instead, this component is
/// visually designed to signal "tap to search" rather than "type here."
///
/// Visual Characteristics:
/// - Uses SearchBar-like styling with rounded corners (12dp)
/// - Prominent search icon that changes to checkmark when filled
/// - Trailing arrow icon (→) signals tappability when empty
/// - Trailing clear button (×) when filled
/// - Background uses surfaceContainerHigh instead of text field background
/// - Subtle border to distinguish from regular form fields
/// - No cursor, no selection handles - clearly not directly editable
///
/// Features:
/// - Full-screen search view with Material 3 transitions
/// - Background scrim (dimming) automatically handled by SearchAnchor
/// - AI-powered suggestions with debouncing and caching
/// - Smooth animations and loading states
/// - Form validation support with error states
/// - Preserves form state when navigating back
/// - Accessible with proper focus management and semantic labels
/// - Multiple dismissal methods (back button, tap outside, clear button)
///
/// Example usage:
/// ```dart
/// SearchableTextField<TaskSuggestion>(
///   controller: _nameController,
///   labelText: 'Task Name',
///   hintText: 'Enter task name',
///   fetchSuggestions: (input) async {
///     final response = await aiService.getTaskSuggestions(...);
///     return response.suggestions;
///   },
///   displayExtractor: (suggestion) => suggestion.name,
///   onSuggestionSelected: (suggestion) {
///     _autoFillFromSuggestion(suggestion);
///   },
///   initialSuggestions: cachedSuggestions,
///   validator: (value) {
///     if (value == null || value.trim().isEmpty) {
///       return 'Please enter a task name';
///     }
///     return null;
///   },
/// )
/// ```
class SearchableTextField<T> extends StatefulWidget {
  /// The text editing controller for the text field
  final TextEditingController controller;

  /// The label text displayed above the field
  final String labelText;

  /// Hint text shown when the field is empty
  final String? hintText;

  /// Callback to fetch suggestions from the AI service
  final SearchFetchSuggestionsCallback<T> fetchSuggestions;

  /// Function to extract display text from suggestion object
  final SearchSuggestionDisplayExtractor<T> displayExtractor;

  /// Callback when user selects a suggestion
  final SearchSuggestionCallback<T> onSuggestionSelected;

  /// Optional validator for form validation
  final String? Function(String?)? validator;

  /// Initial cached suggestions to show immediately
  final List<T>? initialSuggestions;

  /// Minimum number of characters before fetching suggestions (0 to show on open)
  final int minimumCharacters;

  /// Debounce duration before fetching suggestions
  final Duration debounceDuration;

  /// Duration before showing loading indicator
  final Duration loadingThreshold;

  /// Whether the field is required
  final bool isRequired;

  /// Icon to show at the start of the field
  final IconData? leadingIcon;

  const SearchableTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.fetchSuggestions,
    required this.displayExtractor,
    required this.onSuggestionSelected,
    this.hintText,
    this.validator,
    this.initialSuggestions,
    this.minimumCharacters = 0,
    this.debounceDuration = const Duration(milliseconds: 500),
    this.loadingThreshold = const Duration(milliseconds: 800),
    this.isRequired = false,
    this.leadingIcon,
  });

  @override
  State<SearchableTextField<T>> createState() => _SearchableTextFieldState<T>();
}

class _SearchableTextFieldState<T> extends State<SearchableTextField<T>> {
  late final SearchController _searchController;
  List<T> _suggestions = [];
  bool _isLoading = false;
  bool _showLoading = false;
  String? _errorMessage;
  Timer? _debounceTimer;
  Timer? _loadingTimer;
  String _lastFetchedInput = '';
  bool _isShowingInitialSuggestions = false;

  @override
  void initState() {
    super.initState();
    _searchController = SearchController();

    // Initialize with cached suggestions if provided
    if (widget.initialSuggestions != null && widget.initialSuggestions!.isNotEmpty) {
      _suggestions = widget.initialSuggestions!;
      _isShowingInitialSuggestions = true;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    _loadingTimer?.cancel();
    super.dispose();
  }

  /// Handles text changes with debouncing
  void _onSearchChanged(String text) {
    // Cancel previous timers
    _debounceTimer?.cancel();
    _loadingTimer?.cancel();

    // Clear suggestions if text is too short (but not if minimumCharacters is 0)
    if (widget.minimumCharacters > 0 && text.length < widget.minimumCharacters) {
      setState(() {
        // If we have initial suggestions and field is now empty, show them again
        if (text.isEmpty && widget.initialSuggestions != null && widget.initialSuggestions!.isNotEmpty) {
          _suggestions = widget.initialSuggestions!;
          _isShowingInitialSuggestions = true;
        } else {
          _suggestions = [];
          _isShowingInitialSuggestions = false;
        }
        _isLoading = false;
        _showLoading = false;
        _errorMessage = null;
        _lastFetchedInput = '';
      });
      return;
    }

    // Don't fetch if input hasn't changed
    if (text == _lastFetchedInput) {
      return;
    }

    // User is typing - no longer showing initial suggestions
    _isShowingInitialSuggestions = false;

    // Start debounce timer
    _debounceTimer = Timer(widget.debounceDuration, () {
      _fetchSuggestions(text);
    });
  }

  /// Fetches suggestions from the AI service
  Future<void> _fetchSuggestions(String input) async {
    if (!mounted) return;

    // Don't fetch if input hasn't changed (unless it's the initial fetch)
    if (input == _lastFetchedInput && _lastFetchedInput.isNotEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
      _showLoading = false;
      _errorMessage = null;
      _lastFetchedInput = input;
    });

    // Start timer to show loading indicator after threshold
    _loadingTimer = Timer(widget.loadingThreshold, () {
      if (mounted && _isLoading) {
        setState(() {
          _showLoading = true;
        });
      }
    });

    try {
      final suggestions = await widget.fetchSuggestions(input);

      if (mounted) {
        _loadingTimer?.cancel();
        setState(() {
          _suggestions = suggestions.take(5).toList(); // Show up to 5 suggestions in search view
          _isLoading = false;
          _showLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        _loadingTimer?.cancel();
        setState(() {
          _suggestions = [];
          _isLoading = false;
          _showLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  /// Handles suggestion selection
  void _onSuggestionTap(T suggestion) {
    final displayText = widget.displayExtractor(suggestion);

    // Update the main controller
    widget.controller.text = displayText;

    // Update search controller to match
    _searchController.text = displayText;

    // Call the callback
    widget.onSuggestionSelected(suggestion);

    // Close the search view
    _searchController.closeView(displayText);

    // Clear suggestions
    setState(() {
      _suggestions = [];
      _isShowingInitialSuggestions = false;
    });
  }

  /// Builds the suggestion item widget
  Widget _buildSuggestionItem(T suggestion, bool isLast) {
    final displayText = widget.displayExtractor(suggestion);

    return InkWell(
      onTap: () => _onSuggestionTap(suggestion),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.auto_awesome,
              size: 20,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                displayText,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the suggestions list for the search view
  Iterable<Widget> _buildSuggestions(BuildContext context) {
    // Show loading indicator
    if (_showLoading) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
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
        ),
      ];
    }

    // Show error message
    if (_errorMessage != null && _suggestions.isEmpty && !_showLoading) {
      return [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.of(context).failedToFetchSuggestions,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error.withValues(alpha: 0.7),
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ];
    }

    // Show suggestions
    if (_suggestions.isNotEmpty) {
      return [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Icon(
                Icons.auto_awesome,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                _isShowingInitialSuggestions
                    ? AppStrings.of(context).suggestions
                    : AppStrings.of(context).aiSuggestions,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Suggestions list
        ..._suggestions.asMap().entries.map((entry) {
          final index = entry.key;
          final suggestion = entry.value;
          final isLast = index == _suggestions.length - 1;
          return _buildSuggestionItem(suggestion, isLast);
        }),
      ];
    }

    // Show empty state
    return [
      Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.of(context).noSuggestions,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ];
  }

  /// Opens the search view and initializes suggestions
  void _openSearchView(SearchController controller) {
    controller.openView();
    controller.text = widget.controller.text;

    // Show cached suggestions immediately if available and field is empty
    if (widget.initialSuggestions != null &&
        widget.initialSuggestions!.isNotEmpty &&
        controller.text.isEmpty) {
      setState(() {
        _suggestions = widget.initialSuggestions!;
        _isShowingInitialSuggestions = true;
      });
    }

    // Fetch fresh suggestions if needed (will replace cached ones when ready)
    if (widget.minimumCharacters == 0) {
      _fetchSuggestions(controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FormField<String>(
      initialValue: widget.controller.text,
      validator: widget.validator,
      builder: (formFieldState) {
        final hasValue = widget.controller.text.isNotEmpty;
        final hasError = formFieldState.hasError;

        // Determine visual state for the search anchor
        final backgroundColor = hasError
            ? colorScheme.errorContainer.withValues(alpha: 0.3)
            : colorScheme.surfaceContainerHigh;

        final borderColor = hasError
            ? colorScheme.error
            : colorScheme.outlineVariant.withValues(alpha: 0.5);

        final leadingIcon = hasValue ? Icons.check_circle : Icons.search;
        final leadingIconColor = hasValue
            ? colorScheme.primary
            : colorScheme.onSurfaceVariant;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label (consistent with TextFormField)
            if (widget.labelText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  widget.labelText,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: hasError
                        ? colorScheme.error
                        : colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            SearchAnchor(
              searchController: _searchController,
              isFullScreen: true,
              builder: (BuildContext context, SearchController controller) {
                // Search anchor field - styled to look tappable, not editable
                return Material(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () {
                      _openSearchView(controller);
                      formFieldState.didChange(widget.controller.text);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 56),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: borderColor,
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          // Leading icon (search or checkmark)
                          Icon(
                            leadingIcon,
                            size: 24,
                            color: leadingIconColor,
                          ),
                          const SizedBox(width: 12),

                          // Text content
                          Expanded(
                            child: Text(
                              hasValue
                                  ? widget.controller.text
                                  : (widget.hintText ?? widget.labelText),
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: hasValue
                                    ? colorScheme.onSurface
                                    : colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Trailing action icon
                          hasValue
                              ? IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    size: 20,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  onPressed: () {
                                    widget.controller.clear();
                                    formFieldState.didChange('');
                                    setState(() {});
                                  },
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                  padding: EdgeInsets.zero,
                                  tooltip: AppStrings.of(context).clear,
                                )
                              : Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              suggestionsBuilder: (BuildContext context, SearchController controller) {
                // Update suggestions when text changes
                if (controller.text != _lastFetchedInput) {
                  _onSearchChanged(controller.text);
                }

                // Return current suggestions
                return _buildSuggestions(context);
              },
              viewBuilder: (Iterable<Widget> suggestions) {
                // Custom view builder for full control over the search view layout
                return ListView(
                  padding: const EdgeInsets.only(top: 8),
                  children: suggestions.toList(),
                );
              },
              viewHintText: widget.hintText ?? widget.labelText,
              viewLeading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  // Sync the main controller with search controller text before closing
                  widget.controller.text = _searchController.text;
                  formFieldState.didChange(_searchController.text);
                  _searchController.closeView(_searchController.text);
                },
                tooltip: AppStrings.of(context).back,
              ),
              viewTrailing: [
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _suggestions = widget.initialSuggestions ?? [];
                        _isShowingInitialSuggestions = widget.initialSuggestions != null &&
                                                       widget.initialSuggestions!.isNotEmpty;
                        _lastFetchedInput = '';
                      });
                    },
                    tooltip: AppStrings.of(context).clear,
                  ),
              ],
            ),

            // Error message (consistent with TextFormField)
            if (hasError)
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 8),
                child: Text(
                  formFieldState.errorText!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
