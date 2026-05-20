package com.datacorp.sifap.payments.cycle.domain.service;

import com.datacorp.sifap.payments.cycle.application.port.out.BeneficiaryEligibilityPort;
import com.datacorp.sifap.payments.cycle.domain.model.PaymentCycleEntry;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@Service
public class PaymentCycleGenerationDomainService {

    public List<PaymentCycleEntry> buildEntries(UUID cycleId, List<BeneficiaryEligibilityPort.Candidate> candidates) {
        return candidates.stream()
            .map(candidate -> candidate.eligible()
                ? PaymentCycleEntry.included(
                    cycleId,
                    candidate.beneficiaryId(),
                    candidate.cpf(),
                    candidate.programCode(),
                    candidate.grossAmount(),
                    candidate.discountAmount(),
                    candidate.netAmount()
                )
                : PaymentCycleEntry.excluded(
                    cycleId,
                    candidate.beneficiaryId(),
                    candidate.cpf(),
                    candidate.programCode(),
                    candidate.exclusionReasonCode(),
                    candidate.exclusionReasonText()
                )
            )
            .toList();
    }
}
