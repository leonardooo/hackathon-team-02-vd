package com.datacorp.sifap.payments.cycle.domain.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.math.BigDecimal;
import java.util.UUID;

@Entity
@Table(name = "payment_cycle_entry")
public class PaymentCycleEntry {

    @Id
    private UUID id;

    @Column(name = "payment_cycle_id", nullable = false)
    private UUID paymentCycleId;

    @Column(name = "beneficiary_id", nullable = false)
    private UUID beneficiaryId;

    @Column(name = "beneficiary_cpf", length = 14)
    private String beneficiaryCpf;

    @Column(name = "program_code", length = 20)
    private String programCode;

    @Column(name = "inclusion_status", nullable = false, length = 20)
    private InclusionStatus inclusionStatus;

    @Column(name = "exclusion_reason_code", length = 40)
    private String exclusionReasonCode;

    @Column(name = "exclusion_reason_text", length = 400)
    private String exclusionReasonText;

    @Column(name = "gross_amount", precision = 18, scale = 2)
    private BigDecimal grossAmount;

    @Column(name = "discount_amount", precision = 18, scale = 2)
    private BigDecimal discountAmount;

    @Column(name = "net_amount", precision = 18, scale = 2)
    private BigDecimal netAmount;

    @Column(name = "generated_payment_id")
    private UUID generatedPaymentId;

    protected PaymentCycleEntry() {
    }

    public static PaymentCycleEntry included(UUID cycleId, UUID beneficiaryId, String cpf, String programCode,
                                             BigDecimal gross, BigDecimal discount, BigDecimal net) {
      PaymentCycleEntry entry = new PaymentCycleEntry();
      entry.id = UUID.randomUUID();
      entry.paymentCycleId = cycleId;
      entry.beneficiaryId = beneficiaryId;
      entry.beneficiaryCpf = cpf;
      entry.programCode = programCode;
      entry.inclusionStatus = InclusionStatus.INCLUDED;
      entry.grossAmount = gross;
      entry.discountAmount = discount;
      entry.netAmount = net;
      return entry;
    }

    public static PaymentCycleEntry excluded(UUID cycleId, UUID beneficiaryId, String cpf, String programCode,
                                             String reasonCode, String reasonText) {
      PaymentCycleEntry entry = new PaymentCycleEntry();
      entry.id = UUID.randomUUID();
      entry.paymentCycleId = cycleId;
      entry.beneficiaryId = beneficiaryId;
      entry.beneficiaryCpf = cpf;
      entry.programCode = programCode;
      entry.inclusionStatus = InclusionStatus.EXCLUDED;
      entry.exclusionReasonCode = reasonCode;
      entry.exclusionReasonText = reasonText;
      return entry;
    }

    public UUID getId() {
      return id;
    }

    public UUID getPaymentCycleId() {
      return paymentCycleId;
    }

    public UUID getBeneficiaryId() {
      return beneficiaryId;
    }

    public String getBeneficiaryCpf() {
      return beneficiaryCpf;
    }

    public String getProgramCode() {
      return programCode;
    }

    public InclusionStatus getInclusionStatus() {
      return inclusionStatus;
    }

    public String getExclusionReasonCode() {
      return exclusionReasonCode;
    }

    public String getExclusionReasonText() {
      return exclusionReasonText;
    }

    public BigDecimal getGrossAmount() {
      return grossAmount;
    }

    public BigDecimal getDiscountAmount() {
      return discountAmount;
    }

    public BigDecimal getNetAmount() {
      return netAmount;
    }
}
