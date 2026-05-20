package com.datacorp.sifap.payments.cycle.domain.model;

import org.junit.jupiter.api.Test;

import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

class PaymentCycleTest {

    @Test
    void shouldCreateCycleWithGeneratingStatus() {
        UUID id = UUID.randomUUID();
        PaymentCycle cycle = new PaymentCycle(id, "202605", "operator");

        assertEquals(id, cycle.getId());
        assertEquals("202605", cycle.getCompetence());
        assertEquals("operator", cycle.getInitiatedBy());
        assertEquals(PaymentCycleStatus.GENERATING, cycle.getStatus());
        assertNotNull(cycle.getCreatedAt());
        assertNull(cycle.getGeneratedAt());
        assertEquals(0, cycle.getIncludedCount());
        assertEquals(0, cycle.getExcludedCount());
    }

    @Test
    void shouldTransitionToGeneratedStatus() {
        PaymentCycle cycle = new PaymentCycle(UUID.randomUUID(), "202605", "operator");

        cycle.markGenerated(80, 20, "Completed successfully");

        assertEquals(PaymentCycleStatus.GENERATED, cycle.getStatus());
        assertNotNull(cycle.getGeneratedAt());
        assertEquals(80, cycle.getIncludedCount());
        assertEquals(20, cycle.getExcludedCount());
        assertEquals("Completed successfully", cycle.getGenerationSummary());
    }

    @Test
    void shouldTransitionToFailedStatus() {
        PaymentCycle cycle = new PaymentCycle(UUID.randomUUID(), "202605", "operator");

        cycle.markFailed("Database connection timeout");

        assertEquals(PaymentCycleStatus.FAILED, cycle.getStatus());
        assertEquals("Database connection timeout", cycle.getGenerationSummary());
    }
}
