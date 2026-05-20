# Catalogo de Regras de Negocio - SIFAP Legado

> Registre aqui todas as regras de negocio extraidas do codigo Natural/Adabas.
> Cada regra deve ter rastreabilidade ate o codigo-fonte.
>
> **REGRA DURA:** linhas com `Programa Fonte` vazio sao **invalidas** e nao contam para o gate do Estagio 2. Use o formato `legacy/natural-programs/ARQUIVO.NSN#L<inicio>-L<fim>` sempre que possivel. Minimo aceito: nome do arquivo .NSN.

## Niveis de Risco

| Nivel | Descricao |
|-------|-----------|
| **CRITICO** | Regra financeira ou de seguranca - erro causa prejuizo direto |
| **ALTO** | Regra de negocio central - afeta fluxo principal |
| **MEDIO** | Regra de validacao ou formatacao - afeta qualidade dos dados |
| **BAIXO** | Regra de apresentacao ou conveniencia - impacto limitado |

## Regras Encontradas

| ID | Regra de Negocio | Programa Fonte | Campos DDM | Nivel de Risco | Notas |
|----|-----------------|----------------|------------|----------------|-------|
| BR-001 | Operacao de cadastro de beneficiario aceita apenas `I` (inclusao) ou `A` (alteracao). | legacy/natural-programs/CADBENEF.NSN#L99-L103 | BENEFICIARIO.OPERACAO (fluxo), BENEFICIARIO.CPF | ALTO | Qualquer valor fora de I/A interrompe o processamento. |
| BR-002 | CPF do beneficiario e obrigatorio e deve passar validacao Mod-11 de dois digitos verificadores. | legacy/natural-programs/CADBENEF.NSN#L105-L116; legacy/natural-programs/CADBENEF.NSN#L224-L270 | BENEFICIARIO.NUM-CPF/CPF | CRITICO | Regra central de identidade; erro bloqueia inclusao/alteracao. |
| BR-003 | Nome do beneficiario e campo obrigatorio no cadastro. | legacy/natural-programs/CADBENEF.NSN#L119-L123 | BENEFICIARIO.NOME-COMPLETO/NOME | ALTO | Sem nome o cadastro e rejeitado. |
| BR-004 | Data de nascimento do beneficiario e obrigatoria para gravacao. | legacy/natural-programs/CADBENEF.NSN#L125-L129 | BENEFICIARIO.DT-NASCIMENTO | ALTO | Campo usado para calculo de idade e status. |
| BR-005 | Sexo aceito no cadastro de beneficiario e apenas `M` ou `F`. | legacy/natural-programs/CADBENEF.NSN#L131-L135 | BENEFICIARIO.SEXO | MEDIO | Diverge do DDM, que documenta tambem valor `I`. |
| BR-006 | Inclusao (`I`) e bloqueada quando CPF ja existe no arquivo de beneficiario. | legacy/natural-programs/CADBENEF.NSN#L137-L147 | BENEFICIARIO.CPF | CRITICO | Garante unicidade logica por CPF. |
| BR-007 | Alteracao (`A`) e bloqueada quando CPF nao e encontrado na base. | legacy/natural-programs/CADBENEF.NSN#L149-L153 | BENEFICIARIO.CPF | ALTO | Evita update cego sem registro existente. |
| BR-008 | Em inclusao, o status inicial do beneficiario e `A` (ativo). | legacy/natural-programs/CADBENEF.NSN#L162-L164 | BENEFICIARIO.SIT-BENEFICIARIO/STATUS | ALTO | Regra de estado inicial do ciclo de vida. |
| BR-009 | Beneficiario com idade maior que 75 anos tem status ajustado para `S` (suspenso), sobrescrevendo status inicial. | legacy/natural-programs/CADBENEF.NSN#L156-L169 | BENEFICIARIO.DT-NASCIMENTO, BENEFICIARIO.STATUS | CRITICO | Regra sensivel e silenciosa (aplica automaticamente). |
| BR-010 | Na inclusao, sistema grava `DT-CADASTRO` e `DT-ATUALIZACAO` com a data corrente e confirma transacao. | legacy/natural-programs/CADBENEF.NSN#L193-L199 | BENEFICIARIO.DT-CADASTRO, BENEFICIARIO.DT-ATUALIZACAO | MEDIO | Metadados de auditoria temporal da ficha. |
| BR-011 | Inclusao de dependente e proibida para titular com status `C` (cancelado) ou `D` (desligado). | legacy/natural-programs/CADDEPEND.NSN#L56-L60 | BENEFICIARIO.STATUS | ALTO | Regra de bloqueio por elegibilidade do titular. |
| BR-012 | Limite operacional de dependentes por titular e 5; ao exceder, inclusao e encerrada. | legacy/natural-programs/CADDEPEND.NSN#L63-L66 | BENEFICIARIO.NUM-DEPENDENTES, BENEFICIARIO.GRP-DEPENDENTE | ALTO | Diverge do DDM, que define PE com ate 10 ocorrencias. |
| BR-013 | Parentesco permitido para dependente: `FI`, `CO`, `IR`, `OU`; valores fora da lista sao rejeitados. | legacy/natural-programs/CADDEPEND.NSN#L84-L87 | BENEFICIARIO.PARENTESCO | MEDIO | Diverge da codificacao do DDM (`FI`,`CJ`,`NT`,`TU`). |
| BR-014 | CPF de dependente nao pode repetir para o mesmo titular (quando informado e diferente de zero). | legacy/natural-programs/CADDEPEND.NSN#L96-L101 | BENEFICIARIO.CPF-DEPENDENTE | ALTO | Previne duplicidade no grupo periodico de dependentes. |
| BR-015 | Na inclusao de programa social, valor-base persistido e recalculado por `FATOR-K = 1 + (FATOR-REAJ * 0.347215)` e status inicial do programa e `A`. | legacy/natural-programs/CADPROG.NSN#L87-L103 | PROGRAMA-SOCIAL.VLR-BASE, PROGRAMA-SOCIAL.FATOR-K, PROGRAMA-SOCIAL.STATUS-PROG | CRITICO | Constante `0.347215` e regra financeira sem justificativa no codigo. |

> Adicione mais linhas conforme necessario. Lembre-se: existem **10 regras escondidas** no codigo!

## Regras por Categoria

### Calculos Financeiros
<!-- Liste aqui as regras relacionadas a calculos de valores, beneficios, etc. -->
- BR-009 (ajuste de status por idade derivada de data de nascimento)
- BR-015 (recalculo de valor-base por fator K)

### Validacoes de Status
<!-- Liste aqui as regras de transicao de status (A, S, C, I, D) -->
- BR-008 (status inicial `A`)
- BR-009 (idoso > 75 muda para `S`)
- BR-011 (status `C`/`D` bloqueia inclusao de dependente)

### Regras de Autorizacao
<!-- Liste aqui as regras de quem pode fazer o que -->
- BR-001 (operacao permitida apenas I/A)
- BR-006 e BR-007 (controle de existencia para incluir/alterar)

### Regras de Negocio Temporais
<!-- Liste aqui regras com prazos, datas-limite, periodos -->
- BR-010 (datas de cadastro/atualizacao com data corrente)
- BR-009 (regra etaria baseada em ano de nascimento)

## Resumo Estatistico

- Total de regras encontradas: 15
- Regras criticas: 4
- Regras com duplicacao: 0
- Regras sem documentacao (escondidas): 3
