package com.datacorp.sifap.payments.cycle.application.port.out;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

public interface BeneficiaryEligibilityPort {

    List<Candidate> listCandidatesForCompetence(String competence);

    record Candidate(
        UUID beneficiaryId,
        String cpf,
        String programCode,
        boolean eligible,
        String exclusionReasonCode,
        String exclusionReasonText,
        BigDecimal grossAmount,
        BigDecimal discountAmount,
        BigDecimal netAmount
    ) {
    }
}
