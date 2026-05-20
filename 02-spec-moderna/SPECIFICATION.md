# SPECIFICATION - SIFAP 2.0 (Rascunho inicial Par 1 -> Par 2)

> Objetivo: entregar ao Par 2 um ponto de partida rastreavel para Stage 2.
> Todos os requisitos abaixo seguem EARS e incluem `source_legacy`.

**Time**: Team-02-VerdeDanadinho  
**Data**: 20/05/2026  
**Origem**: Handoff #1 (Arqueologia -> Especificacao)

---

## Requisitos EARS (seed)

```yaml
REQ-001:
  pattern: event-driven
  text: "When a beneficiary registration is submitted, the SIFAP shall accept only operation values I (create) or A (update)."
  source_legacy: legacy/natural-programs/CADBENEF.NSN#L99-L103
  acceptance: "Operation value X returns validation error; I and A are accepted."

REQ-002:
  pattern: event-driven
  text: "When a beneficiary is created or updated, the SIFAP shall validate CPF with modulo-11 and reject invalid values."
  source_legacy: legacy/natural-programs/CADBENEF.NSN#L105-L116; legacy/natural-programs/CADBENEF.NSN#L224-L270
  acceptance: "Invalid CPF returns 400; valid CPF proceeds."

REQ-003:
  pattern: event-driven
  text: "When a beneficiary is created, the SIFAP shall require birth date and reject empty value."
  source_legacy: legacy/natural-programs/CADBENEF.NSN#L125-L129
  acceptance: "Create payload without birth date returns 400."

REQ-004:
  pattern: unwanted-behavior
  text: "The SIFAP shall not create a beneficiary when CPF already exists."
  source_legacy: legacy/natural-programs/CADBENEF.NSN#L137-L147
  acceptance: "Create with existing CPF returns 409 conflict."

REQ-005:
  pattern: unwanted-behavior
  text: "The SIFAP shall not update a beneficiary when CPF is not found."
  source_legacy: legacy/natural-programs/CADBENEF.NSN#L149-L153
  acceptance: "Update with unknown CPF returns 404 not found."

REQ-006:
  pattern: state-driven
  text: "While beneficiary age is greater than 75 years at registration time, the SIFAP shall set status to S (suspended)."
  source_legacy: legacy/natural-programs/CADBENEF.NSN#L156-L169
  acceptance: "New beneficiary age 76 is persisted with status S."

REQ-007:
  pattern: state-driven
  text: "While beneficiary status is C or D, the SIFAP shall block dependent creation."
  source_legacy: legacy/natural-programs/CADDEPEND.NSN#L56-L60
  acceptance: "Titular status C or D and dependent create request returns business error."

REQ-008:
  pattern: event-driven
  text: "When adding dependents for one beneficiary, the SIFAP shall enforce the current legacy operational limit of 5 dependents."
  source_legacy: legacy/natural-programs/CADDEPEND.NSN#L63-L66
  acceptance: "5 dependents accepted; 6th dependent is rejected."

REQ-009:
  pattern: event-driven
  text: "When a dependent is created, the SIFAP shall accept only relationship codes FI, CO, IR, or OU."
  source_legacy: legacy/natural-programs/CADDEPEND.NSN#L84-L87
  acceptance: "Relationship XX returns validation error; FI/CO/IR/OU are accepted."

REQ-010:
  pattern: event-driven
  text: "When a social program is created, the SIFAP shall compute FATOR-K with formula 1 + (FATOR-REAJ * 0.347215) and persist active status A."
  source_legacy: legacy/natural-programs/CADPROG.NSN#L87-L103
  acceptance: "Given FATOR-REAJ=1.5, persisted FATOR-K equals 1.5208225 and status is A."

REQ-011:
  pattern: ubiquitous
  text: "The SIFAP shall authenticate API users with OAuth2/JWT."
  source_legacy: "[GREENFIELD] Legacy terminal auth does not satisfy modern web/API security requirements."
  acceptance: "Unauthenticated API request returns 401."
```

---

## Observacoes para o Par 2 (Arquitetura)

1. REQ-008 e REQ-009 devem ser reconciliados com divergencias de DDM identificadas no Stage 1.
2. REQ-010 exige ADR para parametrizacao futura da constante 0.347215.
3. Expandir este seed para cobrir batches (BATCHPGT/BATCHREL/BATCHCON) durante Stage 2.
