import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

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
/// );
/// ```
class TaskCompletionAnimation extends StatefulWidget {
  final int? streakCount;
  final VoidCallback? onComplete;

  const TaskCompletionAnimation({
    super.key,
    this.streakCount,
    this.onComplete,
  });

  /// Shows the animation as a modal overlay
  /// Returns a Future that completes when the animation finishes
  ///
  /// The streak badge will only show if [streakCount] is 3 or more,
  /// making it feel like a meaningful achievement rather than routine.
  static Future<void> show({
    required BuildContext context,
    int? streakCount,
  }) {
    // Provide haptic feedback for tactile satisfaction
    HapticFeedback.mediumImpact();

    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (context) => TaskCompletionAnimation(
        streakCount: streakCount,
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
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 280,
              maxHeight: 280,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Lottie animation - constrained to leave room for streak badge
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

                // Optional streak message - only show for meaningful streaks (3+ days)
                if (widget.streakCount != null && widget.streakCount! >= 3) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
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
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${widget.streakCount} Day Streak!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
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
    );
  }
}
