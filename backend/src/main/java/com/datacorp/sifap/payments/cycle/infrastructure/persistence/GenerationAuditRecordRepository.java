package com.datacorp.sifap.payments.cycle.infrastructure.persistence;

import com.datacorp.sifap.payments.cycle.domain.model.GenerationAuditRecord;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface GenerationAuditRecordRepository extends JpaRepository<GenerationAuditRecord, UUID> {
}
