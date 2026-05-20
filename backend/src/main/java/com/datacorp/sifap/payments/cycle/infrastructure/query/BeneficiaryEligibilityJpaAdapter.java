package com.datacorp.sifap.payments.cycle.infrastructure.query;

import com.datacorp.sifap.payments.cycle.application.port.out.BeneficiaryEligibilityPort;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

@Component
public class BeneficiaryEligibilityJpaAdapter implements BeneficiaryEligibilityPort {

    @Override
    public List<Candidate> listCandidatesForCompetence(String competence) {
        // Placeholder adapter while beneficiary module integration is prepared.
        return List.of(
            new Candidate(
                UUID.randomUUID(),
                "00000000000",
                "BPC",
                true,
                null,
                null,
                BigDecimal.valueOf(1412.00),
                BigDecimal.ZERO,
                BigDecimal.valueOf(1412.00)
            )
        );
    }
}
