import 'package:flutter/material.dart';

/// Reusable status badge widget with icon and label
/// Used for displaying status indicators like invitations, streaks, etc.
class StatusBadge extends StatelessWidget {
  /// The label text to display
  final String label;

  /// The badge background/text color
  final Color color;

  /// Optional icon to display before the label
  final IconData? icon;

  /// Font size for the label text
  final double fontSize;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
