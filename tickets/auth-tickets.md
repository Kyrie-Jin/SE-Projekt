# Tickets: Login & Registrierung

Bezug: User Stories 2.1.1 und 2.1.2 | Modul: Authentifizierung & Benutzerverwaltung

---

## EPIC: Registrierung

**User Story:**
> Als Kunde möchte ich mich über ein Formular, in das ich alle relevanten Daten eingebe, registrieren können. Der Kunde soll nach dem Speichern permanent im System erfasst sein.

**Akzeptanzkriterien:**
- [ ] Ein neuer Kunde kann sich mit Vorname, Nachname, E-Mail und Passwort registrieren
- [ ] Nach erfolgreicher Registrierung ist der Nutzer dauerhaft im System gespeichert
- [ ] Bei bereits vergebener E-Mail-Adresse wird eine verständliche Fehlermeldung angezeigt
- [ ] Pflichtfelder werden validiert (fehlende oder ungültige Eingaben werden gemeldet)
- [ ] Das Passwort wird niemals im Klartext gespeichert

---

### Sub-Ticket 1.1 – Registrierung: Datenbank

**Titel:** `[Datenbank] Registrierung – ApplicationUser Entity und Repository`

**Beschreibung:**
Definition der `ApplicationUser`-Entity mit allen Pflichtfeldern für die Registrierung sowie dem zugehörigen Repository. Diese Entity ist die Grundlage für Backend und Login.

**Aufgaben:**
- `ApplicationUser`-Entity um folgende Felder erweitern:
  - `firstName` (String, `@NotBlank`)
  - `lastName` (String, `@NotBlank`)
  - `email` (String, `@Column(unique = true)`)
  - `password` (String – BCrypt-Hash)
  - `role` (Enum: `ROLE_USER`, `ROLE_ADMIN`)
  - `isLocked` (boolean, default `false`)
  - `failedLoginAttempts` (int, default `0`)
- `@Table`-Constraints prüfen (unique auf `email`)
- `UserRepository`: Methode `findByEmail(String email)` ergänzen
- `UserRepository`: Methode `findAllByIsLockedTrue()` ergänzen
- Testdaten-Generator (`DataGenerator`): mind. 1 Admin-Nutzer und 2 Kunden-Nutzer anlegen

**Akzeptanzkriterien:**
- [ ] Die Tabelle `APPLICATION_USER` enthält alle definierten Spalten
- [ ] Die E-Mail-Spalte hat einen `UNIQUE`-Constraint in der Datenbank
- [ ] `findByEmail()` gibt den korrekten Nutzer zurück
- [ ] `findAllByIsLockedTrue()` gibt nur gesperrte Nutzer zurück
- [ ] Der Testdaten-Generator legt beim Start (Profil `generateData`) Testnutzer an
- [ ] Passwort-Feld enthält niemals Klartextpasswörter (BCrypt-Hash)

**Technische Hinweise:**
- `ApplicationUser` und `UserRepository` existieren bereits im Template – nur erweitern, nicht neu anlegen
- Hibernate generiert das Schema automatisch (`ddl-auto`)

---

### Sub-Ticket 1.2 – Registrierung: Backend

**Titel:** `[Backend] Registrierung – Endpoint, Service und DTOs implementieren`

**Beschreibung:**
Implementierung der serverseitigen Registrierungslogik. Der Kunde gibt alle notwendigen Daten ein. Die Daten werden validiert, das Passwort gehasht und der Nutzer über das Repository gespeichert.

**Aufgaben:**
- `UserRegistrationDto` erstellen (Eingabe-DTO mit Bean-Validation: `@NotBlank`, `@Email`, `@Size`)
- `UserDetailDto` erstellen (Ausgabe-DTO)
- MapStruct-Mapper für `ApplicationUser ↔ DTO` ergänzen
- `UserService` Interface: Methode `registerCustomer(UserRegistrationDto dto)` definieren
- `UserServiceImpl`: Methode implementieren (BCrypt-Hashing via `PasswordEncoder`)
- `UserEndpoint`: `POST /api/v1/users/register` anlegen (kein JWT erforderlich)
- Exception-Handling: `ConflictException` wenn E-Mail bereits vergeben → HTTP 409

**Akzeptanzkriterien:**
- [ ] `POST /api/v1/users/register` mit gültigen Daten gibt HTTP 201 zurück
- [ ] Der neue Nutzer ist danach in der Datenbank mit gehashtem Passwort gespeichert
- [ ] Die Rolle des Nutzers ist standardmäßig `ROLE_USER`
- [ ] Bei fehlenden Pflichtfeldern wird HTTP 422 zurückgegeben
- [ ] Bei ungültigem E-Mail-Format wird HTTP 422 zurückgegeben
- [ ] Bei zu kurzem Passwort (< 8 Zeichen) wird HTTP 422 zurückgegeben
- [ ] Bei bereits vergebener E-Mail wird HTTP 409 zurückgegeben
- [ ] Unit-Tests für `UserServiceImpl.registerCustomer()` vorhanden
- [ ] Integrationstests für `POST /api/v1/users/register` vorhanden

**Abhängigkeit:** Sub-Ticket 1.1 muss abgeschlossen sein

**Technische Hinweise:**
- `PasswordEncoder` ist bereits via `EncoderConfig` als Bean konfiguriert
- Fehlermeldungen dürfen keine internen Stack Traces enthalten

---

### Sub-Ticket 1.3 – Registrierung: Frontend

**Titel:** `[Frontend] Registrierung – Registrierungsformular implementieren`

**Beschreibung:**
Implementierung der Registrierungsseite in Angular. Das Formular enthält alle Pflichtfelder, validiert Eingaben clientseitig und kommuniziert mit dem Backend-Endpoint aus Sub-Ticket 1.2.

**Aufgaben:**
- Angular-Komponente `RegisterComponent` unter `components/register/` anlegen
- Reactive Form mit Feldern: Vorname, Nachname, E-Mail, Passwort, Passwort-Wiederholen
- Client-seitige Validierung (required, email, minLength, passwordMatch)
- `AuthService` um Methode `register(dto: UserRegistrationDto): Observable<void>` erweitern
- Route `/register` in `app-routing.module.ts` eintragen (kein Auth-Guard)
- Fehleranzeige für Serverfehler (409: „E-Mail bereits vergeben", 422: feldspezifische Meldungen)
- Link zur Login-Seite einbauen

**Akzeptanzkriterien:**
- [ ] Die Seite `/register` ist ohne Login erreichbar
- [ ] Alle Pflichtfelder sind vorhanden: Vorname, Nachname, E-Mail, Passwort, Passwort-Wiederholen
- [ ] „Registrieren"-Button ist deaktiviert, solange das Formular ungültige Eingaben enthält
- [ ] Passwort und Passwort-Wiederholen werden auf Übereinstimmung geprüft
- [ ] Bei erfolgreicher Registrierung wird zur `/login`-Seite weitergeleitet
- [ ] Bei HTTP 409 wird „E-Mail bereits vergeben" angezeigt
- [ ] Bei HTTP 422 werden feldspezifische Fehlermeldungen angezeigt
- [ ] Das Passwortfeld zeigt Zeichen verborgen an
- [ ] Es gibt einen Link zur Login-Seite

**Abhängigkeit:** Sub-Ticket 1.2 muss abgeschlossen sein

---

## EPIC: Login & Authentifizierung

**User Story:**
> Als Kunde möchte ich mich durch Eingabe der E-Mail und des Passwortes einloggen können. Bin ich eingeloggt, möchte ich mich auch wieder ausloggen können. Sollte ich fünfmal hintereinander ein falsches Passwort eingeben, soll mein Account aus Sicherheitsgründen gesperrt werden.
>
> Als Administrator möchte ich gesperrte User anzeigen und entsperren können.

**Akzeptanzkriterien:**
- [ ] Ein Kunde kann sich mit E-Mail und Passwort einloggen
- [ ] Nach dem Login kann der Kunde alle geschützten Bereiche der Anwendung nutzen
- [ ] Ein eingeloggter Kunde kann sich ausloggen
- [ ] Nach 5 aufeinanderfolgenden Fehlversuchen wird der Account gesperrt
- [ ] Ein gesperrter Account kann sich nicht mehr einloggen
- [ ] Ein Administrator kann gesperrte Accounts einsehen und entsperren

---

### Sub-Ticket 2.1 – Login: Datenbank

**Titel:** `[Datenbank] Login – Repository-Abfragen für Authentifizierung und Sperre`

**Beschreibung:**
Erweiterung des `UserRepository` um alle Abfragen, die für den Login-Flow und die Account-Sperre benötigt werden. Baut auf Sub-Ticket 1.1 auf (Entity-Felder `isLocked`, `failedLoginAttempts` sind dort definiert).

**Aufgaben:**
- `UserRepository`: Methode `findByEmail(String email)` prüfen / ergänzen (wird für Login benötigt)
- `UserRepository`: Methode `findAllByIsLockedTrue()` prüfen / ergänzen (wird für Admin-Entsperrung benötigt)
- Testdaten-Generator: einen gesperrten Testnutzer anlegen (`isLocked = true`, `failedLoginAttempts = 5`)
- Testdaten-Generator: einen Admin-Nutzer anlegen (`role = ROLE_ADMIN`)

**Akzeptanzkriterien:**
- [ ] `findByEmail()` gibt `Optional<ApplicationUser>` zurück
- [ ] `findAllByIsLockedTrue()` gibt nur Nutzer mit `isLocked = true` zurück
- [ ] Der Testdaten-Generator legt beim Start einen gesperrten Nutzer an
- [ ] Der Testdaten-Generator legt beim Start einen Admin-Nutzer an

**Abhängigkeit:** Sub-Ticket 1.1 muss abgeschlossen sein (Entity-Definition)

---

### Sub-Ticket 2.2 – Login: Backend

**Titel:** `[Backend] Login – Authentifizierung, JWT und Account-Sperre`

**Beschreibung:**
Vollständige Implementierung der Login-Logik. Bei erfolgreichem Login wird ein JWT zurückgegeben. Fehlgeschlagene Versuche werden gezählt; nach 5 Fehlversuchen wird der Account gesperrt. Admins können gesperrte Accounts entsperren.

**Aufgaben:**
- `LoginEndpoint` (`POST /api/v1/authentication`) prüfen und vervollständigen
- `AuthService.loginUser(UserLoginDto dto)` implementieren:
  - Nutzer per E-Mail aus `UserRepository` laden
  - Account-Sperre prüfen (`isLocked == true` → Exception)
  - Passwort mit BCrypt vergleichen
  - Bei falschem Passwort: `failedLoginAttempts` um 1 erhöhen
  - Nach 5 Fehlversuchen: `isLocked = true` setzen
  - Bei Erfolg: `failedLoginAttempts` auf 0 zurücksetzen, JWT via `JwtTokenizer` generieren
- `UserEndpoint`: `GET /api/v1/admin/users/locked` – Liste gesperrter Nutzer (nur ADMIN)
- `UserEndpoint`: `PUT /api/v1/admin/users/{id}/unlock` – Account entsperren (nur ADMIN)
- `UserService` + `UserServiceImpl`: `getLockedUsers()` und `unlockUser(Long id)` implementieren
- `SecurityConfig`: `/api/v1/admin/**` nur für `ROLE_ADMIN` freigeben
- Exception-Handling: gesperrter Account → HTTP 403, falsche Credentials → HTTP 401

**Akzeptanzkriterien:**
- [ ] `POST /api/v1/authentication` mit korrekten Credentials gibt HTTP 200 + gültigen JWT zurück
- [ ] Mit falschem Passwort wird HTTP 401 zurückgegeben
- [ ] Nach dem 5. aufeinanderfolgenden Fehlversuch wird `isLocked = true` in der DB gesetzt
- [ ] Ein gesperrter Account gibt bei Login-Versuch HTTP 403 mit verständlicher Meldung zurück
- [ ] Bei erfolgreichem Login wird `failedLoginAttempts` auf 0 zurückgesetzt
- [ ] Der JWT enthält die Rolle des Nutzers
- [ ] `GET /api/v1/admin/users/locked` gibt Liste gesperrter Nutzer zurück (nur für ADMIN, sonst 403)
- [ ] `PUT /api/v1/admin/users/{id}/unlock` setzt `isLocked = false` und `failedLoginAttempts = 0`
- [ ] Nach dem Entsperren kann sich der Nutzer wieder einloggen
- [ ] Unit-Tests für die Sperr-Logik (nach 4 Fehlern nicht gesperrt, nach 5 gesperrt)
- [ ] Integrationstests für `POST /api/v1/authentication` vorhanden

**Abhängigkeit:** Sub-Ticket 2.1 muss abgeschlossen sein

**Technische Hinweise:**
- `JwtTokenizer` und `JwtAuthorizationFilter` sind bereits im Template vorhanden
- `SecurityConfig` muss `/api/v1/authentication` als public belassen

---

### Sub-Ticket 2.3 – Login: Frontend

**Titel:** `[Frontend] Login – Login-Formular, JWT-Verwaltung und Admin-Entsperrung`

**Beschreibung:**
Vollständige Implementierung des Login-Flows in Angular. Nach dem Login wird der JWT gespeichert und bei jedem Request mitgesendet. Logout löscht den Token. Admins können über eine eigene Seite gesperrte Accounts entsperren.

**Aufgaben:**
- `LoginComponent` prüfen und vervollständigen
- `AuthService.loginUser(dto)`: HTTP-Call + Token in `localStorage` speichern
- `AuthService.logoutUser()`: Token aus `localStorage` entfernen, zu `/login` navigieren
- `AuthService.isLoggedIn()`: prüfen ob gültiger (nicht abgelaufener) Token vorhanden
- HTTP-Interceptor: `Authorization: Bearer <token>` Header an alle geschützten Requests anhängen
- `AuthGuard`: Nicht eingeloggte Nutzer zu `/login` weiterleiten
- `AdminGuard`: Nicht-Admins von Admin-Seiten fernhalten
- Logout-Button im Header (nur wenn eingeloggt sichtbar)
- Fehlermeldungen: HTTP 401 → „E-Mail oder Passwort falsch", HTTP 403 → „Account gesperrt"
- Admin-Seite `/admin/users/locked`: Tabelle gesperrter Nutzer mit „Entsperren"-Button

**Akzeptanzkriterien:**
- [ ] Die Seite `/login` ist ohne Login erreichbar
- [ ] Bei korrekten Credentials wird der Nutzer zur Startseite weitergeleitet
- [ ] Der JWT wird nach dem Login im `localStorage` gespeichert
- [ ] Bei jedem API-Request wird der JWT als `Authorization: Bearer`-Header mitgesendet
- [ ] Nicht eingeloggte Nutzer werden bei geschützten Routen zu `/login` weitergeleitet
- [ ] Logout löscht den Token und leitet zu `/login` weiter
- [ ] Bei HTTP 401 wird „E-Mail oder Passwort falsch" angezeigt
- [ ] Bei HTTP 403 wird „Account gesperrt" angezeigt
- [ ] Der Logout-Button ist nur sichtbar wenn eingeloggt
- [ ] Die Admin-Seite `/admin/users/locked` ist nur für Admins erreichbar
- [ ] Ein Admin kann einen gesperrten Account per Klick entsperren
- [ ] Die Liste aktualisiert sich nach dem Entsperren

**Abhängigkeit:** Sub-Ticket 2.2 muss abgeschlossen sein

---

## Übersicht

```
EPIC: Registrierung (US 2.1.1)
├── Sub-Ticket 1.1  [Datenbank] ApplicationUser Entity & Repository
├── Sub-Ticket 1.2  [Backend]   Endpoint, Service, DTOs       →  benötigt 1.1
└── Sub-Ticket 1.3  [Frontend]  Registrierungsformular        →  benötigt 1.2

EPIC: Login & Authentifizierung (US 2.1.2)
├── Sub-Ticket 2.1  [Datenbank] Repository-Abfragen, Testdaten  →  benötigt 1.1
├── Sub-Ticket 2.2  [Backend]   Login, JWT, Sperre, Entsperren  →  benötigt 2.1
└── Sub-Ticket 2.3  [Frontend]  Login-Flow, Guards, Admin-Seite →  benötigt 2.2
```
