package com.datacorp.sifap.payments.cycle.infrastructure.persistence;

import com.datacorp.sifap.payments.cycle.application.port.out.PaymentRecordWriterPort;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.UUID;

@Component
public class PaymentRecordJpaAdapter implements PaymentRecordWriterPort {

    @Override
    public List<GeneratedPayment> writePayments(UUID paymentCycleId, List<GeneratedPaymentInput> entries) {
        return entries.stream()
            .map(entry -> new GeneratedPayment(entry.beneficiaryId(), UUID.randomUUID()))
            .toList();
    }
}
