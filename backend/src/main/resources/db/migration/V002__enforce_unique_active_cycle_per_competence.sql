CREATE UNIQUE INDEX IF NOT EXISTS ux_payment_cycle_competence_active
ON payment_cycle (competence)
WHERE status IN ('GENERATING', 'GENERATED');
