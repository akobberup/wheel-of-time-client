import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Cirkulær fremskridtsindikator med ikon i midten
/// Viser fuldførelsesprocent med farve baseret på fremskridt
class CircularProgressIndicatorWithIcon extends StatelessWidget {
  /// Antal fuldførte opgaver
  final int completed;

  /// Totalt antal opgaver
  final int total;

  /// Ikon der vises i midten
  final IconData icon;

  /// Størrelse på widgetten
  final double size;

  /// Tykkelse på fremskridtscirklen
  final double strokeWidth;

  /// Om der skal vises fejringsfarve ved 100%
  final bool showCelebration;

  const CircularProgressIndicatorWithIcon({
    super.key,
    required this.completed,
    required this.total,
    this.icon = Icons.list_alt,
    this.size = 48.0,
    this.strokeWidth = 3.0,
    this.showCelebration = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = total > 0 ? completed / total : 0.0;
    final progressColor = _getProgressColor(context, progress);
    final isComplete = progress >= 1.0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Baggrundscirkel
          CustomPaint(
            size: Size(size, size),
            painter: _CircleProgressPainter(
              progress: progress,
              progressColor: progressColor,
              backgroundColor: colorScheme.surfaceContainerHighest,
              strokeWidth: strokeWidth,
            ),
          ),
          // Ikon i midten med animation ved fuldførelse
          if (isComplete && showCelebration)
            _CelebrationIcon(
              icon: Icons.check_circle,
              color: progressColor,
              size: size * 0.5,
            )
          else
            Icon(
              icon,
              size: size * 0.45,
              color: progressColor.withValues(alpha: 0.8),
            ),
        ],
      ),
    );
  }

  /// Returnerer farve baseret på fremskridtsprocent
  Color _getProgressColor(BuildContext context, double progress) {
    final colorScheme = Theme.of(context).colorScheme;

    if (progress >= 1.0 && showCelebration) {
      // 100% - fejringsfarve (tertiary/guld)
      return colorScheme.tertiary;
    } else if (progress >= 0.7) {
      // 70-99% - grøn
      return Colors.green;
    } else if (progress >= 0.3) {
      // 30-69% - amber/orange
      return Colors.amber.shade700;
    } else {
      // 0-29% - rød/orange
      return colorScheme.error;
    }
  }
}

/// Custom painter til at tegne fremskridtscirklen med baggrund og fremskridtsbue
/// Tegner først en baggrundscirkel og derefter en farvet bue baseret på fremskridt
class _CircleProgressPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color backgroundColor;
  final double strokeWidth;

  _CircleProgressPainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Baggrundscirkel
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Fremskridtsbue
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * math.pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2, // Start fra toppen
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CircleProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor;
  }
}

/// Animeret fejringsikon ved 100% fuldførelse
class _CelebrationIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final double size;

  const _CelebrationIcon({
    required this.icon,
    required this.color,
    required this.size,
  });

  @override
  State<_CelebrationIcon> createState() => _CelebrationIconState();
}

class _CelebrationIconState extends State<_CelebrationIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Icon(
            widget.icon,
            size: widget.size,
            color: widget.color,
          ),
        );
      },
    );
  }
}
