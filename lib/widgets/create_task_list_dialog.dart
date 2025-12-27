// Design Version: 1.0.0 (se docs/DESIGN_GUIDELINES.md)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/task_list_provider.dart';
import '../providers/theme_provider.dart';
import '../models/task_list.dart';
import '../l10n/app_strings.dart';
import 'task_list_suggestions_bottom_sheet.dart';

/// Dialog for creating a new task list with AI suggestions support.
///
/// Follows design guidelines v1.0.0 with theme color support for consistent branding.
class CreateTaskListDialog extends ConsumerStatefulWidget {
  final Color? themeColor;
  final Color? secondaryThemeColor;

  const CreateTaskListDialog({
    super.key,
    this.themeColor,
    this.secondaryThemeColor,
  });

  @override
  ConsumerState<CreateTaskListDialog> createState() => _CreateTaskListDialogState();
}

class _CreateTaskListDialogState extends ConsumerState<CreateTaskListDialog>
    with SingleTickerProviderStateMixin {
  // Constants for consistent spacing and sizing
  static const double _borderRadius = 28.0;
  static const double _contentPadding = 24.0;
  static const double _verticalSpacing = 20.0;
  static const double _iconSize = 56.0;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;
  bool _isSuccess = false;

  // Animation controllers
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  /// Sets up entrance animation for the dialog.
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
    _nameController.dispose();
    _descriptionController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  /// Shows the AI suggestions bottom sheet
  void _showAiSuggestions() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TaskListSuggestionsBottomSheet(
        currentInput: _nameController.text,
        onSuggestionSelected: (suggestion) {
          _nameController.text = suggestion;
          HapticFeedback.selectionClick();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  /// Submits the task list creation with success animation.
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.lightImpact();
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    final request = CreateTaskListRequest(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
    );

    final result = await ref.read(taskListProvider.notifier).createTaskList(request);

    if (mounted) {
      if (result != null) {
        setState(() {
          _isLoading = false;
          _isSuccess = true;
        });
        HapticFeedback.heavyImpact();
        
        await Future.delayed(const Duration(milliseconds: 600));
        
        if (mounted) {
          Navigator.of(context).pop(result);
        }
      } else {
        setState(() => _isLoading = false);
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

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final themeState = ref.watch(themeProvider);
    
    // Brug enten den medsendte tema farve eller brugerens valgte tema
    final primaryColor = widget.themeColor ?? themeState.seedColor;
    final secondaryColor = widget.secondaryThemeColor ?? primaryColor;

    // Lys baggrund baseret på tema farve
    final backgroundColor = Color.lerp(primaryColor, Colors.white, 0.90) ??
        primaryColor.withValues(alpha: 0.1);
    final borderColor = Color.lerp(primaryColor, Colors.black, 0.1) ??
        primaryColor;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(_contentPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header med ikon
                _buildHeader(colorScheme, textTheme, primaryColor, strings),
                
                const SizedBox(height: _verticalSpacing),

                // Form indhold
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildNameField(colorScheme, primaryColor, strings),
                      const SizedBox(height: 16),
                      _buildDescriptionField(colorScheme, primaryColor, strings),
                    ],
                  ),
                ),

                const SizedBox(height: _verticalSpacing),

                // Action buttons
                _buildActionButtons(colorScheme, primaryColor, strings),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }

  /// Bygger header med ikon og titel
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
            Icons.list_alt_rounded,
            size: 28,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          strings.createTaskList,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          strings.taskListDescription,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Bygger navn input felt med AI suggestions knap
  Widget _buildNameField(
    ColorScheme colorScheme,
    Color primaryColor,
    AppStrings strings,
  ) {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: strings.name,
        hintText: strings.enterTaskListName,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: primaryColor,
            width: 2,
          ),
        ),
        prefixIcon: Icon(
          Icons.list_alt,
          color: primaryColor.withValues(alpha: 0.7),
        ),
        suffixIcon: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryColor.withValues(alpha: 0.15),
                primaryColor.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            onPressed: _showAiSuggestions,
            icon: Icon(
              Icons.auto_awesome,
              color: primaryColor,
            ),
            tooltip: strings.aiSuggestions,
          ),
        ),
        filled: true,
        fillColor: colorScheme.surface,
      ),
      textCapitalization: TextCapitalization.sentences,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a name';
        }
        return null;
      },
    );
  }

  /// Bygger beskrivelse input felt
  Widget _buildDescriptionField(
    ColorScheme colorScheme,
    Color primaryColor,
    AppStrings strings,
  ) {
    return TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: strings.descriptionOptional,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: primaryColor,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: colorScheme.surface,
      ),
      maxLines: 3,
      textCapitalization: TextCapitalization.sentences,
    );
  }

  /// Bygger action buttons med tema farve gradient
  Widget _buildActionButtons(
    ColorScheme colorScheme,
    Color primaryColor,
    AppStrings strings,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Cancel button
        OutlinedButton(
          onPressed: _isLoading || _isSuccess
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  Navigator.of(context).pop(null);
                },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            side: BorderSide(
              color: colorScheme.outline.withValues(alpha: 0.3),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(strings.cancel),
        ),
        const SizedBox(width: 12),

        // Create button med gradient
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                primaryColor,
                Color.lerp(primaryColor, Colors.black, 0.15) ?? primaryColor,
              ],
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
            onPressed: _isLoading || _isSuccess ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: _buildButtonIcon(),
            label: Text(
              _isSuccess ? strings.done : strings.create,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Bygger passende ikon for create knappen baseret på state
  Widget _buildButtonIcon() {
    if (_isSuccess) {
      return const Icon(Icons.check_circle, size: 20);
    } else if (_isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    } else {
      return const Icon(Icons.add_circle_outline, size: 20);
    }
  }
}
