import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cheer_provider.dart';
import '../l10n/app_strings.dart';

/// Liste af foreslåede genvejs-emojis til hurtig cheer
const List<String> _quickEmojis = ['💪', '🏆', '😂', '😮', '❤️', '🔥'];

/// Bottom sheet til at sende en cheer (emoji-reaktion) på en fuldført opgave.
/// Viser 6 genvejs-emojis og en valgfri besked-mulighed.
class CheerBottomSheet extends ConsumerStatefulWidget {
  final int taskInstanceId;
  final String? existingEmoji;

  const CheerBottomSheet({
    super.key,
    required this.taskInstanceId,
    this.existingEmoji,
  });

  /// Vis bottom sheet og returner true hvis en cheer blev sendt.
  static Future<bool?> show(BuildContext context, {
    required int taskInstanceId,
    String? existingEmoji,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => CheerBottomSheet(
        taskInstanceId: taskInstanceId,
        existingEmoji: existingEmoji,
      ),
    );
  }

  @override
  ConsumerState<CheerBottomSheet> createState() => _CheerBottomSheetState();
}

class _CheerBottomSheetState extends ConsumerState<CheerBottomSheet> {
  bool _showMessageField = false;
  final _messageController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendCheer(String emoji) async {
    if (_isSending) return;
    setState(() => _isSending = true);
    HapticFeedback.mediumImpact();

    final message = _showMessageField && _messageController.text.trim().isNotEmpty
        ? _messageController.text.trim()
        : null;

    final result = await ref.read(cheerProvider.notifier).sendCheer(
      widget.taskInstanceId,
      emoji: emoji,
      message: message,
    );

    if (mounted) {
      if (result != null) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.of(context).cheerSent),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Håndtag
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Titel
          Text(
            strings.cheerTaskInstance,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),

          // Emoji genveje
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _quickEmojis.map((emoji) => _EmojiButton(
              emoji: emoji,
              isSelected: emoji == widget.existingEmoji,
              onTap: _isSending ? null : () => _sendCheer(emoji),
            )).toList(),
          ),
          const SizedBox(height: 16),

          // Besked-toggle
          if (!_showMessageField)
            TextButton.icon(
              onPressed: () => setState(() => _showMessageField = true),
              icon: const Icon(Icons.chat_bubble_outline, size: 18),
              label: Text(strings.writeMessage),
            ),

          // Besked-felt
          if (_showMessageField) ...[
            TextField(
              controller: _messageController,
              maxLength: 160,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: strings.writeMessage,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 4),
          ],

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// Emoji-knap til hurtig cheer-afsendelse.
class _EmojiButton extends StatelessWidget {
  final String emoji;
  final bool isSelected;
  final VoidCallback? onTap;

  const _EmojiButton({
    required this.emoji,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 28),
        ),
      ),
    );
  }
}
