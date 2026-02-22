import 'package:flutter/material.dart';
import '../models/cheer.dart';

/// Viser cheers som emoji-chips under et completed task card.
/// Grupperer identiske emojis og viser antal.
class CheerDisplay extends StatelessWidget {
  final List<CheerResponse> cheers;

  const CheerDisplay({super.key, required this.cheers});

  @override
  Widget build(BuildContext context) {
    if (cheers.isEmpty) return const SizedBox.shrink();

    // Gruppér cheers per emoji
    final emojiCounts = <String, List<CheerResponse>>{};
    for (final cheer in cheers) {
      emojiCounts.putIfAbsent(cheer.emoji, () => []).add(cheer);
    }

    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
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
    );
  }
}
