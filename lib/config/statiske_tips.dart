import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../models/hjaelpe_tip.dart';

/// Returnerer et statisk tip for et givet trigger-punkt, eller null.
HjaelpeTip? hentStatiskTip(TipTriggerPunkt punkt, AppStrings strings) {
  switch (punkt) {
    case TipTriggerPunkt.foerOpretListeOnboarding:
      return HjaelpeTip(
        id: 'foerste_liste_intro',
        ikon: Icons.list_alt_rounded,
        titel: strings.tipVelkommenTitel,
        beskrivelse: strings.tipVelkommenBeskrivelse,
        ekstraTekst: strings.tipVelkommenEkstra,
      );
    case TipTriggerPunkt.foerOpretTaskOnboarding:
      return HjaelpeTip(
        id: 'task_indstillinger_intro',
        ikon: Icons.tune_rounded,
        titel: strings.tipTaskIndstillingerTitel,
        beskrivelse: strings.tipTaskIndstillingerBeskrivelse,
      );
    case TipTriggerPunkt.efterFoersteTaskOprettet:
      return HjaelpeTip(
        id: 'deling_intro',
        ikon: Icons.group_outlined,
        titel: strings.tipDelingTitel,
        beskrivelse: strings.tipDelingBeskrivelse,
      );
  }
}
