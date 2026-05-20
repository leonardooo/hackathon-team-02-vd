# Feature: Geração do Ciclo Mensal de Pagamentos
# Origem  : BATCHPGT.NSN (SIFAP Legado)
# REQ     : REQ-010 (geração ciclo), REQ-011 (somente ativos), REQ-012 (idempotência)
# QA PAR 4 - 2026-05-20

Feature: Geração do ciclo mensal de pagamentos em lote
  Como sistema SIFAP 2.0
  Quero gerar pagamentos para todos os beneficiários ativos no início do mês
  Para que o ciclo mensal seja executado dentro da janela de 2 horas

  Background:
    Given o programa "PBF" está ativo com valor base de R$ 600,00
    And a competência corrente é "202605"

  # --- HAPPY PATH ---

  Scenario: REQ-010 Ciclo gera pagamentos para todos os beneficiários ATIVOS
    Given existem 3 beneficiários ativos no programa "PBF"
    And nenhum pagamento foi gerado para a competência "202605"
    When o ciclo mensal for executado para a competência "202605"
    Then 3 pagamentos devem ser criados com status "PENDENTE"
    And o total de registros processados deve ser 3
    And o total de erros deve ser 0

  Scenario: REQ-011 Beneficiários SUSPENSOS são ignorados pelo ciclo
    Given existem 2 beneficiários ativos e 1 suspenso no programa "PBF"
    When o ciclo mensal for executado para a competência "202605"
    Then apenas 2 pagamentos devem ser criados
    And o total de ignorados deve ser 1

  Scenario: REQ-011 Beneficiários CANCELADOS são ignorados pelo ciclo
    Given existem 2 beneficiários ativos e 1 cancelado no programa "PBF"
    When o ciclo mensal for executado para a competência "202605"
    Then apenas 2 pagamentos devem ser criados
    And o total de ignorados deve ser 1

  Scenario: REQ-012 Ciclo é idempotente — reexecução não duplica pagamentos
    Given existem 2 beneficiários ativos no programa "PBF"
    And o ciclo já foi executado para a competência "202605"
    When o ciclo mensal for executado novamente para a competência "202605"
    Then ainda devem existir apenas 2 pagamentos para a competência "202605"
    And o total de já gerados deve ser 2
    And nenhum pagamento duplicado deve existir

  # --- CASOS DE BORDA ---

  Scenario: REQ-011 Nenhum beneficiário ativo — ciclo encerra sem erro
    Given não existem beneficiários ativos no programa "PBF"
    When o ciclo mensal for executado para a competência "202605"
    Then 0 pagamentos devem ser criados
    And o ciclo deve encerrar com status "SUCESSO"

  Scenario: REQ-010 Beneficiário com dependente deficiente recebe valor diferenciado
    Given um beneficiário com CPF "12300000001" com status "ATIVO"
    And o beneficiário possui 1 dependente ativo com deficiência
    And renda familiar de R$ 200,00
    And código de região 15 (fator regional 1,0000)
    When o ciclo mensal for executado para a competência "202605"
    Then o pagamento gerado deve ter valor bruto maior que R$ 600,00
    # Dependente deficiente aplica fator adicional — confirmar regra com PAR 2

  Scenario: REQ-010 Valor líquido é sempre menor ou igual ao valor bruto
    Given existem 3 beneficiários ativos com descontos configurados
    When o ciclo mensal for executado para a competência "202605"
    Then para cada pagamento gerado o vlr_liquido deve ser menor ou igual ao vlr_bruto
    And o vlr_desconto_total deve ser igual a vlr_bruto menos vlr_liquido

  Scenario: REQ-010 Ciclo gera entrada de auditoria por pagamento criado
    Given existem 2 beneficiários ativos no programa "PBF"
    When o ciclo mensal for executado para a competência "202605"
    Then 2 registros de auditoria devem ser criados com ação "BT"
    And cada registro de auditoria deve referenciar o pagamento gerado
