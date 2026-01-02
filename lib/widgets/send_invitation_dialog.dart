// Design Version: 1.0.0 (se docs/DESIGN_GUIDELINES.md)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/invitation_provider.dart';
import '../providers/theme_provider.dart';
import '../models/invitation.dart';
import '../l10n/app_strings.dart';

/// Dialog for sending an invitation to share a task list.
/// Allows the user to enter an email address to invite another user.
///
/// Follows design guidelines v1.0.0 with theme color support for consistent branding.
class SendInvitationDialog extends ConsumerStatefulWidget {
  final int taskListId;
  final String taskListName;
  final Color? themeColor;
  final Color? secondaryThemeColor;

  const SendInvitationDialog({
    super.key,
    required this.taskListId,
    required this.taskListName,
    this.themeColor,
    this.secondaryThemeColor,
  });

  @override
  ConsumerState<SendInvitationDialog> createState() => _SendInvitationDialogState();
}

class _SendInvitationDialogState extends ConsumerState<SendInvitationDialog>
    with SingleTickerProviderStateMixin {
  // Constants for consistent spacing and sizing
  static const double _borderRadius = 28.0;
  static const double _contentPadding = 24.0;
  static const double _verticalSpacing = 20.0;
  static const double _iconSize = 56.0;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
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
    _emailController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  /// Validates the email format.
  String? _validateEmail(String? value, AppStrings strings) {
    if (value == null || value.trim().isEmpty) {
      return strings.pleaseEnterEmailAddress;
    }

    // Basic email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return strings.pleaseEnterValidEmail;
    }

    return null;
  }

  /// Submits the invitation request with success animation.
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    final request = CreateInvitationRequest(
      taskListId: widget.taskListId,
      emailAddress: _emailController.text.trim(),
    );

    final result = await ref.read(invitationProvider.notifier).createInvitation(request);

    if (mounted) {
      final strings = AppStrings.of(context);
      if (result != null) {
        setState(() {
          _isLoading = false;
          _isSuccess = true;
        });
        HapticFeedback.heavyImpact();
        
        await Future.delayed(const Duration(milliseconds: 600));
        
        if (mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(strings.invitationSentTo(_emailController.text.trim())),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.failedToSendInvitation),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.inviteSomeoneTo(widget.taskListName),
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildEmailField(colorScheme, primaryColor, strings),
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
            Icons.share_outlined,
            size: 28,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          strings.sendInvitation,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Bygger email input felt med tema farve på fokus
  Widget _buildEmailField(
    ColorScheme colorScheme,
    Color primaryColor,
    AppStrings strings,
  ) {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        labelText: strings.emailAddress,
        hintText: strings.enterEmailToInvite,
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
          Icons.email_outlined,
          color: primaryColor.withValues(alpha: 0.7),
        ),
        filled: true,
        fillColor: colorScheme.surface,
      ),
      keyboardType: TextInputType.emailAddress,
      autofocus: true,
      validator: (value) => _validateEmail(value, strings),
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _submit(),
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
        Flexible(
          child: OutlinedButton(
            onPressed: _isLoading || _isSuccess
                ? null
                : () {
                    HapticFeedback.selectionClick();
                    Navigator.of(context).pop(false);
                  },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

        // Send button med gradient
        Flexible(
          child: AnimatedContainer(
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: _buildButtonIcon(),
              label: Text(
                _isSuccess ? strings.done : strings.sendInvite,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Bygger passende ikon for send knappen baseret på state
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
      return const Icon(Icons.send, size: 20);
    }
  }
}
