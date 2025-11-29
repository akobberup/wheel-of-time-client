import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/task_occurrence.dart';
import '../../l10n/app_strings.dart';
import '../../config/api_config.dart';
import '../common/animated_card.dart';
import '../common/gradient_background.dart';
import 'task_urgency.dart';
import 'task_card_badges.dart';

/// Hero-kort til overdue og today opgaver - stort, iøjnefaldende design med billede
class HeroTaskCard extends StatelessWidget {
  final UpcomingTaskOccurrenceResponse occurrence;
  final bool isClickable;
  final TaskUrgency urgency;
  final VoidCallback? onTap;
  final bool isDesktop;

  const HeroTaskCard({
    super.key,
    required this.occurrence,
    required this.isClickable,
    required this.urgency,
    this.onTap,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isOverdue = urgency == TaskUrgency.overdue;
    final accentColor = isOverdue ? colorScheme.error : colorScheme.tertiary;

    return AnimatedCard(
      onTap: isClickable ? onTap : null,
      baseElevation: isDesktop ? 6 : 4,
      pressedElevation: isDesktop ? 12 : 8,
      margin: EdgeInsets.only(bottom: isDesktop ? 0 : 8),
      borderSide: BorderSide(
        color: accentColor.withValues(alpha: 0.5),
        width: 2,
      ),
      borderRadius: isDesktop ? 16 : 20,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Baggrund: billede eller gradient
          _buildBackground(context, accentColor),
          // Gradient overlay for læsbarhed
          _buildGradientOverlay(accentColor),
          // Indhold positioneret i bunden
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildContent(context, accentColor),
          ),
          // Streak badge øverst til venstre
          if (occurrence.currentStreak != null && occurrence.currentStreak!.isActive)
            Positioned(
              top: isDesktop ? 12 : 16,
              left: isDesktop ? 12 : 16,
              child: AnimatedStreakBadge(
                streakCount: occurrence.currentStreak!.streakCount,
                isAtRisk: _shouldShowStreakWarning(),
              ),
            ),
          // Urgency indikator
          if (isOverdue) _buildUrgencyBanner(context),
        ],
      ),
    );
  }

  Widget _buildBackground(BuildContext context, Color accentColor) {
    final imagePath = occurrence.taskImagePath;

    if (imagePath != null && imagePath.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: ApiConfig.getImageUrl(imagePath),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) => GradientBackground(
          seed: occurrence.taskName,
          height: double.infinity,
        ),
        errorWidget: (context, url, error) => GradientBackground(
          seed: occurrence.taskName,
          height: double.infinity,
        ),
      );
    }

    return GradientBackground(
      seed: occurrence.taskName,
      height: double.infinity,
    );
  }

  Widget _buildGradientOverlay(Color accentColor) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.3),
            Colors.black.withValues(alpha: 0.7),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Color accentColor) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);

    // Responsive padding og font-størrelser
    final contentPadding = isDesktop ? 16.0 : 20.0;
    final titleStyle = isDesktop
        ? theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 8,
              ),
            ],
          )
        : theme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 8,
              ),
            ],
          );

    return Padding(
      padding: EdgeInsets.all(contentPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Opgave-liste label
          _buildTaskListLabel(context),
          SizedBox(height: isDesktop ? 6 : 8),
          // Titel
          Text(
            occurrence.taskName,
            style: titleStyle,
            maxLines: isDesktop ? 1 : 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: isDesktop ? 8 : 12),
          // Metadata række
          Row(
            children: [
              DueDateBadge(dueDate: occurrence.dueDate, compact: isDesktop),
              SizedBox(width: isDesktop ? 8 : 12),
              if (occurrence.totalCompletions > 0)
                Flexible(
                  child: MetadataChip(
                    icon: Icons.check_circle_outline,
                    label: strings.timesCompleted(occurrence.totalCompletions),
                    small: isDesktop,
                  ),
                ),
            ],
          ),
          // Streak advarsel hvis relevant
          if (_shouldShowStreakWarning())
            Padding(
              padding: EdgeInsets.only(top: isDesktop ? 8 : 12),
              child: StreakWarningBanner(
                streakCount: occurrence.currentStreak!.streakCount,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTaskListLabel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.list, size: 14, color: Colors.white70),
          const SizedBox(width: 4),
          Text(
            occurrence.taskListName,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgencyBanner(BuildContext context) {
    final strings = AppStrings.of(context);

    return Positioned(
      top: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(16),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber, color: Colors.white, size: 16),
            const SizedBox(width: 4),
            Text(
              strings.overdue,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _shouldShowStreakWarning() {
    if (occurrence.currentStreak == null || !occurrence.currentStreak!.isActive) {
      return false;
    }
    final now = DateTime.now();
    final hoursUntilDue = occurrence.dueDate.difference(now).inHours;
    return hoursUntilDue > 0 && hoursUntilDue <= 6;
  }
}
