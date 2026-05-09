# GEMINI.md

This file provides guidance to gemini

## Workspace-Übersicht

Dies ist der Arbeitsbereich für das TU Wien SEPR Gruppenprojekt **Ticketline 4.0** – eine Ticketverkaufs-Webanwendung (Spring Boot + Angular).

| Verzeichnis / Datei | Inhalt |
|---------------------|--------|
| `angabe/angabe.md` | Offizielle Projektbeschreibung und User Stories der TU Wien |
| `Konzept/` | Eigene Konzeptdokumente: Softwarearchitektur, Domainmodell, Designdokument |
| `mockups/` | UI-Mockups gegliedert nach Seiten (login, customer, admin, …) |
| `tickets/` | Erstellte Tickets mit Akzeptanzkriterien (Markdown, GitLab-kompatibel) |
| `sepr-groupphase-template/` | **Das eigentliche Projekt** – Spring Boot Backend + Angular Frontend + E2E |

## Das eigentliche Projekt

Der gesamte implementierbare Code befindet sich in `sepr-groupphase-template/`:
f
- `backend/` – Spring Boot 4.0.5 / Java 25, Maven, H2-Datenbank, JWT-Authentifizierung
- `frontend/` – Angular 21 / TypeScript, npm
- `e2e/` – End-to-End-Tests

Für alle Implementierungsaufgaben in dieses Verzeichnis wechseln. Dort gibt es eine eigene `GEMINI.md` (falls vorhanden) mit Build-Befehlen und technischer Architektur.

## Konzeptdokumente (`Konzept/`)

- **`Softwarearchitecture.md`** – Technologie-Stack, Schichtenarchitektur (4-Layer), Package-Struktur, Komponentendiagramm
- **`Domainmodell.md`** – Fachliches Domainmodell der Anwendung
- **`Designdokument.md`** – UI/UX-Designentscheidungen

## Tickets (`tickets/`)

- **`auth-tickets.md`** – EPICs und Sub-Tickets für Login & Registrierung (US 2.1.1, 2.1.2)
- **`password-verification-tickets.md`** – EPICs für Passwort-vergessen und E-Mail-Verifikation (US 2.2.2)

Ticket-Struktur: EPIC → Sub-Tickets [Datenbank] → [Backend] → [Frontend], jeweils mit Akzeptanzkriterien als Checkboxen (GitLab-kompatibel).

## Gewählte erweiterte User Stories

Aus den drei optionalen Kategorien wurden gewählt:
- **2.2.1 Merchandise und Prämien**
- **2.2.2 Benutzerverwaltung** (inkl. Passwort zurücksetzen)
