# Wheel of Time - App Design Document

## Appens idé

**Wheel of Time** er en app til håndtering af tilbagevendende opgaver med fokus på samarbejde og motivation. Appen hjælper brugere med at holde styr på regelmæssige opgaver - fra daglige rutiner til ugentlige eller månedlige gøremål - og gør det muligt at dele opgavelister med familie, venner eller kolleger.

### Kernekoncept

Appen bygger på idéen om at mange opgaver i hverdagen er tilbagevendende: tage medicin, vande planter, rengøre, betale regninger, træne osv. I stedet for at oprette den samme opgave igen og igen, definerer brugeren opgaven én gang med et gentagelsesmønster, og appen genererer automatisk nye instanser når det er tid.

### Hovedfunktioner

1. **Fleksibel planlægning**
   - Interval-baseret: "Hver 2. dag", "Hver uge", "Hver 3. måned"
   - Ugedag-mønster: "Hver mandag og onsdag", "Alle hverdage", "Hver 2. uge på fredag"

2. **Delte opgavelister**
   - Opret lister og inviter andre via email
   - Forskellige adgangsniveauer (admin/member)
   - Se hvem der har udført hvilke opgaver

3. **Motiverende elementer**
   - Streak-tracking: Hold øje med hvor mange gange i træk du har udført en opgave
   - Valgfri billeder og kommentarer ved completion
   - Visuel feedback på fremskridt

4. **Smart håndtering af deadlines**
   - Completion window: Definer hvor længe efter forfaldstid en opgave stadig kan udføres
   - Automatisk expiry: Opgaver der ikke udføres inden for vinduet markeres som udløbet
   - Påmindelser via alarmer på bestemte tidspunkter

5. **Personalisering**
   - Billeder på opgaver og lister
   - Profilbilleder
   - Sprogvalg (dansk/engelsk)

---

## Målgruppe

### Primær målgruppe

**Familier og par** der ønsker at koordinere huslige opgaver:
- Forældre der vil dele ansvar for børnerelaterede opgaver
- Par der vil fordele husholdningsopgaver
- Familier med delte ansvarsområder (havedage, rengøring, indkøb)

**Karakteristika:**
- Alder: 25-55 år
- Teknisk komfortable, men ikke nødvendigvis tech-entusiaster
- Værdsætter overblik og struktur i hverdagen
- Har brug for at koordinere med andre

### Sekundær målgruppe

**Individer med behov for rutiner:**
- Personer der tager daglig medicin og har brug for påmindelser
- Folk med regelmæssige sundhedsrutiner (træning, meditation)
- Personer med ADHD eller andre forhold der gør rutiner svære at huske
- Studerende med tilbagevendende deadlines

**Karakteristika:**
- Alder: 18-45 år
- Motiveres af streak-tracking og visuel progress
- Har prøvet andre todo-apps men finder dem for generiske
- Har brug for påmindelser og struktur

### Tertiær målgruppe

**Små teams og arbejdsgrupper:**
- Kollegaer med delte ansvarsområder (kontorplanter, kaffemaskine, mødelokaler)
- Foreninger med tilbagevendende opgaver
- Roommates i deleboliger

---

## Brugsscenarier

### Scenarie 1: Familien med børn
> Maria og Thomas har to børn og en hund. De opretter en delt liste "Hjem" med opgaver som "Lufte hunden" (2x dagligt), "Tømme opvaskemaskinen" (dagligt), og "Støvsuge" (ugentligt). Begge kan se hvem der sidst udførte hver opgave, og børnene kan også tilføjes når de er gamle nok.

### Scenarie 2: Sundhedsrutiner
> Erik tager medicin hver morgen og aften. Han opretter en opgave med alarm kl. 8:00 og 20:00. Appen tracker hans streak, og han kan se at han har taget sin medicin 47 dage i træk. Hvis han glemmer det, udløber instansen efter 4 timer.

### Scenarie 3: Delebofællesskab
> Fire studerende deler en lejlighed. De opretter en liste "Rengøring" med opgaver som "Rengøre badeværelse" og "Støvsuge fællesrum" på ugentlig rotation. Alle kan se hvem der har gjort hvad, og hvornår næste gang er.

---

## Designprincipper

1. **Enkelhed først**: Oprettelse af en opgave skal være hurtig og intuitiv
2. **Visuelt overblik**: Brugeren skal hurtigt kunne se hvad der skal gøres i dag
3. **Positiv forstærkning**: Streaks og completion-feedback skal motivere
4. **Fleksibilitet**: Understøtte mange forskellige gentagelsesmønstre uden kompleksitet
5. **Samarbejde uden friktion**: Deling og invitationer skal være nemme

---

## Teknisk overblik

### Datamodel (hovedentiteter)

| Entitet | Beskrivelse |
|---------|-------------|
| User | Bruger med login, profilbillede, sprogpræference |
| TaskList | Opgaveliste med ejer og medlemmer |
| Task | Tilbagevendende opgave med schedule, billede, alarm |
| TaskInstance | Enkelt forekomst af en opgave (PENDING/COMPLETED/EXPIRED) |
| TaskSchedule | Abstrakt scheduling (IntervalSchedule eller WeeklyPatternSchedule) |
| TaskInstanceStreak | Tracker konsekutive completions |
| TaskListUserInvitation | Invitation til at deltage i en liste |

### Arkitektur

- **Frontend**: Flutter (cross-platform: Android, iOS, Web)
- **Backend**: Spring Boot (Java)
- **Database**: PostgreSQL
- **Autentifikation**: JWT med email/password og OAuth

---

*Dokument oprettet: November 2025*
