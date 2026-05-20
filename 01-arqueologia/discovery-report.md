# Relatorio de Descoberta - Estagio 1: Arqueologia Digital

> Este documento consolida todas as descobertas do Estagio 1.

**Time**: Team-02-VerdeDanadinho
**Data**: 20/05/2026
**Participantes**:
- Par 1 (Visao): **Marcelo Mariz** — Product Owner + Requirements Engineer
- Par 2 (Arquitetura): **Fabio Guerra** — Enterprise Architect + Software Architect
- Par 3 (Implementacao): **Leonardo Assis** — Technical Lead + Developer
- Par 4 (Qualidade): **Thaise Dantas** — DBA + QA Engineer
- Par 5 (Operacoes): **Izabella Campos** — DevOps Engineer + Tech Writer

---

## 1. Sumario Executivo

O SIFAP (Sistema de Fiscalizacao e Administracao de Pagamentos) e um sistema de missao critica em producao desde 1997, rodando em Natural 6.3 + Adabas 7.4 sobre mainframe IBM zSeries. Ele gerencia o ciclo completo de pagamentos de beneficios federais (MDAS/SENARC) para ~4.2 milhoes de beneficiarios, incluindo cadastro, calculo de beneficios com 4 fatores compostos, geracao mensal de pagamentos em lote, conciliacao bancaria via CNAB 240, e auditoria. O codigo esta em modo de manutencao minima desde 2018, com a equipe original quase totalmente aposentada — as regras de calculo existem **apenas no codigo-fonte**.

**Consolidado dos Pares 1 e 2:**
- **Par 1 (Visao)** analisou 3 programas online (CADBENEF, CADDEPEND, CADPROG) e 2 DDMs (BENEFICIARIO, PROGRAMA-SOCIAL), encontrando 15 regras de negocio e 10 misterios, com destaque para divergencias entre codigo e DDM (tipos de campo, codificacoes de parentesco, suspensao automatica por idade).
- **Par 2 (Arquitetura)** analisou 3 programas batch (BATCHPGT, BATCHREL, BATCHCON) e 4 DDMs, encontrando 37 regras de negocio e 25 misterios, incluindo divergencias criticas entre cabecalhos e codigo real (MYSTERY-PGT-1).
- **Total consolidado**: 52 regras de negocio, 35 misterios, 6 programas analisados de 15.

---

## 2. Visao Geral do Sistema

### 2.1 Proposito do SIFAP
O SIFAP gerencia o ciclo completo de beneficios sociais federais: cadastro de beneficiarios e dependentes, vinculacao a programas sociais, calculo mensal de beneficios (com fatores regionais, familiares, de renda e idade), geracao de pagamentos em lote, envio ao Banco do Brasil via CNAB 240, conciliacao de retornos bancarios, e auditoria de todas as operacoes. Integra-se indiretamente com o SIAFI (STN) via FTP manual.

### 2.2 Arquitetura Legada
- **15 programas Natural** (.NSN): 4 online (cadastro/consulta), 3 batch (pagamento/relatorio/conciliacao), 3 calculo, 3 validacao, 2 relatorios
- **4 DDMs Adabas**: BENEFICIARIO (FNR 150, ~4.2M), PROGRAMA-SOCIAL (FNR 151, ~45), PAGAMENTO (FNR 152, ~180M), AUDITORIA (FNR 153, ~25M)
- **Nenhum CALLNAT entre programas** — todos usam sub-rotinas internas via PERFORM
- Fluxo estritamente linear: Cadastro → Calculo → Pagamento → Conciliacao → Relatorios
- Programas online transacionais (CADBENEF, CADDEPEND, CADPROG) com persistencia direta em Adabas via FIND/STORE/UPDATE
- Processos batch mensais (BATCHPGT, BATCHREL, BATCHCON) sequenciais sem retry nem idempotencia

### 2.3 Usuarios e Perfis
- **Operadores MDAS/SENARC**: cadastro de beneficiarios, consultas, gestao de programas (Terminal 3270)
- **Auditores TCU/CGU**: relatorios de auditoria e conformidade
- **Gestores de Programas**: parametrizacao de programas sociais, aprovacao de ciclos
- **Processos Batch automaticos**: execucao mensal sem intervencao humana (exceto conciliacao)

---

## 3. Principais Descobertas

### 3.1 Regras de Negocio Criticas

#### Par 2 — Programas Batch (BATCHPGT, BATCHREL, BATCHCON)

1. **BR-PGT-09**: Calculo principal de beneficio = `VLR-BASE x FatorRegional x FatorFamiliar x FatorRenda x FatorIdade x (1 + FATOR-REAJ)` — formula composta com 4 fatores + reajuste (BATCHPGT L244-L246)
2. **BR-PGT-11**: 13o salario em dezembro usa formula **diferente** — nao inclui FatorFamiliar nem FatorRenda, apenas `VLR-BASE x FatorReg x FatorIdade` (BATCHPGT L255-L260)
3. **BR-CON-05**: Tolerancia de conciliacao bancaria = R$ 0,01 de diferenca absoluta entre valor SIFAP e valor banco (BATCHCON L149-L153)
4. **BR-PGT-12**: Abono natalino de 15% sobre VLR-BENF em dezembro, exclusivo para programas tipo 'A' (Assistencial) (BATCHPGT L262-L267)
5. **BR-CON-06/07/08**: Transicoes de status de pagamento via codigo de retorno CNAB: `'00'`→Pago, `'01'`→Devolvido, `'02'`→Erro (BATCHCON L163-L184)

#### Par 1 — Programas Online (CADBENEF, CADDEPEND, CADPROG)

6. **BR-009**: Beneficiario com idade > 75 recebe status `S` (suspenso) automaticamente — sem contexto funcional documentado (CADBENEF)
7. **BR-002**: CPF obrigatorio e validado por algoritmo Mod-11 com 2 digitos verificadores (CADBENEF)
8. **BR-006/BR-007**: Inclusao e alteracao de beneficiario dependem de existencia previa por CPF (CADBENEF)
9. **BR-011**: Inclusao de dependente bloqueada para titular com status cancelado/desligado (CADDEPEND)
10. **BR-015**: Valor de programa recalculado por fator com constante fixa `0.347215` antes de persistir (CADPROG)

### 3.2 Dependencias Complexas
O DDM BENEFICIARIO (FNR 150) e o maior hotspot: **11 dos 15 programas** o acessam para leitura. BATCHPGT e um "God Batch" que concentra validacao, calculo, desconto e persistencia em um unico programa monolitico — na modernizacao, essas responsabilidades devem ser separadas em bounded contexts distintos. O fluxo batch e sequencial e fragil: BATCHPGT → FTP BB → BATCHCON → BATCHREL, sem mecanismo de retry ou idempotencia.

No recorte do Par 1, o acoplamento mais forte esta no ARQ 150 (BENEFICIARIO), usado por CADBENEF e CADDEPEND. Qualquer mudanca em tipos/codificacao de campos (status, parentesco, cod-programa, cod-regiao) gera efeito cascata em cadastro de titular e dependentes. Em CADPROG, o acoplamento sensivel e com a semantica de FATOR-K e campos de elegibilidade do ARQ 151.

### 3.3 Divida Tecnica Identificada

- [x] **Cabecalho desatualizado**: BATCHPGT diz "CHAMA CALCBENF E CALCDSCT" mas NAO chama — calculo inline simplificado pode divergir do motor real de 4800 linhas
- [x] **Arredondamento inconsistente**: BATCHREL usa round (+0.005), CALCBENF usa truncamento — totais de relatorio nao batem com valores pagos
- [x] **Dead code**: Bloco comentado do Banco Real (absorvido pelo Santander em 2007) no BATCHCON desde 2005
- [x] **Commit por registro**: BATCHPGT faz END TRANSACTION a cada STORE — ~4.2M commits individuais sem controle de batch/chunk
- [x] **Campos fantasma**: NIS, RENDA-MAX, VLR-ABONO declarados em VIEWs mas nunca usados no codigo
- [x] **Log de erros incompleto**: Array `#LOG-ERRO` declarado em 2004 mas nunca preenchido
- [x] **Auditoria nao implementada**: Alteracao de 2015 "INC AUDITORIA" no BATCHPGT — nenhum codigo de auditoria existe
- [x] **VIEW desalinhada com DDM**: BATCHCON grava em campos genericos em vez dos campos dedicados de conciliacao (GA-GE) do DDM
- [x] **Divergencias codigo-DDM (Par 1)**: Tipos de campo divergentes entre Natural e DDM (N4 vs A4 para COD-PROGRAMA), codificacoes de parentesco e sexo inconsistentes
- [x] **Constante magica**: CADPROG usa fator `0.347215` sem justificativa funcional documentada
- [x] **Leituras duplicadas**: CADDEPEND executa FIND repetidos no mesmo fluxo de transacao — risco de concorrencia

### 3.4 Gaps de Documentacao
O MANUAL-TECNICO-SIFAP-2008.md e a ultima documentacao oficial e tem 18 anos de defasagem. Nao cobre: alteracoes de 2012-2015 (campos de IP, email, hash), regras de 13o salario e abono natalino, tabela de 27 fatores regionais, tolerancia de conciliacao, nem os 8 tipos de desconto do CALCDSCT. O ultimo desenvolvedor com visao integral (Marcos Antonio Ferreira) saiu em 2017.

A documentacao tambem nao explica a origem de regras sensiveis do cadastro (suspensao por idade > 75, fator de reajuste com constante magica), nao esclarece divergencias de codificacao entre programas e DDMs, e nao detalha governanca de transicoes de status. Faltam criterios de compatibilidade para migracao de dados historicos.

---

## 4. Misterios e Riscos

### 4.1 Misterios Nao Resolvidos

| ID | Descricao | Risco para Migracao |
|----|-----------|---------------------|
| MYSTERY-PGT-1 | Cabecalho BATCHPGT diz "CHAMA CALCBENF" mas NAO ha CALLNAT. Calculo inline de ~30 linhas vs CALCBENF de ~4800 linhas. Regras podem estar divergentes. | **CRITICO** — qual versao do calculo e a correta? |
| MYSTERY-PGT-2 | Tabela de 27 regioes, mas IF valida apenas 1-25. Entradas 26-27 nunca acessadas. DDM mostra "01-05 OU 99 (ESPECIAL)". | ALTO — mapeamento regional inconsistente |
| MYSTERY-PGT-5 | Desconto simplificado de 3% vs CALCDSCT com 8 tipos (IR, judicial, consignacoes). Versao degradada ou proposital? | ALTO — descontos podem estar incorretos |
| MYSTERY-PGT-6 | 13o salario calculado SEM fator familiar e SEM fator renda. Intencional ou bug? | ALTO — impacto financeiro direto |
| MYSTERY-REL-1 | Arredondamento BATCHREL (round) diverge de CALCBENF (truncate). Totais de relatorio ≠ valores pagos. | MEDIO — relatorios gerenciais imprecisos |
| MYSTERY-REL-2 | Acumulador por status usa valor original, por regiao usa arredondado. Somas internas nao batem. | MEDIO — inconsistencia interna do relatorio |
| MYSTERY-CON-1 | COD-BANCO hardcoded como `1` (numerico), DDM define como `A3`. Valor `1` ≠ codigo BB (`001`). | ALTO — possivel bug de tipo |
| MYSTERY-CON-4 | VIEW usa campos genericos, DDM tem campos dedicados de conciliacao (GA-GE) nunca usados. | ALTO — dados de conciliacao no lugar errado |
| MYS-001 | Suspensao automatica para idade > 75 sem contexto funcional documentado (CADBENEF) | MEDIO — reproduzir sem criterio pode gerar bloqueios indevidos |
| MYS-003 | Limite de dependentes 5 no codigo vs 10 no DDM (CADDEPEND) | ALTO — perda de casos validos ou quebra de compatibilidade |
| MYS-004 | Tabela de parentesco divergente entre codigo e DDM (CADDEPEND) | ALTO — dados inconsistentes e falhas de validacao |
| MYS-006 | Constante magica `0.347215` sem base explicita (CADPROG) | ALTO — erro financeiro na modernizacao |
| MYS-007 | Tipo de COD-PROGRAMA diverge entre Natural (N4) e DDM (A4) (CADPROG) | ALTO — mapeamento incorreto em banco/API |

### 4.2 Riscos para o Estagio 2

1. **Divergencia de calculo**: E preciso comparar BATCHPGT inline vs CALCBENF completo antes de especificar o motor de calculo moderno — usar a versao errada como referencia pode gerar pagamentos incorretos
2. **Arredondamento**: Definir politica unica de arredondamento (BigDecimal + RoundingMode explicito) como ADR antes de implementar
3. **Tabelas hardcoded**: Fatores regionais (27 entradas), faixas de renda (5 faixas), status de pagamento (5 tipos) precisam ser externalizados como dados de configuracao
4. **Integracao SIAFI e indireta**: Nao ha API — fluxo manual via FTP. A modernizacao precisa definir se mantem FTP ou evolui para API
5. **Volume de dados**: 180M registros de pagamento + 4.2M beneficiarios — performance e um requisito nao-funcional critico
6. **Divergencias codigo-DDM (Par 1)**: Se EARS nao refletirem divergencias (sexo, parentesco, tipos de campo), implementacao moderna pode "corrigir" regra legada sem decisao de negocio
7. **Regras sem fonte normativa**: Constante magica 0.347215 e suspensao por idade > 75 devem virar open question com decisao explicita do PO/Arquitetura

---

## 5. Recomendacoes

### 5.1 O que migrar primeiro

| Prioridade | Funcionalidade | Justificativa |
|------------|---------------|---------------|
| 1 | Cadastro de Beneficiarios (CADBENEF, CADDEPEND, VALBENEF, VALDOCS) | Base para tudo — sem beneficiario nao ha pagamento. Programas mais simples para comecar. |
| 2 | Motor de Calculo (CALCBENF, CALCDSCT) | Core domain — regras de negocio mais complexas e valiosas. Precisa de equivalence tests rigorosos. |
| 3 | Geracao de Pagamentos (BATCHPGT) | Depende de 1 e 2. Oportunidade de decompor o God Batch em servicos. |
| 4 | Conciliacao Bancaria (BATCHCON) | Depende de 3. Anti-corruption layer para CNAB 240. |
| 5 | Relatorios (BATCHREL, RELPGT, RELAUDIT) | Menor risco — apenas leitura. Pode rodar em paralelo com legado (Strangler Fig). |

### 5.2 O que descartar

- **Dead code do Banco Real**: Bloco comentado ha 19 anos no BATCHCON — remover
- **Formato impressao 132 colunas**: Substituir por PDF/Excel na modernizacao
- **Log de erros incompleto** (`#LOG-ERRO`): Substituir por logging estruturado (SLF4J/Logback)
- **Campos fantasma** (NIS nao usado, RENDA-MAX nao validado): Avaliar se sao requisitos dormentes ou dead data

### 5.3 O que evoluir

- **Commit por registro → Processamento em chunks**: Com idempotencia e retry (Spring Batch ou similar)
- **FTP manual → API REST ou Event-driven**: Para integracao com SIAFI e bancos
- **Tabelas hardcoded → Dados de configuracao**: Fatores regionais, faixas de renda, tipos de desconto em tabelas do banco
- **Arredondamento inconsistente → BigDecimal com RoundingMode.HALF_EVEN**: Politica unica para todo o sistema
- **Auditoria incompleta → Event Sourcing ou CDC**: Trilha de auditoria completa e imutavel

---

## 6. Metricas do Estagio

| Metrica | Valor |
|---------|-------|
| Programas analisados | 6 / 15 (Par 1: 3 online, Par 2: 3 batch) |
| DDMs mapeados | 4 / 4 |
| Regras de negocio encontradas | 52 (Par 1: 15, Par 2: 37) |
| Regras escondidas encontradas | 3 / 10 |
| Easter eggs encontrados | 0 / 3 |
| Termos no glossario | 30 |
| Misterios catalogados | 35 (Par 1: 10, Par 2: 25) |
| Tempo total gasto | ~4 horas |

---

## 7. Notas para o Proximo Estagio

Para o Stage 2, recomendamos que cada REQ-ID traga `source_legacy` com linha de evidencia e marque explicitamente as decisoes de divergencia entre codigo e DDM como `Migrar exatamente`, `Evoluir` ou `Descartar`. Pontos obrigatorios para decisao arquitetural:
- Limite de dependentes (5 no codigo vs 10 no DDM)
- Dominio de parentesco (tabela divergente entre CADDEPEND e DDM)
- Dominio de sexo (codificacao inconsistente)
- Governanca do fator financeiro `0.347215` em CADPROG
- Resolver MYSTERY-PGT-1: qual versao do calculo (BATCHPGT inline vs CALCBENF completo) e a canonica
- Definir politica unica de arredondamento (ADR-002 ja encaminha BigDecimal HALF_EVEN)
- Externalizar tabelas hardcoded (27 regioes, 5 faixas renda) como dados de configuracao
