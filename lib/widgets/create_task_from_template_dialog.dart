// Design Version: 1.0.0 (se docs/DESIGN_GUIDELINES.md)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ai_suggestion_provider.dart';
import '../providers/task_provider.dart';
import '../providers/suggestion_cache_provider.dart';
import '../services/ai_suggestion_service.dart';
import '../models/task.dart';
import '../models/enums.dart';
import '../models/schedule.dart';
import '../l10n/app_strings.dart';

/// Marker-klasse til at indikere at bruger vil oprette manuelt (tom dialog)
class OpenManualTaskCreateMarker {
  const OpenManualTaskCreateMarker();
}

/// Marker-klasse til at indikere at bruger vil redigere et forslag før oprettelse
class EditTaskSuggestionMarker {
  final TaskSuggestion suggestion;
  const EditTaskSuggestionMarker(this.suggestion);
}

/// Dialog til onboarding af nye brugere i en tasklist med AI-genererede task-forslag.
///
/// Viser en liste af foreslåede tasks som brugeren kan vælge blandt.
/// Ved klik på et forslag vises "Opret" og "Rediger" valg.
class CreateTaskFromTemplateDialog extends ConsumerStatefulWidget {
  final int taskListId;
  final Color? themeColor;
  final Color? secondaryThemeColor;

  const CreateTaskFromTemplateDialog({
    super.key,
    required this.taskListId,
    this.themeColor,
    this.secondaryThemeColor,
  });

  @override
  ConsumerState<CreateTaskFromTemplateDialog> createState() =>
      _CreateTaskFromTemplateDialogState();
}

class _CreateTaskFromTemplateDialogState
    extends ConsumerState<CreateTaskFromTemplateDialog>
    with SingleTickerProviderStateMixin {
  // Constants
  static const double _borderRadius = 28.0;
  static const double _contentPadding = 24.0;
  static const double _iconSize = 56.0;

  List<TaskSuggestion> _suggestions = [];
  bool _isLoadingSuggestions = false;
  bool _showLoadingIndicator = false;
  String? _errorMessage;
  String? _creatingSuggestionName;

  // Expanded state - kun ét kort kan være expanded ad gangen
  int? _expandedIndex;

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

  /// Henter AI-genererede forslag til tasks
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
      // Tjek først om vi har cached forslag
      final suggestionCache = ref.read(suggestionCacheProvider.notifier);
      final cachedSuggestions =
          suggestionCache.getCachedSuggestions(widget.taskListId);

      if (cachedSuggestions != null && cachedSuggestions.isNotEmpty) {
        if (mounted) {
          setState(() {
            _suggestions = cachedSuggestions;
            _isLoadingSuggestions = false;
            _showLoadingIndicator = false;
            _errorMessage = null;
          });
        }
        return;
      }

      // Hent nye forslag fra API
      final aiService = ref.read(aiSuggestionServiceProvider);
      final response = await aiService.getTaskSuggestions(
        taskListId: widget.taskListId,
        partialInput: '',
        maxSuggestions: 5,
      );

      // Cache forslagene
      suggestionCache.cacheSuggestions(widget.taskListId, response.suggestions);

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

  /// Opretter en task direkte fra det valgte forslag
  Future<void> _createFromSuggestion(TaskSuggestion suggestion) async {
    if (_creatingSuggestionName != null) return;

    HapticFeedback.mediumImpact();
    setState(() {
      _creatingSuggestionName = suggestion.name;
    });

    // Byg schedule fra suggestion
    TaskSchedule schedule;
    try {
      final repeatUnit = RepeatUnit.fromJson(suggestion.repeatUnit);
      schedule = TaskSchedule.interval(
        repeatUnit: repeatUnit,
        repeatDelta: suggestion.repeatDelta,
        description: _buildIntervalDescription(repeatUnit, suggestion.repeatDelta),
      );
    } catch (e) {
      // Fallback til weekly
      schedule = const TaskSchedule.interval(
        repeatUnit: RepeatUnit.WEEKS,
        repeatDelta: 1,
        description: 'Weekly',
      );
    }

    final request = CreateTaskRequest(
      name: suggestion.name,
      description: null,
      taskListId: widget.taskListId,
      schedule: schedule,
      firstRunDate: DateTime.now(),
    );

    try {
      final result = await ref
          .read(tasksProvider(widget.taskListId).notifier)
          .createTask(request);

      if (mounted) {
        if (result != null) {
          HapticFeedback.heavyImpact();
          Navigator.of(context).pop(result);
        } else {
          setState(() {
            _creatingSuggestionName = null;
          });
          final strings = AppStrings.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(strings.failedToCreateTask),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _creatingSuggestionName = null;
        });
        final strings = AppStrings.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.failedToCreateTask),
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

  /// Returnerer marker for at åbne manuel opret-dialog med præudfyldt forslag
  void _openEditSuggestion(TaskSuggestion suggestion) {
    HapticFeedback.selectionClick();
    Navigator.of(context).pop(EditTaskSuggestionMarker(suggestion));
  }

  /// Returnerer marker for at åbne tom manuel opret-dialog
  void _openManualCreate() {
    HapticFeedback.selectionClick();
    Navigator.of(context).pop(const OpenManualTaskCreateMarker());
  }

  /// Bygger interval beskrivelse
  String _buildIntervalDescription(RepeatUnit unit, int delta) {
    if (delta == 1) {
      switch (unit) {
        case RepeatUnit.DAYS:
          return 'Daily';
        case RepeatUnit.WEEKS:
          return 'Weekly';
        case RepeatUnit.MONTHS:
          return 'Monthly';
        case RepeatUnit.YEARS:
          return 'Yearly';
      }
    }

    final unitName = unit.toString().split('.').last.toLowerCase();
    return 'Every $delta $unitName';
  }

  /// Formaterer gentagelsesmønster til visning
  String _formatRepeatPattern(TaskSuggestion suggestion, AppStrings strings) {
    final repeatUnit = suggestion.repeatUnit.toLowerCase();
    final delta = suggestion.repeatDelta;

    if (delta == 1) {
      switch (repeatUnit) {
        case 'days':
          return strings.repeatsDaily;
        case 'weeks':
          return strings.repeatsWeekly;
        case 'months':
          return strings.repeatsMonthly;
        case 'years':
          return strings.repeatsYearly;
      }
    }

    return strings.repeatsEveryN(delta, repeatUnit);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final primaryColor = widget.themeColor ?? colorScheme.primary;

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
                child:
                    _buildHeader(colorScheme, textTheme, primaryColor, strings),
              ),

              // Indhold (suggestions liste)
              Flexible(
                child: _buildContent(
                    context, colorScheme, textTheme, primaryColor, strings),
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
          strings.chooseTaskTemplateDescription,
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
        final isExpanded = _expandedIndex == index;
        return _buildSuggestionCard(
          context,
          colorScheme,
          textTheme,
          primaryColor,
          suggestion,
          index,
          isExpanded,
          strings,
        );
      },
    );
  }

  Widget _buildSuggestionCard(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
    Color primaryColor,
    TaskSuggestion suggestion,
    int index,
    bool isExpanded,
    AppStrings strings,
  ) {
    final isCreating = _creatingSuggestionName == suggestion.name;
    final isDisabled = _creatingSuggestionName != null && !isCreating;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0,
        color: isExpanded
            ? Color.lerp(primaryColor, Colors.white, 0.85)
            : (isDisabled
                ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                : colorScheme.surfaceContainerHighest),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isExpanded
              ? BorderSide(color: primaryColor.withValues(alpha: 0.3), width: 1)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: isDisabled
              ? null
              : () {
                  setState(() {
                    _expandedIndex = isExpanded ? null : index;
                  });
                },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Collapsed/Header sektion
                Row(
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
                              Icons.task_alt,
                              color: primaryColor,
                              size: 20,
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            suggestion.name,
                            style: textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isDisabled
                                  ? colorScheme.onSurface.withValues(alpha: 0.5)
                                  : colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatRepeatPattern(suggestion, strings),
                            style: textTheme.bodySmall?.copyWith(
                              color: isDisabled
                                  ? colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.5)
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isCreating)
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.chevron_right,
                        size: 20,
                        color: isDisabled
                            ? colorScheme.onSurfaceVariant.withValues(alpha: 0.3)
                            : colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                  ],
                ),

                // Expanded sektion med knapper
                if (isExpanded && !isCreating) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // "Opret" knap - primær
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isDisabled
                              ? null
                              : () => _createFromSuggestion(suggestion),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            strings.create,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // "Rediger" knap - sekundær
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isDisabled
                              ? null
                              : () => _openEditSuggestion(suggestion),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: primaryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            strings.editBeforeCreating,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
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
                  const SizedBox(height: 6),
                  Container(
                    height: 12,
                    width: 100,
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
    final isDisabled = _creatingSuggestionName != null;

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
