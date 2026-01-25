// Design Version: 1.0.0 (se docs/DESIGN_GUIDELINES.md)

import 'package:flutter/material.dart';
import '../../models/task_occurrence.dart';
import '../../l10n/app_strings.dart';
import 'task_urgency.dart';
import 'hero_task_card.dart';
import 'medium_task_card.dart';
import 'compact_task_card.dart';
import 'frosted_locked_overlay.dart';

/// Kort der viser en enkelt opgaveforekomst med swipe-til-fuldførelse
/// Bruger 3-niveau visuelt hierarki baseret på urgency
/// Understøtter bidirectional swipe: højre-til-venstre = complete, venstre-til-højre = dismiss
class TaskOccurrenceCard extends StatelessWidget {
  final UpcomingTaskOccurrenceResponse occurrence;
  final Future<void> Function(UpcomingTaskOccurrenceResponse) onQuickComplete;
  final Future<void> Function(UpcomingTaskOccurrenceResponse)? onQuickDismiss;
  final Future<void> Function(BuildContext, UpcomingTaskOccurrenceResponse) onTap;
  final bool isDesktop;

  const TaskOccurrenceCard({
    super.key,
    required this.occurrence,
    required this.onQuickComplete,
    this.onQuickDismiss,
    required this.onTap,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    final isClickable = occurrence.isNextOccurrence;
    final urgency = getTaskUrgency(occurrence.dueDate);
    final canDismiss = isClickable && onQuickDismiss != null;

    return Dismissible(
      key: Key(occurrence.occurrenceId),
      direction: isClickable
          ? (canDismiss ? DismissDirection.horizontal : DismissDirection.endToStart)
          : DismissDirection.none,
      confirmDismiss: (direction) async {
        if (!isClickable) return false;
        if (direction == DismissDirection.endToStart) {
          await onQuickComplete(occurrence);
        } else if (direction == DismissDirection.startToEnd && onQuickDismiss != null) {
          await onQuickDismiss!(occurrence);
        }
        return false;
      },
      background: _buildDismissBackgroundForDismiss(context, urgency),
      secondaryBackground: _buildDismissBackgroundForComplete(context, urgency),
      child: _buildCardContent(context, isClickable, urgency),
    );
  }

  /// Baggrund for dismiss (swipe venstre-til-højre) - orange/amber farve
  Widget _buildDismissBackgroundForDismiss(BuildContext context, TaskUrgency urgency) {
    final isUrgent = urgency == TaskUrgency.overdue || urgency == TaskUrgency.today;
    final strings = AppStrings.of(context);

    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 20),
      margin: EdgeInsets.only(bottom: isUrgent ? 8 : 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.event_busy, color: Colors.white, size: 28),
          const SizedBox(width: 8),
          Text(
            strings.taskDismissedSwipe,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  /// Baggrund for complete (swipe højre-til-venstre) - grøn farve
  Widget _buildDismissBackgroundForComplete(BuildContext context, TaskUrgency urgency) {
    final isUrgent = urgency == TaskUrgency.overdue || urgency == TaskUrgency.today;
    final strings = AppStrings.of(context);

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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 28),
          const SizedBox(width: 8),
          Text(
            strings.taskCompletedSwipe,
            style: const TextStyle(
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
