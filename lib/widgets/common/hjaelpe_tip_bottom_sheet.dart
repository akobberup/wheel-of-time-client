import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_strings.dart';
import '../../models/hjaelpe_tip.dart';
import '../../providers/hjaelpe_tip_provider.dart';

/// Bottom sheet der viser et hjælpe-tip.
/// Matcher _FeatureInfoSheet-designet fra login_screen.dart.
class HjaelpeTipBottomSheet extends StatelessWidget {
  final HjaelpeTip tip;
  final Color? temaFarve;

  const HjaelpeTipBottomSheet({
    super.key,
    required this.tip,
    this.temaFarve,
  });

  /// Viser tip som bottom sheet HVIS det ikke allerede er set.
  static Future<void> visHvisRelevant({
    required BuildContext context,
    required WidgetRef ref,
    required TipTriggerPunkt triggerPunkt,
    Color? temaFarve,
    Duration forsinkelse = const Duration(milliseconds: 400),
  }) async {
    final strings = AppStrings.of(context);
    final notifier = ref.read(hjaelpeTipProvider.notifier);
    final tip = await notifier.hentTip(triggerPunkt, strings);
    if (tip == null) return;
    if (await notifier.erSet(tip.id)) return;

    await notifier.markerSomSet(tip.id);
    await Future.delayed(forsinkelse);
    if (!context.mounted) return;

    HapticFeedback.selectionClick();
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => HjaelpeTipBottomSheet(tip: tip, temaFarve: temaFarve),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1E22) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subtitleColor = isDark ? Colors.white70 : const Color(0xFF555555);
    final accentColor = temaFarve ?? const Color(0xFF00897B);
    final strings = AppStrings.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          // Ikon i cirkel
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor.withValues(alpha: 0.12),
            ),
            child: Icon(
              tip.ikon,
              size: 28,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 16),
          // Titel
          Text(
            tip.titel,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          // Beskrivelse
          Text(
            tip.beskrivelse,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: subtitleColor,
              height: 1.5,
            ),
          ),
          // Ekstra tekst (hvis angivet)
          if (tip.ekstraTekst != null) ...[
            const SizedBox(height: 12),
            Text(
              tip.ekstraTekst!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: accentColor,
                height: 1.5,
              ),
            ),
          ],
          const SizedBox(height: 20),
          // "Forstået" knap
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: accentColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              strings.tipForstaaet,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
