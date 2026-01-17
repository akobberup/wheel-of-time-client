// Design Version: 1.0.0 (se docs/DESIGN_GUIDELINES.md)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ai_suggestion_provider.dart';
import '../providers/task_list_provider.dart';
import '../providers/theme_provider.dart';
import '../models/task_list.dart';
import '../l10n/app_strings.dart';

/// Speciel marker-klasse til at indikere at bruger vil oprette manuelt
class OpenManualCreateMarker {
  const OpenManualCreateMarker();
}

/// Dialog til onboarding af nye brugere med AI-genererede skabelon-forslag.
///
/// Viser en liste af foreslåede tasklister som brugeren kan vælge blandt.
/// Ved klik på et forslag oprettes listen og returneres.
class CreateFromTemplateDialog extends ConsumerStatefulWidget {
  const CreateFromTemplateDialog({super.key});

  @override
  ConsumerState<CreateFromTemplateDialog> createState() =>
      _CreateFromTemplateDialogState();
}

class _CreateFromTemplateDialogState
    extends ConsumerState<CreateFromTemplateDialog>
    with SingleTickerProviderStateMixin {
  // Constants
  static const double _borderRadius = 28.0;
  static const double _contentPadding = 24.0;
  static const double _iconSize = 56.0;

  List<String> _suggestions = [];
  bool _isLoadingSuggestions = false;
  bool _showLoadingIndicator = false;
  String? _errorMessage;
  String? _creatingTemplate;

  // Animation
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _fetchSuggestions();
  }

  void _setupAnimations() {
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutCubic,
    );
    _scaleController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  /// Henter AI-genererede forslag til tasklister
  Future<void> _fetchSuggestions() async {
    if (!mounted) return;

    setState(() {
      _isLoadingSuggestions = true;
      _errorMessage = null;
    });

    // Vis loading indicator efter 500ms for at undgå flicker
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && _isLoadingSuggestions) {
        setState(() {
          _showLoadingIndicator = true;
        });
      }
    });

    try {
      final aiService = ref.read(aiSuggestionServiceProvider);
      final response = await aiService.getTaskListSuggestions(
        partialInput: '',
        maxSuggestions: 5,
      );

      if (mounted) {
        setState(() {
          _suggestions = response.suggestions;
          _isLoadingSuggestions = false;
          _showLoadingIndicator = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _suggestions = [];
          _isLoadingSuggestions = false;
          _showLoadingIndicator = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  /// Opretter en taskliste fra det valgte forslag
  Future<void> _createFromTemplate(String templateName) async {
    if (_creatingTemplate != null) return;

    HapticFeedback.mediumImpact();
    setState(() {
      _creatingTemplate = templateName;
    });

    final request = CreateTaskListRequest(
      name: templateName,
      description: null,
    );

    final result =
        await ref.read(taskListProvider.notifier).createTaskList(request);

    if (mounted) {
      if (result != null) {
        HapticFeedback.heavyImpact();
        Navigator.of(context).pop(result);
      } else {
        setState(() {
          _creatingTemplate = null;
        });
        final strings = AppStrings.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.failedToCreateTaskList),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  /// Returnerer marker for at åbne manuel opret-dialog
  void _openManualCreate() {
    HapticFeedback.selectionClick();
    Navigator.of(context).pop(const OpenManualCreateMarker());
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final themeState = ref.watch(themeProvider);
    final primaryColor = themeState.seedColor;

    // Lys baggrund baseret på tema farve
    final backgroundColor =
        Color.lerp(primaryColor, Colors.white, 0.90) ?? primaryColor;
    final borderColor =
        Color.lerp(primaryColor, Colors.black, 0.1) ?? primaryColor;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          side: BorderSide(
            color: borderColor.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        backgroundColor: backgroundColor,
        elevation: 4,
        shadowColor: primaryColor.withValues(alpha: 0.15),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(_contentPadding),
                child: _buildHeader(colorScheme, textTheme, primaryColor, strings),
              ),

              // Indhold (suggestions liste)
              Flexible(
                child: _buildContent(context, colorScheme, textTheme, primaryColor, strings),
              ),

              // Footer med knapper
              Padding(
                padding: const EdgeInsets.all(_contentPadding),
                child: _buildFooter(colorScheme, primaryColor, strings),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    ColorScheme colorScheme,
    TextTheme textTheme,
    Color primaryColor,
    AppStrings strings,
  ) {
    return Column(
      children: [
        Container(
          width: _iconSize,
          height: _iconSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryColor.withValues(alpha: 0.2),
                primaryColor.withValues(alpha: 0.1),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.15),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            Icons.auto_awesome,
            size: 28,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          strings.getStarted,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          strings.chooseTemplateDescription,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildContent(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
    Color primaryColor,
    AppStrings strings,
  ) {
    // Loading state
    if (_isLoadingSuggestions && _suggestions.isEmpty) {
      if (_showLoadingIndicator) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: primaryColor),
                const SizedBox(height: 16),
                Text(
                  strings.generatingSuggestions,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        // Shimmer placeholders
        return ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: _contentPadding),
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
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                strings.pleaseTryAgain,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _buildRetryButton(primaryColor, strings),
            ],
          ),
        ),
      );
    }

    // Success state - vis forslag
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: _contentPadding),
      itemCount: _suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = _suggestions[index];
        return _buildSuggestionCard(
          context,
          colorScheme,
          textTheme,
          primaryColor,
          suggestion,
        );
      },
    );
  }

  Widget _buildSuggestionCard(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
    Color primaryColor,
    String suggestion,
  ) {
    final isCreating = _creatingTemplate == suggestion;
    final isDisabled = _creatingTemplate != null && !isCreating;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: isDisabled
          ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
          : colorScheme.surfaceContainerHighest,
      child: InkWell(
        onTap: isDisabled ? null : () => _createFromTemplate(suggestion),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: isCreating
                    ? Padding(
                        padding: const EdgeInsets.all(10),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: primaryColor,
                        ),
                      )
                    : Icon(
                        Icons.list_alt,
                        color: primaryColor,
                        size: 20,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  suggestion,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isDisabled
                        ? colorScheme.onSurface.withValues(alpha: 0.5)
                        : colorScheme.onSurface,
                  ),
                ),
              ),
              if (!isCreating)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: isDisabled
                      ? colorScheme.onSurfaceVariant.withValues(alpha: 0.3)
                      : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
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

  Widget _buildRetryButton(Color primaryColor, AppStrings strings) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor,
            primaryColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.3),
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
    );
  }

  Widget _buildFooter(
    ColorScheme colorScheme,
    Color primaryColor,
    AppStrings strings,
  ) {
    final isDisabled = _creatingTemplate != null;

    return Row(
      children: [
        // Annuller knap
        Expanded(
          child: OutlinedButton(
            onPressed: isDisabled
                ? null
                : () {
                    HapticFeedback.selectionClick();
                    Navigator.of(context).pop(null);
                  },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              side: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.3),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(strings.cancel),
          ),
        ),
        const SizedBox(width: 12),

        // Opret manuelt knap
        Expanded(
          child: OutlinedButton.icon(
            onPressed: isDisabled ? null : _openManualCreate,
            icon: const Icon(Icons.edit, size: 18),
            label: Text(strings.createManually),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              side: BorderSide(color: primaryColor.withValues(alpha: 0.5)),
              foregroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
