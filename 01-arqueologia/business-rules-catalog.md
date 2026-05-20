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
| BR-PGT-01 | Somente beneficiarios com STATUS='A' sao processados para pagamento | legacy/natural-programs/BATCHPGT.NSN#L195-L198 | BENEFICIARIO.STATUS | CRITICO | Beneficiarios inativos sao silenciosamente ignorados |
| BR-PGT-02 | Idempotencia: no maximo 1 pagamento por CPF por competencia | legacy/natural-programs/BATCHPGT.NSN#L200-L210 | PAGAMENTO.CPF-BENEF, PAGAMENTO.COMPETENCIA | CRITICO | Se ja existe pagamento para a competencia, pula o beneficiario |
| BR-PGT-03 | Programa social deve existir e estar ativo (STATUS-PROG='A') | legacy/natural-programs/BATCHPGT.NSN#L212-L230 | PROGRAMA-SOCIAL.COD-PROGRAMA, PROGRAMA-SOCIAL.STATUS-PROG | ALTO | Programa inexistente gera erro; inativo e silenciosamente ignorado |
| BR-PGT-04 | Tabela de 27 fatores regionais hardcoded (1.00 a 1.40) | legacy/natural-programs/BATCHPGT.NSN#L123-L150 | BENEFICIARIO.COD-REGIAO | CRITICO | Comentario diz "MESMA DO CALCBENF" — duplicacao de logica |
| BR-PGT-05 | Fator regional: COD-REG 1-25 usa tabela; fora da faixa → default 1.0 | legacy/natural-programs/BATCHPGT.NSN#L239-L244 | BENEFICIARIO.COD-REGIAO | MEDIO | Regioes 26-27 estao na tabela como 1.0, redundante com ELSE |
| BR-PGT-06 | 5 faixas de renda: <=300→1.0; <=600→0.85; <=1000→0.70; <=1500→0.55; >1500→0.40 | legacy/natural-programs/BATCHPGT.NSN#L152-L162 | BENEFICIARIO.RENDA-FAMILIAR | CRITICO | Valores hardcoded — quanto maior a renda, menor o fator |
| BR-PGT-07 | Fator familiar: 0 dep→1.0; 1-2→1.0+dep×0.05; 3-4→1.10+(dep-2)×0.03; 5+→1.16+(dep-4)×0.02 | legacy/natural-programs/BATCHPGT.NSN#L246-L259 | BENEFICIARIO.NUM-DEPENDENTES | CRITICO | Progressao escalonada com incremento decrescente por faixa |
| BR-PGT-08 | Fator idade: >=65→1.15; 60-64→1.10; <18→1.05; 18-59→1.00 | legacy/natural-programs/BATCHPGT.NSN#L264-L277 | BENEFICIARIO.DT-NASCIMENTO | ALTO | Idosos e menores recebem acrescimo |
| BR-PGT-09 | Formula principal: VLR_BENF = VLR_BASE × FATOR_REG × FATOR_FAM × FATOR_RND × FATOR_IDADE | legacy/natural-programs/BATCHPGT.NSN#L279-L281 | PROGRAMA-SOCIAL.VLR-BASE | CRITICO | 4 fatores multiplicadores sobre o valor base do programa |
| BR-PGT-10 | Reajuste aplicado: VLR_BENF = VLR_BENF × (1 + FATOR_REAJUSTE) | legacy/natural-programs/BATCHPGT.NSN#L282 | PROGRAMA-SOCIAL.FATOR-REAJUSTE | ALTO | Fator de reajuste vem do cadastro do programa |
| BR-PGT-11 | Truncamento (nao arredondamento) para todos os valores monetarios | legacy/natural-programs/BATCHPGT.NSN#L284-L285 | PAGAMENTO.VLR-BRUTO, VLR-DESCONTO, VLR-LIQUIDO | CRITICO | Difere do BATCHREL que arredonda (+0.005) |
| BR-PGT-12 | 13o salario em dezembro: VLR_13 = VLR_BASE × FATOR_REG × FATOR_IDADE (sem fam/renda) | legacy/natural-programs/BATCHPGT.NSN#L291-L297 | PAGAMENTO.VLR-BRUTO | CRITICO | Formula simplificada — nao inclui FATOR_FAM nem FATOR_RND |
| BR-PGT-13 | Abono de Natal para programas TIPO='A' em dezembro: 15% do VLR_BENF | legacy/natural-programs/BATCHPGT.NSN#L298-L303 | PROGRAMA-SOCIAL.TIPO, PAGAMENTO.VLR-ABONO | ALTO | Abono somado ao bruto. Alteracao de 2009 (Jose Ferreira) |
| BR-PGT-14 | Desconto: se bruto > R$500,00, desconto = 3% do bruto | legacy/natural-programs/BATCHPGT.NSN#L306-L312 | PAGAMENTO.VLR-DESCONTO | ALTO | Limiar hardcoded R$500. Abaixo nao ha desconto |
| BR-PGT-15 | Valor liquido nunca negativo (floor em R$0,00) | legacy/natural-programs/BATCHPGT.NSN#L315-L320 | PAGAMENTO.VLR-LIQUIDO | MEDIO | Liquido = bruto - desconto; se < 0 → 0 |
| BR-PGT-16 | Status inicial do pagamento e 'G' (Gerado) | legacy/natural-programs/BATCHPGT.NSN#L332 | PAGAMENTO.STATUS-PGTO | ALTO | Ponto de entrada da maquina de estados (G→P/D/E via BATCHCON) |
| BR-PGT-17 | Tipo pagamento: 'N' (normal) ou 'D' (dezembro com 13o) | legacy/natural-programs/BATCHPGT.NSN#L289-L293 | PAGAMENTO.TIPO-PGTO | MEDIO | Dezembro recebe tipo 'D' para distinguir parcelas com 13o/abono |
| BR-PGT-18 | Deduplicacao por CPF e ordenacao ascendente para sistemas downstream | legacy/natural-programs/BATCHPGT.NSN#L178-L192 | BENEFICIARIO.CPF | ALTO | Comentario de 1999: "SISTEMAS DOWNSTREAM DEPENDEM DESTA ORDENACAO" |
| BR-PGT-19 | Calculo de idade aproximado (ano corrente - ano nascimento, ignora mes/dia) | legacy/natural-programs/BATCHPGT.NSN#L236-L237 | BENEFICIARIO.DT-NASCIMENTO | MEDIO | Pode causar erro de ±1 ano na virada de aniversario |
| BR-REL-01 | Relatorio filtrado por competencia exata (READ BY + NE escape) | legacy/natural-programs/BATCHREL.NSN#L105-L108 | PAGAMENTO.COMPETENCIA | MEDIO | Competencia informada via INPUT pelo operador |
| BR-REL-02 | Mapeamento de COD-REGIAO para 5 macrorregioes: 1-5→Norte, 6-10→Nordeste, 11-15→Sudeste, 16-20→Sul, 21+→Centro-Oeste | legacy/natural-programs/BATCHREL.NSN#L116-L133 | BENEFICIARIO.COD-REGIAO | ALTO | Difere do BATCHPGT que usa 27 regioes individuais |
| BR-REL-03 | Arredondamento (ROUND +0.005) para bruto no relatorio — difere do truncamento do BATCHPGT | legacy/natural-programs/BATCHREL.NSN#L135-L139 | PAGAMENTO.VLR-BRUTO | CRITICO | Pode causar divergencias centavais |
| BR-REL-04 | 5 categorias de status: G=Gerado, P=Pago, C=Cancelado, D=Devolvido, E=Estornado | legacy/natural-programs/BATCHREL.NSN#L82-L86 | PAGAMENTO.STATUS-PGTO | ALTO | Maquina de estados completa do ciclo de pagamento |
| BR-REL-05 | Status desconhecido tratado como 'Gerado' (clausula NONE → idx 1) | legacy/natural-programs/BATCHREL.NSN#L157-L158 | PAGAMENTO.STATUS-PGTO | MEDIO | Silenciosamente contabiliza status invalidos como gerados |
| BR-REL-06 | Agregacao em 3 dimensoes: por regiao (bruto/desc/liq/qtd), por status (bruto/qtd), e total geral | legacy/natural-programs/BATCHREL.NSN#L140-L167 | PAGAMENTO.VLR-BRUTO, VLR-DESCONTO, VLR-LIQUIDO | MEDIO | Status so agrega bruto (nao desc/liq) — assimetria |
| BR-REL-07 | Total geral de bruto usa valor arredondado (consistente com subtotais regionais) | legacy/natural-programs/BATCHREL.NSN#L164 | PAGAMENTO.VLR-BRUTO | MEDIO | ADD #VLR-ARR ao total geral, nao o valor original |
| BR-REL-08 | Formato impressora mainframe: 66 linhas/pagina, 132 caracteres/linha | legacy/natural-programs/BATCHREL.NSN#L70-L72 | — | BAIXO | Constantes hardcoded para saida flat file. Irrelevante para sistema moderno |
| BR-CON-01 | Apenas registros CNAB 240 tipo detalhe (TIPO-REG='3') sao processados | legacy/natural-programs/BATCHCON.NSN#L115-L118 | — | ALTO | Headers (0), trailers (9) e lotes sao ignorados |
| BR-CON-02 | Layout CNAB 240 BB: CPF pos 44(11), VLR pos 120(15), DT_PGTO pos 140(8), COD_RET pos 231(2), NUM_DOC pos 74(10) | legacy/natural-programs/BATCHCON.NSN#L110-L124 | — | CRITICO | Posicoes hardcoded do layout Banco do Brasil |
| BR-CON-03 | Conversao de centavos para reais: valor CNAB / 100 | legacy/natural-programs/BATCHCON.NSN#L129-L132 | — | ALTO | Valor no CNAB e inteiro em centavos |
| BR-CON-04 | Match de pagamento por chave tripla: NUM_PGTO + CPF + competencia | legacy/natural-programs/BATCHCON.NSN#L137-L152 | PAGAMENTO.NUM-PAGTO, CPF-BENEF, COMPETENCIA | CRITICO | Pagamento nao encontrado e logado mas nao bloqueia o batch |
| BR-CON-05 | Tolerancia de conciliacao: diferenca <= R$0,01 e aceitavel | legacy/natural-programs/BATCHCON.NSN#L154-L160 | PAGAMENTO.VLR-LIQUIDO | CRITICO | Valor absoluto da diferenca. Acima de 1 centavo → divergencia |
| BR-CON-06 | COD_RET '00' → status 'P' (Pago) + grava DT_PAGAMENTO + COD_BANCO=1 (BB) | legacy/natural-programs/BATCHCON.NSN#L172-L180 | PAGAMENTO.STATUS-PGTO, DT-PAGAMENTO, COD-BANCO | CRITICO | Transicao G→P. COD_BANCO hardcoded como 1 |
| BR-CON-07 | COD_RET '01' → status 'D' (Devolvido); nao grava data pagamento | legacy/natural-programs/BATCHCON.NSN#L181-L187 | PAGAMENTO.STATUS-PGTO, COD-RETORNO | CRITICO | Transicao G→D |
| BR-CON-08 | COD_RET '02' → status 'E' (Estornado); nao grava data pagamento | legacy/natural-programs/BATCHCON.NSN#L188-L194 | PAGAMENTO.STATUS-PGTO, COD-RETORNO | CRITICO | Transicao G→E |
| BR-CON-09 | Codigo de retorno desconhecido: logado mas nenhuma transicao de status | legacy/natural-programs/BATCHCON.NSN#L195-L199 | PAGAMENTO.COD-RETORNO | ALTO | Clausula NONE — status permanece inalterado |
| BR-CON-10 | Auditoria obrigatoria: conciliacao (ACAO='CO') e divergencia (ACAO='DV') com valores antes/depois | legacy/natural-programs/BATCHCON.NSN#L232-L264 | AUDITORIA.SEQ-AUDIT, ACAO, VLR-ANTERIOR, VLR-NOVO | ALTO | Dois tipos de registro: 'CO' para OK, 'DV' para divergencia |

> Adicione mais linhas conforme necessario. Lembre-se: existem **10 regras escondidas** no codigo!

## Regras por Categoria

### Calculos Financeiros
- BR-PGT-04 a BR-PGT-10 (fatores regionais, renda, familiar, idade + formula principal + reajuste)
- BR-PGT-11 (truncamento monetario)
- BR-PGT-12 (13o salario com formula simplificada)
- BR-PGT-13 (abono de Natal 15% para tipo A)
- BR-PGT-14 (desconto 3% acima de R$500)
- BR-PGT-15 (floor em R$0,00)
- BR-015 (recalculo de valor-base por fator K com constante 0.347215)
- BR-009 (ajuste de status por idade derivada de data de nascimento)
- BR-CON-03 (conversao centavos → reais)
- BR-CON-05 (tolerancia R$0,01)
- BR-REL-03 (arredondamento round vs truncamento — DIVERGENCIA)

### Validacoes de Status
- BR-008 (status inicial beneficiario `A`)
- BR-009 (idoso > 75 muda para `S`)
- BR-011 (status `C`/`D` bloqueia inclusao de dependente)
- BR-PGT-01 (somente STATUS='A' processado)
- BR-PGT-16 (status inicial pagamento 'G')
- BR-REL-04 (5 categorias: G, P, C, D, E)
- BR-CON-06/07/08 (transicoes G→P, G→D, G→E por COD_RET CNAB)
- BR-CON-09 (retorno desconhecido mantem status)

### Regras de Autorizacao
- BR-001 (operacao permitida apenas I/A)
- BR-006 e BR-007 (controle de existencia para incluir/alterar)
- BR-PGT-02 (idempotencia: 1 pagamento por CPF por competencia)
- BR-PGT-03 (programa deve existir e estar ativo)

### Regras de Negocio Temporais
- BR-010 (datas de cadastro/atualizacao com data corrente)
- BR-009 (regra etaria baseada em ano de nascimento)
- BR-PGT-12 (13o salario somente em dezembro)
- BR-PGT-13 (abono natalino somente em dezembro para tipo A)
- BR-PGT-17 (tipo pagamento 'D' para dezembro)
- BR-PGT-19 (calculo de idade aproximado — ignora mes/dia)

### Conciliacao Bancaria
- BR-CON-01 (somente registros CNAB tipo detalhe)
- BR-CON-02 (layout CNAB 240 BB com posicoes hardcoded)
- BR-CON-04 (match por chave tripla)
- BR-CON-10 (auditoria obrigatoria CO/DV)

### Relatorios
- BR-REL-01 a BR-REL-08 (filtro, agregacao, arredondamento, formato)

## Resumo Estatistico

- Total de regras encontradas: 52 (Par 1: 15, Par 2: 37)
- Regras criticas: 18
- Regras alto risco: 17
- Regras medio risco: 13
- Regras baixo risco: 1
- Regras sem documentacao (escondidas): 3
- Programas cobertos: 6 / 15 (CADBENEF, CADDEPEND, CADPROG, BATCHPGT, BATCHREL, BATCHCON)
