# GEMINI.md

This file provides guidance to for when working with Codex

## Commands

```bash
npm install              # install dependencies (run once after cloning)
npm start                # dev server at http://localhost:4200 (hash routing)
npm run build            # production build → dist/
npm test                 # run Karma/Jasmine unit tests (headless Chrome)
npm run lint             # ESLint + angular-eslint
ng generate component components/<name>   # scaffold new component
ng generate service services/<name>       # scaffold new service
```

Run a single spec file:
```bash
npx ng test --include='**/auth.service.spec.ts'
```

## Architecture

The app is a classic Angular NgModule app (not standalone). All declarations live in `AppModule` (`app.module.ts`).

### Request flow
Every HTTP call goes through `AuthInterceptor` (`interceptors/auth-interceptor.ts`), which attaches `Authorization: Bearer <token>` from `localStorage` to every request **except** `/authentication`. The backend base URL is resolved at runtime by `Globals` (`global/globals.ts`): port 4200 → `http://localhost:8080/api/v1`, otherwise same host as the frontend.

### Auth
- JWT stored as `authToken` in `localStorage`.
- `AuthService` handles login, logout, register, and role extraction (`ROLE_ADMIN` → `'ADMIN'`, `ROLE_USER` → `'USER'`).
- `AuthGuard` protects routes by calling `authService.isLoggedIn()`; redirects to `/login` on failure.

### Routing
Hash-based routing (`useHash: true`). Current routes:

| Path | Component | Guard |
|------|-----------|-------|
| `/` | `HomeComponent` | — |
| `/login` | `LoginComponent` | — |
| `/register` | `RegisterComponent` | — |
| `/message` | `MessageComponent` | `AuthGuard` |

### Key layers
- `components/` – page-level UI components; each has `.ts`, `.html`, `.scss`, `.spec.ts`
- `components/shared/` – wiederverwendbare UI-Komponenten (z.B. `FormFieldComponent`)
- `services/` – injectable classes that talk to the backend via `HttpClient`
- `dtos/` – plain TypeScript classes mirroring backend request/response shapes
- `guards/` – route guards
- `interceptors/` – HTTP interceptors (currently only `AuthInterceptor`)
- `global/globals.ts` – singleton with the resolved `backendUri`

### Shared components
Wiederverwendbare Komponenten leben in `components/shared/` und müssen in `AppModule` deklariert werden.


### UI stack
Bootstrap 5 + ng-bootstrap (`NgbModule`) for UI components. Use Bootstrap utility classes for layout, spacing, and color wherever possible. Custom SCSS is only for design-specific elements Bootstrap cannot cover. Styles live in `src/styles.scss` (global) and per-component `.scss` files.

### Styles-Struktur (`src/styles/`)
- **`_tokens.scss`** — alle Design-Tokens (Farben, etc.) aus `DESIGN.md`. In jeder Component-SCSS importieren mit `@use '../../../styles/tokens' as *;` (Pfad je nach Tiefe anpassen). Keine Farben lokal in Components definieren.
- **`_components.scss`** — globale CSS-Klassen für Elemente die via `ng-content` in shared Components projiziert werden und daher ViewEncapsulation nicht erreicht. Aktuell: `field-input`, `field-eye-btn` und ihre Varianten. Wird in `styles.scss` importiert.

### Design system
Defined in `DESIGN.md` (repo root). Key constraints:
- No 1px solid borders for layout — use background color shifts (`surface-container` tiers) instead.
- Primary color `$primary` (`#003ec7`); never use pure `#000000` (use `$on-surface` = `#191b25`).
- Fonts: Manrope (headlines), Inter (body/labels).
- Glassmorphism (12–20px backdrop blur) for floating elements like filters or summaries.
- Primary CTAs use a 135° gradient from `$primary` to `$primary-container` at 135°.
- 8px spacing scale (8 / 16 / 24 / 32px).

