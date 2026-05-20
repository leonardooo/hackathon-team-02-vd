# Feature: Cálculo do Valor do Benefício
# Origem  : CALCBENF.NSN (SIFAP Legado)
# REQ     : REQ-001 (cálculo base), REQ-002 (fator regional), REQ-003 (fator familiar)
# QA PAR 4 - 2026-05-20

Feature: Cálculo do valor do benefício mensal
  Como sistema SIFAP 2.0
  Quero calcular o valor correto do benefício mensal
  Para que beneficiários ativos recebam o valor justo conforme as regras do programa

  Background:
    Given o programa "PBF" está ativo com valor base de R$ 600,00
    And as faixas de renda estão configuradas conforme CALCBENF.NSN:
      | renda_inicio | renda_fim | fator_multiplicador |
      | 0,00         | 300,00    | 1,0000              |
      | 300,01       | 600,00    | 0,8500              |
      | 600,01       | 1000,00   | 0,7000              |
      | 1000,01      | 1500,00   | 0,5500              |
      | 1500,01      | 9999,99   | 0,4000              |

  # --- HAPPY PATH ---

  Scenario: REQ-001 Beneficiário ativo sem dependentes, renda baixa, região padrão
    Given um beneficiário com CPF "12345678901" com status "ATIVO"
    And renda familiar de R$ 200,00
    And sem dependentes
    And código de região 15 (fator regional 1,0000)
    When o cálculo do benefício for executado para a competência "202605"
    Then o valor bruto deve ser R$ 600,00
    And o status do pagamento deve ser "PENDENTE"
    And um registro de auditoria deve ser gerado com ação "IN"

  Scenario: REQ-002 Fator regional aumenta o valor para regiões Norte/Nordeste
    Given um beneficiário com CPF "22222222222" com status "ATIVO"
    And renda familiar de R$ 200,00
    And sem dependentes
    And código de região 6 (estado MA, fator regional 1,4000)
    When o cálculo do benefício for executado para a competência "202605"
    Then o valor bruto deve ser R$ 840,00
    # 600,00 * 1,4000 = 840,00

  Scenario: REQ-003 Fator familiar com 2 dependentes ativos
    Given um beneficiário com CPF "33333333333" com status "ATIVO"
    And renda familiar de R$ 200,00
    And 2 dependentes ativos
    And código de região 15 (fator regional 1,0000)
    When o cálculo do benefício for executado para a competência "202605"
    Then o valor bruto deve ser R$ 660,00
    # fator_familiar = 1,0000 + (2 * 0,0500) = 1,1000
    # 600,00 * 1,0000 * 1,1000 = 660,00

  Scenario: REQ-003 Fator familiar com 4 dependentes ativos
    Given um beneficiário com CPF "44444444444" com status "ATIVO"
    And renda familiar de R$ 200,00
    And 4 dependentes ativos
    And código de região 15 (fator regional 1,0000)
    When o cálculo do benefício for executado para a competência "202605"
    Then o valor bruto deve ser R$ 756,00
    # fator_familiar = 1,1000 + ((4-2) * 0,0300) = 1,1600
    # 600,00 * 1,1600 = 696,00  ← corrigir após confirmar com PAR 2

  Scenario: REQ-001 Faixa de renda reduz o benefício — renda entre 600 e 1000
    Given um beneficiário com CPF "55555555555" com status "ATIVO"
    And renda familiar de R$ 800,00
    And sem dependentes
    And código de região 15 (fator regional 1,0000)
    When o cálculo do benefício for executado para a competência "202605"
    Then o valor bruto deve ser R$ 420,00
    # 600,00 * 0,7000 = 420,00

  # --- CASOS DE BORDA ---

  Scenario: Beneficiário SUSPENSO não gera pagamento
    Given um beneficiário com CPF "66666666666" com status "SUSPENSO"
    And renda familiar de R$ 200,00
    When o cálculo do benefício for executado para a competência "202605"
    Then nenhum pagamento deve ser gerado
    And uma exceção de negócio "BENEFICIARIO_NAO_ATIVO" deve ser lançada

  Scenario: Beneficiário com renda zero recebe valor base integral
    Given um beneficiário com CPF "77777777777" com status "ATIVO"
    And renda familiar de R$ 0,00
    And sem dependentes
    And código de região 15 (fator regional 1,0000)
    When o cálculo do benefício for executado para a competência "202605"
    Then o valor bruto deve ser R$ 600,00
    # renda 0 cai na primeira faixa (até 300,00) — fator 1,0000

  Scenario: Pagamento duplicado na mesma competência é rejeitado
    Given um beneficiário com CPF "88888888888" com status "ATIVO"
    And já existe um pagamento gerado para a competência "202605"
    When o cálculo do benefício for executado novamente para a competência "202605"
    Then nenhum pagamento duplicado deve ser criado
    And uma exceção de negócio "PAGAMENTO_JA_EXISTENTE" deve ser lançada

  Scenario: Programa INATIVO impede geração de pagamento
    Given um beneficiário com CPF "99999999999" com status "ATIVO"
    And o programa "PROG_X" está com status "INATIVO"
    When o cálculo do benefício for executado para a competência "202605"
    Then nenhum pagamento deve ser gerado
    And uma exceção de negócio "PROGRAMA_INATIVO" deve ser lançada

  # --- ERRO DE BANCO ---

  Scenario: Falha de banco durante a gravação reverte a transação
    Given um beneficiário com CPF "11111111100" com status "ATIVO"
    And renda familiar de R$ 200,00
    And o banco de dados lança erro durante a gravação do pagamento
    When o cálculo do benefício for executado para a competência "202605"
    Then nenhum pagamento deve ser persistido
    And o erro deve ser registrado no log de auditoria com ação "ER"
