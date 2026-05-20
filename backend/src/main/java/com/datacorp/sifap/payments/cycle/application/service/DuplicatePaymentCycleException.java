package com.datacorp.sifap.payments.cycle.application.service;

public class DuplicatePaymentCycleException extends RuntimeException {
    public DuplicatePaymentCycleException(String competence) {
        super("A payment cycle already exists for competence " + competence);
    }
}
