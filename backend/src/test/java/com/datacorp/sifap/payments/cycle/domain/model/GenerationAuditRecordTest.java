package com.datacorp.sifap.payments.cycle.domain.model;

import org.junit.jupiter.api.Test;

import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

class GenerationAuditRecordTest {

    @Test
    void shouldCreateEventRecord() {
        UUID cycleId = UUID.randomUUID();
        GenerationAuditRecord record = GenerationAuditRecord.event(
            cycleId, "202605", "operator", "ATTEMPTED", "Cycle generation requested"
        );

        assertNotNull(record);
    }

    @Test
    void shouldCreateBlockedDuplicateRecord() {
        UUID existingCycleId = UUID.randomUUID();
        GenerationAuditRecord record = GenerationAuditRecord.blockedDuplicate(
            "202605", "operator", existingCycleId
        );

        assertNotNull(record);
    }
}
