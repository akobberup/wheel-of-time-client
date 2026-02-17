import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/task_instance_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../models/task_instance.dart';
import '../models/streak.dart';
import '../l10n/app_strings.dart';
import '../config/api_config.dart';

/// A celebratory dialog for completing tasks with animations and encouraging messages.
///
/// This dialog provides a delightful experience when users complete tasks,
/// featuring entrance animations, haptic feedback, streak encouragement,
/// and progressive disclosure for optional features.
class CompleteTaskDialog extends ConsumerStatefulWidget {
  final int taskId;
  final String taskName;
  final StreakResponse? currentStreak;
  final String? taskImagePath;
  final String? taskListPrimaryColor;
  final String? taskListSecondaryColor;
  final int? taskInstanceId;
  final DateTime dueDate;

  const CompleteTaskDialog({
    super.key,
    required this.taskId,
    required this.taskName,
    this.currentStreak,
    this.taskImagePath,
    this.taskListPrimaryColor,
    this.taskListSecondaryColor,
    this.taskInstanceId,
    required this.dueDate,
  });

  @override
  ConsumerState<CompleteTaskDialog> createState() => _CompleteTaskDialogState();
}

class _CompleteTaskDialogState extends ConsumerState<CompleteTaskDialog>
    with TickerProviderStateMixin {
  // Constants for consistent spacing and sizing
  static const double _verticalSpacing = 16.0;
  static const double _headerPadding = 28.0;
  static const double _contentPadding = 20.0;
  static const double _borderRadius = 28.0;
  static const double _iconSize = 56.0;
  static const double _buttonIconSize = 20.0;

  // Controllers and state
  final _commentController = TextEditingController();
  DateTime _completedDateTime = DateTime.now();
  bool _isLoading = false;
  bool _isSkipping = false;
  bool _isSuccess = false;
  bool _showCommentField = false;
  bool _isTimeSelected = false;
  String? _completionMessage;

  // Animation controllers
  late AnimationController _scaleController;
  late AnimationController _iconBounceController;
  late AnimationController _successController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _iconBounceAnimation;
  late Animation<double> _iconRotationAnimation;
  late Animation<double> _successScaleAnimation;
  late Animation<double> _successOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _fetchCompletionMessage();
  }

  /// Sets up all animations for the dialog.
  void _setupAnimations() {
    // Entrance animation
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    // Icon bounce animation
    _iconBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _iconBounceAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.15)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.15, end: 1.0)
            .chain(CurveTween(curve: Curves.bounceOut)),
        weight: 75,
      ),
    ]).animate(_iconBounceController);

    _iconRotationAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.05, end: 0.05)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.05, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
    ]).animate(_iconBounceController);

    // Success animation
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _successScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.3)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40,
      ),
    ]).animate(_successController);

    _successOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _successController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    // Start entrance animations
    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _iconBounceController.forward();
      }
    });
  }

  /// Parser hex color string (f.eks. "#A8D5A2") til Color objekt
  Color _parseHexColor(String? hexString, Color fallback) {
    if (hexString == null || hexString.isEmpty) return fallback;

    final buffer = StringBuffer();
    if (hexString.length == 7) {
      buffer.write('FF'); // Tilføj alpha hvis ikke angivet
      buffer.write(hexString.replaceFirst('#', ''));
    } else if (hexString.length == 9) {
      buffer.write(hexString.replaceFirst('#', ''));
    } else {
      return fallback;
    }
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Fetches the completion message from the API in the background.
  Future<void> _fetchCompletionMessage() async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final message = await apiService.getTaskCompletionMessage(widget.taskId);

      if (mounted) {
        setState(() {
          _completionMessage = message;
        });
      }
    } catch (e) {
      // Silently fail - completion message is optional
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scaleController.dispose();
    _iconBounceController.dispose();
    _successController.dispose();
    super.dispose();
  }

  /// Opens time/date pickers and updates the completion timestamp.
  Future<void> _selectCompletionTime() async {
    HapticFeedback.selectionClick();

    final date = await showDatePicker(
      context: context,
      initialDate: _completedDateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_completedDateTime),
      );

      if (time != null) {
        setState(() {
          _completedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
          _isTimeSelected = true;
        });
        HapticFeedback.selectionClick();
      }
    }
  }

  /// Springer opgaven over (dismiss) via API
  Future<void> _skip() async {
    HapticFeedback.mediumImpact();
    setState(() => _isSkipping = true);

    final notifier = ref.read(taskInstancesProvider(widget.taskId).notifier);
    final taskInstanceId = widget.taskInstanceId;

    final result = taskInstanceId != null
        ? await notifier.dismissTaskInstance(taskInstanceId)
        : await notifier.dismissTaskOccurrence(widget.dueDate);

    if (mounted) {
      if (result != null) {
        Navigator.of(context).pop({'action': 'skipped'});
      } else {
        setState(() => _isSkipping = false);
        final strings = AppStrings.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.error)),
        );
      }
    }
  }

  /// Submits the task completion with success state animation.
  Future<void> _submit() async {
    HapticFeedback.heavyImpact();
    setState(() => _isLoading = true);

    final request = CreateTaskInstanceRequest(
      taskId: widget.taskId,
      completedDateTime: _completedDateTime,
      optionalComment: _commentController.text.trim().isEmpty
          ? null
          : _commentController.text.trim(),
    );

    final result = await ref
        .read(taskInstancesProvider(widget.taskId).notifier)
        .createTaskInstance(request);

    if (mounted) {
      if (result != null) {
        setState(() {
          _isLoading = false;
          _isSuccess = true;
        });

        HapticFeedback.heavyImpact();
        _successController.forward();

        await Future.delayed(const Duration(milliseconds: 700));

        if (mounted) {
          Navigator.of(context).pop({
            'result': result,
            'message': _completionMessage,
          });
        }
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          final strings = AppStrings.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(strings.failedToCompleteTask)),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final themeState = ref.watch(themeProvider);
    final themeColor = themeState.seedColor;

    // Brug task listens tema farver
    final primaryColor = _parseHexColor(
      widget.taskListPrimaryColor,
      themeColor,
    );
    final secondaryColor = _parseHexColor(
      widget.taskListSecondaryColor,
      primaryColor,
    );

    // Lys baggrund baseret på tema farve
    final backgroundColor = Color.lerp(primaryColor, Colors.white, 0.85) ??
        primaryColor.withValues(alpha: 0.15);
    final borderColor = Color.lerp(primaryColor, Colors.black, 0.1) ??
        primaryColor;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          side: BorderSide(
            color: borderColor.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        backgroundColor: backgroundColor,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Celebratory header with task image
                _buildCelebratoryHeader(colorScheme, textTheme, primaryColor, secondaryColor),

                // Main content area
                Padding(
                  padding: const EdgeInsets.all(_contentPadding),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Streak encouragement message (if applicable)
                      if (_shouldShowStreakEncouragement())
                        _buildStreakEncouragement(colorScheme),

                      const SizedBox(height: _verticalSpacing),

                      // Time selection with micro-interaction
                      _buildTimeSelector(colorScheme),

                      const SizedBox(height: _verticalSpacing),

                      // Progressive disclosure: comment field or "add note" button
                      _showCommentField
                          ? _buildCommentField()
                          : _buildAddNoteButton(),

                      const SizedBox(height: _verticalSpacing * 1.5),

                      // Action buttons
                      _buildActionButtons(colorScheme, themeColor),
                    ],
                  ),
                ),
              ],
            ),

            // Success overlay
            if (_isSuccess) _buildSuccessOverlay(themeColor),
          ],
        ),
        ),
      ),
    );
  }

  /// Builds the celebratory header with task image - no separate background.
  Widget _buildCelebratoryHeader(
    ColorScheme colorScheme,
    TextTheme textTheme,
    Color primaryColor,
    Color secondaryColor,
  ) {
    return Padding(
      padding: const EdgeInsets.all(_headerPadding),
      child: Column(
        children: [
          // Animeret opgave billede eller celebration ikon
          AnimatedBuilder(
            animation: Listenable.merge([
              _iconBounceAnimation,
              _iconRotationAnimation,
            ]),
            builder: (context, child) {
              return Transform.scale(
                scale: _iconBounceAnimation.value,
                child: Transform.rotate(
                  angle: _iconRotationAnimation.value,
                  child: _buildHeaderImage(primaryColor),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            widget.taskName.toUpperCase(),
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
              letterSpacing: 1.0,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Bygger header billedet - enten opgave billede eller celebration ikon
  Widget _buildHeaderImage(Color primaryColor) {
    final imagePath = widget.taskImagePath;

    if (imagePath != null && imagePath.isNotEmpty) {
      // Vis opgavens faktiske billede
      return SizedBox(
        width: 120,
        height: 120,
        child: CachedNetworkImage(
          imageUrl: ApiConfig.getImageUrl(imagePath),
          fit: BoxFit.contain,
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(),
          ),
          errorWidget: (context, url, error) =>
              _buildFallbackIcon(primaryColor),
        ),
      );
    } else {
      // Fallback til celebration ikon
      return _buildFallbackIcon(primaryColor);
    }
  }

  /// Bygger fallback celebration ikon
  Widget _buildFallbackIcon(Color primaryColor) {
    return Container(
      width: _iconSize + 16,
      height: _iconSize + 16,
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
            color: primaryColor.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Icon(
        Icons.celebration_rounded,
        size: _iconSize,
        color: primaryColor,
      ),
    );
  }

  /// Determines if we should show streak encouragement message.
  bool _shouldShowStreakEncouragement() {
    return widget.currentStreak != null &&
        widget.currentStreak!.isActive &&
        widget.currentStreak!.streakCount > 0;
  }

  /// Builds the streak encouragement message container with animation.
  Widget _buildStreakEncouragement(ColorScheme colorScheme) {
    final strings = AppStrings.of(context);
    final streakCount = widget.currentStreak!.streakCount;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.orange.shade50,
                  Colors.amber.shade50,
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.orange.shade300,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Animated fire icon
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 300),
                  tween: Tween(begin: 0.8, end: 1.0),
                  curve: Curves.elasticOut,
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.local_fire_department,
                          color: Colors.deepOrange.shade600,
                          size: 22,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    strings.keepStreakGoing(streakCount),
                    style: TextStyle(
                      color: Colors.orange.shade900,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds the time selector with animated highlight on selection.
  Widget _buildTimeSelector(ColorScheme colorScheme) {
    final strings = AppStrings.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: _isTimeSelected
            ? colorScheme.primaryContainer.withValues(alpha: 0.4)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _isTimeSelected
              ? colorScheme.primary.withValues(alpha: 0.6)
              : colorScheme.outline.withValues(alpha: 0.2),
          width: _isTimeSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        title: Text(
          strings.whenDidYouCompleteThis,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${DateFormat.yMMMd().format(_completedDateTime)} at ${DateFormat.jm().format(_completedDateTime)}',
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
        trailing: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _isTimeSelected
                ? colorScheme.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(
            _isTimeSelected ? Icons.check_circle : Icons.access_time,
            color: colorScheme.primary,
          ),
        ),
        onTap: _selectCompletionTime,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
    );
  }

  /// Builds the comment text field.
  Widget _buildCommentField() {
    final strings = AppStrings.of(context);

    return TextFormField(
      controller: _commentController,
      decoration: InputDecoration(
        labelText: strings.howDidItGo,
        hintText: strings.addNoteHint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
      ),
      maxLines: 3,
      textCapitalization: TextCapitalization.sentences,
    );
  }

  /// Builds the "Add a note" button for progressive disclosure.
  Widget _buildAddNoteButton() {
    final strings = AppStrings.of(context);

    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () {
          HapticFeedback.selectionClick();
          setState(() => _showCommentField = true);
        },
        icon: const Icon(Icons.note_add_outlined),
        label: Text(strings.addNote),
      ),
    );
  }

  /// Builds the action buttons with success state handling.
  Widget _buildActionButtons(ColorScheme colorScheme, Color themeColor) {
    final strings = AppStrings.of(context);
    final bool anyLoading = _isLoading || _isSkipping || _isSuccess;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Cancel button
        Flexible(
          child: OutlinedButton(
            onPressed: anyLoading
                ? null
                : () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: Text(strings.cancel),
          ),
        ),
        const SizedBox(width: 8),

        // Skip button
        Flexible(
          child: OutlinedButton.icon(
            onPressed: anyLoading ? null : _skip,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.orange.shade700,
              side: BorderSide(color: anyLoading ? Colors.grey.shade300 : Colors.orange.shade300),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            icon: _isSkipping
                ? SizedBox(
                    width: _buttonIconSize,
                    height: _buttonIconSize,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.orange.shade700),
                    ),
                  )
                : Icon(Icons.skip_next, size: _buttonIconSize),
            label: Text(strings.taskDismissedSwipe),
          ),
        ),
        const SizedBox(width: 8),

        // Complete button with animated states
        Flexible(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: FilledButton.icon(
              onPressed: anyLoading ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor:
                    _isSuccess ? Colors.green.shade600 : Colors.green.shade500,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                elevation: _isSuccess ? 6 : 2,
                shadowColor: Colors.green.withValues(alpha: 0.4),
              ),
              icon: _buildButtonIcon(),
              label: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  _getButtonLabel(strings),
                  key: ValueKey(_getButtonLabel(strings)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the appropriate icon for the complete button based on state.
  Widget _buildButtonIcon() {
    if (_isSuccess) {
      return const Icon(Icons.check_circle, size: _buttonIconSize);
    } else if (_isLoading) {
      return const SizedBox(
        width: _buttonIconSize,
        height: _buttonIconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    } else {
      return const Icon(Icons.check_circle_outline, size: _buttonIconSize);
    }
  }

  /// Returns the appropriate label for the complete button based on state.
  String _getButtonLabel(AppStrings strings) {
    if (_isSuccess) {
      return strings.done;
    } else if (_isLoading) {
      return strings.completing;
    } else {
      return strings.completeTaskButton;
    }
  }

  /// Builds the success overlay with animation.
  Widget _buildSuccessOverlay(Color themeColor) {
    return AnimatedBuilder(
      animation: _successController,
      builder: (context, child) {
        return Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: _successOpacityAnimation.value * 0.95,
              ),
              borderRadius: BorderRadius.circular(_borderRadius),
            ),
            child: Center(
              child: Transform.scale(
                scale: _successScaleAnimation.value,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.green.shade400,
                            Colors.green.shade600,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withValues(alpha: 0.4),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppStrings.of(context).done,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
