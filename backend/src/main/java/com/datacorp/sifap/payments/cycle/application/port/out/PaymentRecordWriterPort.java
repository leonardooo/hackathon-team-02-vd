package com.datacorp.sifap.payments.cycle.application.port.out;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

public interface PaymentRecordWriterPort {

    List<GeneratedPayment> writePayments(UUID paymentCycleId, List<GeneratedPaymentInput> entries);

    record GeneratedPaymentInput(UUID beneficiaryId, String competence, BigDecimal grossAmount, BigDecimal discountAmount, BigDecimal netAmount) {
    }

    record GeneratedPayment(UUID beneficiaryId, UUID paymentId) {
    }
}
