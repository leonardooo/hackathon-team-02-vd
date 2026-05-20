package com.datacorp.sifap.payments.cycle.domain.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "payment_cycle")
public class PaymentCycle {

    @Id
    private UUID id;

    @Column(nullable = false, length = 6)
    private String competence;

    @Column(nullable = false, length = 20)
    private PaymentCycleStatus status;

    @Column(name = "initiated_by", nullable = false, length = 120)
    private String initiatedBy;

    @Column(name = "generated_at")
    private Instant generatedAt;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt;

    @Column(name = "included_count", nullable = false)
    private int includedCount;

    @Column(name = "excluded_count", nullable = false)
    private int excludedCount;

    @Column(name = "generation_summary", length = 500)
    private String generationSummary;

    protected PaymentCycle() {
    }

    public PaymentCycle(UUID id, String competence, String initiatedBy) {
      this.id = id;
      this.competence = competence;
      this.initiatedBy = initiatedBy;
      this.status = PaymentCycleStatus.GENERATING;
      this.createdAt = Instant.now();
    }

    public UUID getId() {
      return id;
    }

    public String getCompetence() {
      return competence;
    }

    public PaymentCycleStatus getStatus() {
      return status;
    }

    public String getInitiatedBy() {
      return initiatedBy;
    }

    public Instant getGeneratedAt() {
      return generatedAt;
    }

    public Instant getCreatedAt() {
      return createdAt;
    }

    public int getIncludedCount() {
      return includedCount;
    }

    public int getExcludedCount() {
      return excludedCount;
    }

    public String getGenerationSummary() {
      return generationSummary;
    }

    public void markGenerated(int includedCount, int excludedCount, String summary) {
      this.status = PaymentCycleStatus.GENERATED;
      this.generatedAt = Instant.now();
      this.includedCount = includedCount;
      this.excludedCount = excludedCount;
      this.generationSummary = summary;
    }

    public void markFailed(String summary) {
      this.status = PaymentCycleStatus.FAILED;
      this.generationSummary = summary;
    }
}
