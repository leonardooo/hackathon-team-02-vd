# Relatorio de Descoberta - Estagio 1: Arqueologia Digital

> Este documento consolida todas as descobertas do Estagio 1.
> Preencha cada secao com as conclusoes do time.

**Time**: Team-02-VerdeDanadinho
**Data**: 20/05/2026
**Participantes**: Marcelo Mariz (Par 1 - Product Owner + Requirements Engineer), Fabio Guerra (Par 2 - Enterprise Architect + Software Architect), Leonardo Assis (Par 3 - Technical Lead + Developer), Thaise Dantas (Par 4 - DBA + QA Engineer), Izabella Campos (Par 5 - DevOps Engineer + Tech Writer)

---

## 1. Sumario Executivo

> Em 3-5 frases, resuma o que o time descobriu sobre o SIFAP legado.
> O que e este sistema? Qual sua criticidade? Qual o estado do codigo?

O SIFAP legado concentra regras criticas de cadastro de beneficiarios, dependentes e programas sociais com impacto direto na elegibilidade e no valor pago. A base e fortemente orientada a Adabas (ARQ 150 e ARQ 151), com validacoes implementadas de forma procedural em Natural. Encontramos regras de negocio relevantes e silenciosas, como suspensao automatica por idade (>75) e recalculo de valor por constante magica no cadastro de programas. Tambem identificamos inconsistencias entre codigo e DDM (tipos de campo e codificacoes), que elevam risco de regressao no Stage 2 se nao forem tratadas explicitamente nas EARS. O estado do codigo e funcional, mas com baixa explicabilidade e pouca rastreabilidade documental.

---

## 2. Visao Geral do Sistema

### 2.1 Proposito do SIFAP
O SIFAP gerencia o ciclo cadastral de programas sociais: cadastro e manutencao de beneficiarios (`CADBENEF.NSN`), cadastro de dependentes vinculados ao titular (`CADDEPEND.NSN`) e cadastro/consulta de parametros de programas (`CADPROG.NSN`). Essas rotinas alimentam os dados-base usados pelos processos de elegibilidade, calculo e pagamento.

### 2.2 Arquitetura Legada
Arquitetura monolitica em Natural/Adabas, com programas online transacionais e persistencia em arquivos Adabas. No escopo do Par 1, os fluxos principais sao:
- `CADBENEF.NSN` -> valida entrada (inclui CPF Mod-11), consulta ARQ 150, inclui/altera beneficiario.
- `CADDEPEND.NSN` -> localiza titular no ARQ 150, valida regras de dependente, atualiza grupo periodico de dependentes.
- `CADPROG.NSN` -> inclui/consulta programas no ARQ 151 com ajuste de valor por fator.

Panorama do kit: 15 programas Natural + 4 DDMs.

### 2.3 Usuarios e Perfis
[Quem usa o sistema? Quais perfis de acesso existem?]

Pelos fluxos de tela (`INPUT/WRITE`), os usuarios aparentes sao operadores internos de cadastro (atendimento/retaguarda) e analistas administrativos. Nao ha controle de perfil explicito nesses 3 programas; as rotinas assumem sessao autenticada no ambiente legado.

---

## 3. Principais Descobertas

### 3.1 Regras de Negocio Criticas
> Liste as 5 regras de negocio mais importantes encontradas.

1. Beneficiario com idade > 75 recebe status `S` automaticamente (BR-009).
2. CPF obrigatorio e validado por algoritmo Mod-11 com 2 digitos verificadores (BR-002).
3. Inclusao e alteracao de beneficiario dependem de existencia previa por CPF (BR-006 e BR-007).
4. Inclusao de dependente e bloqueada para titular cancelado/desligado (BR-011).
5. Valor de programa e recalculado por fator com constante fixa antes de persistir (BR-015).

### 3.2 Dependencias Complexas
> Quais programas estao mais acoplados? Onde ha risco de efeito cascata?

No recorte do Par 1, o maior acoplamento esta no arquivo `BENEFICIARIO` (ARQ 150), usado por `CADBENEF` e `CADDEPEND`. Qualquer mudanca em tipo/codificacao de campos (ex.: status, parentesco, cod-programa, cod-regiao) gera efeito cascata em cadastro de titular e dependentes. Em `CADPROG`, o acoplamento sensivel e com a semantica de `FATOR-K` e campos de elegibilidade do ARQ 151.

### 3.3 Divida Tecnica Identificada
> Que problemas no codigo legado vao complicar a migracao?

- Divergencias entre programa e DDM (tipos e dominios) sem camada de normalizacao.
- Regras criticas hardcoded (ex.: `0.347215`) sem justificativa funcional no codigo.
- Repeticao de leituras (`FIND`) no mesmo fluxo de transacao em `CADDEPEND`, com risco para concorrencia/performance.

### 3.4 Gaps de Documentacao
> O que a documentacao existente NAO cobre?

A documentacao nao explica a origem de regras sensiveis (suspensao por idade e fator de reajuste), nao esclarece divergencias de codificacao entre programas e DDMs e nao detalha governanca de transicoes de status. Tambem faltam criterios de compatibilidade para migracao de dados historicos.

---

## 4. Misterios e Riscos

### 4.1 Misterios Nao Resolvidos
> Resuma os misterios do arquivo `mysteries-found.md` que permanecem sem explicacao.

| ID | Descricao | Risco para Migracao |
|----|-----------|---------------------|
| MYS-001 | Suspensao automatica para idade > 75 sem contexto funcional | Reproduzir sem criterio pode gerar bloqueios indevidos |
| MYS-003 | Limite de dependentes 5 no codigo vs 10 no DDM | Perda de casos validos ou quebra de compatibilidade |
| MYS-004 | Tabela de parentesco divergente entre codigo e DDM | Dados inconsistentes e falhas de validacao |
| MYS-006 | Constante magica `0.347215` sem base explicita | Erro financeiro na modernizacao |
| MYS-007 | Tipo de `COD-PROGRAMA` diverge (N4 vs A4) | Mapeamento incorreto em banco/API |

### 4.2 Riscos para o Estagio 2
> O que o time de especificacao precisa saber antes de comecar?

1. Divergencias de dominio entre Natural e DDM (sexo, parentesco, tipos de campo) podem gerar implementacao incorreta de API e banco.
2. Se EARS nao refletirem divergencias codigo x DDM, implementacao moderna pode "corrigir" regra legada sem decisao de negocio.
3. Regras de valor e status sem fonte normativa devem virar "open question" com decisao explicita do PO/Arquitetura.

---

## 5. Recomendacoes

### 5.1 O que migrar primeiro
> Com base na priorizacao do Pair 1 (Product Owner), quais funcionalidades devem ser migradas primeiro?

| Prioridade | Funcionalidade | Justificativa |
|------------|---------------|---------------|
| 1 | Cadastro de Beneficiarios (`CADBENEF`) | Porta de entrada da base e maior concentracao de validacoes criticas (CPF, status, unicidade). |
| 2 | Cadastro de Dependentes (`CADDEPEND`) | Impacta elegibilidade familiar e possui inconsistencias de regra/estrutura a resolver cedo. |
| 3 | Cadastro de Programas (`CADPROG`) | Define parametros financeiros (valor-base/fator) consumidos por calculo e pagamento. |

### 5.2 O que descartar
> Funcionalidades que provavelmente nao precisam ser migradas:

- Nenhuma funcionalidade de cadastro foi descartada neste recorte do Par 1; decisoes finais serao consolidadas em `02-spec-moderna/scope-decisions.md`.

### 5.3 O que evoluir
> Funcionalidades que devem ser migradas E melhoradas:

- Cadastro de Beneficiario: evoluir validacao de dominio para alinhar com DDM e registrar motivo de mudanca de status.
- Cadastro de Dependentes: evoluir para regra parametrica de limite e tabela de parentesco unificada.
- Cadastro de Programas: externalizar fator de reajuste para parametro versionado/auditavel.

---

## 6. Metricas do Estagio

| Metrica | Valor |
|---------|-------|
| Programas analisados | 3 / 15 |
| DDMs mapeados | 2 / 4 |
| Regras de negocio encontradas | 15 |
| Regras escondidas encontradas | 3 / 10 |
| Easter eggs encontrados | 0 / 3 |
| Termos no glossario | 0 |
| Misterios catalogados | 10 |
| Tempo total gasto | 2.5 horas |

---

## 7. Notas para o Proximo Estagio

> Deixe aqui mensagens para o time no Estagio 2 (Especificacao Moderna):

Para o Stage 2, recomendamos que cada REQ-ID traga `source_legacy` com linha de evidencia e marque explicitamente as decisoes de divergencia entre codigo e DDM como `Migrar exatamente`, `Evoluir` ou `Descartar`. Pontos obrigatorios para decisao arquitetural: limite de dependentes (5 vs 10), dominio de parentesco, dominio de sexo e governanca do fator financeiro em `CADPROG`.
