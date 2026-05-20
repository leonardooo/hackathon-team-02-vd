---
description: "Implements a Spring REST controller from an OpenAPI endpoint definition, wiring it to the bounded context's services."
mode: agent
model: claude-sonnet-4-6
tools: ['codebase', 'search', 'editFiles', 'runCommands']
---

# /implement-rest-controller

## Goal

Generate a Spring Boot REST controller from an OpenAPI endpoint definition. The controller is a thin adapter — it validates input, delegates to a service, and returns the response. No business logic in the controller.

## When to Invoke

After the service layer for a bounded context exists, when the team is ready to expose it as a REST API.

## Pre-conditions

- `02-spec-moderna/openapi.yaml` exists with the endpoint definition
- The service class for the bounded context exists (or its interface)
- The request/response DTOs are defined (or will be generated as records)

## Inputs the Team Must Provide

- The endpoint to implement (method + path from openapi.yaml)
- The target bounded context and package
- The service class to delegate to

## What I Will Do

- Read the OpenAPI definition for the specified endpoint
- Generate a `@RestController` class with proper annotations
- Create request/response record DTOs with Jakarta Bean Validation
- Wire the controller to the service via constructor injection
- Add `@ControllerAdvice` error handling if not already present
- Run a build to verify compilation

## What I Will NOT Do

- Put business logic in the controller — it delegates to the service layer
- Skip input validation — every endpoint has `@Valid` on its request body
- Use `@Autowired` field injection — constructor injection only
- Hardcode error messages — use RFC 7807 ProblemDetail responses
- Fabricate endpoint behavior not defined in the OpenAPI spec

## Output Format

Java files:
1. Controller at `src/main/java/[package]/api/[Name]Controller.java`
2. Request/Response DTOs at `src/main/java/[package]/api/dto/[Name]Request.java` and `[Name]Response.java`
3. Global exception handler at `src/main/java/[package]/shared/exception/GlobalExceptionHandler.java` (if not exists)

## Definition of Done

- [ ] Controller compiles without errors
- [ ] OpenAPI `operationId` is referenced in Javadoc
- [ ] Request DTO has Jakarta Bean Validation annotations (`@NotNull`, `@Size`, etc.)
- [ ] Response uses proper HTTP status codes (201 for POST, 200 for GET, 204 for DELETE)
- [ ] No business logic in the controller body — only validation, delegation, response mapping
- [ ] Error responses use RFC 7807 `ProblemDetail`
- [ ] Related REQ-IDs are documented in Javadoc

## The Prompt Body

You are the `@builder-agent`. The team needs a REST controller for an endpoint defined in the OpenAPI spec.

**Step 1 — Read the OpenAPI definition.**
Open `02-spec-moderna/openapi.yaml`. Find the specified endpoint. Extract:
- HTTP method and path
- Operation ID and summary
- Request body schema (if any)
- Response schema
- Path/query parameters
- Related REQ-IDs (from the description or tags)

**Step 2 — Generate request/response records.**
Create Java records for the request and response:

```java
public record CreatePaymentRequest(
    @NotNull @Positive BigDecimal amount,
    @NotNull LocalDate dueDate,
    @Size(max = 200) String description
) {}

public record PaymentResponse(
    Long id,
    BigDecimal amount,
    LocalDate dueDate,
    String status
) {}
```

Use Jakarta Bean Validation annotations based on the field types and any constraints in the OpenAPI schema.

**Step 3 — Generate the controller.**
Create the controller class:

```java
@RestController
@RequestMapping("/api/v1/[context]")
@Tag(name = "[Context]", description = "[from OpenAPI]")
public class [Name]Controller {

    private final [Service] service;

    public [Name]Controller([Service] service) {
        this.service = service;
    }

    /**
     * [Operation summary from OpenAPI].
     *
     * <p>OpenAPI operationId: {@code [operationId]}</p>
     * <p>Implements: REQ-NNN</p>
     */
    @PostMapping  // or @GetMapping, etc.
    @Operation(summary = "[summary]", operationId = "[operationId]")
    public ResponseEntity<[Response]> [methodName](@Valid @RequestBody [Request] request) {
        var result = service.[method](/* map request to domain */);
        return ResponseEntity.status(HttpStatus.CREATED).body(/* map domain to response */);
    }
}
```

**Step 4 — Ensure error handling exists.**
Check if `GlobalExceptionHandler` exists in the shared package. If not, generate it with handlers for:
- `MethodArgumentNotValidException` → 400 with validation details
- `EntityNotFoundException` → 404
- `IllegalStateException` → 409 (conflict)
- `Exception` → 500 (catch-all with safe error message, no stack trace exposed)

All error responses use `ProblemDetail` (RFC 7807).

**Step 5 — Verify compilation.**
Run `mvn compile` (or equivalent build command). Report any errors and fix them.

If the service interface does not yet exist, generate a minimal interface with the required method signature and a TODO implementation. The team fills in the logic.

## Example Invocation

```
/implement-rest-controller endpoint="POST /api/v1/payments" context=payment service=PaymentService
```
