# Decisoes de Escopo - SIFAP 2.0

> Para cada funcionalidade encontrada no Estagio 1, decida: **Migrar**, **Descartar** ou **Evoluir**.
>
> - **Migrar**: Trazer para o SIFAP 2.0 como esta (mesma logica, nova tecnologia)
> - **Descartar**: Nao trazer - funcionalidade obsoleta ou desnecessaria
> - **Evoluir**: Trazer E melhorar (nova UX, novo fluxo, nova capacidade)

**Time**: Team-02-VerdeDanadinho
**Data**: 20/05/2026
**Pair 2 (Enterprise Architect) responsavel**: Fabio Guerra
**Pair 1 (Product Owner) responsavel**: Marcelo Mariz

---

## Decisoes por Funcionalidade

| # | Funcionalidade | Decisao | Justificativa | Regra de Negocio (BR-XXX) | Prioridade |
|---|---------------|---------|---------------|--------------------------|------------|
| 1 | Cadastro de Beneficiarios | **Evoluir** | Base para todo o sistema. Adicionar validacao de CPF online (Receita Federal) e upload de documentos digitais. Programas legados: CADBENEF, CADDEPEND | BR-PGT-01 a BR-PGT-04 | Alta |
| 2 | Cadastro de Dependentes | **Evoluir** | Vincular dependentes com parentesco validado. Substituir terminal 3270 por formulario web responsivo | BR-PGT-02, BR-PGT-04 | Alta |
| 3 | Validacao de Beneficiarios (CPF, docs) | **Evoluir** | Validacao atual e offline com modulo-11 local. Evoluir para consulta online a Receita Federal + validacao de docs via OCR | BR-PGT-03 (CPF modulo-11) | Alta |
| 4 | Motor de Calculo de Beneficios | **Evoluir** | Core domain — formula composta com 4 fatores (regional, familiar, renda, idade) + reajuste. Externalizar tabelas hardcoded (27 regioes, 5 faixas renda) para banco. Resolver divergencia BATCHPGT inline vs CALCBENF completo (MYSTERY-PGT-1). Definir politica unica de arredondamento (BigDecimal HALF_EVEN) | BR-PGT-09, BR-PGT-10, BR-PGT-11, BR-PGT-12 | Alta |
| 5 | Calculo de Descontos | **Evoluir** | BATCHPGT usa desconto simplificado de 3%, mas CALCDSCT tem 8 tipos (IR, judicial, consignacoes). Implementar motor completo com cap 30% para nao-judiciais | BR-PGT-05 (desconto 3% simplificado) | Alta |
| 6 | Geracao de Pagamentos (batch mensal) | **Evoluir** | God Batch BATCHPGT faz 4.2M commits individuais sem retry/idempotencia. Decompor em servicos, processar em chunks com Spring Batch, adicionar idempotencia | BR-PGT-06 a BR-PGT-08, BR-PGT-13, BR-PGT-14 | Alta |
| 7 | 13o Salario e Abono Natalino | **Migrar** | Regras de dezembro: 13o usa formula diferente (sem fator familiar/renda), abono de 15% para programas tipo A. Manter logica exata com equivalence tests | BR-PGT-11, BR-PGT-12 | Alta |
| 8 | Conciliacao Bancaria (CNAB 240) | **Evoluir** | Anti-corruption layer para CNAB 240 do Banco do Brasil. Manter tolerancia R$0.01. Remover dead code Banco Real. Adicionar retry e notificacao de divergencias | BR-CON-01 a BR-CON-12 | Alta |
| 9 | Relatorios Gerenciais | **Evoluir** | Substituir formato 132 colunas (impressora matricial) por PDF/Excel/dashboard web. Corrigir arredondamento inconsistente (MYSTERY-REL-1) | BR-REL-01 a BR-REL-07 | Media |
| 10 | Relatorio de Auditoria | **Evoluir** | RELAUDIT apenas le dados. Na modernizacao: dashboard interativo com filtros, export CSV/PDF | BR-REL-05 (se existente) | Media |
| 11 | Gestao de Programas Sociais | **Migrar** | Parametrizacao de programas (tipo A/B/C, valores base, fatores). PROGBENEF e consulta. Manter logica, nova interface | BR-PGT-15 a BR-PGT-18 | Media |
| 12 | Auditoria de Operacoes | **Evoluir** | Legado tem DDM AUDITORIA (FNR 153) mas BATCHPGT nunca implementou a auditoria planejada em 2015. Implementar de verdade com event sourcing ou CDC | (nao implementada no legado) | Alta |
| 13 | Integracao SIAFI (STN) | **Evoluir** | Atualmente via FTP manual. Evoluir para API REST ou mensageria assincrona | BR-PGT-16 (se existente) | Media |
| 14 | Dead code Banco Real | **Descartar** | Bloco comentado no BATCHCON desde 2005, banco absorvido pelo Santander em 2007. Nenhuma utilidade | — | — |
| 15 | Formato impressao 132 colunas | **Descartar** | Layout para impressoras matriciais mainframe. Substituido por relatorios PDF/Excel modernos | — | — |
| 16 | Log de erros incompleto (#LOG-ERRO) | **Descartar** | Array declarado em 2004 mas nunca preenchido. Substituir por logging estruturado (SLF4J/Logback) | — | — |
| 17 | Campos fantasma (NIS, RENDA-MAX, VLR-ABONO) | **Descartar** | Declarados em VIEWs mas nunca usados no codigo. Avaliar na migracao de dados se contem dados uteis | — | Baixa |

---

## Funcionalidades Novas (nao existem no legado)

> Liste funcionalidades que o SIFAP 2.0 deveria ter e que nao existem no sistema legado:

| # | Funcionalidade Nova | Justificativa | Prioridade | Complexidade |
|---|-------------------|---------------|------------|-------------|
| N1 | Autenticacao via Gov.br (OAuth2/OIDC) | Legado usa autenticacao Natural nativa no mainframe. Modernizar com SSO federado | Alta | Media |
| N2 | Dashboard de acompanhamento em tempo real | Legado nao tem visibilidade online dos ciclos de pagamento. Operadores dependem de relatorios batch mensais | Media | Media |
| N3 | Notificacoes de divergencia na conciliacao | Legado processa silenciosamente. Alertar operadores sobre pagamentos devolvidos ou com erro via email/push | Media | Baixa |
| N4 | API REST publica para consulta de status | Permitir que outros sistemas consultem status de pagamentos sem acesso direto ao banco | Media | Baixa |
| N5 | Processamento em chunks com idempotencia | Legado faz commit por registro (4.2M commits). Spring Batch com chunk processing e retry | Alta | Alta |
| N6 | Trilha de auditoria imutavel | Event sourcing ou CDC para auditoria completa — legado prometeu mas nunca implementou | Alta | Alta |

---

## Resumo de Escopo

| Decisao | Quantidade | Percentual |
|---------|-----------|------------|
| Migrar | 2 | 15% |
| Descartar | 4 | 31% |
| Evoluir | 7 | 54% |
| **Total** | **13** | 100% |

> Nota: 4 itens descartados sao dead code/campos obsoletos. Das 13 funcionalidades reais do legado, 2 sao migradas como estao e 7 sao evoluidas. Alem disso, 6 funcionalidades novas (greenfield) foram identificadas.

## Riscos de Escopo

> Liste os riscos das decisoes de escopo tomadas:

| Risco | Probabilidade | Impacto | Mitigacao |
|-------|--------------|---------|-----------|
| Divergencia entre calculo inline (BATCHPGT) e motor completo (CALCBENF) pode gerar pagamentos incorretos se a referencia errada for usada | Alta | Alto | Comparar ambas as versoes com dados reais antes de especificar. Criar equivalence tests obrigatorios |
| Arredondamento inconsistente entre modulos (round vs truncate) pode gerar diferencas financeiras acumuladas | Media | Alto | ADR definindo politica unica de arredondamento (BigDecimal HALF_EVEN). Aplicar em todos os bounded contexts |
| Volume de dados (180M pagamentos + 4.2M beneficiarios) pode causar problemas de performance na migracao | Media | Alto | Migrar em ondas por programa social. Usar pg_bulkload para carga inicial. Performance tests com dados sinteticos |
| Integracao SIAFI via FTP manual — se evoluir para API, pode depender de cronograma externo da STN | Alta | Medio | Manter FTP como fallback via anti-corruption layer. API como evolucao futura |
| Campos fantasma podem conter dados uteis nao documentados — descartar prematuramente pode perder informacoes | Baixa | Medio | Analisar amostra dos dados reais antes de descartar. Manter backup das tabelas originais |

## Aprovacao

- [ ] Pair 1 (Product Owner) aprovou as decisoes de escopo
- [x] Pair 2 (Enterprise Architect) validou a viabilidade tecnica
- [ ] Time concordou com as prioridades
