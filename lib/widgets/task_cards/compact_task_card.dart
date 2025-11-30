import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/task_occurrence.dart';
import '../common/animated_card.dart';
import 'task_card_badges.dart';

/// Kompakt kort til future opgaver - minimalistisk design med hjul-motiv
/// Design Version: 1.0.0 (se docs/DESIGN_GUIDELINES.md)
class CompactTaskCard extends StatelessWidget {
  final UpcomingTaskOccurrenceResponse occurrence;
  final bool isClickable;
  final VoidCallback? onTap;
  final bool isDesktop;

  const CompactTaskCard({
    super.key,
    required this.occurrence,
    required this.isClickable,
    this.onTap,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Responsive dimensioner
    final wheelSize = isDesktop ? 32.0 : 38.0;
    final horizontalPadding = isDesktop ? 12.0 : 14.0;
    final verticalPadding = isDesktop ? 8.0 : 10.0;

    // Subtil gradient baggrund (varm tone)
    final gradientColors = isDark
        ? [
            colorScheme.surfaceContainerLow,
            colorScheme.surfaceContainerLow.withValues(alpha: 0.95),
          ]
        : [
            colorScheme.surface,
            colorScheme.primaryContainer.withValues(alpha: 0.05),
          ];

    return AnimatedCard(
      onTap: isClickable ? onTap : null,
      baseElevation: isDesktop ? 1 : 1,
      pressedElevation: isDesktop ? 3 : 2,
      margin: EdgeInsets.only(bottom: isDesktop ? 0 : 6),
      color: Colors.transparent,
      borderRadius: isDesktop ? 12 : 14,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(isDesktop ? 12 : 14),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        child: Row(
          children: [
            // Cirkulær hjul-indikator
            _WheelIndicator(
              size: wheelSize,
              color: colorScheme.primary,
              isDesktop: isDesktop,
            ),
            SizedBox(width: isDesktop ? 10 : 12),
            // Titel og liste
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    occurrence.taskName,
                    style: (isDesktop
                            ? theme.textTheme.bodyMedium
                            : theme.textTheme.bodyMedium)
                        ?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.folder_outlined,
                        size: isDesktop ? 11 : 12,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          occurrence.taskListName,
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: isDesktop ? 11 : 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Dato badge
            DueDateBadge(dueDate: occurrence.dueDate, compact: isDesktop),
          ],
        ),
      ),
    );
  }
}

/// Cirkulær hjul-indikator med schedule-ikon
/// Symboliserer opgavens position i tidens hjul
class _WheelIndicator extends StatelessWidget {
  final double size;
  final Color color;
  final bool isDesktop;

  const _WheelIndicator({
    required this.size,
    required this.color,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.08),
          ],
        ),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Subtile hjul-spokes
          CustomPaint(
            size: Size(size * 0.6, size * 0.6),
            painter: _WheelSpokesPainter(
              color: color.withValues(alpha: 0.15),
            ),
          ),
          // Schedule ikon i midten
          Icon(
            Icons.schedule,
            color: color,
            size: isDesktop ? 14 : 16,
          ),
        ],
      ),
    );
  }
}

/// Custom painter til at tegne hjul-spokes
class _WheelSpokesPainter extends CustomPainter {
  final Color color;

  _WheelSpokesPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Tegn 8 spokes
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4);
      final end = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawLine(center, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
