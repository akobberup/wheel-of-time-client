import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_strings.dart';
import '../../providers/theme_provider.dart';

/// A festive, celebratory overlay animation displayed when a user completes a task.
///
/// Design decisions:
/// - Semi-transparent overlay to maintain context while celebrating
/// - Auto-dismisses after animation completes (prevents user frustration)
/// - Haptic feedback for tactile satisfaction
/// - Positioned in center for maximum visibility
/// - Custom confetti animation with user's theme colors
/// - Bouncing celebration effects
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
class TaskCompletionAnimation extends ConsumerStatefulWidget {
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
    HapticFeedback.heavyImpact();

    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) => TaskCompletionAnimation(
        streakCount: streakCount,
        completionMessage: completionMessage,
        onComplete: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  ConsumerState<TaskCompletionAnimation> createState() =>
      _TaskCompletionAnimationState();
}

class _TaskCompletionAnimationState
    extends ConsumerState<TaskCompletionAnimation>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _mainController;
  late AnimationController _confettiController;
  late AnimationController _pulseController;
  late AnimationController _streakController;

  // Animations
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _checkmarkAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _streakScaleAnimation;
  late Animation<Offset> _streakSlideAnimation;

  // Confetti particles
  final List<_ConfettiParticle> _confettiParticles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateConfetti();
    _startAnimations();
  }

  void _initializeAnimations() {
    // Main animation controller (for circle and checkmark)
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Confetti controller
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // Pulse controller for the glow effect
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Streak badge controller
    _streakController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Scale animation with bounce
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40,
      ),
    ]).animate(_mainController);

    // Fade animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    // Checkmark draw animation
    _checkmarkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );

    // Pulse animation for glow
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Streak badge animations
    _streakScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.3)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
    ]).animate(_streakController);

    _streakSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _streakController,
      curve: Curves.easeOutBack,
    ));
  }

  void _generateConfetti() {
    // Generate confetti particles with varying properties
    for (int i = 0; i < 50; i++) {
      _confettiParticles.add(_ConfettiParticle(
        x: _random.nextDouble() * 2 - 1, // -1 to 1
        y: _random.nextDouble() * -0.5, // Start above center
        velocityX: (_random.nextDouble() * 2 - 1) * 3,
        velocityY: _random.nextDouble() * 4 + 2,
        rotation: _random.nextDouble() * math.pi * 2,
        rotationSpeed: (_random.nextDouble() * 2 - 1) * 5,
        size: _random.nextDouble() * 8 + 4,
        shape: _random.nextInt(3), // 0: circle, 1: square, 2: rectangle
        colorIndex: _random.nextInt(5),
        delay: _random.nextDouble() * 0.3,
      ));
    }
  }

  void _startAnimations() async {
    // Start main animation
    _mainController.forward();

    // Start confetti slightly delayed
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      _confettiController.forward();
      HapticFeedback.mediumImpact();
    }

    // Start pulse animation
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      _pulseController.repeat(reverse: true);
    }

    // Start streak animation if applicable
    if (widget.streakCount != null && widget.streakCount! >= 3) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        _streakController.forward();
        HapticFeedback.lightImpact();
      }
    }

    // Auto-dismiss efter mindst 5 sekunders visning
    await Future.delayed(const Duration(milliseconds: 4500));
    if (mounted) {
      _dismiss();
    }
  }

  void _dismiss() async {
    _pulseController.stop();
    await _mainController.reverse();
    if (mounted) {
      widget.onComplete?.call();
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _confettiController.dispose();
    _pulseController.dispose();
    _streakController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final themeColor = themeState.seedColor;
    final colorScheme = Theme.of(context).colorScheme;
    final strings = AppStrings.of(context);

    // Generate celebration colors based on theme
    final colors = _generateCelebrationColors(themeColor);

    return GestureDetector(
      // Luk animation ved tap hvor som helst på skærmen
      onTap: _dismiss,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _mainController,
          _confettiController,
          _pulseController,
          _streakController,
        ]),
        builder: (context, child) {
          return Stack(
            children: [
              // Confetti layer
              ..._buildConfettiParticles(colors),

              // Main celebration content
              Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated checkmark circle
                    _buildCheckmarkCircle(themeColor, colorScheme),

                    const SizedBox(height: 24),

                    // Celebration text
                    if (widget.completionMessage != null) ...[
                      _buildCompletionMessage(colorScheme),
                      const SizedBox(height: 16),
                    ],

                    // Streak badge
                    if (widget.streakCount != null &&
                        widget.streakCount! >= 3) ...[
                      _buildStreakBadge(strings),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
        },
      ),
    );
  }

  List<Color> _generateCelebrationColors(Color themeColor) {
    // Create a festive palette based on the user's theme color
    final hslColor = HSLColor.fromColor(themeColor);
    return [
      themeColor,
      hslColor.withHue((hslColor.hue + 30) % 360).toColor(),
      hslColor.withHue((hslColor.hue + 60) % 360).toColor(),
      Colors.amber,
      Colors.white,
    ];
  }

  List<Widget> _buildConfettiParticles(List<Color> colors) {
    return _confettiParticles.map((particle) {
      final progress = (_confettiController.value - particle.delay)
          .clamp(0.0, 1.0 - particle.delay) /
          (1.0 - particle.delay);

      if (progress <= 0) return const SizedBox.shrink();

      final x = particle.x + particle.velocityX * progress;
      final y = particle.y + particle.velocityY * progress + 2 * progress * progress;
      final rotation = particle.rotation + particle.rotationSpeed * progress;
      final opacity = (1.0 - progress).clamp(0.0, 1.0);

      return Positioned(
        left: MediaQuery.of(context).size.width / 2 + x * 100,
        top: MediaQuery.of(context).size.height / 2 + y * 100 - 100,
        child: Transform.rotate(
          angle: rotation,
          child: Opacity(
            opacity: opacity,
            child: _buildConfettiShape(
              particle.shape,
              particle.size,
              colors[particle.colorIndex],
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildConfettiShape(int shape, double size, Color color) {
    switch (shape) {
      case 0: // Circle
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 4,
              ),
            ],
          ),
        );
      case 1: // Square
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 4,
              ),
            ],
          ),
        );
      case 2: // Rectangle
        return Container(
          width: size * 0.6,
          height: size * 1.5,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 4,
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildCheckmarkCircle(Color themeColor, ColorScheme colorScheme) {
    return Transform.scale(
      scale: _scaleAnimation.value,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    themeColor.withValues(alpha: 0.9),
                    HSLColor.fromColor(themeColor)
                        .withLightness(
                            (HSLColor.fromColor(themeColor).lightness - 0.1)
                                .clamp(0.0, 1.0))
                        .toColor(),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: themeColor.withValues(alpha: 0.4),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                  BoxShadow(
                    color: themeColor.withValues(alpha: 0.2),
                    blurRadius: 60,
                    spreadRadius: 20,
                  ),
                ],
              ),
              child: CustomPaint(
                painter: _CheckmarkPainter(
                  progress: _checkmarkAnimation.value,
                  color: Colors.white,
                  strokeWidth: 8,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCompletionMessage(ColorScheme colorScheme) {
    return Transform.scale(
      scale: _scaleAnimation.value.clamp(0.0, 1.0),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Text(
          widget.completionMessage!,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildStreakBadge(AppStrings strings) {
    return SlideTransition(
      position: _streakSlideAnimation,
      child: Transform.scale(
        scale: _streakScaleAnimation.value,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.orange.shade400,
                Colors.deepOrange.shade600,
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withValues(alpha: 0.5),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated fire icon
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 300),
                tween: Tween(begin: 0.8, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: const Icon(
                      Icons.local_fire_department,
                      color: Colors.white,
                      size: 26,
                    ),
                  );
                },
              ),
              const SizedBox(width: 10),
              Text(
                strings.streakCount(widget.streakCount!),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter for drawing an animated checkmark
class _CheckmarkPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _CheckmarkPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final checkmarkSize = size.width * 0.35;

    // Define checkmark points relative to center
    final start = Offset(center.dx - checkmarkSize * 0.5, center.dy);
    final middle = Offset(center.dx - checkmarkSize * 0.1, center.dy + checkmarkSize * 0.4);
    final end = Offset(center.dx + checkmarkSize * 0.5, center.dy - checkmarkSize * 0.3);

    final path = Path();

    if (progress <= 0.5) {
      // First segment: start to middle
      final segmentProgress = progress * 2;
      final currentPoint = Offset.lerp(start, middle, segmentProgress)!;
      path.moveTo(start.dx, start.dy);
      path.lineTo(currentPoint.dx, currentPoint.dy);
    } else {
      // Full first segment + partial second segment
      path.moveTo(start.dx, start.dy);
      path.lineTo(middle.dx, middle.dy);

      final segmentProgress = (progress - 0.5) * 2;
      final currentPoint = Offset.lerp(middle, end, segmentProgress)!;
      path.lineTo(currentPoint.dx, currentPoint.dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CheckmarkPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Data class for confetti particle properties
class _ConfettiParticle {
  final double x;
  final double y;
  final double velocityX;
  final double velocityY;
  final double rotation;
  final double rotationSpeed;
  final double size;
  final int shape;
  final int colorIndex;
  final double delay;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.velocityX,
    required this.velocityY,
    required this.rotation,
    required this.rotationSpeed,
    required this.size,
    required this.shape,
    required this.colorIndex,
    required this.delay,
  });
}
