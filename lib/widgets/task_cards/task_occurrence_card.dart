// Design Version: 1.0.0 (se docs/DESIGN_GUIDELINES.md)

import 'package:flutter/material.dart';
import '../../models/task_occurrence.dart';
import 'task_urgency.dart';
import 'hero_task_card.dart';
import 'medium_task_card.dart';
import 'compact_task_card.dart';
import 'frosted_locked_overlay.dart';

/// Kort der viser en enkelt opgaveforekomst
/// Bruger 3-niveau visuelt hierarki baseret på urgency
/// Tap åbner fuldførelses-dialogen (med mulighed for at springe over)
class TaskOccurrenceCard extends StatelessWidget {
  final UpcomingTaskOccurrenceResponse occurrence;
  final Future<void> Function(BuildContext, UpcomingTaskOccurrenceResponse) onTap;
  final bool isDesktop;

  const TaskOccurrenceCard({
    super.key,
    required this.occurrence,
    required this.onTap,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    final isClickable = occurrence.isNextOccurrence;
    final urgency = getTaskUrgency(occurrence.dueDate);
    return _buildCardContent(context, isClickable, urgency);
  }

  Widget _buildCardContent(BuildContext context, bool isClickable, TaskUrgency urgency) {
    // Vælg kort-type baseret på urgency niveau
    final Widget card = switch (urgency) {
      TaskUrgency.overdue || TaskUrgency.today => HeroTaskCard(
          occurrence: occurrence,
          isClickable: isClickable,
          urgency: urgency,
          onTap: () => onTap(context, occurrence),
          isDesktop: isDesktop,
        ),
      TaskUrgency.tomorrow || TaskUrgency.thisWeek => MediumTaskCard(
          occurrence: occurrence,
          isClickable: isClickable,
          urgency: urgency,
          onTap: () => onTap(context, occurrence),
          isDesktop: isDesktop,
        ),
      TaskUrgency.future => CompactTaskCard(
          occurrence: occurrence,
          isClickable: isClickable,
          onTap: () => onTap(context, occurrence),
          isDesktop: isDesktop,
        ),
    };

    // Brug IntrinsicHeight for at give Stack en defineret størrelse
    // når FrostedLockedOverlay bruger Positioned.fill
    if (!isClickable) {
      return IntrinsicHeight(
        child: Stack(
          children: [
            card,
            FrostedLockedOverlay(urgency: urgency),
          ],
        ),
      );
    }
    return card;
  }
}
