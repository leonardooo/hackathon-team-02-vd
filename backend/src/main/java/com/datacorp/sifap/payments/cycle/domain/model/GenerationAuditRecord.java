package com.datacorp.sifap.payments.cycle.domain.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "generation_audit_record")
public class GenerationAuditRecord {

    @Id
    private UUID id;

    @Column(name = "payment_cycle_id")
    private UUID paymentCycleId;

    @Column(nullable = false, length = 6)
    private String competence;

    @Column(name = "operator_id", nullable = false, length = 120)
    private String operatorId;

    @Column(name = "event_type", nullable = false, length = 40)
    private String eventType;

    @Column(name = "event_timestamp", nullable = false)
    private Instant eventTimestamp;

    @Column(length = 1000)
    private String details;

    protected GenerationAuditRecord() {
    }

    public static GenerationAuditRecord event(UUID cycleId, String competence, String operatorId, String eventType, String details) {
      GenerationAuditRecord record = new GenerationAuditRecord();
      record.id = UUID.randomUUID();
      record.paymentCycleId = cycleId;
      record.competence = competence;
      record.operatorId = operatorId;
      record.eventType = eventType;
      record.details = details;
      record.eventTimestamp = Instant.now();
      return record;
    }

    public static GenerationAuditRecord blockedDuplicate(String competence, String operatorId, UUID existingCycleId) {
      return event(
          existingCycleId,
          competence,
          operatorId,
          "BLOCKED_DUPLICATE",
          "Duplicate generation blocked for competence"
      );
    }
}
