import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/statiske_tips.dart';
import '../l10n/app_strings.dart';
import '../models/hjaelpe_tip.dart';
import 'auth_provider.dart';

/// Holder styr på sete tips via SharedPreferences, scoped til bruger-ID.
/// Extension point: hentTip() kan senere delegere til AI-service.
class HjaelpeTipNotifier extends AsyncNotifier<Set<String>> {
  static const _prefsKeyPrefix = 'sete_hjaelpe_tips';

  /// Returnerer bruger-scoped SharedPreferences-nøgle
  /// så tips trackes separat for hver bruger.
  String get _prefsKey {
    final userId = ref.read(authProvider).user?.userId;
    return '${_prefsKeyPrefix}_$userId';
  }

  @override
  Future<Set<String>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final liste = prefs.getStringList(_prefsKey) ?? [];
    return liste.toSet();
  }

  Future<bool> erSet(String tipId) async {
    final sete = state.valueOrNull ?? {};
    return sete.contains(tipId);
  }

  Future<void> markerSomSet(String tipId) async {
    final sete = Set<String>.from(state.valueOrNull ?? {});
    sete.add(tipId);
    state = AsyncValue.data(sete);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, sete.toList());
  }

  /// Henter et tip for et givet trigger-punkt.
  /// Nu: returnerer statisk tip. Senere: kan kalde AI-endpoint.
  Future<HjaelpeTip?> hentTip(TipTriggerPunkt triggerPunkt, AppStrings strings) {
    return Future.value(hentStatiskTip(triggerPunkt, strings));
  }
}

final hjaelpeTipProvider =
    AsyncNotifierProvider<HjaelpeTipNotifier, Set<String>>(
  HjaelpeTipNotifier.new,
);
