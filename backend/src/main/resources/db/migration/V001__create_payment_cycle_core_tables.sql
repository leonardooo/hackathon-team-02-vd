CREATE TABLE IF NOT EXISTS payment_cycle (
  id UUID PRIMARY KEY,
  competence VARCHAR(6) NOT NULL,
  status VARCHAR(20) NOT NULL,
  initiated_by VARCHAR(120) NOT NULL,
  generated_at TIMESTAMP,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  included_count INTEGER NOT NULL DEFAULT 0,
  excluded_count INTEGER NOT NULL DEFAULT 0,
  generation_summary VARCHAR(500)
);

CREATE TABLE IF NOT EXISTS payment_cycle_entry (
  id UUID PRIMARY KEY,
  payment_cycle_id UUID NOT NULL REFERENCES payment_cycle(id),
  beneficiary_id UUID NOT NULL,
  beneficiary_cpf VARCHAR(14),
  program_code VARCHAR(20),
  inclusion_status VARCHAR(20) NOT NULL,
  exclusion_reason_code VARCHAR(40),
  exclusion_reason_text VARCHAR(400),
  gross_amount NUMERIC(18,2),
  discount_amount NUMERIC(18,2),
  net_amount NUMERIC(18,2),
  generated_payment_id UUID,
  UNIQUE(payment_cycle_id, beneficiary_id)
);

CREATE TABLE IF NOT EXISTS generation_audit_record (
  id UUID PRIMARY KEY,
  payment_cycle_id UUID REFERENCES payment_cycle(id),
  competence VARCHAR(6) NOT NULL,
  operator_id VARCHAR(120) NOT NULL,
  event_type VARCHAR(40) NOT NULL,
  event_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  details VARCHAR(1000)
);
