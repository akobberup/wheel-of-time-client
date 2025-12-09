# "Senere" Section Redesign - UX Improvements

**Version:** 1.0
**Dato:** November 2025
**Status:** Phase 1 Implementeret

---

## Problem Statement

Den oprindelige "Senere" sektion viste alle 38+ fremtidige opgaver med gentagne "Fuldfør tidligere opgaver først" overlays, hvilket:

- Skaber kognitiv overbelastning
- Bryder med "Rolig - Ikke overvældende" design-princippet
- Producerer visuel støj gennem gentagne låste overlays
- Giver al fremtidig content samme visuelle vægt
- Skaber angst i stedet for struktur

## Løsningsarkitektur

### Phase 1: Progressive Disclosure (✅ Implementeret)

**Koncept:** Vis kun et preview af "Senere" sektionen som standard, med elegant ekspansionsmulighed.

**Implementering:**
- Viser kun de første **5 opgaver** i "Senere" sektionen når collapsed
- Tilføjer en varm, indbydende "Vis mere (X opgaver)" knap
- Knappen matcher den organiske æstetik med tema-farve
- Expansion state gemmes i provider (persisterer under session)
- "Vis mindre" knap vises når sektionen er udvidet

**Benefits:**
- ✅ Reducerer drastisk visuel clutter
- ✅ Bevarer rolig, struktureret følelse
- ✅ Brugere kan stadig tilgå alle opgaver ved behov
- ✅ Følger eksisterende pattern (matcher "Seneste aktivitet")
- ✅ Kræver kun minimal kodeændring

**Kode ændringer:**
- `/lib/providers/upcoming_tasks_provider.dart`: Tilføjet `isLaterExpanded` state
- `/lib/screens/upcoming_tasks_screen.dart`: Progressive disclosure logik + expand/collapse knapper

---

### Phase 2: Forbedret Locked State (Næste skridt)

**Problem:** Gentagne "Fuldfør tidligere opgaver først" overlays skaber visuel støj.

**Løsning A - Minimal Visual Indicator (Anbefalet):**
```dart
// Fjern tekst overlay helt
// Tilføj lille lock ikon i hjørne
// Reducer opacity til 0.5-0.6 for låste opgaver
// Gør dem visuelt "stille" - de falder i baggrunden
```

**Løsning B - Single Summary Message:**
```dart
// Fjern overlay på individuelle kort
// Tilføj én elegant besked over sektionen:
// "Disse opgaver låses op efterhånden som du fuldfører tidligere"
// Stil den varmt med tema-farve, ikke som advarsel
```

**Løsning C - Gruppér Låste Opgaver:**
```dart
// Opret "Låste opgaver (X)" undersektion
// Collapse som standard
// Viser antal men ikke alle kort medmindre expanded
```

**Anbefaling:** Start med Løsning A - mest minimal og rolig.

---

### Phase 3: Smartere Tidshorisonter (Fremtidig forbedring)

**Problem:** "Senere" er for bred en kategori - alt fra næste uge til om 6 måneder.

**Løsning:** Mere granulære tids-baserede grupper:

```
📅 Denne uge (2)
📅 Næste uge (5)
📅 Denne måned (12)
📅 Senere (21) ← Collapsed by default
```

**Benefits:**
- Bedre mental model - matcher hvordan brugere tænker om tid
- Naturlig progressive disclosure
- "Senere" bliver virkelig fjern fremtid
- Reducerer opfattet hast/angst

**Implementering:**
```dart
enum TimeHorizon {
  thisWeek,
  nextWeek,
  thisMonth,
  later,
}

TimeHorizon _getTimeHorizon(DateTime dueDate) {
  final now = DateTime.now();
  final daysUntil = dueDate.difference(now).inDays;

  // Logik for at bestemme horizon baseret på dage
  if (daysUntil <= 7) return TimeHorizon.thisWeek;
  if (daysUntil <= 14) return TimeHorizon.nextWeek;
  if (daysUntil <= 30) return TimeHorizon.thisMonth;
  return TimeHorizon.later;
}
```

---

### Phase 4: Summary Card Alternative (Alternativ tilgang)

**Koncept:** Vis ét elegant summary card i stedet for alle opgaver.

```
┌─────────────────────────────────────┐
│  📅 Senere (38 opgaver)             │
│                                     │
│  De næste 3 opgaver:                │
│  • Rengør badeværelse              │
│  • Vask vinduer                    │
│  • Støvsug kælder                  │
│                                     │
│  [Se alle opgaver →]                │
└─────────────────────────────────────┘
```

**Benefits:**
- Ekstremt rolig og minimal
- Viser lige nok kontekst
- Bevarer cirkulær, varm æstetik
- Klar call-to-action til at udvide

**Overvejelser:**
- Mere radikal ændring
- Kræver nyt UI komponant
- Godt til meget store lister (50+ opgaver)

---

## Design Principper

Alle løsninger følger Wheel of Time design guidelines:

### Farver
- **Tema-farve** til call-to-action knapper (brugerens valgte farve)
- **Subtile gradienter** til varme baggrunde
- **Reduceret opacity** til mindre vigtig content

### Typografi
- **Body M (14px)** til sekundær tekst
- **Vægt 600** til knap-labels
- **Letter-spacing -0.2** til moderne udtryk

### Spacing
- **md (16px)** mellem kort og knapper
- **lg (24px)** omkring sektioner
- Responsivt baseret på `isDesktop`

### Animationer
- **300ms easeOutCubic** til expansion/collapse
- Følger "Organiske overgange" princippet
- Subtile, ikke distraherende

### Komponenter
- **16px border radius** til kort og knapper
- **Cirkulære ikoner** refererer til "hjulet"
- **Subtile skygger** kun i lys tilstand (niveau 1: 0.04 opacity)

---

## Implementerings Status

### ✅ Færdigt (Phase 1)
- [x] State management for `isLaterExpanded`
- [x] Progressive disclosure logik (vis 5 opgaver)
- [x] `_ExpandLaterButton` widget med varm æstetik
- [x] `_CollapseLaterButton` widget (diskret)
- [x] Integration med eksisterende localization
- [x] Responsiv design (desktop + mobil)
- [x] Ingen compilation errors

### 🔄 Næste Skridt (Phase 2 - Anbefalet)
- [ ] Implementer Løsning A: Minimal locked state
  - [ ] Fjern frosted overlay tekst
  - [ ] Tilføj lille lock ikon
  - [ ] Reducer opacity på låste kort
- [ ] Test med rigtige brugere
- [ ] Iterér baseret på feedback

### 💡 Fremtidige Forbedringer (Phase 3+)
- [ ] Overvej smartere tidshorisonter
- [ ] Evaluer summary card tilgang for 50+ opgaver
- [ ] A/B test forskellige collapsed counts (3 vs 5 vs 7)

---

## Testing Checklist

Når du tester implementeringen:

- [ ] Navigér til "Kommende" skærmen med 38+ opgaver
- [ ] Verificér at kun 5 opgaver vises i "Senere" som standard
- [ ] Tjek at "Vis mere" knappen vises med korrekt antal
- [ ] Tryk på "Vis mere" og verificér alle opgaver vises
- [ ] Tjek at "Vis mindre" knappen vises efter expansion
- [ ] Tryk på "Vis mindre" og verificér collapse funktionalitet
- [ ] Test responsivt design (mobil + desktop)
- [ ] Verificér tema-farve matcher brugerens valg
- [ ] Tjek at expansion state persisterer ved scroll
- [ ] Test på både lys og mørk tema

---

## Rationale

### Hvorfor progressive disclosure?

1. **Kognitiv Load:** Mennesker kan kun håndtere ~7±2 items i working memory
2. **Relevans:** Nærmeste 5 opgaver er mest relevante; resten er "støj"
3. **Kontrol:** Brugere føler kontrol når de VÆLGER at se mere
4. **Pattern Recognition:** Matcher "Seneste aktivitet" sektion → konsistent UX

### Hvorfor 5 opgaver som preview?

- **3 opgaver:** For få - føles ufuldstændigt
- **5 opgaver:** Sweet spot - nok kontekst, ikke overvældende
- **7 opgaver:** Begynder at føles overfyldt
- **10+ opgaver:** Går imod hele formålet

### Hvorfor ikke bare skjule "Senere" helt?

Brugere skal kunne:
- Få en fornemmelse af hvor meget der kommer
- Planlægge fremad
- Se at systemet fungerer (opgaver er der)
- Bevare følelse af kontrol og oversigt

---

*Sidst opdateret: November 2025*
