package com.datacorp.sifap.payments.cycle.domain.model;

import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

class PaymentCycleEntryTest {

    private static final UUID CYCLE_ID = UUID.randomUUID();
    private static final UUID BENEFICIARY_ID = UUID.randomUUID();

    @Test
    void shouldCreateIncludedEntry() {
        PaymentCycleEntry entry = PaymentCycleEntry.included(
            CYCLE_ID, BENEFICIARY_ID, "52998224725", "BPC",
            BigDecimal.valueOf(1412.00), BigDecimal.valueOf(100.00), BigDecimal.valueOf(1312.00)
        );

        assertNotNull(entry.getId());
        assertEquals(CYCLE_ID, entry.getPaymentCycleId());
        assertEquals(BENEFICIARY_ID, entry.getBeneficiaryId());
        assertEquals("52998224725", entry.getBeneficiaryCpf());
        assertEquals("BPC", entry.getProgramCode());
        assertEquals(InclusionStatus.INCLUDED, entry.getInclusionStatus());
        assertEquals(0, BigDecimal.valueOf(1412.00).compareTo(entry.getGrossAmount()));
        assertEquals(0, BigDecimal.valueOf(100.00).compareTo(entry.getDiscountAmount()));
        assertEquals(0, BigDecimal.valueOf(1312.00).compareTo(entry.getNetAmount()));
        assertNull(entry.getExclusionReasonCode());
    }

    @Test
    void shouldCreateExcludedEntry() {
        PaymentCycleEntry entry = PaymentCycleEntry.excluded(
            CYCLE_ID, BENEFICIARY_ID, "52998224725", "BPC",
            "INACTIVE", "Beneficiary is inactive"
        );

        assertEquals(InclusionStatus.EXCLUDED, entry.getInclusionStatus());
        assertEquals("INACTIVE", entry.getExclusionReasonCode());
        assertEquals("Beneficiary is inactive", entry.getExclusionReasonText());
        assertNull(entry.getGrossAmount());
        assertNull(entry.getNetAmount());
    }

    // REQ-PAG-005: net amount floor at zero
    @Test
    void shouldFloorNetAmountAtZeroWhenNegative() {
        PaymentCycleEntry entry = PaymentCycleEntry.included(
            CYCLE_ID, BENEFICIARY_ID, "52998224725", "BPC",
            BigDecimal.valueOf(100.00), BigDecimal.valueOf(150.00), BigDecimal.valueOf(-50.00)
        );

        assertEquals(0, BigDecimal.ZERO.compareTo(entry.getNetAmount()));
    }

    // REQ-PAG-005: positive net amount is preserved
    @Test
    void shouldPreservePositiveNetAmount() {
        PaymentCycleEntry entry = PaymentCycleEntry.included(
            CYCLE_ID, BENEFICIARY_ID, "52998224725", "BPC",
            BigDecimal.valueOf(100.00), BigDecimal.valueOf(80.00), BigDecimal.valueOf(20.00)
        );

        assertEquals(0, BigDecimal.valueOf(20.00).compareTo(entry.getNetAmount()));
    }

    @Test
    void shouldPreserveZeroNetAmount() {
        PaymentCycleEntry entry = PaymentCycleEntry.included(
            CYCLE_ID, BENEFICIARY_ID, "52998224725", "BPC",
            BigDecimal.valueOf(100.00), BigDecimal.valueOf(100.00), BigDecimal.ZERO
        );

        assertEquals(0, BigDecimal.ZERO.compareTo(entry.getNetAmount()));
    }
}
