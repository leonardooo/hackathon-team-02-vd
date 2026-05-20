package com.datacorp.sifap.payments.cycle.application.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

public record GeneratePaymentCycleCommand(
    @NotBlank @Pattern(regexp = "^[0-9]{6}$") String competence,
    @NotBlank String initiatedBy,
    boolean dryRun
) {
}
