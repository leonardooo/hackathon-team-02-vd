package com.datacorp.sifap.payments.cycle.application.dto;

import com.datacorp.sifap.payments.cycle.domain.model.InclusionStatus;

import java.math.BigDecimal;
import java.util.UUID;

public record PaymentCycleEntryDto(
    UUID beneficiaryId,
    String beneficiaryCpf,
    String programCode,
    InclusionStatus inclusionStatus,
    String exclusionReasonCode,
    String exclusionReasonText,
    BigDecimal grossAmount,
    BigDecimal discountAmount,
    BigDecimal netAmount
) {
}
