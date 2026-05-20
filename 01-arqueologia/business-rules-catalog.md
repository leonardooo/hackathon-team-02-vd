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
| BR-CALC-01 | Tabela de fatores regionais: 27 regioes com variacao 1.00 a 1.40 (Norte/Nordeste ate 40% bonus) | legacy/natural-programs/CALCBENF.NSN#L78-L103 | COD-REGIAO | ALTO | Duplicada no BATCHPGT. Regiao 99 (ESPEC) com fator 1.0 |
| BR-CALC-02 | Fator familiar: 0 dep→1.0; 1-2→1.0+(N×0.05); 3-4→1.1+((N-2)×0.03); 5+→1.16+((N-4)×0.02) | legacy/natural-programs/CALCBENF.NSN#L144-L163 | BENEFICIARIO.NUM-DEPENDENTES | CRITICO | Progressao nao linear. 5 dep = +16% permanente |
| BR-CALC-03 | Fator renda 5 faixas: <=300(1.0), <=600(0.85), <=1000(0.70), <=1500(0.55), >1500(0.40) | legacy/natural-programs/CALCBENF.NSN#L134-L142 | BENEFICIARIO.RENDA-FAMILIAR | CRITICO | Inversamente proporcional a renda |
| BR-CALC-04 | Fator idade: <18→1.05; 18-59→1.0; 60-64→1.1; 65+→1.15 | legacy/natural-programs/CALCBENF.NSN#L167-L180 | BENEFICIARIO.DT-NASCIMENTO | ALTO | Idosos +15%, criancas +5% |
| BR-CALC-05 | Formula principal: VLR_BENF = BASE × FATOR_REG × FATOR_FAM × FATOR_RND × FATOR_IDADE | legacy/natural-programs/CALCBENF.NSN#L195-L197 | Multiplos | CRITICO | 4 fatores compostos. Maximo teorico +88% |
| BR-CALC-06 | Truncamento para 2 casas decimais (mult 100, int, div 100) | legacy/natural-programs/CALCBENF.NSN#L200-L202 | #VLR-TEMP | MEDIO | Nao e arredondamento padrao |
| BR-CALC-07 | 13o salario em dezembro: VLR_13 = BASE × FATOR_REG × FATOR_IDADE (SEM familiar/renda) | legacy/natural-programs/CALCBENF.NSN#L215-L221 | PAGAMENTO.TIPO-PGTO='D' | CRITICO | 13o ~30-40% menor que mes regular |
| BR-CALC-08 | Abono natalino 15% em dezembro para programas TIPO='A' | legacy/natural-programs/CALCBENF.NSN#L224-L230 | PROGRAMA-SOCIAL.TIPO-PROGRAMA | ALTO | Bonus exclusivo tipo A. Criterio nao documentado |
| BR-CALC-09 | Desconto simplificado: 3% se VLR_BRUTO > R$500 | legacy/natural-programs/CALCBENF.NSN#L238-L244 | #VLR-DESC | MEDIO | Versao simplificada — CALCDSCT tem 4 aliquotas |
| BR-CORR-01 | Correcao retroativa por IPCA: indice acumulado × valor original | legacy/natural-programs/CALCCORR.NSN#L104-L116 | PAGAMENTO.VLR-BRUTO, VLR-CORRECAO | ALTO | Aplica apenas se diferenca > 0 |
| BR-CORR-02 | Tabela IPCA carregada apenas para 2010-2012 (ultima carga: 2014) | legacy/natural-programs/CALCCORR.NSN#L38-L80 | #IPCA-ANO | CRITICO | Correcoes 2013+ usam indices obsoletos |
| BR-CORR-03 | Idempotencia: somente registros com IND-CORRIGIDO != 'S' | legacy/natural-programs/CALCCORR.NSN#L97-L101 | PAGAMENTO.IND-CORRIGIDO | MEDIO | Sem mecanismo de retry |
| BR-CORR-04 | Plano Verao (comentado): periodo 01/1989-01/1991 com multiplicador 2.75x | legacy/natural-programs/CALCCORR.NSN#L39-L50 | (desativado) | CRITICO | EGG-001: codigo morto marcado "NAO REMOVER" |
| BR-DSCT-01 | Desconto social 4 aliquotas: <=500(3%), <=1000(5%), <=2000(7%), >2000(9%) | legacy/natural-programs/CALCDSCT.NSN#L43-L49 | PAGAMENTO.VLR-BRUTO | ALTO | Progressividade. Base R$500 pode estar desatualizada |
| BR-DSCT-02 | Teto maximo desconto: 30% do bruto (EXCETO judicial) | legacy/natural-programs/CALCDSCT.NSN#L88-L92 | #VLR-MAX-DSCT | ALTO | Judicial sem protecao — risco de liquido negativo |
| BR-DSCT-03 | 6 tipos de desconto: J=Judicial, P=Pensao, I=Imposto, S=Sindical(1%), C=Contribuicao, A=Administrativo | legacy/natural-programs/CALCDSCT.NSN#L107-L153 | TIPO-DSCT | ALTO | Sindical fixo 1%. Demais variaveis |
| BR-DSCT-04 | Desconto judicial sem teto ("JUDICIAL NAO TEM TETO") | legacy/natural-programs/CALCDSCT.NSN#L119-L130 | TIPO-DSCT='J' | CRITICO | Pode levar liquido a zero/negativo |
| BR-DSCT-05 | Vigencia de descontos: DT-FIM < HOJE ou DT-INICIO > HOJE → ignorado. DT-FIM=0 → sem limite | legacy/natural-programs/CALCDSCT.NSN#L109-L116 | DT-INICIO-DSCT, DT-FIM-DSCT | MEDIO | Comportamento implicito para data zero |
| BR-DSCT-06 | Valor fixo (VLR-DSCT > 0) tem prioridade sobre percentual (PCT-DSCT) | legacy/natural-programs/CALCDSCT.NSN#L124-L153 | VLR-DSCT, PCT-DSCT | MEDIO | Nao documentado. Risco de sobre-desconto |
| BR-VAL-01 | CPF validado por Mod-11 com 2 digitos verificadores (canonica Receita Federal) | legacy/natural-programs/VALBENEF.NSN#L205-L238 | BENEFICIARIO.NUM-CPF | CRITICO | Duplicada em VALDOCS e CADBENEF |
| BR-VAL-02 | CPF com todos 11 digitos iguais e rejeitado (exceto prefixo 000 = "TESTE GOVERNO") | legacy/natural-programs/VALBENEF.NSN#L187-L203 | BENEFICIARIO.NUM-CPF | CRITICO | VALDOCS NAO implementa esta verificacao |
| BR-VAL-03 | EXCECAO: CPF prefixo 000 com digitos iguais aceito como "TESTE GOVERNO" | legacy/natural-programs/VALBENEF.NSN#L196-L200 | BENEFICIARIO.NUM-CPF | CRITICO | Backdoor explicito no codigo |
| BR-VAL-04 | Data nascimento: ano 1900-atual, mes 1-12, dia 1-max do mes | legacy/natural-programs/VALBENEF.NSN#L242-L258 | BENEFICIARIO.DT-NASCIMENTO | ALTO | Formato AAAAMMDD |
| BR-VAL-05 | Fevereiro sempre aceita dia 29 sem verificar bissexto | legacy/natural-programs/VALBENEF.NSN#L96 | BENEFICIARIO.DT-NASCIMENTO | MEDIO | Bug sutil: 29/02 aceito em qualquer ano |
| BR-VAL-06 | Nome obrigatorio com pelo menos 1 espaco (nome + sobrenome) | legacy/natural-programs/VALBENEF.NSN#L262-L277 | BENEFICIARIO.NOME-COMPLETO | ALTO | Alteracao 2010. Nao valida caracteres invalidos |
| BR-VAL-07 | UF validada contra 27 estados hardcoded. UF em branco aceita silenciosamente | legacy/natural-programs/VALBENEF.NSN#L66-L92 | BENEFICIARIO.UF | MEDIO | Campo opcional |
| BR-VAL-08 | Status aceito: A, S, C, I, D. Outro valor rejeitado | legacy/natural-programs/VALBENEF.NSN#L164-L169 | BENEFICIARIO.SIT-BENEFICIARIO | ALTO | Consistente com DDM |
| BR-VAL-09 | Validacao acumulativa: ate 10 erros simultaneos | legacy/natural-programs/VALBENEF.NSN#L31 | — | MEDIO | Array #MSG-ERRO(10). Nao para no primeiro erro |
| BR-VAL-10 | CEP e SEXO declarados mas NUNCA validados neste programa | legacy/natural-programs/VALBENEF.NSN#L17-L19 | BENEFICIARIO.CEP, SEXO | MEDIO | CEP sem validacao. SEXO so validado em CADBENEF |
| BR-DOC-01 | CPF = 0 rejeitado imediatamente antes do calculo de DV | legacy/natural-programs/VALDOCS.NSN#L102-L105 | BENEFICIARIO.NUM-CPF | ALTO | Diferente de VALBENEF |
| BR-DOC-02 | CPF validado por Mod-11 SEM checagem de digitos todos iguais | legacy/natural-programs/VALDOCS.NSN#L100-L143 | BENEFICIARIO.NUM-CPF | CRITICO | Inconsistente com VALBENEF |
| BR-DOC-03 | RG obrigatorio, minimo 5 caracteres | legacy/natural-programs/VALDOCS.NSN#L146-L163 | BENEFICIARIO.RG-NUMERO | MEDIO | Comprimento por posicao do primeiro espaco |
| BR-DOC-04 | 8 prefixos CPF especiais: 000, 001, 002, 010, 011, 099, 100, 999 | legacy/natural-programs/VALDOCS.NSN#L49-L56 | — | CRITICO | Faixas de teste governo hardcoded |
| BR-DOC-05 | BACKDOOR: prefixo especial apaga TODOS erros, forca VALIDO. EGG-002 | legacy/natural-programs/VALDOCS.NSN#L168-L182 | — | CRITICO | Subrotina CHECK-DOC-ESPECIAL. Backdoor de teste em producao |
| BR-DOC-06 | TITULO ELEITOR e CTPS capturados via INPUT mas nunca validados | legacy/natural-programs/VALDOCS.NSN#L22-L23 | — | MEDIO | Codigo morto desde 1998 |
| BR-DOC-07 | DOCUMENTOS-OK declarado mas NUNCA atualizado pelo programa | legacy/natural-programs/VALDOCS.NSN#L18 | BENEFICIARIO.DOCUMENTOS-OK | ALTO | VALELEG depende deste flag. Quem o seta? |
| BR-DOC-08 | CHECK-DOC-ESPECIAL executa APOS validacoes, podendo REVERTER resultados invalidos | legacy/natural-programs/VALDOCS.NSN#L85-L88 | — | CRITICO | Ordem: valida CPF → valida RG → limpa tudo |
| BR-DOC-09 | Maximo 5 mensagens de erro (vs 10 no VALBENEF) | legacy/natural-programs/VALDOCS.NSN#L25 | — | BAIXO | Inconsistencia de design |
| BR-ELEG-01 | Beneficiario deve existir no ARQ 150 (busca por CPF) | legacy/natural-programs/VALELEG.NSN#L69-L84 | BENEFICIARIO.NUM-CPF | ALTO | FIND com flag #FOUND-B |
| BR-ELEG-02 | Programa social deve existir (busca por COD-PROGRAMA) | legacy/natural-programs/VALELEG.NSN#L87-L97 | PROGRAMA-SOCIAL.COD-PROGRAMA | ALTO | Comentario diz ARQ 155, DDM define FNR 151 |
| BR-ELEG-03 | Programa deve estar ativo (STATUS-PROG='A'). Inativo aborta | legacy/natural-programs/VALELEG.NSN#L99-L102 | PROGRAMA-SOCIAL.SIT-PROGRAMA | ALTO | ESCAPE ROUTINE sem registrar motivo |
| BR-ELEG-04 | REGIAO 99 (Internacional/Diplomatico) bypassa TODAS verificacoes. MYS-008 resolvido | legacy/natural-programs/VALELEG.NSN#L107-L111 | BENEFICIARIO.COD-REGIAO | CRITICO | Adicionado 2013 por Anderson Lima. Sem auditoria |
| BR-ELEG-05 | Status 'A' unico aceito. S/C/D/I → nao elegivel com mensagem especifica | legacy/natural-programs/VALELEG.NSN#L116-L134 | BENEFICIARIO.SIT-BENEFICIARIO | ALTO | Verifica todos, nao para no primeiro |
| BR-ELEG-06 | Faixa etaria: IDADE-MIN e IDADE-MAX do programa (se > 0) verificados | legacy/natural-programs/VALELEG.NSN#L139-L152 | PROGRAMA-SOCIAL.IDADE-MIN, IDADE-MAX | ALTO | Valor 0 desativa check |
| BR-ELEG-07 | Renda familiar: se RENDA-MAX > 0, renda nao pode exceder | legacy/natural-programs/VALELEG.NSN#L157-L163 | PROGRAMA-SOCIAL.RENDA-MAX | CRITICO | Verificacao generica do programa |
| BR-ELEG-08 | Tipo A (Assistencial): renda > R$600 sem dependentes → inelegivel. Exige DOCUMENTOS-OK='S' | legacy/natural-programs/VALELEG.NSN#L169-L182 | BENEFICIARIO.VLR-RENDA-FAMILIAR, NUM-DEPENDENTES | CRITICO | R$600 hardcoded. Com dependentes, aceita |
| BR-ELEG-09 | Tipo P (Previdenciario): idade minima 60 hardcoded | legacy/natural-programs/VALELEG.NSN#L183-L189 | BENEFICIARIO.DT-NASCIMENTO | ALTO | Pode conflitar com IDADE-MIN do programa |
| BR-ELEG-10 | Tipo T (Trabalho): idade 16-65 hardcoded | legacy/natural-programs/VALELEG.NSN#L190-L196 | BENEFICIARIO.DT-NASCIMENTO | ALTO | Pode conflitar com IDADE-MIN/MAX |
| BR-ELEG-11 | Tipo desconhecido (nao A/P/T) → inelegivel | legacy/natural-programs/VALELEG.NSN#L197-L201 | PROGRAMA-SOCIAL.TIPO-PROGRAMA | MEDIO | Clausula NONE |
| BR-ELEG-12 | Elegibilidade especifica: 1o char='R' → exige NIS; 2o char='D' → exige dependentes | legacy/natural-programs/VALELEG.NSN#L223-L242 | PROGRAMA-SOCIAL.COD-ELEGIBILIDADE | ALTO | Apenas 2 dos 5 chars interpretados |
| BR-ELEG-13 | Calculo idade aproximado: ano_atual - ano_nascimento (ignora mes/dia) | legacy/natural-programs/VALELEG.NSN#L72-L73 | BENEFICIARIO.DT-NASCIMENTO | MEDIO | Pode errar ±1 ano |
| BR-ELEG-14 | Rejeicao acumulativa: ate 10 motivos simultaneos | legacy/natural-programs/VALELEG.NSN#L41 | — | MEDIO | Exceto regiao 99 e abortos |
| BR-ELEG-15 | NAO verifica se beneficiario ja esta inscrito no programa | legacy/natural-programs/VALELEG.NSN#L19 | BENEFICIARIO.COD-PROGRAMA | BAIXO | Verificacao pre-inscricao |
| BR-CONS-01 | Busca por CPF (tipo 'C') ou NIS (tipo 'N'). Outro valor rejeitado | legacy/natural-programs/CONSBENF.NSN#L76-L90 | BENEFICIARIO.CPF, NIS | ALTO | Dual-key lookup |
| BR-CONS-02 | Tipo busca em branco → default CPF ('C') | legacy/natural-programs/CONSBENF.NSN#L73-L75 | — | MEDIO | Regra silenciosa |
| BR-CONS-03 | Tela MAP com fallback INPUT inline quando erro | legacy/natural-programs/CONSBENF.NSN#L65-L71 | — | MEDIO | Degradacao graceful |
| BR-CONS-04 | CPF mascarado ***.***.XXX-XX (oculta 6 primeiros, exibe 5 ultimos) | legacy/natural-programs/CONSBENF.NSN#L149-L168 | BENEFICIARIO.CPF | CRITICO | Bug conhecido: CPF < 10^10 mostra primeiros 3 digitos |
| BR-CONS-05 | Status mapeado: A=ATIVO, S=SUSPENSO, C=CANCELADO, I=INATIVO, D=DESLIGADO | legacy/natural-programs/CONSBENF.NSN#L97-L110 | BENEFICIARIO.STATUS | ALTO | Tratamento NONE→DESCONHECIDO |
| BR-CONS-06 | Historico pagamentos limitado a ultimos 12 registros | legacy/natural-programs/CONSBENF.NSN#L127-L140 | PAGAMENTO.CPF-BENEF | ALTO | Hardcoded 12. Sem paginacao |
| BR-CONS-07 | Leitura por READ BY CPF-BENEF (ascendente). Para quando CPF muda | legacy/natural-programs/CONSBENF.NSN#L128-L132 | PAGAMENTO.CPF-BENEF | MEDIO | Sem filtro de periodo |
| BR-CONS-08 | Mensagem "NENHUM PAGAMENTO ENCONTRADO" se historico vazio | legacy/natural-programs/CONSBENF.NSN#L143-L145 | — | BAIXO | Feedback operador |
| BR-CONS-09 | "BENEFICIARIO NAO ENCONTRADO" aborta com ESCAPE ROUTINE | legacy/natural-programs/CONSBENF.NSN#L92-L94 | — | ALTO | Fluxo interrompido |
| BR-CONS-10 | Exibe 15 campos cadastrais na tela (renda, endereco, NIS, CPF) | legacy/natural-programs/CONSBENF.NSN#L112-L125 | BENEFICIARIO.* | MEDIO | Exposicao dados sensiveis sem controle de acesso |
| BR-RPGT-01 | Filtro periodo por competencia: COMP-INI a COMP-FIM | legacy/natural-programs/RELPGT.NSN#L70-L74 | PAGAMENTO.COMPETENCIA | ALTO | READ BY COMPETENCIA indexado |
| BR-RPGT-02 | Filtro programa: COD-PROG-FILTRO=0 → todos os programas | legacy/natural-programs/RELPGT.NSN#L76-L79 | PAGAMENTO.COD-PROGRAMA | ALTO | Zero como wildcard |
| BR-RPGT-03 | Quebra (control-break) por programa: subtotal quando COD-PROGRAMA muda | legacy/natural-programs/RELPGT.NSN#L82-L88 | PAGAMENTO.COD-PROGRAMA | ALTO | Requer ordenacao estavel |
| BR-RPGT-04 | Lookup beneficiario para cada pagamento: FIND por CPF (N+1 query) | legacy/natural-programs/RELPGT.NSN#L91-L96 | BENEFICIARIO.CPF, NOME, UF | MEDIO | Se nao encontra, nome/UF ficam branco |
| BR-RPGT-05 | CPF mascarado ***.XXX.XXX-XX (oculta 3 primeiros, exibe posicoes 4-11) | legacy/natural-programs/RELPGT.NSN#L99-L102 | PAGAMENTO.CPF-BENEF | CRITICO | Mascara DIFERENTE do CONSBENF |
| BR-RPGT-06 | Tipo pagamento: N=NORMAL, D=DECIMO, T=TERCEIRO. Outros→OUTRO | legacy/natural-programs/RELPGT.NSN#L105-L114 | PAGAMENTO.TIPO-PGTO | ALTO | TERCEIRO ('T') nao gerado por nenhum programa conhecido |
| BR-RPGT-07 | Status pagamento: G=GERADO, P=PAGO, C=CANCELAD, D=DEVOLVID, E=ESTORNAD | legacy/natural-programs/RELPGT.NSN#L117-L130 | PAGAMENTO.STATUS-PGTO | ALTO | Descricoes truncadas 8 chars |
| BR-RPGT-08 | Paginacao mainframe: 66 linhas/pagina. Form feed '/' | legacy/natural-programs/RELPGT.NSN#L58 | — | BAIXO | Cabecalho 6 linhas. Reserva 5 para footer |
| BR-RPGT-09 | Acumuladores gerais: TOT-BRUTO, TOT-DESC, TOT-LIQ, TOT-ABONO, QTD-REG (N13.2) | legacy/natural-programs/RELPGT.NSN#L140-L147 | PAGAMENTO.VLR-BRUTO, VLR-DESCONTO, VLR-LIQUIDO, VLR-ABONO | CRITICO | Acumula ABONO mas nao imprime por linha |
| BR-RPGT-10 | Subtotais por programa: apenas BRUTO e LIQUIDO + QTD (sem DESC/ABONO) | legacy/natural-programs/RELPGT.NSN#L148-L150 | — | MEDIO | Assimetria com total geral |
| BR-RPGT-11 | Total geral imprime ABONO em linha separada | legacy/natural-programs/RELPGT.NSN#L157-L163 | — | MEDIO | Adicionado 2010 Jose Ferreira |
| BR-RPGT-12 | Cabecalho: periodo, data atual, numero pagina | legacy/natural-programs/RELPGT.NSN#L188-L199 | — | BAIXO | Layout padrao mainframe |
| BR-RAUD-01 | Acoes de EXCLUSAO ('EX') SEMPRE filtradas do relatorio | legacy/natural-programs/RELAUDIT.NSN#L97-L100 | AUDITORIA.ACAO | CRITICO | Exclusoes invisiveis — so via SYSAOS |
| BR-RAUD-02 | Filtro periodo: DT-INI a DT-FIM. ESCAPE TOP/BOTTOM | legacy/natural-programs/RELAUDIT.NSN#L87-L93 | AUDITORIA.DT-EVENTO | ALTO | Leitura sequencial por data |
| BR-RAUD-03 | Default DT-INI = 19970101 (inception SIFAP). DT-FIM = data atual | legacy/natural-programs/RELAUDIT.NSN#L78-L83 | — | MEDIO | Sem data inicial lista TODO historico |
| BR-RAUD-04 | Filtro acao opcional: exibe apenas eventos da acao especificada | legacy/natural-programs/RELAUDIT.NSN#L103-L108 | AUDITORIA.ACAO | MEDIO | Filtro por valor exato |
| BR-RAUD-05 | Filtro usuario opcional | legacy/natural-programs/RELAUDIT.NSN#L111-L116 | AUDITORIA.USUARIO | MEDIO | Funcional |
| BR-RAUD-06 | Filtro tabela opcional | legacy/natural-programs/RELAUDIT.NSN#L119-L124 | AUDITORIA.TABELA-REF | MEDIO | Funcional |
| BR-RAUD-07 | Contadores por acao: IN, AL, CO, CN, DV. Outros→OUTRA | legacy/natural-programs/RELAUDIT.NSN#L128-L147 | AUDITORIA.ACAO | ALTO | 'CO' = CONCILIACAO aqui, mas DDM diz CO = CONSULTA |
| BR-RAUD-08 | Hora formatada HHMMSS → HH:MM:SS | legacy/natural-programs/RELAUDIT.NSN#L150-L152 | AUDITORIA.HR-EVENTO | BAIXO | Formatacao apresentacao |
| BR-RAUD-09 | Saida dual: T=Tela (WRITE) ou I=Impressora (PRINT). Default T | legacy/natural-programs/RELAUDIT.NSN#L74-L76 | — | MEDIO | Tela omite DESCRICAO |
| BR-RAUD-10 | Tela OMITE campo DESCRICAO (A80) — so visivel na impressora | legacy/natural-programs/RELAUDIT.NSN#L158-L167 | AUDITORIA.DESCRICAO | ALTO | Info critica nao visivel online |
| BR-RAUD-11 | Resumo final: total registros, exibidos, filtrados, breakdown por acao | legacy/natural-programs/RELAUDIT.NSN#L172-L204 | — | MEDIO | Resumo completo |
| BR-RAUD-12 | Paginacao: 66 linhas/pag. Impressora 120 col, tela 100 col | legacy/natural-programs/RELAUDIT.NSN#L155-L157 | — | BAIXO | Layout diferente por tipo saida |
| BR-RAUD-13 | Registros filtrados contabilizados separadamente (#QTD-FILTRADOS) | legacy/natural-programs/RELAUDIT.NSN#L95 | — | MEDIO | Permite verificar omissoes |

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
- BR-CALC-01 a BR-CALC-09 (motor de calculo completo: 4 fatores, 13o, abono, desconto simplificado)
- BR-CORR-01 a BR-CORR-04 (correcao retroativa IPCA, Plano Verao)
- BR-DSCT-01 a BR-DSCT-06 (descontos 4 aliquotas, 6 tipos, teto 30%, judicial sem teto)

### Validacoes de Status
- BR-008 (status inicial beneficiario `A`)
- BR-009 (idoso > 75 muda para `S`)
- BR-011 (status `C`/`D` bloqueia inclusao de dependente)
- BR-PGT-01 (somente STATUS='A' processado)
- BR-PGT-16 (status inicial pagamento 'G')
- BR-REL-04 (5 categorias: G, P, C, D, E)
- BR-CON-06/07/08 (transicoes G→P, G→D, G→E por COD_RET CNAB)
- BR-CON-09 (retorno desconhecido mantem status)
- BR-ELEG-05 (status A unico aceito para elegibilidade)

### Validacoes Cadastrais e de Documentos
- BR-VAL-01 a BR-VAL-10 (CPF Mod-11, data nascimento, nome, UF, status)
- BR-DOC-01 a BR-DOC-09 (CPF, RG, backdoor TESTE GOVERNO, DOCUMENTOS-OK)
- BR-ELEG-01 a BR-ELEG-15 (elegibilidade por tipo programa, regiao 99, renda, idade)

### Regras de Autorizacao
- BR-001 (operacao permitida apenas I/A)
- BR-006 e BR-007 (controle de existencia para incluir/alterar)
- BR-PGT-02 (idempotencia: 1 pagamento por CPF por competencia)
- BR-PGT-03 (programa deve existir e estar ativo)
- BR-DOC-05 (backdoor CHECK-DOC-ESPECIAL — EGG-002)
- BR-ELEG-04 (regiao 99 bypassa elegibilidade — MYS-008)

### Regras de Negocio Temporais
- BR-010 (datas de cadastro/atualizacao com data corrente)
- BR-009 (regra etaria baseada em ano de nascimento)
- BR-PGT-12 (13o salario somente em dezembro)
- BR-PGT-13 (abono natalino somente em dezembro para tipo A)
- BR-PGT-17 (tipo pagamento 'D' para dezembro)
- BR-PGT-19 (calculo de idade aproximado — ignora mes/dia)
- BR-DSCT-05 (vigencia de descontos com DT-FIM=0 → sem limite)
- BR-CORR-02 (tabela IPCA congelada 2010-2012)

### Conciliacao Bancaria
- BR-CON-01 (somente registros CNAB tipo detalhe)
- BR-CON-02 (layout CNAB 240 BB com posicoes hardcoded)
- BR-CON-04 (match por chave tripla)
- BR-CON-10 (auditoria obrigatoria CO/DV)

### Consulta e Relatorios
- BR-REL-01 a BR-REL-08 (filtro, agregacao, arredondamento, formato)
- BR-CONS-01 a BR-CONS-10 (busca dual CPF/NIS, mascara CPF, historico 12 registros)
- BR-RPGT-01 a BR-RPGT-12 (relatorio pagamentos: quebra programa, mascaramento, paginacao)
- BR-RAUD-01 a BR-RAUD-13 (auditoria: exclusoes ocultas, saida dual, filtros, contadores)

## Resumo Estatistico

- Total de regras encontradas: **120** (Par 1: 15, Par 2: 37, Par 3: 19, Par 4: 34, Par 5: 35)
- Regras criticas: 34
- Regras alto risco: 41
- Regras medio risco: 34
- Regras baixo risco: 8
- Regras sem documentacao (escondidas): 10 / 10
- Programas cobertos: **15 / 15**
- Easter eggs encontrados: **3 / 3** (EGG-001 Plano Verao, EGG-002 Backdoor VALDOCS, EGG-003 Banco Real)
