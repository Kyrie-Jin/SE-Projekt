# Registration – DB & Backend Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement Sub-Tickets 1.1 and 1.2 – a proper JPA `ApplicationUser` entity, a real Spring Data repository, a `DataGenerator` with test users, and a `POST /api/v1/users/register` endpoint backed by a validated service.

**Architecture:** 4-layer strict flow: `UserEndpoint → UserService → UserRepository → H2`. The entity is rewritten from scratch (the template has a non-JPA stub). `AuthServiceImpl` is updated in-place after the entity/repository change to keep the build green. MapStruct converts between entity and DTOs inside the service layer.

**Tech Stack:** Spring Boot, JPA/Hibernate, Spring Data JPA, MapStruct 1.6.3 (Spring component model), BCrypt (`PasswordEncoder` bean in `EncoderConfig`), Bean Validation (`spring-boot-starter-validation`), JUnit 5 + MockMvc.

---

## File Map

| Action | File |
|--------|------|
| Create | `entity/UserRole.java` |
| Rewrite | `entity/ApplicationUser.java` |
| Rewrite | `repository/UserRepository.java` |
| Update | `service/impl/AuthServiceImpl.java` |
| Create | `datagenerator/DataGenerator.java` |
| Create | `dto/UserRegistrationDto.java` |
| Create | `dto/UserDetailDto.java` |
| Create | `exception/ConflictException.java` |
| Update | `endpoint/exceptionhandler/GlobalExceptionHandler.java` |
| Create | `service/mapper/UserMapper.java` |
| Update | `service/UserService.java` |
| Update | `service/impl/UserServiceImpl.java` |
| Create | `endpoint/UserEndpoint.java` |
| Update | `basetest/TestData.java` |
| Create | `integrationtest/UserRepositoryTest.java` |
| Create | `unittests/UserServiceImplTest.java` |
| Create | `integrationtest/UserEndpointTest.java` |

**Base package for all files:** `at.ac.tuwien.sepr.groupphase.backend`
**Source root:** `sepr-groupphase-template/backend/src/main/java/`
**Test root:** `sepr-groupphase-template/backend/src/test/java/`

---

## Task 1: `UserRole` Enum

**Files:**
- Create: `backend/src/main/java/at/ac/tuwien/sepr/groupphase/backend/entity/UserRole.java`

- [ ] **Step 1: Create the enum**

```java
package at.ac.tuwien.sepr.groupphase.backend.entity;

public enum UserRole {
    ROLE_USER,
    ROLE_ADMIN
}
```

- [ ] **Step 2: Compile to verify**

Run from `sepr-groupphase-template/backend/`:
```bash
mvn compile -q
```
Expected: BUILD SUCCESS

- [ ] **Step 3: Commit**

```bash
git add backend/src/main/java/at/ac/tuwien/sepr/groupphase/backend/entity/UserRole.java
git commit -m "feat: add UserRole enum (ROLE_USER, ROLE_ADMIN)"
```

---

## Task 2: Rewrite `ApplicationUser` as a proper JPA Entity

**Files:**
- Rewrite: `backend/src/main/java/at/ac/tuwien/sepr/groupphase/backend/entity/ApplicationUser.java`

The template stub has no `@Entity`, wrong fields, and no JPA annotations. This task replaces it completely.

- [ ] **Step 1: Replace the file**

```java
package at.ac.tuwien.sepr.groupphase.backend.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import jakarta.validation.constraints.NotBlank;

@Entity
@Table(name = "APPLICATION_USER",
    uniqueConstraints = {@UniqueConstraint(columnNames = {"email"})})
public class ApplicationUser {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank
    @Column(nullable = false)
    private String firstName;

    @NotBlank
    @Column(nullable = false)
    private String lastName;

    @Column(unique = true, nullable = false)
    private String email;

    @Column(nullable = false)
    private String password;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private UserRole role;

    @Column(nullable = false)
    private Boolean isLocked = false;

    @Column(nullable = false)
    private Integer failedLoginAttempts = 0;

    public ApplicationUser() {
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getFirstName() {
        return firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getLastName() {
        return lastName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public UserRole getRole() {
        return role;
    }

    public void setRole(UserRole role) {
        this.role = role;
    }

    public Boolean getIsLocked() {
        return isLocked;
    }

    public void setIsLocked(Boolean isLocked) {
        this.isLocked = isLocked;
    }

    public Integer getFailedLoginAttempts() {
        return failedLoginAttempts;
    }

    public void setFailedLoginAttempts(Integer failedLoginAttempts) {
        this.failedLoginAttempts = failedLoginAttempts;
    }
}
```

- [ ] **Step 2: Compile (will fail until Task 3 fixes the repository)**

```bash
mvn compile -q 2>&1 | head -30
```
Expected: errors in `UserRepository.java` and `AuthServiceImpl.java` because they reference the old API. That's fine — Tasks 3 and 4 fix those.

---

## Task 3: Rewrite `UserRepository` as a Spring Data JPA Interface

**Files:**
- Rewrite: `backend/src/main/java/at/ac/tuwien/sepr/groupphase/backend/repository/UserRepository.java`

The stub is a `@Repository` class with hardcoded users. Replace entirely with a JPA interface.

- [ ] **Step 1: Replace the file**

```java
package at.ac.tuwien.sepr.groupphase.backend.repository;

import at.ac.tuwien.sepr.groupphase.backend.entity.ApplicationUser;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface UserRepository extends JpaRepository<ApplicationUser, Long> {

    Optional<ApplicationUser> findByEmail(String email);

    List<ApplicationUser> findAllByIsLockedTrue();
}
```

- [ ] **Step 2: Compile (will still fail due to AuthServiceImpl references)**

```bash
mvn compile -q 2>&1 | head -30
```
Expected: errors only in `AuthServiceImpl.java`. Proceed to Task 4.

---

## Task 4: Update `AuthServiceImpl` to use the new Entity and Repository API

**Files:**
- Update: `backend/src/main/java/at/ac/tuwien/sepr/groupphase/backend/service/impl/AuthServiceImpl.java`

Two things changed: `findUserByEmail` → `findByEmail` (returns `Optional`), and `getAdmin()` → `getRole()`.

- [ ] **Step 1: Replace the file**

```java
package at.ac.tuwien.sepr.groupphase.backend.service.impl;

import at.ac.tuwien.sepr.groupphase.backend.dto.UserLoginDto;
import at.ac.tuwien.sepr.groupphase.backend.entity.ApplicationUser;
import at.ac.tuwien.sepr.groupphase.backend.entity.UserRole;
import at.ac.tuwien.sepr.groupphase.backend.exception.NotFoundException;
import at.ac.tuwien.sepr.groupphase.backend.repository.UserRepository;
import at.ac.tuwien.sepr.groupphase.backend.security.JwtTokenizer;
import at.ac.tuwien.sepr.groupphase.backend.service.AuthService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.AuthorityUtils;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.lang.invoke.MethodHandles;
import java.util.List;

@Service
public class AuthServiceImpl implements AuthService {

    private static final Logger LOGGER = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenizer jwtTokenizer;

    public AuthServiceImpl(UserRepository userRepository, PasswordEncoder passwordEncoder, JwtTokenizer jwtTokenizer) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtTokenizer = jwtTokenizer;
    }

    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        LOGGER.debug("Load user by email");
        try {
            ApplicationUser applicationUser = findApplicationUserByEmail(email);

            List<GrantedAuthority> grantedAuthorities;
            if (applicationUser.getRole() == UserRole.ROLE_ADMIN) {
                grantedAuthorities = AuthorityUtils.createAuthorityList("ROLE_ADMIN", "ROLE_USER");
            } else {
                grantedAuthorities = AuthorityUtils.createAuthorityList("ROLE_USER");
            }

            return new User(applicationUser.getEmail(), applicationUser.getPassword(), grantedAuthorities);
        } catch (NotFoundException e) {
            throw new UsernameNotFoundException(e.getMessage(), e);
        }
    }

    @Override
    public ApplicationUser findApplicationUserByEmail(String email) {
        LOGGER.debug("Find application user by email");
        return userRepository.findByEmail(email)
            .orElseThrow(() -> new NotFoundException(
                String.format("Could not find the user with the email address %s", email)));
    }

    @Override
    public String login(UserLoginDto userLoginDto) {
        UserDetails userDetails = loadUserByUsername(userLoginDto.getEmail());
        if (userDetails != null
            && userDetails.isAccountNonExpired()
            && userDetails.isAccountNonLocked()
            && userDetails.isCredentialsNonExpired()
            && passwordEncoder.matches(userLoginDto.getPassword(), userDetails.getPassword())
        ) {
            List<String> roles = userDetails.getAuthorities()
                .stream()
                .map(GrantedAuthority::getAuthority)
                .toList();
            return jwtTokenizer.getAuthToken(userDetails.getUsername(), roles);
        }
        throw new BadCredentialsException("Username or password is incorrect or account is locked");
    }
}
```

- [ ] **Step 2: Compile and verify build is green**

```bash
mvn compile -q
```
Expected: BUILD SUCCESS

- [ ] **Step 3: Run existing tests to confirm nothing regressed**

```bash
mvn test -q 2>&1 | tail -20
```
Expected: BUILD SUCCESS (existing tests should still pass; login tests now hit an empty H2 DB — they may fail if they relied on in-memory users, which is acceptable at this stage)

- [ ] **Step 4: Commit**

```bash
git add backend/src/main/java/at/ac/tuwien/sepr/groupphase/backend/entity/ApplicationUser.java \
        backend/src/main/java/at/ac/tuwien/sepr/groupphase/backend/entity/UserRole.java \
        backend/src/main/java/at/ac/tuwien/sepr/groupphase/backend/repository/UserRepository.java \
        backend/src/main/java/at/ac/tuwien/sepr/groupphase/backend/service/impl/AuthServiceImpl.java
git commit -m "feat: rewrite ApplicationUser as JPA entity, UserRepository as Spring Data interface"
```

---

## Task 5: Create `DataGenerator`

**Files:**
- Create: `backend/src/main/java/at/ac/tuwien/sepr/groupphase/backend/datagenerator/DataGenerator.java`

Active only under the `generateData` Spring profile. Creates 1 admin and 2 customer users.

- [ ] **Step 1: Create the file**

```java
package at.ac.tuwien.sepr.groupphase.backend.datagenerator;

import at.ac.tuwien.sepr.groupphase.backend.entity.ApplicationUser;
import at.ac.tuwien.sepr.groupphase.backend.entity.UserRole;
import at.ac.tuwien.sepr.groupphase.backend.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.ApplicationListener;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.annotation.Profile;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.lang.invoke.MethodHandles;

@Component
@Profile("generateData")
public class DataGenerator implements ApplicationListener<ApplicationReadyEvent> {

    private static final Logger LOGGER = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public DataGenerator(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public void onApplicationEvent(ApplicationReadyEvent event) {
        if (userRepository.count() > 0) {
            LOGGER.debug("DataGenerator: users already exist, skipping");
            return;
        }
        generateUsers();
    }

    private void generateUsers() {
        LOGGER.debug("DataGenerator: generating test users");

        ApplicationUser admin = new ApplicationUser();
        admin.setFirstName("Admin");
        admin.setLastName("User");
        admin.setEmail("admin@ticketline.at");
        admin.setPassword(passwordEncoder.encode("Admin1234!"));
        admin.setRole(UserRole.ROLE_ADMIN);
        admin.setIsLocked(false);
        admin.setFailedLoginAttempts(0);
        userRepository.save(admin);

        ApplicationUser customer1 = new ApplicationUser();
        customer1.setFirstName("Max");
        customer1.setLastName("Mustermann");
        customer1.setEmail("max@ticketline.at");
        customer1.setPassword(passwordEncoder.encode("User1234!"));
        customer1.setRole(UserRole.ROLE_USER);
        customer1.setIsLocked(false);
        customer1.setFailedLoginAttempts(0);
        userRepository.save(customer1);

        ApplicationUser customer2 = new ApplicationUser();
        customer2.setFirstName("Anna");
        customer2.setLastName("Muster");
        customer2.setEmail("anna@ticketline.at");
        customer2.setPassword(passwordEncoder.encode("User1234!"));
        customer2.setRole(UserRole.ROLE_USER);
        customer2.setIsLocked(false);
        customer2.setFailedLoginAttempts(0);
        userRepository.save(customer2);

        LOGGER.debug("DataGenerator: created 1 admin and 2 customers");
    }
}
```

- [ ] **Step 2: Compile**

```bash
mvn compile -q
```
Expected: BUILD SUCCESS

- [ ] **Step 3: Commit**

```bash
git add backend/src/main/java/at/ac/tuwien/sepr/groupphase/backend/datagenerator/DataGenerator.java
git commit -m "feat: add DataGenerator with 1 admin and 2 customer test users (profile: generateData)"
```

---

## Task 6: Write Repository Tests (TDD for Task 3)

**Files:**
- Create: `backend/src/test/java/at/ac/tuwien/sepr/groupphase/backend/integrationtest/UserRepositoryTest.java`

- [ ] **Step 1: Write the tests**

```java
package at.ac.tuwien.sepr.groupphase.backend.integrationtest;

import at.ac.tuwien.sepr.groupphase.backend.entity.ApplicationUser;
import at.ac.tuwien.sepr.groupphase.backend.entity.UserRole;
import at.ac.tuwien.sepr.groupphase.backend.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.junit.jupiter.SpringExtension;

import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;

@ExtendWith(SpringExtension.class)
@SpringBootTest
@ActiveProfiles("test")
public class UserRepositoryTest {

    @Autowired
    private UserRepository userRepository;

    @BeforeEach
    void setUp() {
        userRepository.deleteAll();
    }

    @Test
    void findByEmail_existingEmail_returnsUser() {
        ApplicationUser user = buildUser("test@example.com", false);
        userRepository.save(user);

        Optional<ApplicationUser> found = userRepository.findByEmail("test@example.com");

        assertTrue(found.isPresent());
        assertEquals("test@example.com", found.get().getEmail());
    }

    @Test
    void findByEmail_unknownEmail_returnsEmpty() {
        Optional<ApplicationUser> found = userRepository.findByEmail("nobody@example.com");
        assertFalse(found.isPresent());
    }

    @Test
    void findAllByIsLockedTrue_returnsOnlyLockedUsers() {
        ApplicationUser locked = buildUser("locked@example.com", true);
        ApplicationUser active = buildUser("active@example.com", false);
        userRepository.save(locked);
        userRepository.save(active);

        List<ApplicationUser> result = userRepository.findAllByIsLockedTrue();

        assertEquals(1, result.size());
        assertEquals("locked@example.com", result.get(0).getEmail());
    }

    @Test
    void findAllByIsLockedTrue_noLockedUsers_returnsEmptyList() {
        userRepository.save(buildUser("active@example.com", false));

        List<ApplicationUser> result = userRepository.findAllByIsLockedTrue();

        assertTrue(result.isEmpty());
    }

    private ApplicationUser buildUser(String email, boolean locked) {
        ApplicationUser user = new ApplicationUser();
        user.setFirstName("Test");
        user.setLastName("User");
        user.setEmail(email);
        user.setPassword("hashed_password");
        user.setRole(UserRole.ROLE_USER);
        user.setIsLocked(locked);
        user.setFailedLoginAttempts(0);
        return user;
    }
}
```

- [ ] **Step 2: Run tests**

```bash
mvn test -Dtest=UserRepositoryTest -q
```
Expected: BUILD SUCCESS, all 4 tests pass

- [ ] **Step 3: Commit**

```bash
git add backend/src/test/java/at/ac/tuwien/sepr/groupphase/backend/integrationtest/UserRepositoryTest.java
git commit -m "test: add UserRepository integration tests for findByEmail and findAllByIsLockedTrue"
```

---

## Task 7: Create DTOs — `UserRegistrationDto` and `UserDetailDto`

**Files:**
- Create: `backend/src/main/java/at/ac/tuwien/sepr/groupphase/backend/dto/UserRegistrationDto.java`
- Create: `backend/src/main/java/at/ac/tuwien/sepr/groupphase/backend/dto/UserDetailDto.java`

- [ ] **Step 1: Create `UserRegistrationDto`**

```java
package at.ac.tuwien.sepr.groupphase.backend.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class UserRegistrationDto {

    @NotBlank
    private String firstName;

    @NotBlank
    private String lastName;

    @NotBlank
    @Email
    private String email;

    @NotBlank
    @Size(min = 8, message = "must be at least 8 characters")
    private String password;

    public String getFirstName() {
        return firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getLastName() {
        return lastName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }
}
```

- [ ] **Step 2: Create `UserDetailDto`**

```java
package at.ac.tuwien.sepr.groupphase.backend.dto;

public class UserDetailDto {

    private Long id;
    private String firstName;
    private String lastName;
    private String email;
    private String role;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getFirstName() {
        return firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getLastName() {
        return lastName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }
}
```

- [ ] **Step 3: Compile**

```bash
mvn compile -q
```
Expected: BUILD SUCCESS

- [ ] **Step 4: Commit**

```bash
git add backend/src/main/java/at/ac/tuwien/sepr/groupphase/backend/dto/UserRegistrationDto.java \
        backend/src/main/java/at/ac/tuwien/sepr/groupphase/backend/dto/UserDetailDto.java
git commit -m "feat: add UserRegistrationDto and UserDetailDto"
```

---

## Task 8: Add `ConflictException` and Register in `GlobalExceptionHandler`

**Files:**
- Create: `backend/src/main/java/at/ac/tuwien/sepr/groupphase/backend/exception/ConflictException.java`
- Update: `backend/src/main/java/at/ac/tuwien/sepr/groupphase/backend/endpoint/exceptionhandler/GlobalExceptionHandler.java`

- [ ] **Step 1: Create `ConflictException`**

```java
package at.ac.tuwien.sepr.groupphase.backend.exception;

public class ConflictException extends RuntimeException {

    public ConflictException(String message) {
        super(message);
    }
}
```

- [ ] **Step 2: Add handler to `GlobalExceptionHandler`**

Add this method inside the class, after the existing `handleNotFound` method:

```java
@ExceptionHandler(value = {ConflictException.class})
protected ResponseEntity<Object> handleConflict(RuntimeException ex, WebRequest request) {
    LOGGER.warn(ex.getMessage());
    return handleExceptionInternal(ex, ex.getMessage(), new HttpHeaders(), HttpStatus.CONFLICT, request);
}
```

Also add the import:
```java
import at.ac.tuwien.sepr.groupphase.backend.exception.ConflictException;
```

- [ ] **Step 3: Compile**

```bash
mvn compile -q
```
Expected: BUILD SUCCESS

- [ ] **Step 4: Commit**

```bash
git add backend/src/main/java/at/ac/tuwien/sepr/groupphase/backend/exception/ConflictException.java \
        backend/src/main/java/at/ac/tuwien/sepr/groupphase/backend/endpoint/exceptionhandler/GlobalExceptionHandler.java
git commit -m "feat: add ConflictException and HTTP 409 handler"
```

---

## Task 9: Create `UserMapper` (MapStruct)

**Files:**
- Create: `backend/src/main/java/at/ac/tuwien/sepr/groupphase/backend/service/mapper/UserMapper.java`

MapStruct is configured with `defaultComponentModel=spring` — the generated mapper is a Spring bean, inject with `@Autowired`.

- [ ] **Step 1: Create the mapper**

```java
package at.ac.tuwien.sepr.groupphase.backend.service.mapper;

import at.ac.tuwien.sepr.groupphase.backend.dto.UserDetailDto;
import at.ac.tuwien.sepr.groupphase.backend.dto.UserRegistrationDto;
import at.ac.tuwien.sepr.groupphase.backend.entity.ApplicationUser;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper
public interface UserMapper {

    @Mapping(target = "role", expression = "java(applicationUser.getRole().name())")
    UserDetailDto applicationUserToUserDetailDto(ApplicationUser applicationUser);

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "role", ignore = true)
    @Mapping(target = "isLocked", ignore = true)
    @Mapping(target = "failedLoginAttempts", ignore = true)
    @Mapping(target = "password", ignore = true)
    ApplicationUser userRegistrationDtoToApplicationUser(UserRegistrationDto userRegistrationDto);
}
```

- [ ] **Step 2: Compile (MapStruct generates the implementation)**

```bash
mvn compile -q
```
Expected: BUILD SUCCESS. MapStruct generates `UserMapperImpl.java` in `target/`.

- [ ] **Step 3: Commit**

```bash
git add backend/src/main/java/at/ac/tuwien/sepr/groupphase/backend/service/mapper/UserMapper.java
git commit -m "feat: add UserMapper (MapStruct) for ApplicationUser <-> DTO conversion"
```

---

## Task 10: Implement `UserService.registerCustomer()` in `UserServiceImpl`

**Files:**
- Update: `backend/src/main/java/at/ac/tuwien/sepr/groupphase/backend/service/UserService.java`
- Update: `backend/src/main/java/at/ac/tuwien/sepr/groupphase/backend/service/impl/UserServiceImpl.java`

- [ ] **Step 1: Add the method to `UserService` interface**

```java
package at.ac.tuwien.sepr.groupphase.backend.service;

import at.ac.tuwien.sepr.groupphase.backend.dto.UserDetailDto;
import at.ac.tuwien.sepr.groupphase.backend.dto.UserRegistrationDto;

public interface UserService {

    UserDetailDto registerCustomer(UserRegistrationDto dto);
}
```

- [ ] **Step 2: Implement in `UserServiceImpl`**

```java
package at.ac.tuwien.sepr.groupphase.backend.service.impl;

import at.ac.tuwien.sepr.groupphase.backend.dto.UserDetailDto;
import at.ac.tuwien.sepr.groupphase.backend.dto.UserRegistrationDto;
import at.ac.tuwien.sepr.groupphase.backend.entity.ApplicationUser;
import at.ac.tuwien.sepr.groupphase.backend.entity.UserRole;
import at.ac.tuwien.sepr.groupphase.backend.exception.ConflictException;
import at.ac.tuwien.sepr.groupphase.backend.repository.UserRepository;
import at.ac.tuwien.sepr.groupphase.backend.service.UserService;
import at.ac.tuwien.sepr.groupphase.backend.service.mapper.UserMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.lang.invoke.MethodHandles;

@Service
public class UserServiceImpl implements UserService {

    private static final Logger LOGGER = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final UserMapper userMapper;

    public UserServiceImpl(UserRepository userRepository, PasswordEncoder passwordEncoder, UserMapper userMapper) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.userMapper = userMapper;
    }

    @Override
    @Transactional
    public UserDetailDto registerCustomer(UserRegistrationDto dto) {
        LOGGER.debug("Registering customer with email {}", dto.getEmail());
        if (userRepository.findByEmail(dto.getEmail()).isPresent()) {
            throw new ConflictException(
                String.format("Email address %s is already registered", dto.getEmail()));
        }
        ApplicationUser user = userMapper.userRegistrationDtoToApplicationUser(dto);
        user.setPassword(passwordEncoder.encode(dto.getPassword()));
        user.setRole(UserRole.ROLE_USER);
        user.setIsLocked(false);
        user.setFailedLoginAttempts(0);
        ApplicationUser saved = userRepository.save(user);
        return userMapper.applicationUserToUserDetailDto(saved);
    }
}
```

- [ ] **Step 3: Compile**

```bash
mvn compile -q
```
Expected: BUILD SUCCESS

- [ ] **Step 4: Commit**

```bash
git add backend/src/main/java/at/ac/tuwien/sepr/groupphase/backend/service/UserService.java \
        backend/src/main/java/at/ac/tuwien/sepr/groupphase/backend/service/impl/UserServiceImpl.java
git commit -m "feat: implement UserService.registerCustomer with BCrypt hashing and conflict check"
```

---

## Task 11: Create `UserEndpoint` — `POST /api/v1/users/register`

**Files:**
- Create: `backend/src/main/java/at/ac/tuwien/sepr/groupphase/backend/endpoint/UserEndpoint.java`

No changes needed to `SecurityConfig` — `@PermitAll` at the method level is sufficient for public endpoints (same pattern as `LoginEndpoint`).

- [ ] **Step 1: Create the endpoint**

```java
package at.ac.tuwien.sepr.groupphase.backend.endpoint;

import at.ac.tuwien.sepr.groupphase.backend.dto.UserDetailDto;
import at.ac.tuwien.sepr.groupphase.backend.dto.UserRegistrationDto;
import at.ac.tuwien.sepr.groupphase.backend.service.UserService;
import jakarta.annotation.security.PermitAll;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/users")
public class UserEndpoint {

    private final UserService userService;

    public UserEndpoint(UserService userService) {
        this.userService = userService;
    }

    @PermitAll
    @PostMapping("/register")
    @ResponseStatus(HttpStatus.CREATED)
    public UserDetailDto register(@Valid @RequestBody UserRegistrationDto dto) {
        return userService.registerCustomer(dto);
    }
}
```

- [ ] **Step 2: Compile**

```bash
mvn compile -q
```
Expected: BUILD SUCCESS

- [ ] **Step 3: Commit**

```bash
git add backend/src/main/java/at/ac/tuwien/sepr/groupphase/backend/endpoint/UserEndpoint.java
git commit -m "feat: add POST /api/v1/users/register endpoint"
```

---

## Task 12: Unit Tests for `UserServiceImpl.registerCustomer()`

**Files:**
- Update: `backend/src/test/java/at/ac/tuwien/sepr/groupphase/backend/basetest/TestData.java`
- Create: `backend/src/test/java/at/ac/tuwien/sepr/groupphase/backend/unittests/UserServiceImplTest.java`

- [ ] **Step 1: Add user registration constants to `TestData`**

Add these constants to the existing `TestData` interface:

```java
String USER_BASE_URI = BASE_URI + "/users";
String REGISTER_URI = USER_BASE_URI + "/register";

String VALID_FIRST_NAME = "Max";
String VALID_LAST_NAME = "Mustermann";
String VALID_EMAIL = "max.mustermann@example.com";
String VALID_PASSWORD = "SecurePass1!";
String DUPLICATE_EMAIL = "duplicate@example.com";
```

- [ ] **Step 2: Write the unit tests**

```java
package at.ac.tuwien.sepr.groupphase.backend.unittests;

import at.ac.tuwien.sepr.groupphase.backend.basetest.TestData;
import at.ac.tuwien.sepr.groupphase.backend.dto.UserDetailDto;
import at.ac.tuwien.sepr.groupphase.backend.dto.UserRegistrationDto;
import at.ac.tuwien.sepr.groupphase.backend.entity.ApplicationUser;
import at.ac.tuwien.sepr.groupphase.backend.entity.UserRole;
import at.ac.tuwien.sepr.groupphase.backend.exception.ConflictException;
import at.ac.tuwien.sepr.groupphase.backend.repository.UserRepository;
import at.ac.tuwien.sepr.groupphase.backend.service.impl.UserServiceImpl;
import at.ac.tuwien.sepr.groupphase.backend.service.mapper.UserMapper;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class UserServiceImplTest implements TestData {

    @Mock
    private UserRepository userRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @Mock
    private UserMapper userMapper;

    @InjectMocks
    private UserServiceImpl userService;

    @Test
    void registerCustomer_validData_returnsUserDetailDto() {
        UserRegistrationDto dto = buildRegistrationDto(VALID_EMAIL);
        ApplicationUser mappedUser = buildUnsavedUser(VALID_EMAIL);
        ApplicationUser savedUser = buildSavedUser(VALID_EMAIL);
        UserDetailDto expectedDto = buildUserDetailDto(VALID_EMAIL);

        when(userRepository.findByEmail(VALID_EMAIL)).thenReturn(Optional.empty());
        when(userMapper.userRegistrationDtoToApplicationUser(dto)).thenReturn(mappedUser);
        when(passwordEncoder.encode(VALID_PASSWORD)).thenReturn("hashed_password");
        when(userRepository.save(any(ApplicationUser.class))).thenReturn(savedUser);
        when(userMapper.applicationUserToUserDetailDto(savedUser)).thenReturn(expectedDto);

        UserDetailDto result = userService.registerCustomer(dto);

        assertNotNull(result);
        assertEquals(VALID_EMAIL, result.getEmail());
        assertEquals("ROLE_USER", result.getRole());
        verify(passwordEncoder).encode(VALID_PASSWORD);
        verify(userRepository).save(any(ApplicationUser.class));
    }

    @Test
    void registerCustomer_duplicateEmail_throwsConflictException() {
        UserRegistrationDto dto = buildRegistrationDto(DUPLICATE_EMAIL);
        ApplicationUser existing = buildSavedUser(DUPLICATE_EMAIL);

        when(userRepository.findByEmail(DUPLICATE_EMAIL)).thenReturn(Optional.of(existing));

        assertThrows(ConflictException.class, () -> userService.registerCustomer(dto));
        verify(userRepository, never()).save(any());
    }

    @Test
    void registerCustomer_passwordIsHashed_plaintextNeverSaved() {
        UserRegistrationDto dto = buildRegistrationDto(VALID_EMAIL);
        ApplicationUser mappedUser = buildUnsavedUser(VALID_EMAIL);
        ApplicationUser savedUser = buildSavedUser(VALID_EMAIL);

        when(userRepository.findByEmail(VALID_EMAIL)).thenReturn(Optional.empty());
        when(userMapper.userRegistrationDtoToApplicationUser(dto)).thenReturn(mappedUser);
        when(passwordEncoder.encode(VALID_PASSWORD)).thenReturn("$2a$hashed");
        when(userRepository.save(any(ApplicationUser.class))).thenReturn(savedUser);
        when(userMapper.applicationUserToUserDetailDto(savedUser)).thenReturn(buildUserDetailDto(VALID_EMAIL));

        userService.registerCustomer(dto);

        verify(userRepository).save(argThat(u -> "$2a$hashed".equals(u.getPassword())));
    }

    @Test
    void registerCustomer_roleIsAlwaysRoleUser() {
        UserRegistrationDto dto = buildRegistrationDto(VALID_EMAIL);
        ApplicationUser mappedUser = buildUnsavedUser(VALID_EMAIL);
        ApplicationUser savedUser = buildSavedUser(VALID_EMAIL);

        when(userRepository.findByEmail(VALID_EMAIL)).thenReturn(Optional.empty());
        when(userMapper.userRegistrationDtoToApplicationUser(dto)).thenReturn(mappedUser);
        when(passwordEncoder.encode(anyString())).thenReturn("hashed");
        when(userRepository.save(any(ApplicationUser.class))).thenReturn(savedUser);
        when(userMapper.applicationUserToUserDetailDto(savedUser)).thenReturn(buildUserDetailDto(VALID_EMAIL));

        userService.registerCustomer(dto);

        verify(userRepository).save(argThat(u -> UserRole.ROLE_USER == u.getRole()));
    }

    private UserRegistrationDto buildRegistrationDto(String email) {
        UserRegistrationDto dto = new UserRegistrationDto();
        dto.setFirstName(VALID_FIRST_NAME);
        dto.setLastName(VALID_LAST_NAME);
        dto.setEmail(email);
        dto.setPassword(VALID_PASSWORD);
        return dto;
    }

    private ApplicationUser buildUnsavedUser(String email) {
        ApplicationUser u = new ApplicationUser();
        u.setFirstName(VALID_FIRST_NAME);
        u.setLastName(VALID_LAST_NAME);
        u.setEmail(email);
        return u;
    }

    private ApplicationUser buildSavedUser(String email) {
        ApplicationUser u = buildUnsavedUser(email);
        u.setId(1L);
        u.setPassword("hashed_password");
        u.setRole(UserRole.ROLE_USER);
        u.setIsLocked(false);
        u.setFailedLoginAttempts(0);
        return u;
    }

    private UserDetailDto buildUserDetailDto(String email) {
        UserDetailDto dto = new UserDetailDto();
        dto.setId(1L);
        dto.setFirstName(VALID_FIRST_NAME);
        dto.setLastName(VALID_LAST_NAME);
        dto.setEmail(email);
        dto.setRole("ROLE_USER");
        return dto;
    }
}
```

- [ ] **Step 3: Run unit tests**

```bash
mvn test -Dtest=UserServiceImplTest -q
```
Expected: BUILD SUCCESS, all 4 tests pass

- [ ] **Step 4: Commit**

```bash
git add backend/src/test/java/at/ac/tuwien/sepr/groupphase/backend/basetest/TestData.java \
        backend/src/test/java/at/ac/tuwien/sepr/groupphase/backend/unittests/UserServiceImplTest.java
git commit -m "test: add unit tests for UserServiceImpl.registerCustomer"
```

---

## Task 13: Integration Tests for `POST /api/v1/users/register`

**Files:**
- Create: `backend/src/test/java/at/ac/tuwien/sepr/groupphase/backend/integrationtest/UserEndpointTest.java`

- [ ] **Step 1: Write the integration tests**

```java
package at.ac.tuwien.sepr.groupphase.backend.integrationtest;

import at.ac.tuwien.sepr.groupphase.backend.basetest.TestData;
import at.ac.tuwien.sepr.groupphase.backend.dto.UserDetailDto;
import at.ac.tuwien.sepr.groupphase.backend.dto.UserRegistrationDto;
import at.ac.tuwien.sepr.groupphase.backend.entity.ApplicationUser;
import at.ac.tuwien.sepr.groupphase.backend.entity.UserRole;
import at.ac.tuwien.sepr.groupphase.backend.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.mock.web.MockHttpServletResponse;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.junit.jupiter.SpringExtension;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import tools.jackson.databind.json.JsonMapper;

import static org.junit.jupiter.api.Assertions.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;

@ExtendWith(SpringExtension.class)
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
@AutoConfigureMockMvc
public class UserEndpointTest implements TestData {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private JsonMapper jsonMapper;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @BeforeEach
    void setUp() {
        userRepository.deleteAll();
    }

    @Test
    void register_validData_returns201AndUserDetailDto() throws Exception {
        UserRegistrationDto dto = buildDto(VALID_FIRST_NAME, VALID_LAST_NAME, VALID_EMAIL, VALID_PASSWORD);

        MvcResult result = mockMvc.perform(post(REGISTER_URI)
                .contentType(MediaType.APPLICATION_JSON)
                .content(jsonMapper.writeValueAsString(dto)))
            .andReturn();
        MockHttpServletResponse response = result.getResponse();

        assertEquals(HttpStatus.CREATED.value(), response.getStatus());

        UserDetailDto body = jsonMapper.readValue(response.getContentAsString(), UserDetailDto.class);
        assertEquals(VALID_EMAIL, body.getEmail());
        assertEquals(VALID_FIRST_NAME, body.getFirstName());
        assertEquals(VALID_LAST_NAME, body.getLastName());
        assertEquals("ROLE_USER", body.getRole());
        assertNotNull(body.getId());
    }

    @Test
    void register_validData_passwordIsStoredHashed() throws Exception {
        UserRegistrationDto dto = buildDto(VALID_FIRST_NAME, VALID_LAST_NAME, VALID_EMAIL, VALID_PASSWORD);

        mockMvc.perform(post(REGISTER_URI)
                .contentType(MediaType.APPLICATION_JSON)
                .content(jsonMapper.writeValueAsString(dto)))
            .andReturn();

        ApplicationUser saved = userRepository.findByEmail(VALID_EMAIL).orElseThrow();
        assertNotEquals(VALID_PASSWORD, saved.getPassword());
        assertTrue(passwordEncoder.matches(VALID_PASSWORD, saved.getPassword()));
    }

    @Test
    void register_missingFirstName_returns422() throws Exception {
        UserRegistrationDto dto = buildDto("", VALID_LAST_NAME, VALID_EMAIL, VALID_PASSWORD);

        MvcResult result = mockMvc.perform(post(REGISTER_URI)
                .contentType(MediaType.APPLICATION_JSON)
                .content(jsonMapper.writeValueAsString(dto)))
            .andReturn();

        assertEquals(HttpStatus.UNPROCESSABLE_ENTITY.value(), result.getResponse().getStatus());
    }

    @Test
    void register_invalidEmailFormat_returns422() throws Exception {
        UserRegistrationDto dto = buildDto(VALID_FIRST_NAME, VALID_LAST_NAME, "not-an-email", VALID_PASSWORD);

        MvcResult result = mockMvc.perform(post(REGISTER_URI)
                .contentType(MediaType.APPLICATION_JSON)
                .content(jsonMapper.writeValueAsString(dto)))
            .andReturn();

        assertEquals(HttpStatus.UNPROCESSABLE_ENTITY.value(), result.getResponse().getStatus());
    }

    @Test
    void register_passwordTooShort_returns422() throws Exception {
        UserRegistrationDto dto = buildDto(VALID_FIRST_NAME, VALID_LAST_NAME, VALID_EMAIL, "short");

        MvcResult result = mockMvc.perform(post(REGISTER_URI)
                .contentType(MediaType.APPLICATION_JSON)
                .content(jsonMapper.writeValueAsString(dto)))
            .andReturn();

        assertEquals(HttpStatus.UNPROCESSABLE_ENTITY.value(), result.getResponse().getStatus());
    }

    @Test
    void register_duplicateEmail_returns409() throws Exception {
        UserRegistrationDto dto = buildDto(VALID_FIRST_NAME, VALID_LAST_NAME, VALID_EMAIL, VALID_PASSWORD);

        mockMvc.perform(post(REGISTER_URI)
                .contentType(MediaType.APPLICATION_JSON)
                .content(jsonMapper.writeValueAsString(dto)))
            .andReturn();

        MvcResult result = mockMvc.perform(post(REGISTER_URI)
                .contentType(MediaType.APPLICATION_JSON)
                .content(jsonMapper.writeValueAsString(dto)))
            .andReturn();

        assertEquals(HttpStatus.CONFLICT.value(), result.getResponse().getStatus());
    }

    private UserRegistrationDto buildDto(String firstName, String lastName, String email, String password) {
        UserRegistrationDto dto = new UserRegistrationDto();
        dto.setFirstName(firstName);
        dto.setLastName(lastName);
        dto.setEmail(email);
        dto.setPassword(password);
        return dto;
    }
}
```

- [ ] **Step 2: Run all new tests together**

```bash
mvn test -Dtest="UserRepositoryTest,UserServiceImplTest,UserEndpointTest" -q
```
Expected: BUILD SUCCESS, all tests pass

- [ ] **Step 3: Run the full test suite to check for regressions**

```bash
mvn test -q 2>&1 | tail -20
```
Expected: BUILD SUCCESS

- [ ] **Step 4: Commit**

```bash
git add backend/src/test/java/at/ac/tuwien/sepr/groupphase/backend/integrationtest/UserEndpointTest.java
git commit -m "test: add integration tests for POST /api/v1/users/register"
```

---

## Self-Review Checklist

### Spec Coverage

| Requirement (from tickets) | Covered in |
|----------------------------|------------|
| `firstName`, `lastName`, `email`, `password`, `role`, `isLocked`, `failedLoginAttempts` on entity | Task 2 |
| `UNIQUE` constraint on `email` | Task 2 (`@Column(unique=true)` + `@UniqueConstraint`) |
| `findByEmail()` returning correct user | Task 3 + Task 6 |
| `findAllByIsLockedTrue()` returning only locked users | Task 3 + Task 6 |
| DataGenerator: 1 admin + 2 customers | Task 5 |
| Passwords never stored in plaintext | Tasks 10, 12, 13 |
| `POST /api/v1/users/register` returns HTTP 201 | Task 11 + Task 13 |
| Role defaults to `ROLE_USER` | Tasks 10, 12, 13 |
| HTTP 422 for missing/invalid fields | Task 7 (`@NotBlank`, `@Email`, `@Size`) + Task 13 |
| HTTP 409 for duplicate email | Tasks 8, 10, 13 |
| Unit tests for `UserServiceImpl.registerCustomer()` | Task 12 |
| Integration tests for the endpoint | Task 13 |

### No Placeholders
All steps have concrete code. No TBDs.

### Type Consistency
- `userRepository.findByEmail(String)` returns `Optional<ApplicationUser>` — used consistently in Tasks 3, 4, 10, 12.
- `userRepository.findAllByIsLockedTrue()` returns `List<ApplicationUser>` — used in Tasks 3, 6.
- `UserMapper.userRegistrationDtoToApplicationUser(dto)` and `applicationUserToUserDetailDto(user)` — used consistently in Tasks 9, 10, 12.
- `applicationUser.getIsLocked()` / `setIsLocked(Boolean)` — consistent across Tasks 2, 5, 6, 10, 12, 13.
