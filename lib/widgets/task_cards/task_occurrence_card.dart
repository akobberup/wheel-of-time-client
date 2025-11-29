import 'package:flutter/material.dart';
import '../../models/task_occurrence.dart';
import 'task_urgency.dart';
import 'hero_task_card.dart';
import 'medium_task_card.dart';
import 'compact_task_card.dart';
import 'frosted_locked_overlay.dart';

/// Kort der viser en enkelt opgaveforekomst med swipe-til-fuldførelse
/// Bruger 3-niveau visuelt hierarki baseret på urgency
class TaskOccurrenceCard extends StatelessWidget {
  final UpcomingTaskOccurrenceResponse occurrence;
  final Future<void> Function(UpcomingTaskOccurrenceResponse) onQuickComplete;
  final Future<void> Function(BuildContext, UpcomingTaskOccurrenceResponse) onTap;
  final bool isDesktop;

  const TaskOccurrenceCard({
    super.key,
    required this.occurrence,
    required this.onQuickComplete,
    required this.onTap,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    final isClickable = occurrence.isNextOccurrence;
    final urgency = getTaskUrgency(occurrence.dueDate);

    return Dismissible(
      key: Key(occurrence.occurrenceId),
      direction: isClickable ? DismissDirection.endToStart : DismissDirection.none,
      confirmDismiss: (direction) async {
        if (!isClickable) return false;
        await onQuickComplete(occurrence);
        return false;
      },
      background: _buildDismissBackground(urgency),
      child: _buildCardContent(context, isClickable, urgency),
    );
  }

  Widget _buildDismissBackground(TaskUrgency urgency) {
    final isUrgent = urgency == TaskUrgency.overdue || urgency == TaskUrgency.today;

    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      margin: EdgeInsets.only(bottom: isUrgent ? 8 : 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: Colors.white, size: 28),
          SizedBox(width: 8),
          Text(
            'Fuldført!',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
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

    return Stack(
      children: [
        card,
        if (!isClickable) FrostedLockedOverlay(urgency: urgency),
      ],
    );
  }
}
