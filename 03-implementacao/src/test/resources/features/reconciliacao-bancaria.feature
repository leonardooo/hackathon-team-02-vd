# Feature: Reconciliação Bancária (CNAB 240 / Banco do Brasil)
# Origem  : BATCHCON.NSN (SIFAP Legado)
# REQ     : REQ-020 (conciliação), REQ-021 (divergência), REQ-022 (auditoria)
# QA PAR 4 - 2026-05-20

Feature: Reconciliação de pagamentos com retorno bancário CNAB 240
  Como sistema SIFAP 2.0
  Quero conciliar os pagamentos emitidos com o arquivo de retorno do Banco do Brasil
  Para identificar pagamentos confirmados, divergentes e não encontrados

  Background:
    Given a competência de reconciliação é "202605"
    And existem pagamentos com status "EMITIDO" para a competência "202605"

  # --- HAPPY PATH ---

  Scenario: REQ-020 Pagamento conciliado com valor igual — status muda para CONFIRMADO
    Given um pagamento emitido com num_pagamento "1000001" e vlr_liquido R$ 600,00
    And o arquivo CNAB 240 contém registro com num_doc "1000001", valor R$ 600,00 e código retorno "00"
    When a reconciliação bancária for executada
    Then o pagamento "1000001" deve ter status "CONFIRMADO"
    And a data de confirmação deve ser preenchida
    And um registro de auditoria deve ser gerado com ação "AL"

  Scenario: REQ-020 Tolerância de R$ 0,01 é aceita como conciliado
    # Regra original: IF #DIFF > 0.01 → divergência (BATCHCON.NSN linha ~150)
    Given um pagamento emitido com num_pagamento "1000002" e vlr_liquido R$ 600,00
    And o arquivo CNAB 240 contém registro com valor R$ 600,01 e código retorno "00"
    When a reconciliação bancária for executada
    Then o pagamento "1000002" deve ter status "CONFIRMADO"

  # --- DIVERGÊNCIAS ---

  Scenario: REQ-021 Divergência de valor acima de R$ 0,01 gera registro de auditoria
    Given um pagamento emitido com num_pagamento "1000003" e vlr_liquido R$ 600,00
    And o arquivo CNAB 240 contém registro com valor R$ 550,00 e código retorno "00"
    When a reconciliação bancária for executada
    Then o pagamento "1000003" deve permanecer com status "EMITIDO"
    And o pagamento deve ser marcado como "DIVERGENTE" na conciliação
    And um registro de auditoria deve ser gerado com ação "AL" e descrição contendo "DIVERGENCIA"
    And o contador de divergências deve ser 1

  Scenario: REQ-021 Pagamento não encontrado no arquivo CNAB é registrado
    Given um pagamento emitido com num_pagamento "1000004" e vlr_liquido R$ 600,00
    And o arquivo CNAB 240 NÃO contém registro para o num_pagamento "1000004"
    When a reconciliação bancária for executada
    Then o pagamento "1000004" deve permanecer com status "EMITIDO"
    And o contador de não encontrados deve ser 1

  Scenario: REQ-021 CPF do arquivo CNAB não bate com o pagamento — divergência
    Given um pagamento emitido com num_pagamento "1000005" para CPF "11111111111"
    And o arquivo CNAB 240 contém registro com num_doc "1000005" mas CPF "99999999999"
    When a reconciliação bancária for executada
    Then o pagamento "1000005" deve permanecer com status "EMITIDO"
    And o contador de não encontrados deve ser incrementado

  # --- AUDITORIA ---

  Scenario: REQ-022 Toda divergência gera registro imutável na tabela auditoria
    Given um pagamento emitido com num_pagamento "1000006" e vlr_liquido R$ 600,00
    And o arquivo CNAB 240 contém valor divergente R$ 400,00
    When a reconciliação bancária for executada
    Then um registro deve existir em auditoria com:
      | campo          | valor esperado          |
      | cod_acao       | AL                      |
      | tipo_entidade  | PGTO                    |
      | id_entidade    | 1000006                 |
      | cod_modulo     | BATCHCON                |
    And nenhum UPDATE ou DELETE deve ter ocorrido na tabela auditoria

  Scenario: REQ-022 Relatório final do ciclo de reconciliação é consistente
    Given um arquivo CNAB 240 com 5 registros:
      | num_doc | valor    | codigo_retorno | situacao_esperada |
      | 2000001 | 600,00   | 00             | CONFIRMADO        |
      | 2000002 | 600,01   | 00             | CONFIRMADO        |
      | 2000003 | 550,00   | 00             | DIVERGENTE        |
      | 2000004 | 600,00   | 00             | CONFIRMADO        |
      | 9999999 | 600,00   | 00             | NAO_ENCONTRADO    |
    When a reconciliação bancária for executada
    Then o relatório final deve conter:
      | lidos             | 5 |
      | conciliados       | 3 |
      | divergentes       | 1 |
      | nao_encontrados   | 1 |
