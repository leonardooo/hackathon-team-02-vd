package com.datacorp.sifap.payments.cycle.application.service;

import com.datacorp.sifap.payments.cycle.application.dto.PaymentCycleEntryDto;
import com.datacorp.sifap.payments.cycle.domain.model.InclusionStatus;
import com.datacorp.sifap.payments.cycle.infrastructure.persistence.PaymentCycleEntryRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
public class ListPaymentCycleEntriesService {

    private final PaymentCycleEntryRepository paymentCycleEntryRepository;

    public ListPaymentCycleEntriesService(PaymentCycleEntryRepository paymentCycleEntryRepository) {
        this.paymentCycleEntryRepository = paymentCycleEntryRepository;
    }

    @Transactional(readOnly = true)
    public List<PaymentCycleEntryDto> list(UUID cycleId, InclusionStatus inclusionStatus) {
        return (inclusionStatus == null
            ? paymentCycleEntryRepository.findByPaymentCycleId(cycleId)
            : paymentCycleEntryRepository.findByPaymentCycleIdAndInclusionStatus(cycleId, inclusionStatus))
            .stream()
            .map(entry -> new PaymentCycleEntryDto(
                entry.getBeneficiaryId(),
                entry.getBeneficiaryCpf(),
                entry.getProgramCode(),
                entry.getInclusionStatus(),
                entry.getExclusionReasonCode(),
                entry.getExclusionReasonText(),
                entry.getGrossAmount(),
                entry.getDiscountAmount(),
                entry.getNetAmount()
            ))
            .toList();
    }
}
