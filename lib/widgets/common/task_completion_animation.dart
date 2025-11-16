import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import '../../l10n/app_strings.dart';

/// A polished overlay animation displayed when a user completes a task.
///
/// Design decisions:
/// - Semi-transparent overlay to maintain context while celebrating
/// - Auto-dismisses after animation completes (prevents user frustration)
/// - Haptic feedback for tactile satisfaction
/// - Positioned in center for maximum visibility
/// - Uses Lottie animation for smooth, professional celebration
/// - Only shows streak badge for meaningful streaks (3+ days)
///
/// Usage:
/// ```dart
/// await TaskCompletionAnimation.show(
///   context: context,
///   streakCount: occurrence.currentStreak?.streakCount,
///   completionMessage: 'Great job!',
/// );
/// ```
class TaskCompletionAnimation extends StatefulWidget {
  final int? streakCount;
  final VoidCallback? onComplete;
  final String? completionMessage;

  const TaskCompletionAnimation({
    super.key,
    this.streakCount,
    this.onComplete,
    this.completionMessage,
  });

  /// Shows the animation as a modal overlay
  /// Returns a Future that completes when the animation finishes
  ///
  /// The streak badge will only show if [streakCount] is 3 or more,
  /// making it feel like a meaningful achievement rather than routine.
  /// If [completionMessage] is provided, it will be displayed below the animation.
  static Future<void> show({
    required BuildContext context,
    int? streakCount,
    String? completionMessage,
  }) {
    // Provide haptic feedback for tactile satisfaction
    HapticFeedback.mediumImpact();

    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (context) => TaskCompletionAnimation(
        streakCount: streakCount,
        completionMessage: completionMessage,
        onComplete: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  State<TaskCompletionAnimation> createState() => _TaskCompletionAnimationState();
}

class _TaskCompletionAnimationState extends State<TaskCompletionAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Fade animation for smooth entrance and exit
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    // Start fade in
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  /// Handles animation completion - fades out and dismisses
  void _onAnimationComplete() {
    // Wait a brief moment before dismissing (allows user to see completion)
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _fadeController.reverse().then((_) {
          if (mounted) {
            widget.onComplete?.call();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 320,
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Lottie animation
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: Lottie.asset(
                      'assets/animations/success_animation.json',
                      repeat: false,
                      fit: BoxFit.contain,
                      onLoaded: (composition) {
                        // Calculate when animation will complete based on duration
                        final animationDuration = composition.duration;
                        Future.delayed(animationDuration, _onAnimationComplete);
                      },
                    ),
                  ),

                  // Optional completion message - shown if provided by the API
                  if (widget.completionMessage != null) ...[
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          widget.completionMessage!,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],

                  // Optional streak message - only show for meaningful streaks (3+ days)
                  if (widget.streakCount != null && widget.streakCount! >= 3) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.orange.shade400,
                            Colors.deepOrange.shade600,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_fire_department,
                            color: Colors.white,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            strings.streakCount(widget.streakCount!),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
