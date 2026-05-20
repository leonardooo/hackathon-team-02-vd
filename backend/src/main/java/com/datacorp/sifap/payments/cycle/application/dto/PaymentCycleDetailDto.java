package com.datacorp.sifap.payments.cycle.application.dto;

import com.datacorp.sifap.payments.cycle.domain.model.PaymentCycleStatus;

import java.time.Instant;
import java.util.UUID;

public record PaymentCycleDetailDto(
    UUID id,
    String competence,
    PaymentCycleStatus status,
    int includedCount,
    int excludedCount,
    Instant createdAt,
    Instant generatedAt,
    String generationSummary,
    String initiatedBy
) {
}
