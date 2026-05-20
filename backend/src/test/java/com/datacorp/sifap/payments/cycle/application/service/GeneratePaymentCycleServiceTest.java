package com.datacorp.sifap.payments.cycle.application.service;

import com.datacorp.sifap.payments.cycle.application.dto.GeneratePaymentCycleCommand;
import com.datacorp.sifap.payments.cycle.application.dto.PaymentCycleSummaryDto;
import com.datacorp.sifap.payments.cycle.application.port.out.BeneficiaryEligibilityPort;
import com.datacorp.sifap.payments.cycle.application.port.out.PaymentRecordWriterPort;
import com.datacorp.sifap.payments.cycle.domain.model.GenerationAuditRecord;
import com.datacorp.sifap.payments.cycle.domain.model.PaymentCycle;
import com.datacorp.sifap.payments.cycle.domain.model.PaymentCycleEntry;
import com.datacorp.sifap.payments.cycle.domain.model.PaymentCycleStatus;
import com.datacorp.sifap.payments.cycle.domain.service.PaymentCycleGenerationDomainService;
import com.datacorp.sifap.payments.cycle.infrastructure.persistence.GenerationAuditRecordRepository;
import com.datacorp.sifap.payments.cycle.infrastructure.persistence.PaymentCycleEntryRepository;
import com.datacorp.sifap.payments.cycle.infrastructure.persistence.PaymentCycleRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class GeneratePaymentCycleServiceTest {

    @Mock private PaymentCycleRepository paymentCycleRepository;
    @Mock private PaymentCycleEntryRepository paymentCycleEntryRepository;
    @Mock private GenerationAuditRecordRepository generationAuditRecordRepository;
    @Mock private BeneficiaryEligibilityPort beneficiaryEligibilityPort;
    @Mock private PaymentRecordWriterPort paymentRecordWriterPort;

    private GeneratePaymentCycleService service;

    @BeforeEach
    void setUp() {
        PaymentCycleGenerationDomainService domainService = new PaymentCycleGenerationDomainService();
        service = new GeneratePaymentCycleService(
            paymentCycleRepository,
            paymentCycleEntryRepository,
            generationAuditRecordRepository,
            beneficiaryEligibilityPort,
            paymentRecordWriterPort,
            domainService
        );
    }

    @Test
    void shouldGenerateCycleSuccessfully() {
        GeneratePaymentCycleCommand command = new GeneratePaymentCycleCommand("202605", "operator", false);

        when(paymentCycleRepository.findByCompetenceAndStatusIn(eq("202605"), anyList()))
            .thenReturn(Optional.empty());
        when(paymentCycleRepository.save(any(PaymentCycle.class)))
            .thenAnswer(invocation -> invocation.getArgument(0));

        List<BeneficiaryEligibilityPort.Candidate> candidates = List.of(
            new BeneficiaryEligibilityPort.Candidate(
                UUID.randomUUID(), "52998224725", "BPC", true,
                null, null,
                BigDecimal.valueOf(1412.00), BigDecimal.ZERO, BigDecimal.valueOf(1412.00)
            )
        );
        when(beneficiaryEligibilityPort.listCandidatesForCompetence("202605")).thenReturn(candidates);
        when(paymentRecordWriterPort.writePayments(any(), anyList())).thenReturn(List.of());

        PaymentCycleSummaryDto result = service.generate(command);

        assertNotNull(result);
        assertEquals("202605", result.competence());
        assertEquals(PaymentCycleStatus.GENERATED, result.status());
        assertEquals(1, result.includedCount());
        assertEquals(0, result.excludedCount());

        verify(paymentCycleRepository, times(2)).save(any(PaymentCycle.class));
        verify(paymentCycleEntryRepository).saveAll(anyList());
        verify(generationAuditRecordRepository, times(2)).save(any(GenerationAuditRecord.class));
    }

    @Test
    void shouldThrowDuplicateExceptionWhenCycleExists() {
        GeneratePaymentCycleCommand command = new GeneratePaymentCycleCommand("202605", "operator", false);

        PaymentCycle existing = new PaymentCycle(UUID.randomUUID(), "202605", "other-operator");
        when(paymentCycleRepository.findByCompetenceAndStatusIn(eq("202605"), anyList()))
            .thenReturn(Optional.of(existing));

        assertThrows(DuplicatePaymentCycleException.class, () -> service.generate(command));

        verify(generationAuditRecordRepository).save(any(GenerationAuditRecord.class));
        verify(paymentCycleEntryRepository, never()).saveAll(anyList());
    }

    @Test
    void shouldHandleMixedEligibilityResults() {
        GeneratePaymentCycleCommand command = new GeneratePaymentCycleCommand("202606", "admin", false);

        when(paymentCycleRepository.findByCompetenceAndStatusIn(eq("202606"), anyList()))
            .thenReturn(Optional.empty());
        when(paymentCycleRepository.save(any(PaymentCycle.class)))
            .thenAnswer(invocation -> invocation.getArgument(0));

        List<BeneficiaryEligibilityPort.Candidate> candidates = List.of(
            new BeneficiaryEligibilityPort.Candidate(
                UUID.randomUUID(), "11111111111", "BPC", true,
                null, null,
                BigDecimal.valueOf(1000.00), BigDecimal.ZERO, BigDecimal.valueOf(1000.00)
            ),
            new BeneficiaryEligibilityPort.Candidate(
                UUID.randomUUID(), "22222222222", "BPC", false,
                "INACTIVE", "Inactive beneficiary",
                BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO
            )
        );
        when(beneficiaryEligibilityPort.listCandidatesForCompetence("202606")).thenReturn(candidates);
        when(paymentRecordWriterPort.writePayments(any(), anyList())).thenReturn(List.of());

        PaymentCycleSummaryDto result = service.generate(command);

        assertEquals(1, result.includedCount());
        assertEquals(1, result.excludedCount());
    }

    @Test
    void shouldWriteOnlyIncludedEntriesToPaymentPort() {
        GeneratePaymentCycleCommand command = new GeneratePaymentCycleCommand("202607", "operator", false);

        when(paymentCycleRepository.findByCompetenceAndStatusIn(eq("202607"), anyList()))
            .thenReturn(Optional.empty());
        when(paymentCycleRepository.save(any(PaymentCycle.class)))
            .thenAnswer(invocation -> invocation.getArgument(0));

        List<BeneficiaryEligibilityPort.Candidate> candidates = List.of(
            new BeneficiaryEligibilityPort.Candidate(
                UUID.randomUUID(), "11111111111", "BPC", true,
                null, null,
                BigDecimal.valueOf(500.00), BigDecimal.valueOf(50.00), BigDecimal.valueOf(450.00)
            ),
            new BeneficiaryEligibilityPort.Candidate(
                UUID.randomUUID(), "22222222222", "BPC", false,
                "DOCS_INVALID", "Missing documents",
                BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO
            )
        );
        when(beneficiaryEligibilityPort.listCandidatesForCompetence("202607")).thenReturn(candidates);
        when(paymentRecordWriterPort.writePayments(any(), anyList())).thenReturn(List.of());

        service.generate(command);

        @SuppressWarnings("unchecked")
        ArgumentCaptor<List<PaymentRecordWriterPort.GeneratedPaymentInput>> captor =
            ArgumentCaptor.forClass(List.class);
        verify(paymentRecordWriterPort).writePayments(any(), captor.capture());

        List<PaymentRecordWriterPort.GeneratedPaymentInput> writtenPayments = captor.getValue();
        assertEquals(1, writtenPayments.size());
        assertEquals(0, BigDecimal.valueOf(450.00).compareTo(writtenPayments.getFirst().netAmount()));
    }
}
