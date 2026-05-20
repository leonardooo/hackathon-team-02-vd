package com.datacorp.sifap.payments.cycle.application.service;

import com.datacorp.sifap.payments.cycle.application.dto.PaymentCycleDetailDto;
import com.datacorp.sifap.payments.cycle.infrastructure.persistence.PaymentCycleRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
public class GetPaymentCycleDetailService {

    private final PaymentCycleRepository paymentCycleRepository;

    public GetPaymentCycleDetailService(PaymentCycleRepository paymentCycleRepository) {
        this.paymentCycleRepository = paymentCycleRepository;
    }

    @Transactional(readOnly = true)
    public PaymentCycleDetailDto get(UUID cycleId) {
        return paymentCycleRepository.findById(cycleId)
            .map(cycle -> new PaymentCycleDetailDto(
                cycle.getId(),
                cycle.getCompetence(),
                cycle.getStatus(),
                cycle.getIncludedCount(),
                cycle.getExcludedCount(),
                cycle.getCreatedAt(),
                cycle.getGeneratedAt(),
                cycle.getGenerationSummary(),
                cycle.getInitiatedBy()
            ))
            .orElseThrow();
    }
}
