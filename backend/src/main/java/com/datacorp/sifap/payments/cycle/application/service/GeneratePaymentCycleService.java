package com.datacorp.sifap.payments.cycle.application.service;

import com.datacorp.sifap.payments.cycle.application.dto.GeneratePaymentCycleCommand;
import com.datacorp.sifap.payments.cycle.application.dto.PaymentCycleSummaryDto;
import com.datacorp.sifap.payments.cycle.application.port.out.BeneficiaryEligibilityPort;
import com.datacorp.sifap.payments.cycle.application.port.out.PaymentRecordWriterPort;
import com.datacorp.sifap.payments.cycle.domain.model.GenerationAuditRecord;
import com.datacorp.sifap.payments.cycle.domain.model.InclusionStatus;
import com.datacorp.sifap.payments.cycle.domain.model.PaymentCycle;
import com.datacorp.sifap.payments.cycle.domain.model.PaymentCycleEntry;
import com.datacorp.sifap.payments.cycle.domain.model.PaymentCycleStatus;
import com.datacorp.sifap.payments.cycle.domain.service.PaymentCycleGenerationDomainService;
import com.datacorp.sifap.payments.cycle.infrastructure.persistence.GenerationAuditRecordRepository;
import com.datacorp.sifap.payments.cycle.infrastructure.persistence.PaymentCycleEntryRepository;
import com.datacorp.sifap.payments.cycle.infrastructure.persistence.PaymentCycleRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
public class GeneratePaymentCycleService {

    private static final Logger LOGGER = LoggerFactory.getLogger(GeneratePaymentCycleService.class);

    private final PaymentCycleRepository paymentCycleRepository;
    private final PaymentCycleEntryRepository paymentCycleEntryRepository;
    private final GenerationAuditRecordRepository generationAuditRecordRepository;
    private final BeneficiaryEligibilityPort beneficiaryEligibilityPort;
    private final PaymentRecordWriterPort paymentRecordWriterPort;
    private final PaymentCycleGenerationDomainService generationDomainService;

    public GeneratePaymentCycleService(
        PaymentCycleRepository paymentCycleRepository,
        PaymentCycleEntryRepository paymentCycleEntryRepository,
        GenerationAuditRecordRepository generationAuditRecordRepository,
        BeneficiaryEligibilityPort beneficiaryEligibilityPort,
        PaymentRecordWriterPort paymentRecordWriterPort,
        PaymentCycleGenerationDomainService generationDomainService
    ) {
        this.paymentCycleRepository = paymentCycleRepository;
        this.paymentCycleEntryRepository = paymentCycleEntryRepository;
        this.generationAuditRecordRepository = generationAuditRecordRepository;
        this.beneficiaryEligibilityPort = beneficiaryEligibilityPort;
        this.paymentRecordWriterPort = paymentRecordWriterPort;
        this.generationDomainService = generationDomainService;
    }

    @Transactional
    public PaymentCycleSummaryDto generate(GeneratePaymentCycleCommand command) {
        paymentCycleRepository
            .findByCompetenceAndStatusIn(command.competence(), List.of(PaymentCycleStatus.GENERATING, PaymentCycleStatus.GENERATED))
            .ifPresent(existing -> {
                generationAuditRecordRepository.save(
                    GenerationAuditRecord.blockedDuplicate(command.competence(), command.initiatedBy(), existing.getId())
                );
                throw new DuplicatePaymentCycleException(command.competence());
            });

        PaymentCycle cycle = new PaymentCycle(UUID.randomUUID(), command.competence(), command.initiatedBy());
        paymentCycleRepository.save(cycle);
        generationAuditRecordRepository.save(
            GenerationAuditRecord.event(cycle.getId(), command.competence(), command.initiatedBy(), "ATTEMPTED", "Cycle generation requested")
        );

        List<BeneficiaryEligibilityPort.Candidate> candidates = beneficiaryEligibilityPort.listCandidatesForCompetence(command.competence());
        List<PaymentCycleEntry> entries = generationDomainService.buildEntries(cycle.getId(), candidates);
        paymentCycleEntryRepository.saveAll(entries);

        List<PaymentRecordWriterPort.GeneratedPaymentInput> includedEntries = entries.stream()
            .filter(entry -> entry.getInclusionStatus() == InclusionStatus.INCLUDED)
            .map(entry -> new PaymentRecordWriterPort.GeneratedPaymentInput(
                entry.getBeneficiaryId(),
                command.competence(),
                entry.getGrossAmount(),
                entry.getDiscountAmount(),
                entry.getNetAmount()
            ))
            .toList();
        paymentRecordWriterPort.writePayments(cycle.getId(), includedEntries);

        int includedCount = (int) entries.stream().filter(entry -> entry.getInclusionStatus() == InclusionStatus.INCLUDED).count();
        int excludedCount = entries.size() - includedCount;
        cycle.markGenerated(includedCount, excludedCount, "Cycle generation completed");
        paymentCycleRepository.save(cycle);

        generationAuditRecordRepository.save(
            GenerationAuditRecord.event(cycle.getId(), command.competence(), command.initiatedBy(), "GENERATED", "Cycle generated successfully")
        );

        LOGGER.info("Payment cycle generated competence={} included={} excluded={}", maskCompetence(command.competence()), includedCount, excludedCount);

        return new PaymentCycleSummaryDto(
            cycle.getId(),
            cycle.getCompetence(),
            cycle.getStatus(),
            cycle.getIncludedCount(),
            cycle.getExcludedCount(),
            cycle.getCreatedAt(),
            cycle.getGeneratedAt()
        );
    }

    private String maskCompetence(String competence) {
        if (competence.length() != 6) {
            return "******";
        }
        return "****" + competence.substring(4);
    }
}
