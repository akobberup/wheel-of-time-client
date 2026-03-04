import 'package:flutter/material.dart';
import '../models/cheer.dart';

/// Viser cheers som emoji-chips og beskeder under et completed task card.
/// Cheers med besked vises individuelt, rene emojis grupperes.
class CheerDisplay extends StatelessWidget {
  final List<CheerResponse> cheers;

  const CheerDisplay({super.key, required this.cheers});

  @override
  Widget build(BuildContext context) {
    if (cheers.isEmpty) return const SizedBox.shrink();

    // Opdel cheers i dem med besked og dem uden
    final cheersWithMessage = cheers.where((c) => c.message != null && c.message!.isNotEmpty).toList();
    final cheersWithoutMessage = cheers.where((c) => c.message == null || c.message!.isEmpty).toList();

    // Gruppér emoji-only cheers per emoji
    final emojiCounts = <String, List<CheerResponse>>{};
    for (final cheer in cheersWithoutMessage) {
      emojiCounts.putIfAbsent(cheer.emoji, () => []).add(cheer);
    }

    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Cheers med besked vises individuelt
          for (final cheer in cheersWithMessage)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.15),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (cheer.emoji.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Text(cheer.emoji, style: const TextStyle(fontSize: 14)),
                      ),
                    Flexible(
                      child: Text(
                        cheer.message!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '– ${cheer.userName}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Emoji-only cheers grupperet
          if (emojiCounts.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: emojiCounts.entries.map((entry) {
                final emoji = entry.key;
                final cheerList = entry.value;
                final names = cheerList.map((c) => c.userName).join(', ');

                return Tooltip(
                  message: names,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.15),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 14)),
                        if (cheerList.length > 1) ...[
                          const SizedBox(width: 3),
                          Text(
                            '${cheerList.length}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
