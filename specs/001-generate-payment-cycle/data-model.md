# Data Model: Generate Payment Cycle

## Entity: PaymentCycle

**Purpose**: Represents one operator-triggered generation run for a monthly competence.

**Fields**:
- `id`: UUID or numeric surrogate key
- `competence`: monthly reference in `YYYYMM` format
- `status`: `GENERATING`, `GENERATED`, `FAILED`, `CANCELLED`
- `initiatedBy`: operator identifier
- `generatedAt`: timestamp when generation completed
- `createdAt`: timestamp when request was accepted
- `includedCount`: number of included beneficiaries
- `excludedCount`: number of excluded beneficiaries
- `generationSummary`: short business-readable summary

**Validation rules**:
- `competence` must represent a valid monthly period
- only one active cycle may exist for the same `competence`
- `status` transitions must be monotonic and auditable

**Relationships**:
- one `PaymentCycle` has many `PaymentCycleEntry`
- one `PaymentCycle` has many `GenerationAuditRecord`

**State transitions**:
- `GENERATING` -> `GENERATED`
- `GENERATING` -> `FAILED`
- `GENERATED` -> `CANCELLED` only by an explicit future capability, not in current scope

## Entity: PaymentCycleEntry

**Purpose**: Stores the per-beneficiary outcome of a cycle generation run.

**Fields**:
- `id`: UUID or numeric surrogate key
- `paymentCycleId`: foreign key to `PaymentCycle`
- `beneficiaryId`: foreign key to beneficiary aggregate
- `beneficiaryCpf`: denormalized identifier for traceable review
- `programCode`: social program code
- `inclusionStatus`: `INCLUDED` or `EXCLUDED`
- `exclusionReasonCode`: nullable machine-readable reason
- `exclusionReasonText`: nullable operator-readable explanation
- `grossAmount`: nullable calculated gross amount
- `discountAmount`: nullable calculated discount amount
- `netAmount`: nullable calculated net amount
- `generatedPaymentId`: nullable reference to payment row created from this entry

**Validation rules**:
- `INCLUDED` entries must have calculated amounts and no exclusion reason
- `EXCLUDED` entries must have an exclusion reason
- each beneficiary can appear only once per cycle

**Relationships**:
- many `PaymentCycleEntry` rows belong to one `PaymentCycle`
- many entries reference one `Beneficiary`

## Entity: Beneficiary

**Purpose**: Operational representation of the legacy `BENEFICIARIO` DDM row used to determine eligibility and payment context.

**Fields relevant to this feature**:
- `id`
- `registrationNumber`
- `cpf`
- `fullName`
- `dateOfBirth`
- `programCode`
- `benefitStartDate`
- `benefitEndDate`
- `beneficiaryStatus`
- `statusReasonCode`
- `familyIncome`
- `familyMemberCount`
- `regionCode`
- `uf`

**Validation rules**:
- `cpf` must be unique and normalized
- `beneficiaryStatus` must map from legacy values such as `A`, `S`, `C`, `I`, `D`
- active eligibility for a competence requires status and temporal validity checks

## Entity: Payment

**Purpose**: Modern relational representation of the legacy `PAGAMENTO` DDM used for generated financial records.

**Fields relevant to this feature**:
- `id`
- `paymentNumber`
- `beneficiaryId`
- `programCode`
- `competence`
- `cycleNumber`
- `grossAmount`
- `discountTotal`
- `netAmount`
- `paymentStatus`
- `generatedDate`
- `bankCode`
- `agencyCode`
- `accountNumber`

**Validation rules**:
- one payment per beneficiary per competence per cycle
- amounts must be non-negative
- `paymentStatus` must start in generated/pending state for this feature

## Entity: GenerationAuditRecord

**Purpose**: Immutable log of cycle generation attempts and outcomes.

**Fields**:
- `id`
- `paymentCycleId`: nullable for blocked attempts before cycle creation
- `competence`
- `operatorId`
- `eventType`: `ATTEMPTED`, `GENERATED`, `BLOCKED_DUPLICATE`, `FAILED`
- `eventTimestamp`
- `details`

**Validation rules**:
- every generation request must produce at least one audit record
- audit records are append-only

## Derived Rules From Legacy Inputs

- `BATCHPGT.NSN` processes beneficiaries ordered by CPF and skips non-active records.
- Duplicate generation for the same competence must be prevented.
- Program status must be active for generation to continue.
- Payment entries must preserve the outcome snapshot used during generation.
