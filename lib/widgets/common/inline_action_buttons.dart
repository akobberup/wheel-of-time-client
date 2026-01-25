import 'package:flutter/material.dart';

/// Genbrugelig widget til inline Edit, Share og Delete knapper på cards
/// Viser outlined knapper med subtle fill der matcher tema-farver
class InlineActionButtons extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onShare;
  final Color themeColor;
  final bool isDark;
  final String itemName;
  final double buttonSize;
  final String editLabel;
  final String deleteLabel;
  final String? shareLabel;

  const InlineActionButtons({
    super.key,
    required this.onEdit,
    required this.onDelete,
    this.onShare,
    required this.themeColor,
    required this.isDark,
    required this.itemName,
    required this.editLabel,
    required this.deleteLabel,
    this.shareLabel,
    this.buttonSize = 34,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildEditButton(context),
        const SizedBox(width: 8),
        if (onShare != null) ...[
          _buildShareButton(context),
          const SizedBox(width: 8),
        ],
        _buildDeleteButton(context),
      ],
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return Semantics(
      label: '$editLabel $itemName',
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: themeColor.withValues(alpha: 0.4),
                width: 1.5,
              ),
              color: themeColor.withValues(alpha: 0.08),
            ),
            child: Icon(
              Icons.edit_outlined,
              size: 18,
              color: themeColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShareButton(BuildContext context) {
    // Brug en blå farve til del-knappen for at adskille den visuelt
    final shareColor = isDark
        ? const Color(0xFF64B5F6)
        : const Color(0xFF1976D2);

    return Semantics(
      label: '${shareLabel ?? 'Del'} $itemName',
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onShare,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: shareColor.withValues(alpha: 0.4),
                width: 1.5,
              ),
              color: shareColor.withValues(alpha: 0.08),
            ),
            child: Icon(
              Icons.people_outline,
              size: 18,
              color: shareColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    final deleteColor =
        isDark ? const Color(0xFFFF6B6B) : const Color(0xFFE53935);

    return Semantics(
      label: '$deleteLabel $itemName',
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onDelete,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: deleteColor.withValues(alpha: 0.35),
                width: 1.5,
              ),
              color: deleteColor.withValues(alpha: 0.08),
            ),
            child: Icon(
              Icons.delete_outline,
              size: 18,
              color: deleteColor,
            ),
          ),
        ),
      ),
    );
  }
}
