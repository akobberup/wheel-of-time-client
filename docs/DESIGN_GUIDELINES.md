# Wheel of Time - Design Guidelines

**Version:** 1.0.0  
**Sidst opdateret:** November 2025

---

## Versionshistorik

| Version | Dato | Beskrivelse |
|---------|------|-------------|
| 1.0.0 | Nov 2025 | Initial design system med brand-farve, komponenter og animationer |
| 1.1.0 | Dec 2025 | Festive task completion celebration UI med confetti og animationer |

---

## Design Filosofi

Wheel of Time er en app om **cyklusser, gentagelser og tid**. Designet skal afspejle denne idé gennem:

- **Bløde, cirkulære former** - refererer til hjulet/cyklussen
- **Varme, indbydende farver** - familiært og motiverende
- **Organiske overgange** - flydende animationer der føles naturlige
- **Positiv feedback** - fejring af streaks og fremskridt

### Kerneværdier i designet

1. **Tilgængelig** - Nem at bruge for alle aldre (25-55 primært)
2. **Motiverende** - Positive farver og feedback
3. **Rolig** - Ikke overvældende, hjælper med struktur
4. **Varm** - Familiær og indbydende, ikke kold/corporate

---

## Farvepalette

### Primær farve (brugervalgt)
Brugeren vælger selv sin tema-farve fra preset paletten. Denne farve bruges til:
- Primære knapper og call-to-actions
- Aktive tilstande og fokus
- Accent-elementer og highlights
- Streak-indikatorer

### Semantiske farver

| Funktion | Lys tema | Mørk tema |
|----------|----------|-----------|
| Baggrund (primær) | `#FAFAF8` (varm hvid) | `#121214` (dyb grå) |
| Baggrund (sekundær) | `#F5F4F2` | `#1A1A1C` |
| Overflade (cards) | `#FFFFFF` | `#222226` |
| Tekst (primær) | `#1A1A1A` | `#F5F5F5` |
| Tekst (sekundær) | `#6B6B6B` | `#A0A0A0` |
| Divider/border | `rgba(0,0,0,0.08)` | `rgba(255,255,255,0.08)` |

### Status farver

| Status | Farve | Brug |
|--------|-------|------|
| Succes/Completed | `#22C55E` | Udførte opgaver, streaks |
| Advarsel/Pending | `#F59E0B` | Snart deadline |
| Fejl/Expired | `#EF4444` | Udløbne opgaver, fejl |
| Info | Brugerens tema-farve | Generel information |

---

## Typografi

### Font-anbefalinger

**Primær font (headings):**
- System default eller `SF Pro Display` / `Roboto`
- Vægt: 600-700 for titler
- Letter-spacing: -0.5 til -1.0 for store titler

**Sekundær font (body):**
- System default eller `SF Pro Text` / `Roboto`
- Vægt: 400-500 for brødtekst
- Letter-spacing: 0 til 0.2

### Skala

| Niveau | Størrelse | Vægt | Brug |
|--------|-----------|------|------|
| Display | 32-40px | 700 | App titel, store headers |
| H1 | 28px | 700 | Skærm titler |
| H2 | 22px | 600 | Sektion headers |
| H3 | 18px | 600 | Card titler |
| Body L | 16px | 400-500 | Primær tekst |
| Body M | 14px | 400-500 | Sekundær tekst |
| Caption | 12px | 500 | Labels, hints |
| Overline | 11px | 600 | Kategori labels (uppercase) |

---

## Komponenter

### Border radius

| Komponent | Radius |
|-----------|--------|
| Små elementer (badges, chips) | 8px |
| Input felter | 12-14px |
| Cards | 16-20px |
| Modals/sheets | 24-28px |
| Cirkulære elementer | 50% |

### Shadows (elevation)

```
Niveau 1 (subtle): 0 2px 8px rgba(0,0,0,0.04)
Niveau 2 (cards): 0 4px 16px rgba(0,0,0,0.06)
Niveau 3 (floating): 0 8px 32px rgba(0,0,0,0.10)
Niveau 4 (modal): 0 16px 48px rgba(0,0,0,0.15)
```

I mørk tilstand: Brug lysere baggrunde i stedet for shadows.

### Knapper

**Primær knap:**
- Baggrund: Brugerens tema-farve med gradient (lidt mørkere i bunden)
- Tekst: Hvid
- Højde: 52-56px
- Border radius: 14-16px
- Shadow: Brug tema-farve med opacity 0.3

**Sekundær knap:**
- Baggrund: Transparent med border
- Border: Tema-farve med opacity 0.3
- Tekst: Tema-farve

**Text knap:**
- Ingen baggrund
- Tekst: Tema-farve eller sekundær tekst-farve

---

## Animationer

### Principper

1. **Naturlige kurver** - Brug `Curves.easeOutCubic` for indtræden, `Curves.easeInCubic` for udtræden
2. **Hurtig respons** - Micro-interactions: 100-200ms
3. **Smooth transitions** - Skærm-overgange: 300-400ms
4. **Subtile loops** - Baggrunds-animationer: 15-30 sekunder

### Specifikke animationer

| Animation | Varighed | Kurve |
|-----------|----------|-------|
| Button press | 100-150ms | easeOut |
| Focus state | 200ms | easeInOut |
| Card appear | 300ms | easeOutCubic |
| Page transition | 350ms | easeInOutCubic |
| Streak celebration | 600ms | elasticOut |

### Wheel/Cycle motiv

Brug cirkulære og roterende elementer subtilt:
- Baggrunds-orber der bevæger sig langsomt
- Loading spinners som hjul
- Progress indicators som cirkler
- Streak badges med cirkulær progress

---

## Spacing

### Base unit: 4px

| Token | Værdi | Brug |
|-------|-------|------|
| xs | 4px | Minimal afstand |
| sm | 8px | Tæt spacing |
| md | 16px | Standard spacing |
| lg | 24px | Sektion spacing |
| xl | 32px | Store sektioner |
| 2xl | 48px | Skærm padding |

### Layout spacing

- Skærm padding: 20-28px horisontalt
- Card padding: 16-20px
- Input felter: 16-20px padding internt
- Mellem form felter: 16-20px
- Mellem sektioner: 32-48px

---

## Ikoner

### Stil
- Rounded/outlined stil (ikke filled som default)
- Stroke width: 1.5-2px
- Størrelse: 20-24px for UI, 40-48px for illustrationer

### Anbefalede ikoner for kernefunktioner

| Funktion | Ikon |
|----------|------|
| Opgaver | `check_circle_outline` |
| Lister | `list_alt` / `folder_outlined` |
| Streaks | `local_fire_department` / `bolt` |
| Tid/Schedule | `schedule` / `event_repeat` |
| Profil | `person_outline` |
| Indstillinger | `settings_outlined` |
| Deling | `group_outlined` / `share` |
| Tilføj | `add_circle_outline` |

---

## Login Skærm Specifikt

### Atmosfære
- Varm og indbydende - brugeren skal føle sig velkommen
- Subtil bevægelse i baggrunden - antyder "hjulet der drejer"
- Fokus på formularen - ikke for mange distraktioner

### Elementer
1. **Baggrund**: Gradient med brugerens tema-farve (eller default lilla) + subtile cirkulære former
2. **Logo/Ikon**: Cirkulært element der symboliserer gentagelse
3. **Formular container**: Glasmorfisme eller soft card med god kontrast
4. **Input felter**: Bløde kanter, tydelig fokus-state
5. **CTA knap**: Prominent med tema-farve og subtle glow

### Undgå
- Fantasy/medieval æstetik (det er IKKE Wheel of Time bogen!)
- Kolde, kliniske farver
- Skarpe hjørner overalt
- For mange animationer der distraherer

---

## Implementerede Komponenter

Sporing af hvilke komponenter der er blevet implementeret i henhold til design guidelines.

| Komponent | Fil | Status | Dato |
|-----------|-----|--------|------|
| Task Completion Animation | `lib/widgets/common/task_completion_animation.dart` | ✅ Implementeret | Dec 2025 |
| Complete Task Dialog | `lib/widgets/complete_task_dialog.dart` | ✅ Implementeret | Dec 2025 |

### Task Completion Celebration Features
- Custom confetti animation med 50 partikler i brugerens tema-farve
- Animeret checkmark der tegnes segment for segment
- Pulserende glow-effekt på success-cirklen
- Elastiske bounce-animationer
- Haptic feedback ved nøglemomenter
- Streak-badge med glow-effekt
- Auto-dismiss efter 2.2 sekunder

---

*Sidst opdateret: December 2025*
