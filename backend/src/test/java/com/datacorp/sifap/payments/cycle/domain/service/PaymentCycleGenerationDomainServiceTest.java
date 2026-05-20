package com.datacorp.sifap.payments.cycle.domain.service;

import com.datacorp.sifap.payments.cycle.application.port.out.BeneficiaryEligibilityPort;
import com.datacorp.sifap.payments.cycle.domain.model.InclusionStatus;
import com.datacorp.sifap.payments.cycle.domain.model.PaymentCycleEntry;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

class PaymentCycleGenerationDomainServiceTest {

    private PaymentCycleGenerationDomainService domainService;

    @BeforeEach
    void setUp() {
        domainService = new PaymentCycleGenerationDomainService();
    }

    @Test
    void shouldBuildIncludedEntryForEligibleCandidate() {
        UUID cycleId = UUID.randomUUID();
        List<BeneficiaryEligibilityPort.Candidate> candidates = List.of(
            new BeneficiaryEligibilityPort.Candidate(
                UUID.randomUUID(), "52998224725", "BPC", true,
                null, null,
                BigDecimal.valueOf(1412.00), BigDecimal.ZERO, BigDecimal.valueOf(1412.00)
            )
        );

        List<PaymentCycleEntry> entries = domainService.buildEntries(cycleId, candidates);

        assertEquals(1, entries.size());
        assertEquals(InclusionStatus.INCLUDED, entries.getFirst().getInclusionStatus());
        assertEquals(cycleId, entries.getFirst().getPaymentCycleId());
    }

    @Test
    void shouldBuildExcludedEntryForIneligibleCandidate() {
        UUID cycleId = UUID.randomUUID();
        List<BeneficiaryEligibilityPort.Candidate> candidates = List.of(
            new BeneficiaryEligibilityPort.Candidate(
                UUID.randomUUID(), "52998224725", "BPC", false,
                "INACTIVE", "Beneficiary inactive",
                BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO
            )
        );

        List<PaymentCycleEntry> entries = domainService.buildEntries(cycleId, candidates);

        assertEquals(1, entries.size());
        assertEquals(InclusionStatus.EXCLUDED, entries.getFirst().getInclusionStatus());
        assertEquals("INACTIVE", entries.getFirst().getExclusionReasonCode());
    }

    @Test
    void shouldHandleMixedEligibilityList() {
        UUID cycleId = UUID.randomUUID();
        List<BeneficiaryEligibilityPort.Candidate> candidates = List.of(
            new BeneficiaryEligibilityPort.Candidate(
                UUID.randomUUID(), "11111111111", "BPC", true,
                null, null,
                BigDecimal.valueOf(1000.00), BigDecimal.ZERO, BigDecimal.valueOf(1000.00)
            ),
            new BeneficiaryEligibilityPort.Candidate(
                UUID.randomUUID(), "22222222222", "BPC", false,
                "SUSPENDED", "Beneficiary suspended",
                BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO
            ),
            new BeneficiaryEligibilityPort.Candidate(
                UUID.randomUUID(), "33333333333", "PBF", true,
                null, null,
                BigDecimal.valueOf(600.00), BigDecimal.valueOf(50.00), BigDecimal.valueOf(550.00)
            )
        );

        List<PaymentCycleEntry> entries = domainService.buildEntries(cycleId, candidates);

        assertEquals(3, entries.size());
        long included = entries.stream().filter(e -> e.getInclusionStatus() == InclusionStatus.INCLUDED).count();
        long excluded = entries.stream().filter(e -> e.getInclusionStatus() == InclusionStatus.EXCLUDED).count();
        assertEquals(2, included);
        assertEquals(1, excluded);
    }

    @Test
    void shouldReturnEmptyListForNoCandidates() {
        UUID cycleId = UUID.randomUUID();

        List<PaymentCycleEntry> entries = domainService.buildEntries(cycleId, List.of());

        assertTrue(entries.isEmpty());
    }
}
