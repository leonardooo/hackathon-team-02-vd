package com.datacorp.sifap.payments.cycle.infrastructure.persistence;

import com.datacorp.sifap.payments.cycle.domain.model.PaymentCycle;
import com.datacorp.sifap.payments.cycle.domain.model.PaymentCycleStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface PaymentCycleRepository extends JpaRepository<PaymentCycle, UUID> {
    Optional<PaymentCycle> findByCompetenceAndStatusIn(String competence, List<PaymentCycleStatus> statuses);
}
