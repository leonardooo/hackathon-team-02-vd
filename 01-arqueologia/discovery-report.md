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

**Consolidado de todos os 5 Pares:**
- **Par 1 (Visao)** analisou 3 programas online (CADBENEF, CADDEPEND, CADPROG) e 2 DDMs (BENEFICIARIO, PROGRAMA-SOCIAL), encontrando 15 regras de negocio e 10 misterios, com destaque para divergencias entre codigo e DDM (tipos de campo, codificacoes de parentesco, suspensao automatica por idade).
- **Par 2 (Arquitetura)** analisou 3 programas batch (BATCHPGT, BATCHREL, BATCHCON) e 4 DDMs, encontrando 37 regras de negocio e 15 misterios, incluindo divergencias criticas entre cabecalhos e codigo real (MYSTERY-PGT-1).
- **Par 3 (Implementacao)** analisou 3 programas de calculo (CALCBENF, CALCCORR, CALCDSCT), encontrando 19 regras de negocio e 10 misterios. Destaque: EGG-001 (Plano Verao em CALCCORR), tabela IPCA congelada desde 2014, 3 versoes divergentes de desconto, 13o salario sem fatores familiar/renda.
- **Par 4 (Qualidade)** analisou 3 programas de validacao (VALBENEF, VALDOCS, VALELEG), encontrando 34 regras de negocio e 16 misterios. Destaque: EGG-002 (backdoor CHECK-DOC-ESPECIAL em VALDOCS), MYS-008 resolvido (Regiao 99 = Internacional/Diplomatico), DOCUMENTOS-OK nunca setado, R$600 hardcoded.
- **Par 5 (Operacoes)** analisou 3 programas de consulta/relatorio (CONSBENF, RELPGT, RELAUDIT), encontrando 35 regras de negocio e 10 misterios. Destaque: exclusoes invisiveis na auditoria, colisao semantica 'CO', bug conhecido de mascara CPF, tipo pagamento 'T' sem origem.
- **Total consolidado**: 120 regras de negocio, 61 misterios, **15/15 programas analisados**, **3/3 easter eggs encontrados**.

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

#### Par 3 — Motor de Calculo (CALCBENF, CALCCORR, CALCDSCT)

11. **BR-CALC-05**: Formula completa com 4 fatores multiplicadores. Maximo teorico +88% sobre VLR-BASE
12. **BR-CALC-07**: 13o salario SEM fatores familiar/renda — ~30-40% menor que mes regular
13. **BR-CORR-02**: Tabela IPCA congelada 2010-2012, ultima carga 2014 — correcoes 13 anos desatualizadas
14. **BR-CORR-04**: **EGG-001** — Plano Verao (1989-1991) comentado, multiplicador 2.75x, marcado "NAO REMOVER"
15. **BR-DSCT-04**: Desconto judicial SEM teto — pode gerar liquido negativo
16. **BR-DSCT-01**: 4 aliquotas progressivas (3/5/7/9%) vs 3% flat simplificado do BATCHPGT — 3 versoes de desconto coexistem

#### Par 4 — Validacao (VALBENEF, VALDOCS, VALELEG)

17. **BR-DOC-05**: **EGG-002** — Backdoor CHECK-DOC-ESPECIAL aceita 8 prefixos CPF especiais, apaga TODOS erros
18. **BR-ELEG-04**: Regiao 99 (Internacional/Diplomatico) bypassa TODAS verificacoes de elegibilidade — MYS-008 resolvido
19. **BR-ELEG-08**: R$600 hardcoded como limiar renda para tipo A. Sem parametrizacao
20. **BR-DOC-07**: DOCUMENTOS-OK nunca setado por VALDOCS mas exigido por VALELEG para tipo A
21. **BR-VAL-02**: CPF prefixo 000 aceito como "TESTE GOVERNO" — backdoor de teste cadastral

#### Par 5 — Consulta e Relatorios (CONSBENF, RELPGT, RELAUDIT)

22. **BR-RAUD-01**: Exclusoes ('EX') SEMPRE filtradas do relatorio de auditoria — invisiveis
23. **BR-CONS-04**: Bug mascara CPF conhecido — CPFs com zeros a esquerda vazam dados. "NAO CORRIGIR SEM APROVACAO DA AUDITORIA"
24. **BR-RPGT-05**: Mascara CPF diferente do CONSBENF — politicas de privacidade divergentes
25. **BR-RAUD-07**: Codigo 'CO' = CONCILIACAO no relatorio, mas DDM diz CO = CONSULTA — colisao semantica

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
- [x] **3 versoes de desconto**: BATCHPGT (3% flat >R$500), CALCBENF (3% >R$500), CALCDSCT (4 aliquotas 3/5/7/9%) — qual e a canonica?
- [x] **Tabela IPCA congelada**: CALCCORR carrega indices apenas 2010-2012, ultima carga 2014 — 13 anos sem atualizacao
- [x] **Plano Verao morto**: Bloco comentado em CALCCORR (1989-1991) marcado "NAO REMOVER" — 29 anos de dead code
- [x] **Desconto judicial sem teto**: CALCDSCT permite desconto judicial sem limite — pode gerar liquido negativo
- [x] **Backdoor de teste em producao**: VALDOCS CHECK-DOC-ESPECIAL aceita 8 prefixos CPF especiais sem verificacao
- [x] **DOCUMENTOS-OK orfao**: VALDOCS nunca seta o flag exigido por VALELEG para programas tipo A
- [x] **Fevereiro sem bissexto**: VALBENEF aceita 29/02 em qualquer ano
- [x] **Exclusoes invisiveis**: RELAUDIT filtra acoes 'EX' incondicionalmente — lacuna compliance
- [x] **Colisao semantica 'CO'**: DDM diz CO=Consulta, RELAUDIT/BATCHCON usam CO=Conciliacao
- [x] **Bug mascara CPF**: CONSBENF vaza primeiros 3 digitos para CPFs com zeros. "NAO CORRIGIR SEM APROVACAO"
- [x] **Mascaras CPF divergentes**: CONSBENF oculta 6 digitos, RELPGT oculta 3 — sem politica uniforme
- [x] **R$600 hardcoded**: Limiar renda elegibilidade tipo A sem parametrizacao
- [x] **Lookup N+1**: RELPGT faz FIND beneficiario para cada pagamento (potencialmente 100k+ FINDs)

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
| MYS-028 | Tabela IPCA congelada 2010-2012, ultima carga 2014. Correcoes 2013+ incorretas | **CRITICO** — 13 anos de correcoes potencialmente erradas |
| MYS-030 | 3 versoes de desconto coexistem (BATCHPGT, CALCBENF, CALCDSCT). Qual e canonica? | ALTO — divergencia silenciosa |
| MYS-035 | Desconto judicial sem teto. Pode gerar liquido negativo | **CRITICO** — risco legal e financeiro |
| MYS-037 | DOCUMENTOS-OK nunca setado por VALDOCS mas exigido por VALELEG | **CRITICO** — tipo A rejeitado sistematicamente? |
| MYS-048 | R$600 hardcoded para elegibilidade tipo A. Sem parametrizacao | ALTO — afeta milhoes de beneficiarios |
| MYS-052 | Bug mascara CPF conhecido. "NAO CORRIGIR SEM APROVACAO DA AUDITORIA" | **CRITICO** — vazamento dados sensiveis |
| MYS-056 | Codigo 'CO' com duplo significado (Consulta vs Conciliacao) | **CRITICO** — analise auditoria incorreta |
| MYS-058 | Exclusoes invisiveis na trilha de auditoria. So via SYSAOS | **CRITICO** — lacuna compliance IN-TCU 63/2010 |

### 4.1.1 Misterios Resolvidos

| ID | Descricao | Resolucao |
|----|-----------|-----------|
| MYS-008 | Regiao que pula verificacoes de elegibilidade | **Regiao 99 = Internacional/Diplomatico** (VALELEG.NSN#L107-L111). Adicionado 2013 por Anderson Lima |
| EGG-001 | Politica economica dos anos 90 em bloco comentado | **Plano Verao** (1989-1991), CALCCORR.NSN#L39-L50. Multiplicador 2.75x, transicao Cruzado→Cruzeiro |
| EGG-002 | Funcao de validacao especial (backdoor de teste) | **CHECK-DOC-ESPECIAL** em VALDOCS.NSN#L166-L182. 8 prefixos CPF limpam todos erros |
| EGG-003 | Dead code bancario | **Banco Real** (cod 356) em BATCHCON.NSN#L200-L230. Absorvido Santander 2007, comentado 2005 |

### 4.2 Riscos para o Estagio 2

1. **Divergencia de calculo**: E preciso comparar BATCHPGT inline vs CALCBENF completo antes de especificar o motor de calculo moderno — usar a versao errada como referencia pode gerar pagamentos incorretos
2. **Arredondamento**: Definir politica unica de arredondamento (BigDecimal + RoundingMode explicito) como ADR antes de implementar
3. **Tabelas hardcoded**: Fatores regionais (27 entradas), faixas de renda (5 faixas), status de pagamento (5 tipos), limiar R$600 precisam ser externalizados como dados de configuracao
4. **Integracao SIAFI e indireta**: Nao ha API — fluxo manual via FTP. A modernizacao precisa definir se mantem FTP ou evolui para API
5. **Volume de dados**: 180M registros de pagamento + 4.2M beneficiarios — performance e um requisito nao-funcional critico
6. **Divergencias codigo-DDM (Par 1)**: Se EARS nao refletirem divergencias (sexo, parentesco, tipos de campo), implementacao moderna pode "corrigir" regra legada sem decisao de negocio
7. **Regras sem fonte normativa**: Constante magica 0.347215 e suspensao por idade > 75 devem virar open question com decisao explicita do PO/Arquitetura
8. **Backdoor em producao**: CHECK-DOC-ESPECIAL e CPF prefixo 000 devem ser **removidos** na modernizacao — risco de seguranca critico (OWASP A01)
9. **IPCA congelada**: Motor de correcao monetaria produz valores incorretos desde 2014 — modernizacao deve integrar API do IBGE ou tabela atualizada
10. **3 versoes de desconto**: Decisao arquitetural obrigatoria sobre qual versao (BATCHPGT, CALCBENF, CALCDSCT) e canonica antes de implementar
11. **Compliance auditoria**: Exclusoes invisiveis e colisao semantica 'CO' violam IN-TCU 63/2010 — modernizacao deve corrigir obrigatoriamente
12. **DOCUMENTOS-OK gap**: Fluxo VALDOCS→VALELEG quebrado para tipo A — definir se e bug historico ou workaround intencional
13. **Mascara CPF**: Bug conhecido vaza dados. Modernizacao deve implementar politica unica de mascaramento (LGPD Art. 46)

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
- **Plano Verao (EGG-001)**: Bloco comentado de 1989-1991 em CALCCORR — documentar e remover
- **Backdoor CHECK-DOC-ESPECIAL (EGG-002)**: Remover obrigatoriamente — risco seguranca OWASP A01
- **CPF prefixo 000 "TESTE GOVERNO"**: Remover backdoor de teste em VALBENEF
- **Formato impressao 132 colunas**: Substituir por PDF/Excel na modernizacao
- **Log de erros incompleto** (`#LOG-ERRO`): Substituir por logging estruturado (SLF4J/Logback)
- **Campos fantasma** (NIS nao usado, RENDA-MAX nao validado): Avaliar se sao requisitos dormentes ou dead data

### 5.3 O que evoluir

- **Commit por registro → Processamento em chunks**: Com idempotencia e retry (Spring Batch ou similar)
- **FTP manual → API REST ou Event-driven**: Para integracao com SIAFI e bancos
- **Tabelas hardcoded → Dados de configuracao**: Fatores regionais, faixas de renda, tipos de desconto, limiar R$600 em tabelas do banco
- **Arredondamento inconsistente → BigDecimal com RoundingMode.HALF_EVEN**: Politica unica para todo o sistema
- **Auditoria incompleta → Event Sourcing ou CDC**: Trilha de auditoria completa e imutavel, incluindo acoes 'EX'
- **3 descontos → 1 motor canonico**: Unificar BATCHPGT/CALCBENF/CALCDSCT em unico bounded context Calculo
- **IPCA congelada → Integracao API IBGE**: Correcao monetaria com indices atualizados automaticamente
- **Mascara CPF → Politica LGPD unica**: Mascaramento uniforme em todos os endpoints/relatorios
- **Validacao data → java.time**: Eliminar bug 29/02 em anos nao-bissextos
- **Lookup N+1 → JOIN/batch fetch**: RELPGT deve usar query otimizada em vez de FIND por registro

---

## 6. Metricas do Estagio

| Metrica | Valor |
|---------|-------|
| Programas analisados | **15 / 15** (Par 1: 3 online, Par 2: 3 batch, Par 3: 3 calculo, Par 4: 3 validacao, Par 5: 3 consulta/relatorio) |
| DDMs mapeados | 4 / 4 |
| Regras de negocio encontradas | **120** (Par 1: 15, Par 2: 37, Par 3: 19, Par 4: 34, Par 5: 35) |
| Regras escondidas encontradas | **10 / 10** |
| Easter eggs encontrados | **3 / 3** (Plano Verao, Backdoor VALDOCS, Banco Real) |
| Termos no glossario | **113** |
| Misterios catalogados | **61** (Par 1: 10, Par 2: 15, Par 3: 10, Par 4: 16, Par 5: 10) |
| Tempo total gasto | ~6 horas |

---

## 7. Notas para o Proximo Estagio

Para o Stage 2, recomendamos que cada REQ-ID traga `source_legacy` com linha de evidencia e marque explicitamente as decisoes de divergencia entre codigo e DDM como `Migrar exatamente`, `Evoluir` ou `Descartar`. Pontos obrigatorios para decisao arquitetural:

### Decisoes herdadas do Par 1/2
- Limite de dependentes (5 no codigo vs 10 no DDM)
- Dominio de parentesco (tabela divergente entre CADDEPEND e DDM)
- Dominio de sexo (codificacao inconsistente)
- Governanca do fator financeiro `0.347215` em CADPROG
- Resolver MYSTERY-PGT-1: qual versao do calculo (BATCHPGT inline vs CALCBENF completo) e a canonica
- Definir politica unica de arredondamento (ADR-002 ja encaminha BigDecimal HALF_EVEN)
- Externalizar tabelas hardcoded (27 regioes, 5 faixas renda) como dados de configuracao

### Decisoes novas do Par 3 (Calculo)
- **ADR necessario**: Qual versao de desconto e canonica (3% flat vs 4 aliquotas progressivas)?
- **ADR necessario**: IPCA — integrar API IBGE ou manter tabela interna com carga periodica?
- CALCBENF completo (4 fatores) deve ser a referencia canonica, nao BATCHPGT inline
- Desconto judicial deve ter teto configuravel para evitar liquido negativo

### Decisoes novas do Par 4 (Validacao)
- **Remocao obrigatoria**: Backdoor CHECK-DOC-ESPECIAL e CPF prefixo 000
- **Resolver gap**: DOCUMENTOS-OK nunca setado — workflow tipo A esta funcionando hoje?
- Fevereiro/bissexto: usar java.time.LocalDate na modernizacao
- R$600 hardcoded: parametrizar como configuracao de programa
- Regiao 99 (Internacional): manter como regra explicita com REQ-ID

### Decisoes novas do Par 5 (Relatorios/Auditoria)
- **Compliance obrigatoria**: Exclusoes devem aparecer na trilha de auditoria (IN-TCU 63/2010)
- **Resolver colisao 'CO'**: Definir codificacao canonica (DDM ou codigo?) e migrar dados
- **LGPD**: Politica unica de mascaramento CPF para todos endpoints e relatorios
- Bug mascara CPF: corrigir na modernizacao (nao precisa aprovacao auditoria para sistema novo)
- Tipo pagamento 'T' (Transferencia?): confirmar significado antes de migrar
