# Tickets: Passwort vergessen & Registrierungs-Verifikation

Bezug: User Story 2.2.2 (Passwort selbst zurücksetzen) & Zusatzanforderung (E-Mail-Verifikation)

---

## EPIC: Passwort vergessen

**User Story:**
> Als User möchte ich mein eigenes Passwort über eine Passwort-vergessen-Funktion zurücksetzen können. Dabei wird eine Mail verschickt, die das Zurücksetzen des Passwortes erlaubt.

**Akzeptanzkriterien:**
- [ ] Ein Nutzer kann auf der Login-Seite „Passwort vergessen" auswählen
- [ ] Nach Eingabe der E-Mail-Adresse erhält der Nutzer eine Mail mit einem Reset-Link
- [ ] Der Reset-Link ist nur einmalig verwendbar und zeitlich begrenzt (24 Stunden)
- [ ] Nach dem Klick auf den Link kann der Nutzer ein neues Passwort setzen
- [ ] Nach erfolgreichem Reset wird der Nutzer zur Login-Seite weitergeleitet
- [ ] Das alte Passwort ist nach dem Reset nicht mehr gültig
- [ ] Bei unbekannter E-Mail-Adresse wird keine Fehlermeldung angezeigt (Sicherheit – kein User-Enumeration)

---

### Sub-Ticket 1.1 – Passwort vergessen: Datenbank

**Titel:** `[Datenbank] Passwort vergessen – PasswordResetToken Entity und Repository`

**Beschreibung:**
Definition der `PasswordResetToken`-Entity zur Speicherung von Reset-Links sowie das zugehörige Repository. Jeder Token ist einem Nutzer zugeordnet, hat ein Ablaufdatum und wird nach Verwendung gelöscht.

**Aufgaben:**
- `PasswordResetToken`-Entity anlegen mit Feldern:
  - `id` (Long, Primary Key)
  - `token` (String, UUID, `@Column(unique = true)`)
  - `user` (ManyToOne → `ApplicationUser`)
  - `expiresAt` (LocalDateTime)
  - `used` (boolean, default `false`)
- `PasswordResetTokenRepository` anlegen mit Methoden:
  - `findByToken(String token)`
  - `deleteByUser(ApplicationUser user)` (alten Token löschen vor neuem Erstellen)

**Akzeptanzkriterien:**
- [ ] Die Tabelle `PASSWORD_RESET_TOKEN` existiert in der Datenbank
- [ ] Der `token`-Spalte hat einen `UNIQUE`-Constraint
- [ ] `findByToken()` gibt `Optional<PasswordResetToken>` zurück
- [ ] `deleteByUser()` löscht alle bestehenden Tokens des Nutzers

**Technische Hinweise:**
- `PasswordResetTokenRepository` ist in der Architektur bereits vorgesehen (siehe Komponentendiagramm)

---

### Sub-Ticket 1.2 – Passwort vergessen: Backend

**Titel:** `[Backend] Passwort vergessen – Token-Generierung, E-Mail-Versand und Passwort-Reset`

**Beschreibung:**
Implementierung der serverseitigen Logik: Token generieren, per Mail versenden, Token validieren und Passwort zurücksetzen. Der E-Mail-Versand erfolgt via Spring Mail (SMTP).

**Aufgaben:**
- Spring Mail Dependency (`spring-boot-starter-mail`) in `pom.xml` ergänzen
- `EmailService` (Interface + Impl): Methode `sendPasswordResetEmail(String to, String resetLink)` implementieren
- SMTP-Konfiguration in `application.properties` (Host, Port, Credentials als Umgebungsvariablen)
- `UserService` + `UserServiceImpl`: Methode `initiatePasswordReset(String email)`:
  - Nutzer per E-Mail suchen (kein Fehler bei unbekannter E-Mail → Silent Fail)
  - Bestehende Tokens des Nutzers löschen
  - Neuen UUID-Token generieren, mit 24h Ablauf speichern
  - Reset-Link per Mail versenden
- `UserService` + `UserServiceImpl`: Methode `resetPassword(String token, String newPassword)`:
  - Token aus DB laden und prüfen (existiert, nicht abgelaufen, nicht bereits verwendet)
  - Passwort hashen und in `ApplicationUser` speichern
  - Token als `used = true` markieren (oder löschen)
  - `failedLoginAttempts` zurücksetzen, `isLocked = false` setzen
- `UserEndpoint`:
  - `POST /api/v1/users/password-reset/request` – E-Mail mit Token anfordern (kein JWT)
  - `POST /api/v1/users/password-reset/confirm` – Neues Passwort setzen (kein JWT)

**Akzeptanzkriterien:**
- [ ] `POST /api/v1/users/password-reset/request` gibt immer HTTP 200 zurück (auch bei unbekannter E-Mail)
- [ ] Bei bekannter E-Mail wird ein Token in der DB gespeichert und eine Mail versendet
- [ ] Der Token läuft nach 24 Stunden ab
- [ ] `POST /api/v1/users/password-reset/confirm` mit gültigem Token setzt das neue Passwort
- [ ] Nach dem Reset kann sich der Nutzer mit dem neuen Passwort einloggen
- [ ] Bei abgelaufenem Token wird HTTP 400 zurückgegeben
- [ ] Bei bereits verwendetem Token wird HTTP 400 zurückgegeben
- [ ] Bei unbekanntem Token wird HTTP 400 zurückgegeben
- [ ] Das neue Passwort wird als BCrypt-Hash gespeichert
- [ ] Unit-Tests für `initiatePasswordReset()` und `resetPassword()` vorhanden
- [ ] Integrationstests für beide Endpoints vorhanden

**Abhängigkeit:** Sub-Ticket 1.1 muss abgeschlossen sein

---

### Sub-Ticket 1.3 – Passwort vergessen: Frontend

**Titel:** `[Frontend] Passwort vergessen – Formular, E-Mail-Eingabe und Reset-Seite`

**Beschreibung:**
Implementierung der „Passwort vergessen"-Seite und der Reset-Seite in Angular. Der Link zur Passwort-vergessen-Seite erscheint auf der Login-Seite.

**Aufgaben:**
- „Passwort vergessen?"-Link auf der Login-Seite (`/login`) ergänzen
- Komponente `ForgotPasswordComponent` unter `components/forgot-password/` anlegen:
  - Formular mit E-Mail-Feld
  - Nach Absenden: Bestätigungsmeldung anzeigen (unabhängig vom Ergebnis)
- Route `/forgot-password` in `app-routing.module.ts` eintragen (kein Auth-Guard)
- Komponente `ResetPasswordComponent` unter `components/reset-password/` anlegen:
  - Token aus URL-Parameter auslesen (`/reset-password?token=...`)
  - Formular mit Passwort und Passwort-Wiederholen
  - Bei Erfolg: Weiterleitung zu `/login` mit Erfolgsmeldung
- `AuthService` um `requestPasswordReset(email)` und `confirmPasswordReset(token, password)` erweitern
- Fehlerbehandlung: abgelaufener / ungültiger Token → Fehlermeldung anzeigen

**Akzeptanzkriterien:**
- [ ] Auf der Login-Seite ist ein „Passwort vergessen?"-Link sichtbar
- [ ] Die Seite `/forgot-password` ist ohne Login erreichbar
- [ ] Nach Eingabe einer E-Mail und Absenden wird eine Bestätigungsmeldung angezeigt (immer, unabhängig ob E-Mail bekannt)
- [ ] Die Seite `/reset-password?token=...` ist ohne Login erreichbar
- [ ] Das Formular enthält Passwort und Passwort-Wiederholen mit Übereinstimmungsprüfung
- [ ] Bei erfolgreichem Reset wird zur `/login`-Seite mit Erfolgsmeldung weitergeleitet
- [ ] Bei ungültigem oder abgelaufenem Token wird eine Fehlermeldung angezeigt
- [ ] Das Passwortfeld zeigt Zeichen verborgen an

**Abhängigkeit:** Sub-Ticket 1.2 muss abgeschlossen sein

---

## EPIC: E-Mail-Verifikation bei Registrierung

**User Story:**
> Als Kunde möchte ich nach der Registrierung eine Verifikationsmail erhalten, damit meine E-Mail-Adresse bestätigt wird und mein Account aktiviert wird.

**Akzeptanzkriterien:**
- [ ] Nach der Registrierung erhält der Nutzer eine Verifikationsmail
- [ ] Der Account ist bis zur Verifikation nicht vollständig nutzbar (kein Login möglich)
- [ ] Nach Klick auf den Verifikationslink wird der Account aktiviert
- [ ] Der Verifikationslink ist zeitlich begrenzt (48 Stunden)
- [ ] Bei abgelaufenem Link kann ein neuer Link angefordert werden
- [ ] Nach erfolgreicher Verifikation wird der Nutzer zur Login-Seite weitergeleitet

---

### Sub-Ticket 2.1 – E-Mail-Verifikation: Datenbank

**Titel:** `[Datenbank] E-Mail-Verifikation – EmailVerificationToken Entity und Repository`

**Beschreibung:**
Definition der `EmailVerificationToken`-Entity zur Speicherung von Verifikations-Tokens sowie das zugehörige Repository. Zusätzlich wird die `ApplicationUser`-Entity um ein `isVerified`-Flag erweitert.

**Aufgaben:**
- `ApplicationUser`-Entity: Feld `isVerified` (boolean, default `false`) hinzufügen
- `EmailVerificationToken`-Entity anlegen mit Feldern:
  - `id` (Long, Primary Key)
  - `token` (String, UUID, `@Column(unique = true)`)
  - `user` (OneToOne → `ApplicationUser`)
  - `expiresAt` (LocalDateTime)
- `EmailVerificationTokenRepository` anlegen mit Methoden:
  - `findByToken(String token)`
  - `findByUser(ApplicationUser user)`
- Testdaten-Generator: verifizierten und unverizierten Testnutzer anlegen

**Akzeptanzkriterien:**
- [ ] Die Tabelle `EMAIL_VERIFICATION_TOKEN` existiert in der Datenbank
- [ ] Die `ApplicationUser`-Tabelle hat eine `IS_VERIFIED`-Spalte (default `false`)
- [ ] `findByToken()` gibt `Optional<EmailVerificationToken>` zurück
- [ ] Der Testdaten-Generator legt einen nicht-verifizierten Nutzer an

**Abhängigkeit:** Sub-Ticket 1.1 aus EPIC Registrierung muss abgeschlossen sein

---

### Sub-Ticket 2.2 – E-Mail-Verifikation: Backend

**Titel:** `[Backend] E-Mail-Verifikation – Token-Generierung, E-Mail-Versand und Account-Aktivierung`

**Beschreibung:**
Erweiterung der Registrierungslogik: Nach der Registrierung wird ein Verifikationstoken generiert und per Mail versendet. Login ist erst nach Verifikation möglich. Ein abgelaufener Token kann neu angefordert werden.

**Aufgaben:**
- `UserServiceImpl.registerCustomer()` erweitern:
  - Nach dem Speichern des Nutzers: Verifikationstoken generieren (UUID, 48h Ablauf)
  - Verifikationsmail via `EmailService` versenden
- `EmailService`: Methode `sendVerificationEmail(String to, String verificationLink)` implementieren
- `UserService` + `UserServiceImpl`: Methode `verifyEmail(String token)`:
  - Token laden und prüfen (existiert, nicht abgelaufen)
  - `isVerified = true` auf `ApplicationUser` setzen
  - Token löschen
- `UserService` + `UserServiceImpl`: Methode `resendVerificationEmail(String email)`:
  - Alten Token löschen, neuen generieren und versenden
- `AuthService.loginUser()` erweitern: Login ablehnen wenn `isVerified == false` → HTTP 403
- `UserEndpoint`:
  - `GET /api/v1/users/verify?token=...` – Account verifizieren (kein JWT)
  - `POST /api/v1/users/verify/resend` – Neue Verifikationsmail anfordern (kein JWT)

**Akzeptanzkriterien:**
- [ ] Nach der Registrierung wird eine Verifikationsmail versendet
- [ ] Ein nicht verifizierter Nutzer kann sich nicht einloggen (HTTP 403 mit passender Meldung)
- [ ] `GET /api/v1/users/verify?token=...` mit gültigem Token setzt `isVerified = true`
- [ ] Nach der Verifikation kann sich der Nutzer einloggen
- [ ] Bei abgelaufenem Token wird HTTP 400 zurückgegeben
- [ ] `POST /api/v1/users/verify/resend` sendet einen neuen Verifikationslink
- [ ] Unit-Tests für `verifyEmail()` vorhanden
- [ ] Integrationstests für beide Endpoints vorhanden

**Abhängigkeit:** Sub-Ticket 2.1 muss abgeschlossen sein; `EmailService` aus EPIC Passwort vergessen (Sub-Ticket 1.2) kann wiederverwendet werden

---

### Sub-Ticket 2.3 – E-Mail-Verifikation: Frontend

**Titel:** `[Frontend] E-Mail-Verifikation – Hinweis nach Registrierung und Verifikationsseite`

**Beschreibung:**
Nach der Registrierung wird dem Nutzer ein Hinweis angezeigt, dass er seine E-Mail bestätigen soll. Die Verifikationsseite verarbeitet den Token aus der URL automatisch.

**Aufgaben:**
- Nach erfolgreicher Registrierung: statt Weiterleitung zu `/login` eine Bestätigungsseite `/register/success` anzeigen mit Hinweis „Bitte bestätige deine E-Mail-Adresse"
- Komponente `EmailVerifyComponent` unter `components/email-verify/` anlegen:
  - Token aus URL-Parameter auslesen (`/verify-email?token=...`)
  - Automatisch `GET /api/v1/users/verify?token=...` aufrufen beim Laden der Seite
  - Bei Erfolg: Erfolgsmeldung + Link zur Login-Seite
  - Bei Fehler (abgelaufener Token): Fehlermeldung + Button „Neuen Link anfordern"
- Route `/verify-email` in `app-routing.module.ts` eintragen (kein Auth-Guard)
- Login-Seite: Bei HTTP 403 mit Meldung „nicht verifiziert" entsprechenden Hinweis anzeigen + Link zur erneuten Zusendung

**Akzeptanzkriterien:**
- [ ] Nach der Registrierung wird eine Seite mit Hinweis „Bitte E-Mail bestätigen" angezeigt
- [ ] Die Seite `/verify-email?token=...` ruft automatisch den Verifikations-Endpoint auf
- [ ] Bei gültigem Token wird eine Erfolgsmeldung mit Link zu `/login` angezeigt
- [ ] Bei abgelaufenem Token wird eine Fehlermeldung und ein Button „Neuen Link anfordern" angezeigt
- [ ] Die Login-Seite zeigt bei nicht verifiziertem Account einen entsprechenden Hinweis an
- [ ] Alle Seiten sind ohne Login erreichbar

**Abhängigkeit:** Sub-Ticket 2.2 muss abgeschlossen sein

---

## Übersicht

```
EPIC: Passwort vergessen (US 2.2.2)
├── Sub-Ticket 1.1  [Datenbank]  PasswordResetToken Entity & Repository
├── Sub-Ticket 1.2  [Backend]    Token-Generierung, E-Mail-Versand, Reset-Endpoint  →  benötigt 1.1
└── Sub-Ticket 1.3  [Frontend]   Forgot-Password-Seite, Reset-Seite                 →  benötigt 1.2

EPIC: E-Mail-Verifikation bei Registrierung
├── Sub-Ticket 2.1  [Datenbank]  EmailVerificationToken Entity, isVerified-Flag
├── Sub-Ticket 2.2  [Backend]    Token-Generierung, Versand, Verifikations-Endpoint  →  benötigt 2.1
└── Sub-Ticket 2.3  [Frontend]   Bestätigungsseite, Verifikationsseite               →  benötigt 2.2

Hinweis: EmailService aus EPIC Passwort vergessen (Sub-Ticket 1.2) kann in
         EPIC E-Mail-Verifikation (Sub-Ticket 2.2) wiederverwendet werden.
         → EPIC Passwort vergessen sollte zuerst implementiert werden.
```
