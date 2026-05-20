# Glossario do SIFAP Legado

> Preencha esta tabela com todos os termos, abreviacoes e siglas encontrados no codigo Natural/Adabas.
> **Meta: minimo 30 termos.**

## Como preencher

- **Termo**: A abreviacao ou sigla exatamente como aparece no codigo
- **Expansao**: O significado completo do termo
- **Programa**: Em qual arquivo .NSN ou .ddm o termo foi encontrado
- **Contexto**: Breve explicacao de como/onde o termo e usado

## Termos encontrados

| # | Termo | Expansao | Programa | Contexto |
|---|-------|----------|----------|----------|
| 1 | CPF | Cadastro de Pessoa Fisica | legacy/natural-programs/CADBENEF.NSN | Identificador principal do beneficiario e chave de busca no cadastro. |
| 2 | NIS | Numero de Identificacao Social | legacy/natural-programs/CADBENEF.NSN | Campo social do titular usado no registro cadastral. |
| 3 | DT-NASC | Data de Nascimento | legacy/natural-programs/CADBENEF.NSN | Base para validacao obrigatoria e calculo de idade. |
| 4 | #OPER | Operacao do fluxo (I/A ou I/C) | legacy/natural-programs/CADBENEF.NSN | Controla se a rotina executa inclusao ou alteracao/consulta. |
| 5 | MOD 11 | Algoritmo Modulo 11 | legacy/natural-programs/CADBENEF.NSN | Regra usada para validar os digitos verificadores do CPF. |
| 6 | #FOUND | Flag de registro encontrado | legacy/natural-programs/CADBENEF.NSN | Variavel logica que indica se o FIND localizou registro. |
| 7 | #ERRO | Flag de erro de validacao | legacy/natural-programs/CADBENEF.NSN | Aciona desvio de fluxo quando alguma regra falha. |
| 8 | STATUS | Situacao do beneficiario | legacy/natural-programs/CADBENEF.NSN | Define estado como ativo/suspenso/cancelado/desligado. |
| 9 | DT-CADASTRO | Data de cadastro inicial | legacy/natural-programs/CADBENEF.NSN | Campo gravado na inclusao do beneficiario. |
| 10 | DT-ATUALIZACAO | Data da ultima atualizacao | legacy/natural-programs/CADBENEF.NSN | Atualizada em inclusao e alteracao cadastral. |
| 11 | PE | Periodic Group | legacy/natural-programs/CADDEPEND.NSN | Estrutura repetitiva usada para armazenar dependentes. |
| 12 | NUM-DEPENDENTES | Quantidade de dependentes | legacy/natural-programs/CADDEPEND.NSN | Contador do total de dependentes vinculados ao titular. |
| 13 | PARENTESCO | Codigo de relacao familiar | legacy/natural-programs/CADDEPEND.NSN | Define tipo de dependente (FI/CO/IR/OU no programa). |
| 14 | CPF-DEP | CPF do dependente | legacy/natural-programs/CADDEPEND.NSN | Usado para evitar cadastro duplicado no mesmo titular. |
| 15 | #IDX | Indice da ocorrencia no grupo PE | legacy/natural-programs/CADDEPEND.NSN | Posiciona em qual ocorrencia do grupo de dependentes gravar. |
| 16 | REPEAT | Laco repetitivo Natural | legacy/natural-programs/CADDEPEND.NSN | Loop interativo para inclusao de multiplos dependentes. |
| 17 | ESCAPE TOP | Retorno ao topo do loop | legacy/natural-programs/CADDEPEND.NSN | Recomeça iteracao quando ha erro de validacao. |
| 18 | ESCAPE BOTTOM | Saida do loop/bloco | legacy/natural-programs/CADDEPEND.NSN | Encerra fluxo de inclusao quando limite/condicao e atingida. |
| 19 | COD-PROGRAMA | Codigo do programa social | legacy/natural-programs/CADPROG.NSN | Chave logica do cadastro de programas sociais. |
| 20 | VLR-BASE | Valor base do beneficio | legacy/natural-programs/CADPROG.NSN | Valor inicial que passa por fator de ajuste. |
| 21 | FATOR-REAJ | Fator de reajuste | legacy/natural-programs/CADPROG.NSN | Parametro informado na inclusao para recalculo monetario. |
| 22 | FATOR-K | Fator de correcao especial | legacy/natural-programs/CADPROG.NSN | Multiplicador aplicado no valor base com constante fixa. |
| 23 | COD-ELEGIBILIDADE | Codigo de elegibilidade | legacy/natural-programs/CADPROG.NSN | Identifica regra/cenario de elegibilidade do programa. |
| 24 | DT-FIM = 0 | Vigencia indeterminada | legacy/natural-programs/CADPROG.NSN | Convencao de data fim zerada para programa sem prazo final. |
| 25 | FIND | Comando de busca no Adabas | legacy/natural-programs/CADBENEF.NSN | Recupera registro por criterio em VIEW Adabas. |
| 26 | STORE | Comando de insercao de registro | legacy/natural-programs/CADBENEF.NSN | Persiste novo registro no arquivo Adabas. |
| 27 | UPDATE | Comando de atualizacao de registro | legacy/natural-programs/CADDEPEND.NSN | Grava alteracoes no registro ja encontrado. |
| 28 | END TRANSACTION | Confirmacao transacional | legacy/natural-programs/CADPROG.NSN | Confirma unidade de trabalho apos store/update. |
| 29 | DDM | Data Definition Module | legacy/adabas-ddms/BENEFICIARIO.ddm | Define schema Adabas (campos, tipo, tamanho, ocorrencias). |
| 30 | DE | Descriptor (indice Adabas) | legacy/adabas-ddms/BENEFICIARIO.ddm | Marca campo indexado para pesquisa eficiente. |
| 31 | COMPETENCIA | Mes/ano de referencia do pagamento | legacy/natural-programs/BATCHPGT.NSN | Chave do ciclo mensal (formato AAAAMM). Usada em idempotencia e filtros. |
| 32 | VLR-BENF | Valor calculado do beneficio | legacy/natural-programs/BATCHPGT.NSN | Resultado da formula de 4 fatores × VLR-BASE × (1+FATOR-REAJ). |
| 33 | VLR-BRUTO | Valor bruto do pagamento | legacy/natural-programs/BATCHPGT.NSN | Soma de beneficio + 13o salario + abono natalino. |
| 34 | VLR-LIQUIDO | Valor liquido apos descontos | legacy/natural-programs/BATCHPGT.NSN | VLR-BRUTO - VLR-DESCONTO, com floor em R$0,00. |
| 35 | FATOR-REG | Fator regional | legacy/natural-programs/BATCHPGT.NSN | Tabela hardcoded de 27 regioes (1.00 a 1.40). |
| 36 | FATOR-FAM | Fator familiar | legacy/natural-programs/BATCHPGT.NSN | Escalonado por numero de dependentes (0→1.0 ate 5+→1.16+). |
| 37 | FATOR-RND | Fator renda | legacy/natural-programs/BATCHPGT.NSN | 5 faixas inversamente proporcionais a renda familiar. |
| 38 | FATOR-IDADE | Fator etario | legacy/natural-programs/BATCHPGT.NSN | Acrescimo para idosos (>=65→1.15) e menores (<18→1.05). |
| 39 | CNAB 240 | Layout bancario padrao FEBRABAN | legacy/natural-programs/BATCHCON.NSN | Formato de arquivo de retorno do Banco do Brasil. |
| 40 | COD-RET | Codigo de retorno CNAB | legacy/natural-programs/BATCHCON.NSN | '00'=Pago, '01'=Devolvido, '02'=Estornado. |
| 41 | STATUS-PGTO | Status do pagamento | legacy/natural-programs/BATCHPGT.NSN | Maquina de estados: G(erado)→P(ago)/D(evolvido)/E(stornado)/C(ancelado). |
| 42 | NUM-PGTO | Numero unico do pagamento | legacy/natural-programs/BATCHPGT.NSN | Sequencial por ciclo. Parte da chave tripla de match na conciliacao. |
| 43 | TIPO-PGTO | Tipo do pagamento | legacy/natural-programs/BATCHPGT.NSN | 'N'=normal, 'D'=dezembro (com 13o/abono). |
| 44 | ACAO | Tipo de acao de auditoria | legacy/natural-programs/BATCHCON.NSN | 'CO'=conciliacao OK, 'DV'=divergencia encontrada. |
| 45 | SEQ-AUDIT | Sequencial de auditoria | legacy/natural-programs/BATCHCON.NSN | Contador incremental para trilha de auditoria (DDM AUDITORIA FNR 153). |
| 46 | SIFAP | Sistema de Fiscalizacao e Administracao de Pagamentos | legacy/legacy-docs/ | Sistema legado alvo da modernizacao. Em producao desde 1997. |
| 47 | MDAS | Ministerio do Desenvolvimento e Assistencia Social | legacy/legacy-docs/ | Orgao responsavel pelos programas sociais. |
| 48 | SENARC | Secretaria Nacional de Renda de Cidadania | legacy/legacy-docs/ | Secretaria que opera o SIFAP no dia a dia. |
| 49 | FNR | File Number (Adabas) | legacy/adabas-ddms/ | Numero do arquivo fisico Adabas (150=BENEF, 151=PROG, 152=PGTO, 153=AUDIT). |
| 50 | SIAFI | Sistema Integrado de Administracao Financeira | legacy/natural-programs/BATCHCON.NSN | Sistema do Tesouro Nacional. Integracao via FTP manual. |
| 51 | COMPETENCIA | Periodo de referencia AAAAMM | legacy/natural-programs/CALCBENF.NSN | Chave para identificar mes/ano do pagamento |
| 52 | FATOR-REG | Fator de Ajuste Regional | legacy/natural-programs/CALCBENF.NSN | Multiplicador 1.0-1.4 por regiao geografica |
| 53 | FATOR-FAM | Fator Familiar | legacy/natural-programs/CALCBENF.NSN | Aumenta 1.0 a 1.2 conforme dependentes |
| 54 | FATOR-RND | Fator de Renda | legacy/natural-programs/CALCBENF.NSN | Reduz beneficio: 1.0→0.40 conforme renda |
| 55 | FATOR-IDADE | Fator Etario | legacy/natural-programs/CALCBENF.NSN | Multiplicador 1.0-1.15 por faixa de idade |
| 56 | VLR-BENF | Valor do Beneficio Mensal | legacy/natural-programs/CALCBENF.NSN | Resultado formula: BASE × 4 fatores |
| 57 | VLR-ABONO | Valor do Abono Natalino | legacy/natural-programs/CALCBENF.NSN | +15% em dezembro para tipo A |
| 58 | VLR-13 | Valor do 13o Salario | legacy/natural-programs/CALCBENF.NSN | BASE × FATOR_REG × FATOR_IDADE (sem renda/dependentes) |
| 59 | TIPO-PROG | Tipo de Programa Social | legacy/natural-programs/CALCBENF.NSN | 'A'=Assistencial (com abono); outros sem |
| 60 | DT-CORRECAO | Data da Correcao Retroativa | legacy/natural-programs/CALCCORR.NSN | Preenchida quando VLR_CORRECAO calculado |
| 61 | VLR-CORRECAO | Valor da Correcao Retroativa | legacy/natural-programs/CALCCORR.NSN | Diferenca acumulada por IPCA |
| 62 | IND-CORRIGIDO | Indicador de Correcao Aplicada | legacy/natural-programs/CALCCORR.NSN | 'S'=ja corrigido (idempotencia) |
| 63 | IPCA | Indice Nacional Precos Consumidor Amplo | legacy/natural-programs/CALCCORR.NSN | Inflacao oficial usada para correcao |
| 64 | IND-ACUM | Indice Acumulado | legacy/natural-programs/CALCCORR.NSN | Produto dos (1 + IPCA_MES) para periodo |
| 65 | COMP-INI / COMP-FIM | Competencia Inicial/Final | legacy/natural-programs/CALCCORR.NSN | Periodo processamento correcoes |
| 66 | PLANO-VERAO | Correcao Plano Verao 1989-1991 (comentado) | legacy/natural-programs/CALCCORR.NSN | Moeda Cruzado→Cruzeiro; multiplicador 2.75x; EGG-001 |
| 67 | VLR-DESCONTO | Valor Total de Descontos | legacy/natural-programs/CALCDSCT.NSN | Soma de todos os descontos aplicados |
| 68 | TIPO-DSCT | Tipo de Desconto | legacy/natural-programs/CALCDSCT.NSN | J=Judicial, P=Pensao, I=Imposto, S=Sindical, C=Contrib, A=Admin |
| 69 | PCT-DSCT | Percentual de Desconto | legacy/natural-programs/CALCDSCT.NSN | Se VLR-DSCT=0, usar percentual sobre bruto |
| 70 | VLR-DSCT | Valor Fixo de Desconto | legacy/natural-programs/CALCDSCT.NSN | Se > 0, prioridade sobre PCT-DSCT |
| 71 | DT-INICIO-DSCT / DT-FIM-DSCT | Vigencia do Desconto | legacy/natural-programs/CALCDSCT.NSN | DT-FIM=0 → sem limite |
| 72 | NUM-PROCESSO | Numero do Processo Judicial | legacy/natural-programs/CALCDSCT.NSN | Identifica ordem judicial de desconto |
| 73 | VLR-MAX-DSCT | Teto Maximo de Desconto | legacy/natural-programs/CALCDSCT.NSN | 30% bruto (exceto judicial) |
| 74 | #RESULTADO | Flag resultado V=Valido / I=Invalido | legacy/natural-programs/VALBENEF.NSN | Retorno principal da validacao cadastral |
| 75 | #TODOS-IGUAIS | Flag CPF com todos digitos iguais | legacy/natural-programs/VALBENEF.NSN | CPFs como 111...1 sao invalidos |
| 76 | #DV1 / #DV2 | Digitos verificadores calculados | legacy/natural-programs/VALBENEF.NSN | Comparados com posicoes 10 e 11 do CPF |
| 77 | #DIAS-MES | Tabela dias por mes (array 1-12) | legacy/natural-programs/VALBENEF.NSN | Feb=29 fixo (sem check bissexto) |
| 78 | RG | Registro Geral (carteira identidade) | legacy/natural-programs/VALDOCS.NSN | Obrigatorio, minimo 5 caracteres |
| 79 | TITULO | Titulo de Eleitor | legacy/natural-programs/VALDOCS.NSN | Capturado mas nunca validado (morto) |
| 80 | CTPS | Carteira de Trabalho e Previdencia Social | legacy/natural-programs/VALDOCS.NSN | Capturado mas nunca validado (morto) |
| 81 | #PREF-ESP | Prefixos Especiais CPF (governo/teste) | legacy/natural-programs/VALDOCS.NSN | 8 prefixos: 000,001,002,010,011,099,100,999 |
| 82 | CHECK-DOC-ESPECIAL | Subrotina verificacao doc especial | legacy/natural-programs/VALDOCS.NSN | Backdoor que limpa erros para prefixos especiais |
| 83 | #ELEGIVEL | Flag de elegibilidade | legacy/natural-programs/VALELEG.NSN | TRUE=elegivel, FALSE=nao elegivel |
| 84 | REGIAO 99 | Regiao especial Internacional/Diplomatico | legacy/natural-programs/VALELEG.NSN | Bypassa todas verificacoes. Adicionada 2013 |
| 85 | TIPO A | Programa Assistencial | legacy/natural-programs/VALELEG.NSN | Exige renda baixa e documentacao completa |
| 86 | TIPO P | Programa Previdenciario | legacy/natural-programs/VALELEG.NSN | Exige idade minima 60 (hardcoded) |
| 87 | TIPO T | Programa de Trabalho | legacy/natural-programs/VALELEG.NSN | Exige idade 16-65 (hardcoded) |
| 88 | DOCUMENTOS-OK | Flag documentacao completa S/N | legacy/natural-programs/VALELEG.NSN | Usado tipo A. Nunca setado por VALDOCS |
| 89 | COD-ELEGIBILIDADE | Codigo elegibilidade especifica A5 | legacy/natural-programs/VALELEG.NSN | 1o char R=exige NIS, 2o char D=exige dependentes |
| 90 | #MOTIVO | Array motivos inelegibilidade (10) | legacy/natural-programs/VALELEG.NSN | Acumulador razoes de rejeicao |
| 91 | CONSBENF | Consulta Beneficiario | legacy/natural-programs/CONSBENF.NSN | Programa online 3270 consulta cadastral |
| 92 | #TIPO-BUSCA | Tipo busca (C=CPF, N=NIS) | legacy/natural-programs/CONSBENF.NSN | Seletor modo de busca |
| 93 | #CPF-MASK | CPF mascarado para exibicao | legacy/natural-programs/CONSBENF.NSN | Formato ***.***.XXX-XX |
| 94 | #STATUS-DESC | Descricao status do beneficiario | legacy/natural-programs/CONSBENF.NSN | Traducao codigo 1 char → texto |
| 95 | RELPGT | Relatorio de Pagamentos | legacy/natural-programs/RELPGT.NSN | Relatorio analitico com totalizadores |
| 96 | #COMP-INI / #COMP-FIM | Competencia inicial/final (filtro RELPGT) | legacy/natural-programs/RELPGT.NSN | Periodo do relatorio AAAAMM |
| 97 | #COD-PROG-FILTRO | Codigo programa filtro (0=todos) | legacy/natural-programs/RELPGT.NSN | Zero como wildcard |
| 98 | #MAX-LINHAS | Maximo linhas por pagina | legacy/natural-programs/RELPGT.NSN | Hardcoded 66 — padrao mainframe |
| 99 | #PROG-ANT | Programa anterior (controle quebra) | legacy/natural-programs/RELPGT.NSN | Detecta mudanca de programa |
| 100 | TIPO-PGTO 'T' | Tipo pagamento TERCEIRO | legacy/natural-programs/RELPGT.NSN | Mapeado mas nao gerado — origem desconhecida |
| 101 | RELAUDIT | Relatorio de Auditoria | legacy/natural-programs/RELAUDIT.NSN | Trilha auditoria com filtros e resumo |
| 102 | #TIPO-SAIDA | Tipo saida (T=Tela, I=Impressora) | legacy/natural-programs/RELAUDIT.NSN | Seletor destino relatorio |
| 103 | #ACAO-FILTRO | Filtro acao auditoria | legacy/natural-programs/RELAUDIT.NSN | Filtra por codigo acao (2 chars) |
| 104 | #USUARIO-FILTRO | Filtro usuario auditoria | legacy/natural-programs/RELAUDIT.NSN | Filtra por login operador |
| 105 | ACAO 'EX' | Acao Exclusao (sempre oculta) | legacy/natural-programs/RELAUDIT.NSN | Filtrada incondicionalmente — so via SYSAOS |
| 106 | ACAO 'CN' | Acao Consulta (extensao) | legacy/natural-programs/RELAUDIT.NSN | Nao definido no DDM |
| 107 | ACAO 'DV' | Acao Divergencia (extensao) | legacy/natural-programs/RELAUDIT.NSN | Divergencias conciliacao — nao no DDM |
| 108 | SYSAOS | System Adabas Online Services | legacy/adabas-ddms/AUDITORIA.ddm | Interface direta Adabas — unico modo ver exclusoes |
| 109 | IN-TCU 63/2010 | Instrucao Normativa TCU 63/2010 | legacy/adabas-ddms/AUDITORIA.ddm | Obrigatoriedade legal trilha auditoria |
| 110 | PORT. 213/2010 | Portaria CGTI 213/2010 | legacy/adabas-ddms/AUDITORIA.ddm | Decisao parar gravar acoes CO (consulta) |
| 111 | #QTD-FILTRADOS | Quantidade registros filtrados | legacy/natural-programs/RELAUDIT.NSN | Conta total registros omitidos |
| 112 | RENDA-MAX | Teto renda familiar do programa | legacy/natural-programs/VALELEG.NSN | Se >0, renda familiar nao pode exceder |
| 113 | NIS | Numero Identificacao Social (VALELEG) | legacy/natural-programs/VALELEG.NSN | Mapeamento DDM incerto (NUM-INSCRICAO?) |

> Adicione mais linhas conforme necessario. Nao se limite a 30!

## Observacoes

- Anote aqui qualquer padrao de nomenclatura que o time identificou:
- Prefixo `#` para variaveis locais de trabalho em Natural.
- Sufixo `-V` para views de arquivo Adabas (ex.: `BENEFICIARIO-V`).
- Convencoes de prefixo/sufixo encontradas:
- Campos de data com prefixo `DT-` e codigos com prefixo `COD-`.
- Campos de valor com prefixo `VLR-` e contadores com `NUM-`.
- Termos ambiguos que precisam de validacao com especialista:
- Tabela de parentesco divergente entre programa e DDM (`CO/IR/OU` vs `CJ/NT/TU`).
- Uso e origem normativa do `FATOR-K` e da constante 0.347215.
