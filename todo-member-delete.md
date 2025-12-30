# Feature: Slet Bruger Konto

## Oversigt

Implementer funktionalitet så brugere kan slette deres konto og tilhørende data. Dette er et krav fra Google Play Store.

## Brugerflow

1. Bruger trykker "Slet konto" i app'ens indstillinger
2. Bekræftelsesdialog vises med advarsel om konsekvenser
3. Ved bekræftelse sendes en email til brugerens email-adresse
4. Email indeholder et unikt link med sletnings-token
5. Bruger klikker på linket og kommer til en webside
6. På websiden kan brugeren endeligt bekræfte sletningen
7. Konto og alle tilhørende data slettes permanent

## Tekniske Krav

### Server (Backend)

#### Ny Entity: `AccountDeletionRequest`

```
AccountDeletionRequest:
  - id: UUID (primary key)
  - userId: UUID (foreign key til User)
  - token: String (unikt, kryptografisk sikkert token)
  - createdAt: DateTime
  - expiresAt: DateTime (f.eks. 24 timer efter oprettelse)
  - status: Enum (PENDING, COMPLETED, EXPIRED, CANCELLED)
```

#### Nye API Endpoints

1. **POST `/api/account/request-deletion`**
   - Kræver authentication
   - Opretter `AccountDeletionRequest` med unikt token
   - Sender email med sletningslink
   - Response: `{ "message": "Email sendt" }`

2. **GET `/api/account/deletion/{token}`**
   - Public endpoint (ingen auth krævet)
   - Validerer token (eksisterer, ikke udløbet, status=PENDING)
   - Response: `{ "valid": true, "email": "bruger@example.com", "expiresAt": "..." }`

3. **POST `/api/account/deletion/{token}/confirm`**
   - Public endpoint
   - Validerer token
   - Sletter brugerens data:
     - Alle tasks
     - Alle task lists (og fjerner bruger fra delte lister)
     - Alle invitations
     - Alle notifications
     - Brugerens profil og credentials
   - Markerer `AccountDeletionRequest` som COMPLETED
   - Response: `{ "message": "Konto slettet" }`

#### Email Template

- Emne: "Bekræft sletning af din Årshjulet konto"
- Indhold:
  - Forklaring af hvad der sker
  - Link til sletningssiden med token
  - Advarsel om at linket udløber efter 24 timer
  - Bemærkning om at ignorere emailen hvis man ikke ønsker at slette

### Klient (Flutter App)

#### Ændringer i Settings Screen

1. Tilføj sektion "Konto" eller "Farezone" nederst i indstillinger
2. Tilføj knap "Slet min konto" med rød/advarselsstil
3. Ved tryk vises `AlertDialog`:
   - Titel: "Slet konto?"
   - Beskrivelse: "Dette vil permanent slette din konto og alle dine data. Du vil modtage en email med et bekræftelseslink."
   - Knapper: "Annuller" / "Send sletningsmail"

#### Ny Provider/Service Metode

```dart
Future<void> requestAccountDeletion() async {
  await _apiService.post('/api/account/request-deletion');
}
```

#### Success Dialog

Efter vellykket API-kald vises besked:
"Vi har sendt en email til [email]. Klik på linket i emailen for at bekræfte sletningen."

### Webside (Sletningsbekræftelse)

Simpel webside der håndterer det endelige sletningsflow:

#### URL Struktur
`https://api.aarshjulet.dk/account/delete/{token}`

#### Sider

1. **Token Validering Side**
   - Viser loading mens token valideres
   - Ved ugyldig/udløbet token: Fejlbesked
   - Ved valid token: Viser bekræftelsesside

2. **Bekræftelsesside**
   - Viser brugerens email (delvist maskeret)
   - Advarsel om hvad der slettes
   - Checkbox: "Jeg forstår at denne handling ikke kan fortrydes"
   - Knap: "Slet min konto permanent"

3. **Succes Side**
   - Bekræftelse på at kontoen er slettet
   - Link til app store hvis de vil geninstallere

## Data der Slettes

Ved kontosletning fjernes:
- Brugerens profil og login credentials
- Alle tasks oprettet af brugeren
- Alle task lists hvor brugeren er eneste medlem
- Brugerens medlemskab af delte task lists
- Alle invitations sendt til/fra brugeren
- Alle notifications

## Data der IKKE slettes

- Task lists delt med andre (andre medlemmer beholder adgang)
- Tasks i delte lister (ownership overføres evt. til anden bruger)

## Sikkerhedshensyn

1. Token skal være kryptografisk sikkert (min. 32 bytes, URL-safe encoding)
2. Token udløber efter 24 timer
3. Token kan kun bruges én gang
4. Rate limiting på request-deletion endpoint
5. Log alle sletningsanmodninger for audit

## Lokalisering

Tilføj følgende strings til `app_strings.dart`:

```dart
String get deleteAccount;           // "Slet konto"
String get deleteAccountTitle;      // "Slet din konto?"
String get deleteAccountWarning;    // "Dette vil permanent slette..."
String get deleteAccountConfirm;    // "Send sletningsmail"
String get deleteAccountEmailSent;  // "Vi har sendt en email..."
```

## Test Cases

1. Happy path: Bruger anmoder, modtager email, bekræfter, konto slettes
2. Udløbet token: Bruger klikker efter 24 timer, får fejl
3. Allerede brugt token: Bruger klikker igen, får fejl
4. Bruger annullerer i dialog: Ingen email sendes
5. Bruger ignorerer email: Ingen data slettes, token udløber

## Google Play URL

Efter implementering skal denne URL angives i Google Play Console:
`https://api.aarshjulet.dk/account/delete`

Denne side skal forklare processen:
1. Åbn Årshjulet appen
2. Gå til Indstillinger
3. Tryk "Slet konto"
4. Følg instruktionerne i emailen
