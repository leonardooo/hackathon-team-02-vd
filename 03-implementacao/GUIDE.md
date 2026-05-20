---
title: "Stage 3 - Implementation"
description: "Guide for implementing SIFAP 2.0 using the prototype as a base"
---

# Stage 3 - Implementation (3 hours)

## Objective

Extend the working SIFAP 2.0 prototype by implementing the features prioritized in Stage 2. The prototype already has the base structure — your team will add features, fix bugs, and write tests.

---

## Getting Started (first 15 minutes)

### 1. Bring up the environment

```bash
# At the repository root (04-prototipo-sifap-moderno/)
docker compose up -d
```

This starts:
- **PostgreSQL 16** on port 5432
- **Backend (Java 21 + Spring Boot 3)** on port 8080
- **Frontend (Next.js 15)** on port **3000** (local) or **3001** (root docker-compose)

> **WARNING**: If you ran `docker compose up` from the workspace ROOT (recommended), the frontend is at **http://localhost:3001**. If you ran it from inside `04-prototipo-sifap-moderno/`, it is at **http://localhost:3000**.

### 2. Verify everything works

- Backend health: http://localhost:8080/actuator/health
- Swagger UI: http://localhost:8080/swagger-ui.html
- Frontend: http://localhost:3001 (or 3000 if local compose)

### 3. Default credentials

| User | Password | Profile | What they can do |
|------|----------|---------|-----------------|
| `admin` | `client2026` | ADMIN | Everything: manage users, configurations |
| `operator1` | `client2026` | OPERATOR | Register beneficiaries, record payments |
| `auditor1` | `client2026` | AUDITOR | Query, generate reports, audit |

### 4. Test the API in Swagger

Open http://localhost:8080/swagger-ui.html and test:
1. `POST /api/v1/auth/login` with `{"username": "admin", "password": "client2026"}`
2. Copy the returned JWT token
3. Click "Authorize" in Swagger and paste the token
4. Test the beneficiary and payment endpoints

---

## Backend Structure

The backend follows a **modular monolith** architecture with 4 modules and 3 layers each:

```
src/main/java/br/gov/client/sifap/
|
|-- beneficiary/ # Module: Beneficiaries
| |-- domain/ # Entities and business rules
| |-- application/ # Services and DTOs
| |-- infrastructure/ # Controllers, Repositories, JPA Entities
|
|-- payment/ # Module: Payments
| |-- domain/
| |-- application/
| |-- infrastructure/
|
|-- audit/ # Module: Audit
| |-- domain/
| |-- application/
| |-- infrastructure/
|
|-- admin/ # Module: Administration
| |-- domain/
| |-- application/
| |-- infrastructure/
```

### Layers (inside out)

| Layer | Responsibility | Examples |
|-------|----------------|----------|
| **domain** | Pure business rules, with no framework dependency | Status enums, repository interfaces, value objects |
| **application** | Use cases, orchestration | Services, Request/Response DTOs |
| **infrastructure** | Technical details, I/O | REST controllers, JPA Entities, Spring Data Repositories |

### Golden rule

The `domain` layer **never** imports classes from `infrastructure`. The flow is always: Controller -> Service -> Repository (interface in domain, implementation in infrastructure).

---

## How to Add a New Feature

Follow these 5 steps for each piece of functionality:

### Step 1: Create or update the domain entity

```java
// src/.../payment/domain/PaymentStatus.java
public enum PaymentStatus {
 PENDING, APPROVED, REJECTED, CANCELLED
}
```

### Step 2: Create the service

```java
// src/.../payment/application/PaymentService.java
@Service
public class PaymentService {
 // Inject the repository, implement the logic
}
```

### Step 3: Create the controller

```java
// src/.../payment/infrastructure/PaymentController.java
@RestController
@RequestMapping("/api/v1/payments")
public class PaymentController {
 // Inject the service, expose the endpoints
}
```

### Step 4: Create the database migration

```sql
-- src/main/resources/db/migration/V2__add_payment_status.sql
ALTER TABLE payments ADD COLUMN status VARCHAR(20) DEFAULT 'PENDING';
```

> **Important**: Use Flyway. Never modify existing migrations — always create new ones (V2__, V3__, etc.).

### Step 5: Write tests

```java
// src/test/.../payment/application/PaymentServiceTest.java
@SpringBootTest
class PaymentServiceTest {
 @Test
 void shouldCalculatePaymentCorrectly() {
 // Arrange, Act, Assert
 }
}
```

---

## Workflow with Copilot Edits

To implement features quickly with Copilot:

1. **Select the relevant files** in VS Code (Ctrl+click)
2. **Open Copilot Edits** (Ctrl+Shift+I)
3. **Describe the change** in natural language:
 > "Add a PUT /api/v1/beneficiaries/{id}/status endpoint that allows
 > changing the beneficiary's status. Validate that the status transition is valid
 > (ACTIVE -> SUSPENDED is allowed, INACTIVE -> ACTIVE is not). Create the test."
4. **Review the diff** before accepting — verify it follows the architecture
5. **Run the tests** to confirm

---

## Tests

### Run all tests

```bash
cd 04-prototipo-sifap-moderno/backend
./mvnw test
```

### Requirements

- **Docker must be running** — the tests use Testcontainers to spin up a real PostgreSQL
- Java 21 installed (or use the DevContainer)

### Expected test types

| Type | Where | What it tests |
|------|-------|---------------|
| Unit | `*ServiceTest.java` | Isolated business logic |
| Integration | `*ControllerTest.java` | Full endpoint (HTTP -> DB) |
| Repository | `*RepositoryTest.java` | Custom queries |

---

## Frontend

### Run the frontend locally

```bash
cd 04-prototipo-sifap-moderno/frontend
npm install
npm run dev
```

Open http://localhost:3000

### Frontend Architecture

The frontend uses **Next.js 15 with App Router** and **Server Components**:

```
src/app/
|-- layout.tsx # Root layout
|-- page.tsx # Home page
|-- (auth)/
| |-- login/page.tsx # Login page
|-- (dashboard)/
| |-- beneficiaries/ # Beneficiary CRUD
| |-- payments/ # Payment CRUD
| |-- audit/ # Audit logs
| |-- admin/ # User management
```

### Server Components pattern

- **Server Components** (default): Fetch data on the server, with no JavaScript on the client
- **Client Components** (`"use client"`): Only when interactivity is needed (forms, modals)

---

---

## Traceability: Requirement → Code → Test

For every feature you implement, keep traceability with the spec:

| EARS Requirement | Code | Test |
|------------------|------|------|
| REQ-BEN-01: "The SIFAP shall validate CPF with modulo-11" | `Cpf.java` (domain) | `CpfTest.java` - 11 tests |
| REQ-PAY-03: "When a cycle is generated, create payments for ACTIVE beneficiaries" | `PaymentCycleService.generate()` | `PaymentCycleServiceTest.generate_openCycle` |
| REQ-AUD-01: "When an entity is changed, write an audit record" | `AuditService.record()` | `SifapApplicationIntegrationTest` |

When you add a feature, document it in your commit: "Implements REQ-XXX". This closes the spec → code → test loop.

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `docker compose up` fails | Check: Docker Desktop running? Ports 5432/8080/3000 free? Try `docker compose down && docker compose up -d` |
| Backend does not connect to PostgreSQL | Check that the postgres container is healthy: `docker compose ps` |
| Frontend shows "Failed to load" | Is the backend running? Test: `curl http://localhost:8080/actuator/health` |
| Login returns "Invalid credentials" | Use: admin / client2026. Check that V4__auth.sql ran (Flyway) |
| Test fails with Testcontainers | Docker Desktop must be running. Alternative: unit test with Mockito |
| Migration fails on startup | NEVER edit an existing migration. Create a new one (V5__, V6__...) |
| `mvn test-compile` import error | Check that the package follows the structure: domain/ → application/ → infrastructure/ |
| Swagger UI does not appear | Try: http://localhost:8080/swagger-ui/index.html (alternative path) |

---

## Definition of Done

By the end of Stage 3, your team must have:

- [ ] Working backend with at least 2 new endpoints implemented
- [ ] Frontend with at least 1 new screen or significant improvement
- [ ] Tests passing: `./mvnw test` with no failures
- [ ] Working `docker compose up` — any reviewer can bring the system up
- [ ] Swagger UI showing all endpoints documented
- [ ] At least 1 business rule from Stage 1 implemented and tested

## Prompts for Copilot Chat

1. "Create a REST endpoint for [functionality] following the existing architecture"
2. "Write an integration test for the [endpoint] endpoint"
3. "Add Bean Validation to the DTO [class]"
4. "Create a Flyway migration to add [table/column]"
5. "Implement business rule BR-XXX: [rule description]"
6. "Create a React Server Component to list [entity]"
7. "Add error handling for the case of [scenario]"
8. "Refactor this service to separate the logic of [responsibility]"

## Golden Tip

Don't try to implement everything. Focus on **quality over quantity**. One well-built endpoint, with tests, validation, and documentation, is worth more than 5 broken endpoints.
