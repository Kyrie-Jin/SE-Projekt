# SE PR Gruppenphase - Ticketline 4.0

Dieses Repository enthält die Konzepte, Mockups und den Quellcode für das Projekt Ticketline 4.0.

## Projektstruktur

- `Konzept/`: Enthält Designdokument, Domänenmodell und Softwarearchitektur.
- `mockups/`: HTML-Prototypen und Design-Assets.
- `26ss-se-pr-inso-13/`: Das Haupt-Backend und Frontend (als Git Submodule).
- `.ai-configs/`: Zentrale Verwaltung der AI-Instruktionen (`CLAUDE.md, GEMINI.md, AGENTS.md`).

## AI Workflow (CLAUDE.md, GEMINI.md, AGENTS.md)

Um die AI-Unterstützung projektweit konsistent zu halten, ohne das Template-Submodule zu verändern, nutzen wir ein Synchronisations-Script für alle Konfigurationsdateien.

### Änderungen an AI-Instruktionen
Die "Master"-Dateien befinden sich organisiert in `.ai-configs/`:
- `.ai-configs/claude-md/`: Master-Dateien für Claude Code.
- `.ai-configs/gemini-md/`: Master-Dateien für Gemini CLI.
- `.ai-configs/agents-md/`: Master-Dateien für AI Agents.

Jeder Ordner enthält eine `root-*.md` für das Hauptverzeichnis und eine `backend-*.md` für das Submodule.

### Synchronisation
Nach Änderungen in `.ai-configs/` muss das Script ausgeführt werden:

```bash
./sync-ai.sh
```

**Was macht das Script?**
1. Verteilt alle Master-Dateien an ihre Zielorte (Root & Submodule).
2. Setzt lokale Ignorier-Regeln im Submodule (`.git/info/exclude`), damit `CLAUDE.md`, `GEMINI.md` und `AGENTS.md` dort nicht getrackt werden.

## Entwicklung

### Backend & Frontend
Informationen zum Build-Prozess und zur Entwicklung findest du in der [README.md des Templates](26ss-se-pr-inso-13/backend/Readme.md).

