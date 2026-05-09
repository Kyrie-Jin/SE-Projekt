# 5.10 Softwarearchitektur – Ticketline 4.0

---

## 1. Definition des Architekturstils

Ticketline 4.0 verwendet eine **Drei-Schicht-Webanwendung** (3-Tier Web Application) kombiniert mit einer **Layered Architecture** auf der Serverseite.

**Physische Topologie (3-Tier):**

| Tier | Komponente | Laufzeitumgebung |
|------|------------|-----------------|
| Präsentations-Tier | Angular 21 SPA | Browser (Client) |
| Applikations-Tier | Spring Boot 4.0 | JVM (Server) |
| Daten-Tier | H2 Database 2.4.x | JVM (Server, co-located) |

**Logische Schichtenarchitektur (4 Schichten im Backend):**

Die Applikation ist intern in vier logische Schichten gegliedert, die strikt von oben nach unten kommunizieren. Keine Schicht darf übersprungen werden.

```
UI (Browser) → REST API → Business Logic → Persistence → Datenbank
```

---

## 2. Strukturierung der Applikation

### 2.1 Vertikale Strukturierung (Layer)

```mermaid
graph TD
    A["UI-Schicht<br/>Angular 21 SPA<br/>(Browser)"]
    B["Präsentation / REST-API<br/>Spring MVC<br/>Package: endpoint"]
    C["Business-Logik / Service<br/>Spring Service<br/>Package: service + service.implementation"]
    D["Persistenzschicht<br/>Spring Data JPA / Hibernate<br/>Package: repository"]
    E[("H2 Datenbank<br/>File-based")]

    A -- "HTTP / JSON + JWT" --> B
    B -- "DTO" --> C
    C -- "Entity" --> D
    D -- "JDBC" --> E
```

| Schicht | Verantwortung | Spring-Annotationen |
|---------|--------------|---------------------|
| **UI** | Darstellung, Formularvalidierung, Token-Management | – (Angular) |
| **REST API** | HTTP-Routing, Request-Validierung, Swagger-Doku | `@RestController`, `@RequestMapping` |
| **Service** | Fachliche Regeln, Transaktionen, Berechtigungen | `@Service`, `@Transactional` |
| **Persistenz** | CRUD-Operationen, Datenbankabfragen | `@Repository`, `JpaRepository` |

**Datentransfer zwischen Schichten:**
- **DTO (Data Transfer Object):** Transport zwischen UI und REST-API (kein direktes Entity-Exposure)
- **Entity:** Repräsentation der Datenbankzeilen, wird nur innerhalb des Backends verwendet
- **MapStruct:** Automatisiertes, typsicheres Mapping zwischen DTO <-> Entity zur Compile-Zeit

### 2.2 Horizontale Strukturierung (Module)

Die Applikation gliedert sich in folgende fachliche Module:

| Modul | Beschreibung | Basis / Erweitert | Betroffene User Stories |
|-------|--------------|-------------------|-------------------------|
| Authentifizierung & Sicherheit | Login, Logout, Account-Sperre | Basis | 2.1.2 |
| Benutzerverwaltung | Registrierung, Profil, Admin: Nutzer anlegen/sperren, Passwort zurücksetzen | Basis + **Erweitert 2.2.2** | 2.1.1, 2.1.4, 2.2.2 |
| News | Erstellen, Anzeigen, Detailansicht | Basis | 2.1.3 |
| Veranstaltungen | Suche nach Künstler/Ort/Veranstaltung/Zeit, Top 10 | Basis | 2.1.5 |
| Tickets | Saalplan, Kauf, Reservierung, Stornierung | Basis | 2.1.6 |
| Rechnungsdruck | PDF-Rechnung, PDF-Stornorechnung | Basis | 2.1.7 |
| Merchandise & Prämien | Artikel kaufen, Prämienübersicht, Punkte sammeln & einlösen | **Erweitert 2.2.1** | 2.2.1 |

### 2.3 Backend Package-Struktur (Layer-Slicing)

Das Basis-Package lautet `at.ac.tuwien.sepr.groupphase.backend` und gliedert sich in folgende Sub-Packages:

- **`endpoint/`**: REST Controller (Präsentationsschicht)
  - **`dto/`**: Data Transfer Objects
- **`service/`**: Service-Interfaces (Business-Logik)
  - **`impl/`**: Service-Implementierungen (`@Service`)
  - **`mapper/`**: MapStruct Mapper Interfaces
- **`entity/`**: JPA Entities (Domänenmodell)
- **`dto/`**: Data Transfer Objects
- **`repository/`**: JPA Repositories (`@Repository`)
- **`security/`**: JWT-Konfiguration, Spring Security
- **`configuration/`**: Spring `@Configuration` Klassen
- **`exception/`**: Custom Exception-Klassen
- **`datagenerator/`**: Testdaten-Generator (Profil: `generateData`)

---

## 3. Komponenten- und Verteilungsdiagramm

### 3.1 Komponentendiagramm

```mermaid
graph TB
    subgraph Client["Client (Browser)"]
        FE["Angular 21 SPA<br/>TypeScript / HTML / CSS"]
    end

    subgraph Server["Server (JVM – Spring Boot 4.0.5)"]
        TC["Embedded Tomcat<br/>HTTP-Server :8080"]

        subgraph REST["Präsentationsschicht"]
            EP["REST Endpoints<br/>Spring MVC"]
            SW["Swagger UI<br/>OpenAPI 3.0"]
        end

        subgraph SVC["Service-Schicht"]
            AS["AuthService"]
            US["UserService"]
            NS["MessageService"]
            ES["EventService"]
            TS["TicketService"]
            OS["OrderService"]
            BS["BillingService"]
            MS["MerchandiseService"]
            RS["RewardService"]
        end

        subgraph REPO["Persistenzschicht"]
            UR["UserRepository"]
            NR["MessageRepository"]
            MRR["MessageReadRepository"]
            ER["EventRepository"]
            AR["ArtistRepository"]
            VR["VenueRepository"]
            PR["PerformanceRepository"]
            TR["TicketRepository"]
            OR["OrderRepository"]
            IR["InvoiceRepository"]
            MR["MerchandiseRepository"]
            PTR["PasswordResetTokenRepository"]
        end

        subgraph SEC["Security"]
            JWT["JWT Filter<br/>Spring Security"]
        end
    end

    subgraph DB["Datenbank (JVM)"]
        H2["H2 Database<br/>File-based<br/>./database/db"]
    end

    FE -- "HTTP/JSON + JWT" --> TC
    TC --> JWT
    JWT --> EP
    EP --> AS & US & NS & ES & TS & OS & BS & MS & RS
    AS & US --> UR
    US --> PTR
    NS --> NR & MRR
    ES --> ER & AR & VR & PR & TR
    TS --> TR & PR
    OS --> OR & TR & UR
    BS --> IR & OR
    MS --> MR
    RS --> MR & UR
    UR & NR & MRR & ER & AR & VR & PR & TR & OR & IR & MR & PTR -- "JDBC" --> H2
```

### 3.2 Verteilungsdiagramm

```mermaid
graph TB
    subgraph UserDevice["Endgerät (Client)"]
        Browser["Web-Browser<br/>Angular SPA<br/>localhost:4200 / Prod-URL"]
    end

    subgraph AppServer["Applikationsserver (JVM)"]
        SpringBoot["Spring Boot Applikation<br/>Embedded Tomcat :8080<br/>REST API + Business Logic + JPA"]
        H2DB["H2 Database<br/>./database/db"]
    end

    subgraph DevOps["DevOps (TU-Infrastruktur)"]
        GitLab["GitLab CI/CD<br/>Pipeline: Build → Test → Docker → Deploy"]
        Registry["GitLab Container Registry<br/>Docker Image"]
        K8s["Kubernetes Cluster (TU Wien)<br/>Production-Deployment<br/>nur über TU-IP erreichbar"]
    end

    Browser -- "HTTPS / REST+JSON" --> SpringBoot
    SpringBoot -- "JDBC (Embedded)" --> H2DB
    GitLab -- "Docker push" --> Registry
    Registry -- "Deploy" --> K8s
    K8s -- "hostet" --> SpringBoot
```

---

## 4. Eingesetzte Technologien

### 4.1 Backend

| Kategorie | Technologie | Version |
|-----------|------------|---------|
| Programmiersprache | Java (OpenJDK) | 25 |
| Application Framework | Spring Boot | 4.0.5 |
| Web-Schicht | Spring MVC | (mit Spring Boot) |
| Persistenz (ORM) | Spring Data JPA + Hibernate | (mit Spring Boot) |
| Application Server | Apache Tomcat (Embedded) | (mit Spring Boot) |
| DTO-Mapping | MapStruct | 1.6.3 |
| API-Dokumentation | OpenAPI 3.0 / Swagger UI | (mit Spring Boot) |
| Authentifizierung | JSON Web Token (JWT) | – |
| Build-Tool | Apache Maven | 3 |
| Test-Framework | JUnit | Durch spring-boot-starter-test eingebunden|
| Assertion-Bibliothek | AssertJ | spring-boot-starter-test eingebunden |

### 4.2 Frontend

| Kategorie | Technologie | Version |
|-----------|------------|---------|
| Frontend-Framework | Angular | 21 |
| Programmiersprache | TypeScript | (mit Angular) |
| JavaScript-Runtime | Node.js | 24.14.0 LTS |
| Package-Manager | npm | 11.9.0 |

### 4.3 Infrastruktur & DevOps

| Kategorie | Technologie | Version |
|-----------|------------|---------|
| Versionskontrolle | Git | 2.x |
| CI/CD | GitLab CI | – |
| Containerisierung | Docker | – |
| Orchestrierung | Kubernetes | – (TU-betrieben) |
| IDE | IntelliJ IDEA | Community / Ultimate |

---

## 5. Datenhaltung

### 5.1 Datenbanksystem

Es wird eine **relationale Datenbank** eingesetzt: **H2 Database (Version 2.4.x)**.

| Eigenschaft | Wert |
|-------------|------|
| Datenbanktyp | Relationale SQL-Datenbank |
| Betriebsmodus | File-based (Automatic Mixed Mode) |
| Speicherort | `./database/db` (relativ zum Backend-Verzeichnis) |
| Verbindungsprotokoll | JDBC (Java Database Connectivity) |
| JDBC-Connection-String | `jdbc:h2:file:<absoluterPfad>/database/db` |
| Zugangsdaten | Username: `admin`, Passwort: `password` |

H2 im Automatic Mixed Mode erlaubt parallele Zugriffe durch das Backend (über JDBC) und durch externe Tools (IntelliJ IDEA, DataGrip) gleichzeitig.

### 5.2 Datenzugriff (Repository Pattern)

Der Zugriff auf die Datenbank erfolgt ausschließlich über das **Repository Pattern** mittels Spring Data JPA:

- **Einfache CRUD-Operationen:** werden automatisch durch `JpaRepository<Entity, ID>` bereitgestellt
- **Komplexe Abfragen:** werden via JPQL mit `@Query`-Annotation oder der JPA Criteria API definiert
- **Transaktionen:** werden durch `@Transactional` auf Service-Ebene gesteuert

### 5.3 Datenbankschema-Verwaltung

Das Datenbankschema wird beim Start der Applikation durch **Hibernate automatisch** aktualisiert (`spring.jpa.hibernate.ddl-auto`). Bei nicht lösbaren Schemakonflikten wird das Datenbankverzeichnis (`./database/`) manuell gelöscht und beim nächsten Start neu erstellt.

### 5.4 Datenflussbeschreibung

```mermaid
sequenceDiagram
    participant Browser
    participant Controller as REST Controller<br/>(endpoint)
    participant Service as Service<br/>(service.impl)
    participant Repo as Repository<br/>(repository)
    participant DB as H2 Database

    Browser->>Controller: HTTP Request + JWT (JSON/DTO)
    Controller->>Controller: JWT validieren (Spring Security)
    Controller->>Service: DTO übergeben
    Service->>Service: MapStruct: DTO → Entity
    Service->>Repo: Entity speichern / abfragen
    Repo->>DB: JDBC (SQL via JPA)
    DB-->>Repo: Ergebnis (Entity)
    Repo-->>Service: Entity
    Service->>Service: MapStruct: Entity → DTO
    Service-->>Controller: DTO
    Controller-->>Browser: HTTP Response (JSON/DTO)
```

---
