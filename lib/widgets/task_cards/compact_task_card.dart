import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/task_occurrence.dart';
import '../../config/api_config.dart';
import '../common/animated_card.dart';
import 'task_card_badges.dart';

/// Kompakt kort til future opgaver - minimalistisk design med tema-farver
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

  /// Parser hex color string til Color objekt
  Color _parseHexColor(String? hexString, Color fallback) {
    if (hexString == null || hexString.isEmpty) return fallback;

    final buffer = StringBuffer();
    if (hexString.length == 7) {
      buffer.write('FF');
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

    // Brug task listens tema farve
    final primaryColor = _parseHexColor(
      occurrence.taskListPrimaryColor,
      colorScheme.primary,
    );

    // Responsive dimensioner
    final avatarSize = isDesktop ? 36.0 : 42.0;
    final horizontalPadding = isDesktop ? 12.0 : 14.0;
    final verticalPadding = isDesktop ? 10.0 : 12.0;

    return AnimatedCard(
      onTap: isClickable ? onTap : null,
      baseElevation: isDesktop ? 1 : 1,
      pressedElevation: isDesktop ? 3 : 2,
      margin: EdgeInsets.only(bottom: isDesktop ? 0 : 6),
      borderRadius: isDesktop ? 12 : 14,
      borderSide: BorderSide(
        color: primaryColor.withValues(alpha: 0.15),
        width: 1,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        child: Row(
          children: [
            // Cirkulær avatar med billede eller tema-farve
            _buildAvatar(context, primaryColor, avatarSize),
            SizedBox(width: isDesktop ? 10 : 12),
            // Titel og liste
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Titel - uppercase for konsistens
                  Text(
                    occurrence.taskName.toUpperCase(),
                    style: (isDesktop
                            ? theme.textTheme.labelLarge
                            : theme.textTheme.titleSmall)
                        ?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  // Task list label
                  _buildTaskListLabel(context, primaryColor),
                ],
              ),
            ),
            SizedBox(width: isDesktop ? 8 : 10),
            // Dato badge
            DueDateBadge(dueDate: occurrence.dueDate, compact: true),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, Color primaryColor, double size) {
    final imagePath = occurrence.taskImagePath;

    // Lysere baggrund baseret på tema farve
    final backgroundColor = Color.lerp(primaryColor, Colors.white, 0.75) ??
        primaryColor.withValues(alpha: 0.2);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: imagePath != null && imagePath.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: ApiConfig.getImageUrl(imagePath),
              fit: BoxFit.cover,
              placeholder: (context, url) => _buildAvatarPlaceholder(primaryColor),
              errorWidget: (context, url, error) => _buildAvatarPlaceholder(primaryColor),
            )
          : _buildAvatarPlaceholder(primaryColor),
    );
  }

  Widget _buildAvatarPlaceholder(Color color) {
    return Center(
      child: Icon(
        Icons.task_alt_rounded,
        color: color.withValues(alpha: 0.6),
        size: isDesktop ? 18 : 22,
      ),
    );
  }

  Widget _buildTaskListLabel(BuildContext context, Color primaryColor) {
    final theme = Theme.of(context);

    // Brug tema farven til label
    final labelTextColor = Color.lerp(primaryColor, Colors.black, 0.2) ??
        theme.colorScheme.onSurfaceVariant;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.folder_outlined,
          size: isDesktop ? 11 : 12,
          color: labelTextColor.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            occurrence.taskListName,
            style: TextStyle(
              color: labelTextColor,
              fontSize: isDesktop ? 11 : 12,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
