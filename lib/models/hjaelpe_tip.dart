import 'package:flutter/material.dart';

/// Et tip der kan vises i UI — uafhængigt af om det er statisk eller AI-genereret.
class HjaelpeTip {
  final String id;
  final IconData ikon;
  final String titel;
  final String beskrivelse;
  final String? ekstraTekst;

  const HjaelpeTip({
    required this.id,
    required this.ikon,
    required this.titel,
    required this.beskrivelse,
    this.ekstraTekst,
  });
}

/// Kendte trigger-punkter i appen hvor tips kan vises.
/// Bruges både til statiske tips og som kontekst til AI-endpointet senere.
enum TipTriggerPunkt {
  foerOpretListeOnboarding,
  foerOpretTaskOnboarding,
  efterFoersteTaskOprettet,
}
