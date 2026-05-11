# GEMINI.md

This file provides guidance to gemini

## Commands

```bash
# Build
mvn package -DskipTests

# Run (starts on :8080, management on :8081)
mvn spring-boot:run

# Run with test data
mvn spring-boot:run -Dspring-boot.run.profiles=generateData

# All tests
mvn test

# Single test class
mvn test -Dtest=MessageEndpointTest

# Checkstyle (runs automatically on build, but can be run standalone)
mvn checkstyle:check
```

> **Important:** Checkstyle is enforced on every build (`validate` phase). Fix violations before committing. Config is in `checkstyle.xml`.

## Architecture

**4-layer, strict top-to-bottom:** `endpoint → service → repository → DB`. No layer skipping.

```
endpoint/       REST controllers (@RestController), DTOs live in endpoint/dto/
service/        Interfaces + impl/ for implementations (@Service, @Transactional)
  mapper/       MapStruct mappers (auto-generated, Spring component model)
repository/     JPA repositories (@Repository, extends JpaRepository)
entity/         JPA entities (never exposed outside backend)
security/       JwtTokenizer, JwtAuthorizationFilter
config/         Spring @Configuration classes (SecurityConfig, EncoderConfig, …)
exception/      Custom exception classes
datagenerator/  Test data (active only with profile generateData)
```

**Base package:** `at.ac.tuwien.sepr.groupphase.backend`

## Key conventions

**DTOs vs Entities:** DTOs travel between `endpoint ↔ service`. Entities stay inside the backend. MapStruct mappers in `service/mapper/` convert between them. MapStruct uses `defaultComponentModel=spring` — mappers are Spring beans, inject with `@Autowired`.

**Security:** Stateless JWT. The filter `JwtAuthorizationFilter` validates the `Authorization: Bearer <token>` header on every request. Public endpoints must be explicitly permitted in `SecurityConfig`. JWT expiry is 12 hours. Secret and settings are in `application.yml` under `security.jwt`.

**Database:** H2 file-based at `./database/db` (AUTO_SERVER=TRUE allows parallel tool access). Schema managed by Hibernate `ddl-auto: update`. Delete `./database/` to reset schema.

**Tests:** Split into `unittests/` and `integrationtest/` packages under `src/test/`. Shared constants in `basetest/TestData.java`.

## Template TODOs

`ApplicationUser` entity is a stub — needs `@Entity`, `@Table`, all fields, and proper JPA annotations before any auth work can proceed.
