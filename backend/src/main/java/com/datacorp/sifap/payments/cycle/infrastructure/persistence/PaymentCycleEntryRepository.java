package com.datacorp.sifap.payments.cycle.infrastructure.persistence;

import com.datacorp.sifap.payments.cycle.domain.model.InclusionStatus;
import com.datacorp.sifap.payments.cycle.domain.model.PaymentCycleEntry;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface PaymentCycleEntryRepository extends JpaRepository<PaymentCycleEntry, UUID> {
    List<PaymentCycleEntry> findByPaymentCycleId(UUID paymentCycleId);
    List<PaymentCycleEntry> findByPaymentCycleIdAndInclusionStatus(UUID paymentCycleId, InclusionStatus inclusionStatus);
}
