// Design Version: 1.0.0 (se docs/DESIGN_GUIDELINES.md)

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/task_occurrence.dart';
import '../../l10n/app_strings.dart';
import '../../config/api_config.dart';
import '../common/animated_card.dart';
import 'task_urgency.dart';
import 'task_card_badges.dart';

/// Hero-kort til overdue og today opgaver - stort, iøjnefaldende design med billede
class HeroTaskCard extends StatefulWidget {
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
  State<HeroTaskCard> createState() => _HeroTaskCardState();
}

class _HeroTaskCardState extends State<HeroTaskCard> {
  bool _isHovered = false;

  /// Parser hex color string (f.eks. "#A8D5A2") til Color objekt
  Color _parseHexColor(String? hexString, Color fallback) {
    if (hexString == null || hexString.isEmpty) return fallback;
    
    final buffer = StringBuffer();
    if (hexString.length == 7) {
      buffer.write('FF'); // Tilføj alpha hvis ikke angivet
      buffer.write(hexString.replaceFirst('#', ''));
    } else if (hexString.length == 9) {
      buffer.write(hexString.replaceFirst('#', ''));
    } else {
      return fallback;
    }
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isOverdue = widget.urgency == TaskUrgency.overdue;

    // Brug task listens tema farve, eller fallback til standard farver
    final primaryColor = _parseHexColor(
      widget.occurrence.taskListPrimaryColor,
      isOverdue ? colorScheme.error : colorScheme.tertiary,
    );
    final accentColor = isOverdue ? colorScheme.error : primaryColor;

    // Giv kortet en fast aspect ratio - mere kvadratisk for at vise billeder bedre
    return AspectRatio(
      aspectRatio: widget.isDesktop ? 1.6 : 1.2,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedCard(
          onTap: widget.isClickable ? widget.onTap : null,
          baseElevation: widget.isDesktop ? 6 : 4,
          pressedElevation: widget.isDesktop ? 12 : 8,
          margin: EdgeInsets.only(bottom: widget.isDesktop ? 0 : 8),
          borderSide: BorderSide(
            color: accentColor.withValues(alpha: 0.5),
            width: 2,
          ),
          borderRadius: widget.isDesktop ? 16 : 20,
          child: Column(
            children: [
              // Billede sektion - fylder det meste af kortet
              Expanded(
                flex: 4,
                child: _buildImageSection(context, accentColor),
              ),
              // Titel sektion - store bogstaver, fed, centreret
              _buildTitleSection(context),
              // Beskrivelse sektion (hvis den findes)
              if (widget.occurrence.description != null && widget.occurrence.description!.isNotEmpty)
                _buildDescriptionSection(context),
              // Kontroller/metadata sektion - fast højde, farvet baggrund
              _buildControlsSection(context, accentColor),
            ],
          ),
        ),
      ),
    );
  }

  /// Billede sektion med fullbleed illustration, gradient overlay og badges
  Widget _buildImageSection(BuildContext context, Color accentColor) {
    final theme = Theme.of(context);
    final isOverdue = widget.urgency == TaskUrgency.overdue;
    final imagePath = widget.occurrence.taskImagePath;

    // Baggrundsfarve: brug task listens tema farve (lysere variant) eller fallback
    final themeColor = _parseHexColor(
      widget.occurrence.taskListPrimaryColor,
      theme.colorScheme.tertiaryContainer,
    );
    // Lav en lysere version af farven til baggrunden
    final backgroundColor = isOverdue
        ? theme.colorScheme.errorContainer
        : Color.lerp(themeColor, Colors.white, 0.7) ?? themeColor.withValues(alpha: 0.3);

    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(widget.isDesktop ? 16 : 20),
        topRight: Radius.circular(widget.isDesktop ? 16 : 20),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Ensfarvet baggrund
          Container(color: backgroundColor),

          // Billede med zoom-effekt og minimal padding
          if (imagePath != null && imagePath.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AnimatedScale(
                  scale: _isHovered ? 1.03 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  child: CachedNetworkImage(
                    imageUrl: ApiConfig.getImageUrl(imagePath),
                    fit: BoxFit.cover, // Fyld hele området
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) => Icon(
                      Icons.image_not_supported_outlined,
                      size: widget.isDesktop ? 60 : 80,
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),
            ),

          // Subtil gradient overlay for badge-synlighed (top-right hjørne)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                margin: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: const Alignment(0.0, 0.5),
                    colors: [
                      Colors.black.withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Subtil gradient overlay for streak badge (top-left hjørne)
          if (widget.occurrence.currentStreak != null && widget.occurrence.currentStreak!.isActive)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  margin: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: const Alignment(0.5, 0.5),
                      colors: [
                        Colors.black.withValues(alpha: 0.25),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Streak badge øverst til venstre
          if (widget.occurrence.currentStreak != null && widget.occurrence.currentStreak!.isActive)
            Positioned(
              top: widget.isDesktop ? 16 : 20,
              left: widget.isDesktop ? 16 : 20,
              child: AnimatedStreakBadge(
                streakCount: widget.occurrence.currentStreak!.streakCount,
                isAtRisk: _shouldShowStreakWarning(),
              ),
            ),

          // Urgency banner øverst til højre
          if (isOverdue)
            Positioned(
              top: 8,
              right: 8,
              child: _buildUrgencyBanner(context),
            ),
        ],
      ),
    );
  }

  /// Titel sektion - store bogstaver, fed, centreret, skalerer ned hvis nødvendigt
  Widget _buildTitleSection(BuildContext context) {
    final theme = Theme.of(context);

    final titleStyle = widget.isDesktop
        ? theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          )
        : theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          );

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isDesktop ? 16.0 : 20.0,
        vertical: widget.isDesktop ? 12.0 : 16.0,
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          widget.occurrence.taskName.toUpperCase(),
          style: titleStyle,
          textAlign: TextAlign.center,
          maxLines: 1,
        ),
      ),
    );
  }

  /// Beskrivelse sektion - centreret, subtil farve
  Widget _buildDescriptionSection(BuildContext context) {
    final theme = Theme.of(context);

    final descriptionStyle = widget.isDesktop
        ? theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          )
        : theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          );

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isDesktop ? 16.0 : 20.0,
      ),
      child: Text(
        widget.occurrence.description!,
        style: descriptionStyle,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// Kontroller/metadata sektion - ingen baggrund, matcher resten af kortet
  Widget _buildControlsSection(BuildContext context, Color accentColor) {
    return Padding(
      padding: EdgeInsets.only(
        left: widget.isDesktop ? 16.0 : 20.0,
        right: widget.isDesktop ? 16.0 : 20.0,
        bottom: widget.isDesktop ? 12.0 : 16.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Opgave-liste og schedule info
          _buildTaskListLabel(context),

          // Udløbstidspunkt for forsinkede opgaver med completion window
          if (_getExpiryDuration() != null)
            Padding(
              padding: EdgeInsets.only(top: widget.isDesktop ? 8 : 10),
              child: _buildExpiryBanner(context),
            ),

          // Streak advarsel hvis relevant
          if (_shouldShowStreakWarning())
            Padding(
              padding: EdgeInsets.only(top: widget.isDesktop ? 8 : 10),
              child: StreakWarningBanner(
                streakCount: widget.occurrence.currentStreak!.streakCount,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTaskListLabel(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.list,
                size: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                widget.occurrence.taskListName,
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        // Ansvarlig bruger badge
        if (widget.occurrence.assignedUserName != null) ...[
          const SizedBox(width: 8),
          AssignedUserBadge(
            userName: widget.occurrence.assignedUserName!,
            compact: false,
          ),
        ],
      ],
    );
  }

  Widget _buildUrgencyBanner(BuildContext context) {
    final strings = AppStrings.of(context);

    return Container(
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
    );
  }

  /// Beregner resterende tid til udløb for forsinkede opgaver.
  /// Returnerer null hvis opgaven ikke er forsinket eller ikke har completion window.
  Duration? _getExpiryDuration() {
    if (widget.urgency != TaskUrgency.overdue) return null;
    final windowHours = widget.occurrence.completionWindowHours;
    if (windowHours == null) return null;

    final expiryTime = widget.occurrence.dueDate.add(Duration(hours: windowHours));
    final remaining = expiryTime.difference(DateTime.now());
    if (remaining.isNegative) return null;
    return remaining;
  }

  /// Formaterer varighed til menneskeligt læsbar streng (f.eks. "2 dage", "5 timer", "30 min.")
  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return duration.inDays == 1 ? '1 dag' : '${duration.inDays} dage';
    }
    if (duration.inHours > 0) {
      final hours = duration.inHours;
      return hours == 1 ? '1 time' : '$hours timer';
    }
    final minutes = duration.inMinutes;
    if (minutes <= 0) return '< 1 min.';
    return '$minutes min.';
  }

  Widget _buildExpiryBanner(BuildContext context) {
    final strings = AppStrings.of(context);
    final theme = Theme.of(context);
    final remaining = _getExpiryDuration()!;
    final isUrgent = remaining.inHours < 6;
    final color = isUrgent ? theme.colorScheme.error : const Color(0xFFF59E0B);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              strings.expiresIn(_formatDuration(remaining)),
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _shouldShowStreakWarning() {
    if (widget.occurrence.currentStreak == null || !widget.occurrence.currentStreak!.isActive) {
      return false;
    }
    final now = DateTime.now();
    final hoursUntilDue = widget.occurrence.dueDate.difference(now).inHours;
    return hoursUntilDue > 0 && hoursUntilDue <= 6;
  }
}
