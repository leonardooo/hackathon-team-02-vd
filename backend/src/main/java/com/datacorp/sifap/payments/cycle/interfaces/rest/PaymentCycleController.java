package com.datacorp.sifap.payments.cycle.interfaces.rest;

import com.datacorp.sifap.payments.cycle.application.dto.GeneratePaymentCycleCommand;
import com.datacorp.sifap.payments.cycle.application.dto.PaymentCycleDetailDto;
import com.datacorp.sifap.payments.cycle.application.dto.PaymentCycleEntryDto;
import com.datacorp.sifap.payments.cycle.application.dto.PaymentCycleSummaryDto;
import com.datacorp.sifap.payments.cycle.application.service.DuplicatePaymentCycleException;
import com.datacorp.sifap.payments.cycle.application.service.GeneratePaymentCycleService;
import com.datacorp.sifap.payments.cycle.application.service.GetPaymentCycleDetailService;
import com.datacorp.sifap.payments.cycle.application.service.ListPaymentCycleEntriesService;
import com.datacorp.sifap.payments.cycle.application.service.ListPaymentCyclesService;
import com.datacorp.sifap.payments.cycle.domain.model.InclusionStatus;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ProblemDetail;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.NoSuchElementException;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/payment-cycles")
public class PaymentCycleController {

    private static final Logger LOGGER = LoggerFactory.getLogger(PaymentCycleController.class);

    private final GeneratePaymentCycleService generatePaymentCycleService;
    private final ListPaymentCyclesService listPaymentCyclesService;
    private final GetPaymentCycleDetailService getPaymentCycleDetailService;
    private final ListPaymentCycleEntriesService listPaymentCycleEntriesService;

    public PaymentCycleController(
        GeneratePaymentCycleService generatePaymentCycleService,
        ListPaymentCyclesService listPaymentCyclesService,
        GetPaymentCycleDetailService getPaymentCycleDetailService,
        ListPaymentCycleEntriesService listPaymentCycleEntriesService
    ) {
        this.generatePaymentCycleService = generatePaymentCycleService;
        this.listPaymentCyclesService = listPaymentCyclesService;
        this.getPaymentCycleDetailService = getPaymentCycleDetailService;
        this.listPaymentCycleEntriesService = listPaymentCycleEntriesService;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public PaymentCycleSummaryDto generate(@Valid @RequestBody GeneratePaymentCycleCommand command) {
        return generatePaymentCycleService.generate(command);
    }

    @GetMapping
    public List<PaymentCycleSummaryDto> list(@RequestParam(required = false) String competence) {
        return listPaymentCyclesService.list(competence);
    }

    @GetMapping("/{cycleId}")
    public PaymentCycleDetailDto detail(@PathVariable UUID cycleId) {
        return getPaymentCycleDetailService.get(cycleId);
    }

    @GetMapping("/{cycleId}/entries")
    public List<PaymentCycleEntryDto> entries(
        @PathVariable UUID cycleId,
        @RequestParam(required = false) InclusionStatus inclusionStatus
    ) {
        return listPaymentCycleEntriesService.list(cycleId, inclusionStatus);
    }

    @ExceptionHandler(DuplicatePaymentCycleException.class)
    @ResponseStatus(HttpStatus.CONFLICT)
    public ProblemDetail handleDuplicate(DuplicatePaymentCycleException exception) {
        return ProblemDetail.forStatusAndDetail(HttpStatus.CONFLICT, exception.getMessage());
    }

    @ExceptionHandler(NoSuchElementException.class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    public ProblemDetail handleNotFound(NoSuchElementException exception) {
        return ProblemDetail.forStatusAndDetail(HttpStatus.NOT_FOUND, "Requested cycle was not found");
    }

    @ExceptionHandler(IllegalArgumentException.class)
    @ResponseStatus(HttpStatus.UNPROCESSABLE_ENTITY)
    public ProblemDetail handleInvalidArgument(IllegalArgumentException exception) {
        LOGGER.warn("Rejected payment-cycle request reason={}", exception.getMessage());
        return ProblemDetail.forStatusAndDetail(HttpStatus.UNPROCESSABLE_ENTITY, "Request could not be processed");
    }
}
