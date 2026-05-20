package com.datacorp.sifap.payments.cycle.application.service;

import com.datacorp.sifap.payments.cycle.application.dto.PaymentCycleSummaryDto;
import com.datacorp.sifap.payments.cycle.infrastructure.persistence.PaymentCycleRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class ListPaymentCyclesService {

    private final PaymentCycleRepository paymentCycleRepository;

    public ListPaymentCyclesService(PaymentCycleRepository paymentCycleRepository) {
        this.paymentCycleRepository = paymentCycleRepository;
    }

    @Transactional(readOnly = true)
    public List<PaymentCycleSummaryDto> list(String competence) {
        return paymentCycleRepository.findAll().stream()
            .filter(cycle -> competence == null || competence.isBlank() || competence.equals(cycle.getCompetence()))
            .map(cycle -> new PaymentCycleSummaryDto(
                cycle.getId(),
                cycle.getCompetence(),
                cycle.getStatus(),
                cycle.getIncludedCount(),
                cycle.getExcludedCount(),
                cycle.getCreatedAt(),
                cycle.getGeneratedAt()
            ))
            .toList();
    }
}
