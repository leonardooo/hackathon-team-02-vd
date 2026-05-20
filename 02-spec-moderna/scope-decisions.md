# Decisoes de Escopo - SIFAP 2.0

> Para cada funcionalidade encontrada no Estagio 1, decida: **Migrar**, **Descartar** ou **Evoluir**.
>
> - **Migrar**: Trazer para o SIFAP 2.0 como esta (mesma logica, nova tecnologia)
> - **Descartar**: Nao trazer - funcionalidade obsoleta ou desnecessaria
> - **Evoluir**: Trazer E melhorar (nova UX, novo fluxo, nova capacidade)

**Time**: Team-02-VerdeDanadinho
**Data**: 20/05/2026
**Pair 1 (Product Owner) responsavel**: Marcelo Mariz

---

## Decisoes por Funcionalidade

| # | Funcionalidade | Decisao | Justificativa | Regra de Negocio (BR-XXX) | Prioridade |
|---|---------------|---------|---------------|--------------------------|------------|
| 1 | Cadastro de Beneficiarios | Evoluir | Fluxo e critico e deve manter regras legadas com correcao de inconsistencias de dominio (sexo, tipos, status). | BR-001, BR-002, BR-006, BR-009 | Alta |
| 2 | Consulta de Beneficiarios | Migrar | Necessario para operacao diaria; baixo risco de mudanca funcional no primeiro incremento. | BR-006, BR-007 | Alta |
| 3 | Registro de Pagamentos | Migrar | Fluxo core do SIFAP; manter comportamento legado primeiro, otimizar depois. | A definir (Par 3/4) | Alta |
| 4 | Processamento Batch | Migrar | Dependencia de processos existentes e janelas operacionais; foco em compatibilidade. | A definir (Par 2) | Alta |
| 5 | Calculo de Beneficios | Evoluir | Regras financeiras exigem rastreabilidade e parametrizacao (evitar constantes magicas). | BR-015 | Alta |
| 6 | Validacao de CPF | Migrar | Regra legada Mod-11 e obrigatoria para qualidade de cadastro. | BR-002 | Alta |
| 7 | Relatorios | Evoluir | Modernizar com filtros e transparencia de auditoria para operacao e controle. | A definir (Par 5) | Media |
| 8 | Auditoria | Evoluir | Necessario fortalecer trilha para mudancas automaticas de status e parametros. | BR-009, BR-015 | Alta |
| 9 | Gestao de Usuarios | Evoluir | Legado nao cobre requisitos modernos de seguranca e perfis API/web. | [GREENFIELD] | Alta |
| 10 | Cadastro de Dependentes | Evoluir | Manter vinculo familiar, mas harmonizar limite e codigos de parentesco com DDM. | BR-011, BR-012, BR-013, BR-014 | Alta |
| 11 | Cadastro de Programas Sociais | Evoluir | Preservar cadastro e consulta com revisao de governanca do fator de reajuste. | BR-015 | Alta |
| 12 | Exportacao manual em layout legado | Descartar | Sera substituida por API e relatorios digitais versionados. | [GREENFIELD] | Baixa |

> Adicione linhas para cada funcionalidade identificada.

---

## Funcionalidades Novas (nao existem no legado)

> Liste funcionalidades que o SIFAP 2.0 deveria ter e que nao existem no sistema legado:

| # | Funcionalidade Nova | Justificativa | Prioridade | Complexidade |
|---|-------------------|---------------|------------|-------------|
| N1 | Autenticacao OAuth2/JWT | Necessaria para frontend/API moderna e segregacao de acesso por perfil. | Alta | Media |
| N2 | Trilha de auditoria estruturada por evento | Suportar compliance e investigacao de mudancas sensiveis. | Alta | Media |
| N3 | Painel de inconsistencias cadastrais | Reduzir retrabalho operacional em dados com divergencia de dominio. | Media | Alta |

---

## Resumo de Escopo

| Decisao | Quantidade | Percentual |
|---------|-----------|------------|
| Migrar | 4 | 33% |
| Descartar | 1 | 8% |
| Evoluir | 7 | 59% |
| **Total** | 12 | 100% |

## Riscos de Escopo

> Liste os riscos das decisoes de escopo tomadas:

| Risco | Probabilidade | Impacto | Mitigacao |
|-------|--------------|---------|-----------|
| Divergencia entre dominio de codigo e DDM gerar implementacao incorreta | Alta | Alto | Registrar REQ com `source_legacy` em codigo e DDM, e decidir no Handoff #2 a regra canonica. |
| Regras financeiras hardcoded serem perdidas na migracao | Media | Alto | Criar requisito explicito para parametrizacao e teste de regressao de calculo. |
| Escopo de evolucao exceder janela do workshop | Alta | Medio | Priorizar MVP com 2-3 fluxos ponta-a-ponta e backlogar extras. |

## Aprovacao

- [x] Pair 1 (Product Owner) aprovou as decisoes de escopo
- [ ] Pair 2 (Enterprise Architect) validou a viabilidade tecnica
- [x] Time concordou com as prioridades
