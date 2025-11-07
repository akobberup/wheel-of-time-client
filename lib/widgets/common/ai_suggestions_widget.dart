import 'package:flutter/material.dart';
import 'dart:async';
import '../../l10n/app_strings.dart';

/// Callback type for when a suggestion is tapped (generic version)
typedef SuggestionCallback<T> = void Function(T suggestion);

/// Callback type for fetching suggestions based on user input (generic version)
typedef FetchSuggestionsCallback<T> = Future<List<T>> Function(String input);

/// Function type to extract display text from a suggestion object
typedef SuggestionDisplayExtractor<T> = String Function(T suggestion);

/// A reusable widget that displays AI-powered suggestions below an input field.
/// Generic type T allows handling both simple strings and complex objects (like TaskSuggestion).
///
/// Features:
/// - Debounced input (500ms) to avoid excessive API calls
/// - Smooth AnimatedSize transitions prevent jarring dialog resizing
/// - Fade-in/fade-out animations for polished appearance
/// - Loading indicator for slow responses (>800ms)
/// - Elegant, non-intrusive design with optional sparkle icon
/// - Up to 3 suggestions displayed by default
/// - Handles errors gracefully
/// - Shows cached suggestions immediately when available
/// - Can show suggestions on dialog open (before user types)
/// - Maintains layout stability in dialogs and forms
///
/// Example usage with strings:
/// ```dart
/// AiSuggestionsWidget<String>(
///   fetchSuggestions: (input) async {
///     final response = await aiService.getTaskListSuggestions(partialInput: input);
///     return response.suggestions;
///   },
///   displayExtractor: (suggestion) => suggestion,
///   onSuggestionTapped: (suggestion) {
///     nameController.text = suggestion;
///   },
///   textEditingController: nameController,
/// )
/// ```
///
/// Example usage with TaskSuggestion objects:
/// ```dart
/// AiSuggestionsWidget<TaskSuggestion>(
///   fetchSuggestions: (input) async {
///     final response = await aiService.getTaskSuggestions(...);
///     return response.suggestions;
///   },
///   displayExtractor: (suggestion) => suggestion.name,
///   onSuggestionTapped: (suggestion) {
///     // Handle full TaskSuggestion object with repeat pattern
///     _autoFillFromSuggestion(suggestion);
///   },
///   textEditingController: nameController,
///   initialSuggestions: cachedSuggestions,
///   showSparkleWhenEmpty: false,
/// )
/// ```
class AiSuggestionsWidget<T> extends StatefulWidget {
  /// Callback to fetch suggestions from the AI service
  final FetchSuggestionsCallback<T> fetchSuggestions;

  /// Callback when user taps a suggestion
  final SuggestionCallback<T> onSuggestionTapped;

  /// Function to extract display text from suggestion object
  final SuggestionDisplayExtractor<T> displayExtractor;

  /// The text controller to monitor for input changes
  final TextEditingController textEditingController;

  /// Initial cached suggestions to show immediately
  final List<T>? initialSuggestions;

  /// Minimum number of characters before fetching suggestions (0 to show on open)
  final int minimumCharacters;

  /// Debounce duration before fetching suggestions
  final Duration debounceDuration;

  /// Duration before showing loading indicator
  final Duration loadingThreshold;

  /// Whether to show sparkle icon when showing initial suggestions (before user types)
  final bool showSparkleWhenEmpty;

  const AiSuggestionsWidget({
    super.key,
    required this.fetchSuggestions,
    required this.onSuggestionTapped,
    required this.displayExtractor,
    required this.textEditingController,
    this.initialSuggestions,
    this.minimumCharacters = 2,
    this.debounceDuration = const Duration(milliseconds: 500),
    this.loadingThreshold = const Duration(milliseconds: 800),
    this.showSparkleWhenEmpty = true,
  });

  @override
  State<AiSuggestionsWidget<T>> createState() => _AiSuggestionsWidgetState<T>();
}

class _AiSuggestionsWidgetState<T> extends State<AiSuggestionsWidget<T>> {
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
    widget.textEditingController.addListener(_onTextChanged);

    // Show initial suggestions if provided
    if (widget.initialSuggestions != null && widget.initialSuggestions!.isNotEmpty) {
      _suggestions = widget.initialSuggestions!;
      _isShowingInitialSuggestions = true;
    } else if (widget.minimumCharacters == 0) {
      // If no initial suggestions and minimumCharacters is 0,
      // fetch suggestions immediately with empty input
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchSuggestions('');
      });
    }
  }

  @override
  void dispose() {
    widget.textEditingController.removeListener(_onTextChanged);
    _debounceTimer?.cancel();
    _loadingTimer?.cancel();
    super.dispose();
  }

  /// Handles text changes with debouncing
  void _onTextChanged() {
    final text = widget.textEditingController.text.trim();

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
          _suggestions = suggestions.take(3).toList(); // Limit to 3 suggestions
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

  /// Handles suggestion tap
  void _onSuggestionTap(T suggestion) {
    widget.onSuggestionTapped(suggestion);
    setState(() {
      _suggestions = [];
      _isShowingInitialSuggestions = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check if we should show the container
    final bool hasContent = _suggestions.isNotEmpty || _showLoading || _errorMessage != null;

    // Use AnimatedSize to smoothly transition height changes
    // This prevents jarring dialog resizing
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: AnimatedOpacity(
        opacity: hasContent ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: hasContent
            ? Container(
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
            // Header with optional sparkle icon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  // Show sparkle icon only when appropriate
                  if (!_isShowingInitialSuggestions || widget.showSparkleWhenEmpty) ...[
                    Icon(
                      Icons.auto_awesome,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    _isShowingInitialSuggestions && !widget.showSparkleWhenEmpty
                        ? AppStrings.of(context).suggestions
                        : AppStrings.of(context).aiSuggestions,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),

            // Divider
            Divider(
              height: 1,
              thickness: 1,
              color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3),
            ),

            // Loading indicator
            if (_showLoading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),

            // Suggestions list
            if (_suggestions.isNotEmpty)
              ...(_suggestions.asMap().entries.map((entry) {
                final index = entry.key;
                final suggestion = entry.value;
                final isLast = index == _suggestions.length - 1;
                final displayText = widget.displayExtractor(suggestion);

                return InkWell(
                  onTap: () => _onSuggestionTap(suggestion),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      border: isLast
                          ? null
                          : Border(
                              bottom: BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outlineVariant
                                    .withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            displayText,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList()),

                    // Error message (if any)
                    if (_errorMessage != null && _suggestions.isEmpty && !_showLoading)
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          AppStrings.of(context).failedToFetchSuggestions,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.error.withOpacity(0.7),
                                fontStyle: FontStyle.italic,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
