# Misterios Encontrados - SIFAP Legado

> Registre aqui toda logica, comportamento ou codigo que o time nao conseguiu explicar.
> "Misterios" sao trechos de codigo sem documentacao, com logica nao-obvia ou que parecem workarounds.

## O que conta como "misterio"?

- Codigo que faz algo inesperado sem comentario explicando por que
- Valores hardcoded sem explicacao (numeros magicos)
- Logica condicional que parece um workaround ou gambiarra
- Campos no DDM que nao sao usados por nenhum programa
- Programas que existem mas nao sao chamados por ninguem
- Comportamento diferente entre o que a documentacao diz e o que o codigo faz
- Easter eggs deixados pelos desenvolvedores originais

## Niveis de Confianca

| Nivel | Significado |
|-------|-------------|
| **ALTA** | Temos certeza de que ha algo estranho aqui |
| **MEDIA** | Parece suspeito, mas pode ter explicacao |
| **BAIXA** | Pode ser intencional, mas nao conseguimos confirmar |

## Misterios Catalogados

| ID | Descricao | Onde Encontrado | Impacto Potencial | Confianca |
|----|-----------|-----------------|-------------------|-----------|
| MYS-001 | Regra silenciosa muda status para `S` quando idade > 75, mesmo em inclusao nova. | legacy/natural-programs/CADBENEF.NSN#L156-L169 | Pode suspender automaticamente beneficiarios sem trilha explicativa para usuario/API. | ALTA |
| MYS-002 | Validacao de sexo no cadastro aceita apenas `M/F`, mas DDM oficial inclui `I` (indefinido). | legacy/natural-programs/CADBENEF.NSN#L131-L135; legacy/adabas-ddms/BENEFICIARIO.ddm#L26 | Risco de rejeitar dados validos segundo schema legado; quebra compatibilidade de carga historica. | ALTA |
| MYS-003 | Limite de dependentes no programa e 5, mas DDM define PE com maximo 10 ocorrencias. | legacy/natural-programs/CADDEPEND.NSN#L63-L66; legacy/adabas-ddms/BENEFICIARIO.ddm#L59-L61 | Perda funcional na migracao se limite correto for 10; divergencia de regra de negocio. | ALTA |
| MYS-004 | Codigos de parentesco divergem entre programa e DDM (`CO/IR/OU` vs `CJ/NT/TU`). | legacy/natural-programs/CADDEPEND.NSN#L84-L87; legacy/adabas-ddms/BENEFICIARIO.ddm#L65 | Inconsistencia de dominio e risco de dados invalidos/nao interoperaveis entre modulos. | ALTA |
| MYS-005 | CPF de dependente `0` passa na regra de duplicidade (validacao ignora quando CPF=0). | legacy/natural-programs/CADDEPEND.NSN#L96-L101; legacy/adabas-ddms/BENEFICIARIO.ddm#L62 | Permite multiplos dependentes sem identificador real; dificulta deduplicacao e antifraude. | MEDIA |
| MYS-006 | Constante magica `0.347215` no calculo de `FATOR-K` sem justificativa funcional no codigo. | legacy/natural-programs/CADPROG.NSN#L87-L88; legacy/adabas-ddms/PROGRAMA-SOCIAL.ddm#L39-L40 | Risco financeiro alto ao portar calculo sem origem normativa/documental. | ALTA |
| MYS-007 | Tipo de `COD-PROGRAMA` e alfanumerico no DDM (`A4`), mas programas tratam como numerico (`N4`). | legacy/natural-programs/CADBENEF.NSN#L23-L24; legacy/natural-programs/CADPROG.NSN#L14-L15; legacy/adabas-ddms/BENEFICIARIO.ddm#L48; legacy/adabas-ddms/PROGRAMA-SOCIAL.ddm#L21 | Possivel truncamento/conversao incorreta na modernizacao (ex.: codigos alfanumericos futuros). | ALTA |
| MYS-008 | Tipo de `COD-REGIAO` diverge: `N2` no programa e `A2` no DDM (valores `01-05` ou `99`). | legacy/natural-programs/CADBENEF.NSN#L30-L31; legacy/adabas-ddms/BENEFICIARIO.ddm#L44 | Falhas de serializacao e filtros por regiao se tipos nao forem harmonizados no novo modelo. | MEDIA |
| MYS-009 | Campo `DT-FIM` aceita `0=indeterminado`, mas nao ha validacao de consistencia com `DT-INICIO`. | legacy/natural-programs/CADPROG.NSN#L69-L70 | Pode permitir janelas de vigencia invalidas e regras temporais incoerentes no Stage 2. | MEDIA |
| MYS-010 | Fluxo de inclusao de dependentes faz multiplos `FIND` do mesmo titular no mesmo loop (leitura/validacao/update separados). | legacy/natural-programs/CADDEPEND.NSN#L47-L50; legacy/natural-programs/CADDEPEND.NSN#L95-L103; legacy/natural-programs/CADDEPEND.NSN#L110-L122 | Risco de condicao de corrida/performance e inconsistencias em ambiente concorrente moderno. | MEDIA |
| MYS-011 | Cabecalho BATCHPGT diz "CHAMA CALCBENF E CALCDSCT" mas NAO ha CALLNAT. Calculo inline de ~30 linhas vs CALCBENF de ~4800 linhas. | legacy/natural-programs/BATCHPGT.NSN#L1-L10; legacy/natural-programs/BATCHPGT.NSN#L279-L285 | **CRITICO** — qual versao do calculo e a canonica? Divergencia pode gerar pagamentos incorretos. | ALTA |
| MYS-012 | Tabela de 27 regioes hardcoded, mas IF valida apenas 1-25. Entradas 26-27 nunca acessadas. DDM mostra "01-05 OU 99 (ESPECIAL)". | legacy/natural-programs/BATCHPGT.NSN#L123-L150; legacy/natural-programs/BATCHPGT.NSN#L239-L244 | Mapeamento regional inconsistente entre programas. | ALTA |
| MYS-013 | Desconto simplificado de 3% no BATCHPGT vs CALCDSCT com 8 tipos (IR, judicial, consignacoes). | legacy/natural-programs/BATCHPGT.NSN#L306-L312 | Descontos podem estar incorretos — versao degradada ou proposital? | ALTA |
| MYS-014 | 13o salario calculado SEM fator familiar e SEM fator renda. Apenas VLR_BASE × FATOR_REG × FATOR_IDADE. | legacy/natural-programs/BATCHPGT.NSN#L291-L297 | Impacto financeiro direto — intencional ou bug? | ALTA |
| MYS-015 | Arredondamento BATCHREL (round +0.005) diverge de BATCHPGT (truncamento). Totais de relatorio ≠ valores pagos. | legacy/natural-programs/BATCHREL.NSN#L135-L139; legacy/natural-programs/BATCHPGT.NSN#L284-L285 | Relatorios gerenciais imprecisos — diferenca centaval acumulada. | ALTA |
| MYS-016 | Acumulador por status usa valor original, por regiao usa valor arredondado. Somas internas nao batem. | legacy/natural-programs/BATCHREL.NSN#L140-L167 | Inconsistencia interna do relatorio — total geral ≠ soma subtotais. | MEDIA |
| MYS-017 | COD-BANCO hardcoded como `1` (numerico), DDM define como `A3`. Valor `1` ≠ codigo BB (`001`). | legacy/natural-programs/BATCHCON.NSN#L172-L180; legacy/adabas-ddms/PAGAMENTO.ddm | Possivel bug de tipo — dados no campo podem estar incorretos. | ALTA |
| MYS-018 | VIEW do BATCHCON usa campos genericos, DDM tem campos dedicados de conciliacao (GA-GE) nunca usados. | legacy/natural-programs/BATCHCON.NSN#L50-L70; legacy/adabas-ddms/PAGAMENTO.ddm | Dados de conciliacao gravados no lugar errado — campos GA-GE desperdicados. | ALTA |
| MYS-019 | Bloco de codigo do Banco Real (356) comentado desde 2005, banco absorvido pelo Santander em 2007. | legacy/natural-programs/BATCHCON.NSN#L200-L230 | Dead code ha 19 anos. Nenhum risco funcional, mas poluicao do fonte. | BAIXA |
| MYS-020 | Array `#LOG-ERRO` declarado em 2004 no BATCHPGT mas nunca preenchido. | legacy/natural-programs/BATCHPGT.NSN#L90-L95 | Log de erros incompleto — erros de processamento sao silenciosos. | MEDIA |
| MYS-021 | Alteracao de 2015 "INC AUDITORIA" no BATCHPGT — nenhum codigo de auditoria existe no programa. | legacy/natural-programs/BATCHPGT.NSN#L340-L345 | Auditoria planejada mas nunca implementada — lacuna de compliance. | ALTA |
| MYS-022 | Campos NIS, RENDA-MAX e VLR-ABONO declarados em VIEWs do BATCHPGT mas nunca usados no codigo. | legacy/natural-programs/BATCHPGT.NSN#L50-L80 | Campos fantasma — requisitos dormentes ou dead data? | MEDIA |
| MYS-023 | Status 'C' (Cancelado) aparece na tabela do BATCHREL mas nenhum programa faz transicao para 'C'. | legacy/natural-programs/BATCHREL.NSN#L82-L86 | Quem seta STATUS='C'? Possivelmente operacao manual nunca implementada. | MEDIA |
| MYS-024 | BATCHPGT faz END TRANSACTION a cada STORE — ~4.2M commits individuais sem controle de batch/chunk. | legacy/natural-programs/BATCHPGT.NSN#L335-L340 | Performance e risco de inconsistencia — crash no meio deixa processamento parcial. | ALTA |
| MYS-025 | Calculo de idade usa apenas ano (ignora mes/dia) — pode errar ±1 ano na virada de aniversario. | legacy/natural-programs/BATCHPGT.NSN#L236-L237 | Beneficiarios nascidos no segundo semestre podem ter fator idade incorreto. | MEDIA |
| MYS-026 | 13o salario (CALCBENF) NAO aplica fator de renda e dependentes. Reduz valor 30-40% vs mes normal. Intencional ou bug? | legacy/natural-programs/CALCBENF.NSN#L215-L221 | Beneficiarios recebem 13o ~30-40% menor que pagamento regular. | MEDIA |
| MYS-027 | Abono natalino 15% apenas para programa tipo 'A'. Criterio nao documentado. | legacy/natural-programs/CALCBENF.NSN#L224-L230 | Apenas subset de beneficiarios ganha bonus natalino. | MEDIA |
| MYS-028 | Tabela IPCA (CALCCORR) carregada apenas ate 2012 com nota "ULTIMA CARGA: 2014". Correcoes 2013+ usam indices obsoletos ou falham. | legacy/natural-programs/CALCCORR.NSN#L38-L80 | **CRITICO** — 13 anos de correcoes potencialmente incorretas. | ALTA |
| MYS-029 | **EGG-001 — PLANO VERAO**: Bloco comentado referencia transicao Cruzado→Cruzeiro (1989-1991) com multiplicador 2.75x. Marcado "NAO REMOVER (HISTORICO)". | legacy/natural-programs/CALCCORR.NSN#L39-L50 | Codigo morto de 2003 ainda presente em 2026. Politica economica anos 90. | ALTA |
| MYS-030 | Desconto CALCBENF simplificado (3% >500) vs CALCDSCT completo (4 aliquotas: 3/5/7/9%). Qual modulo e chamado? Duplicacao. | legacy/natural-programs/CALCBENF.NSN#L238-L244 vs CALCDSCT.NSN#L43-L49 | Logica de desconto divergente entre programas. | MEDIA |
| MYS-031 | #FATOR-REAJ no CALCBENF multiplicado na formula final mas origem/setup nao aparece no codigo. Reajustes silenciosos. | legacy/natural-programs/CALCBENF.NSN#L191-L201 | Reajustes aplicados sem auditoria. | MEDIA |
| MYS-032 | Regiao 99 ("ESPEC") no CALCBENF com fator 1.0 mas nunca e setada em beneficiarios (antes da descoberta em VALELEG). | legacy/natural-programs/CALCBENF.NSN#L103 | Possivel codigo morto para regiao especial. | MEDIA |
| MYS-033 | C*DESCONTOS (CALCDSCT): sintaxe Natural para count de ocorrencias PE. Confirmacao necessaria. | legacy/natural-programs/CALCDSCT.NSN#L109 | Sintaxe legada pode nao ser obvia na modernizacao. | MEDIA |
| MYS-034 | VLR-DSCT (fixo) vs PCT-DSCT (percentual) podem ambos estar preenchidos. Codigo prioriza VLR-DSCT sem doc. | legacy/natural-programs/CALCDSCT.NSN#L124-L153 | Comportamento implicito, risco de sobre-desconto. | MEDIA |
| MYS-035 | Desconto judicial "NAO TEM TETO" enquanto outros tem 30%. Pode gerar liquido negativo sem protecao. | legacy/natural-programs/CALCDSCT.NSN#L119-L130 | **CRITICO** — risco legal e financeiro sem salvaguarda. | ALTA |
| MYS-036 | **EGG-002 — BACKDOOR TESTE**: CHECK-DOC-ESPECIAL em VALDOCS apaga TODOS erros para 8 prefixos CPF (000,001,002,010,011,099,100,999). Comentario "GOVERNO/TESTE" — nunca removido. | legacy/natural-programs/VALDOCS.NSN#L166-L182 | **CRITICO** — permite documentos invalidos passarem. Risco de fraude. | ALTA |
| MYS-037 | **DOCUMENTOS-OK nunca e setado**: VALDOCS declara campo na VIEW mas nunca grava. VALELEG depende de DOCUMENTOS-OK='S' para tipo A. | legacy/natural-programs/VALDOCS.NSN#L18; VALELEG.NSN#L178 | **CRITICO** — programas assistenciais podem ser rejeitados sistematicamente. | ALTA |
| MYS-038 | Fevereiro sempre aceita dia 29 sem verificar ano bissexto. #DIAS-MES(2)=29 fixo. | legacy/natural-programs/VALBENEF.NSN#L96 | Aceita 29/02 em anos nao-bissextos (ex: 29/02/2023). | ALTA |
| MYS-039 | CPFs com todos digitos iguais NAO rejeitados no VALDOCS (mas sim no VALBENEF). Inconsistencia entre validadores. | legacy/natural-programs/VALDOCS.NSN#L100-L143 vs VALBENEF.NSN#L187-L203 | Dois programas com regras diferentes para mesmo campo. | ALTA |
| MYS-040 | ARQ 155 nos comentarios de VALELEG vs FNR 151 no DDM PROGRAMA-SOCIAL. Comentario desatualizado? | legacy/natural-programs/VALELEG.NSN#L10-L86 | Se ARQ 155 diferente existe, VIEW pode ler dados errados. | MEDIA |
| MYS-041 | COD-PROGRAMA tipo N4 no programa vs A4 no DDM. Reforça MYS-007. | legacy/natural-programs/VALELEG.NSN#L19-L28 | Conversao implicita Adabas pode mascarar problemas. | ALTA |
| MYS-042 | COD-REGIAO tipo N2 no programa vs A2 no DDM. Regiao "99" funciona como numerico. | legacy/natural-programs/VALELEG.NSN#L22 | Texto como "AA" seria incompativel. | MEDIA |
| MYS-043 | Conflito regras idade hardcoded vs parametrizadas: tipo P exige >=60, tipo T exige 16-65, mas IDADE-MIN/MAX do programa ja verifica. | legacy/natural-programs/VALELEG.NSN#L139-L196 | Parametrizacao parcialmente ignorada por hardcode. | MEDIA |
| MYS-044 | Variaveis #NOME-TEMP e #CHAR declaradas no VALBENEF mas nunca usadas. Refactoring incompleto de 2010. | legacy/natural-programs/VALBENEF.NSN#L56-L59 | Dead variables. | ALTA |
| MYS-045 | TITULO ELEITOR e CTPS capturados no INPUT de VALDOCS e descartados. Codigo morto desde 1998. | legacy/natural-programs/VALDOCS.NSN#L22-L63 | Operador preenche campos desnecessariamente ha 26+ anos. | ALTA |
| MYS-046 | NIS declarado na VIEW de VALELEG mas nao existe no DDM com esse nome. Possivel mapeamento para NUM-INSCRICAO. | legacy/natural-programs/VALELEG.NSN#L24-L228 | Se mapeamento errado, verificacao NIS le campo errado. | MEDIA |
| MYS-047 | NOME e UF declarados na VIEW de VALDOCS mas nunca acessados. Campos fantasma — overhead I/O. | legacy/natural-programs/VALDOCS.NSN#L15-L17 | Overhead desnecessario. | ALTA |
| MYS-048 | R$600 hardcoded como limiar renda para programas assistenciais. Sem parametrizacao. | legacy/natural-programs/VALELEG.NSN#L171 | Valor magico financeiro afeta elegibilidade de milhoes. | ALTA |
| MYS-049 | Regiao 99 bypassada SEM registrar motivo (#MOTIVO). ESCAPE ROUTINE direto. Sem trilha auditavel. | legacy/natural-programs/VALELEG.NSN#L107-L111 | Elegibilidade concedida sem rastro. | ALTA |
| MYS-050 | Acesso a campos fora do bloco FIND (apos END-FIND). Natural retém ultimo valor. | legacy/natural-programs/VALELEG.NSN#L99-L157 | Se COD-PROGRAMA nao for unico, comportamento indefinido. | BAIXA |
| MYS-051 | #MSG (A78) declarada em VALELEG mas nunca usada. Dead variable. | legacy/natural-programs/VALELEG.NSN#L56 | Planejada para mensagem consolidada, substituida por #MOTIVO. | ALTA |
| MYS-052 | **Bug mascara CPF CONHECIDO**: CPF < 10^10 mostra primeiros 3 digitos em vez dos ultimos. Comentario: "NAO CORRIGIR SEM APROVACAO DA AUDITORIA". | legacy/natural-programs/CONSBENF.NSN#L149-L168 | **CRITICO** — exposicao de dados sensiveis. Aprovacao nunca veio. | ALTA |
| MYS-053 | Tipo pagamento 'T' (TERCEIRO) no RELPGT sem origem conhecida. BATCHPGT gera apenas 'N' e 'D'. | legacy/natural-programs/RELPGT.NSN#L108-L110 | Dead code ou entrada de sistema externo. | MEDIA |
| MYS-054 | Mascara CPF inconsistente: CONSBENF oculta 6 primeiros, RELPGT oculta 3 primeiros. Politicas divergentes. | legacy/natural-programs/CONSBENF.NSN#L154-L168 vs RELPGT.NSN#L99-L102 | Sem politica uniforme de mascaramento. | ALTA |
| MYS-055 | Lookup N+1 no RELPGT: FIND beneficiario para CADA pagamento. 100k pgtos = 100k FINDs extras. | legacy/natural-programs/RELPGT.NSN#L91-L96 | Performance degradada. Falhas silenciosas. | ALTA |
| MYS-056 | **Codigo acao 'CO' com DUPLO SIGNIFICADO**: DDM diz CO=CONSULTA, RELAUDIT/BATCHCON usam CO=CONCILIACAO. | legacy/natural-programs/RELAUDIT.NSN#L132-L133 vs AUDITORIA.ddm | **CRITICO** — colisao de namespace. Auditoria confunde conciliacoes/consultas. | ALTA |
| MYS-057 | Codigos 'CN' e 'DV' nao definidos no DDM AUDITORIA. Extensoes nao documentadas. | legacy/natural-programs/RELAUDIT.NSN#L136-L141 | Codigos de acao nao registrados na definicao formal. | MEDIA |
| MYS-058 | **Exclusoes INVISIVEIS na trilha de auditoria.** RELAUDIT filtra 'EX' incondicionalmente. Unico acesso via SYSAOS. | legacy/natural-programs/RELAUDIT.NSN#L97-L100 + AUDITORIA.ddm#L89-L91 | **CRITICO** — lacuna compliance. Possivel violacao IN-TCU 63/2010. | ALTA |
| MYS-059 | SEQ-AUDIT declarado N10 no VIEW vs N15 no DDM. Truncamento em IDs > 9.999.999.999. | legacy/natural-programs/RELAUDIT.NSN#L14 vs AUDITORIA.ddm#L22 | Relatorio pode truncar IDs de auditoria futuramente. | MEDIA |
| MYS-060 | VLR-ABONO acumulado globalmente no RELPGT mas NUNCA impresso por linha. Impossivel auditar quais pagamentos tiveram abono. | legacy/natural-programs/RELPGT.NSN#L29-L161 | Rastreabilidade prejudicada. Adicionado 2010. | ALTA |
| MYS-061 | Consulta CONSBENF sem controle de acesso. Qualquer operador ve TODOS os dados sensiveis (renda, endereco, NIS, CPF). | legacy/natural-programs/CONSBENF.NSN#L112-L125 | Exposicao dados sensiveis sem auditoria da consulta. | MEDIA |

## Detalhamento dos Misterios

### MYS-001: Suspensao automatica por idade

- **Arquivo**: `legacy/natural-programs/CADBENEF.NSN#L156-L169`
- **O que esperavamos**: status inicial `A` em toda inclusao valida.
- **O que o codigo faz**: altera para `S` quando idade > 75.
- **Hipotese do time**: regra historica de risco/fraude sem documentacao funcional atual.
- **Risco se ignorarmos**: modernizacao pode ativar idosos indevidamente ou suspender sem explicacao.

### MYS-003: Limite de dependentes divergente

- **Arquivo**: `legacy/natural-programs/CADDEPEND.NSN#L63-L66` + `legacy/adabas-ddms/BENEFICIARIO.ddm#L59-L61`
- **O que esperavamos**: limite operacional igual ao limite estrutural da base.
- **O que o codigo faz**: bloqueia no 6o dependente apesar de PE permitir 10.
- **Hipotese do time**: regra de negocio foi reduzida no front sem ajuste no DDM.
- **Risco se ignorarmos**: perda de casos validos na migracao e desalinhamento com dados legados.

### MYS-006: Constante magica no FATOR-K

- **Arquivo**: `legacy/natural-programs/CADPROG.NSN#L87-L88` + `legacy/adabas-ddms/PROGRAMA-SOCIAL.ddm#L39-L40`
- **O que esperavamos**: fonte normativa ou tabela parametrica para fator.
- **O que o codigo faz**: aplica multiplicador fixo `0.347215` hardcoded.
- **Hipotese do time**: regra implantada por demanda urgente sem ADR/documento.
- **Risco se ignorarmos**: erro financeiro cumulativo em todos os programas sociais.

### MYS-011: Cabecalho BATCHPGT mente sobre CALLNAT (CRITICO)

- **Arquivo**: `legacy/natural-programs/BATCHPGT.NSN#L1-L10` e `#L279-L285`
- **O que esperavamos**: BATCHPGT chamar CALCBENF e CALCDSCT via CALLNAT conforme cabecalho.
- **O que o codigo faz**: calculo inline simplificado de ~30 linhas, sem nenhum CALLNAT. CALCBENF tem ~4800 linhas com logica muito mais complexa.
- **Hipotese do time**: cabecalho desatualizado apos refactoring emergencial. A versao inline pode ser uma simplificacao proposital para performance.
- **Risco se ignorarmos**: usar a versao errada como referencia na modernizacao pode gerar pagamentos incorretos para 4.2M beneficiarios.

### MYS-015: Arredondamento divergente entre pagamento e relatorio

- **Arquivo**: `legacy/natural-programs/BATCHREL.NSN#L135-L139` e `BATCHPGT.NSN#L284-L285`
- **O que esperavamos**: mesma politica de arredondamento em todo o sistema.
- **O que o codigo faz**: BATCHPGT trunca (mult 100, int, div 100); BATCHREL arredonda (+0.005).
- **Hipotese do time**: equipes diferentes implementaram sem coordenacao.
- **Risco se ignorarmos**: totais de relatorio nao batem com valores efetivamente pagos — divergencia centaval acumulada em milhoes de registros.

### MYS-017: COD-BANCO tipo inconsistente

- **Arquivo**: `legacy/natural-programs/BATCHCON.NSN#L172-L180`
- **O que esperavamos**: COD-BANCO como `A3` ('001' para BB) conforme DDM.
- **O que o codigo faz**: grava `1` como numerico.
- **Hipotese do time**: programador usou atalho numerico; Adabas pode converter implicitamente.
- **Risco se ignorarmos**: migracao para PostgreSQL com tipo VARCHAR pode gerar '1' em vez de '001'.

### MYS-029: EGG-001 — Plano Verao (CALCCORR)

- **Arquivo**: `legacy/natural-programs/CALCCORR.NSN#L39-L50`
- **O que esperavamos**: codigo ativo ou removido.
- **O que o codigo faz**: bloco comentado referencia transicao Cruzado→Cruzeiro (1989-1991) com multiplicador 2.75x. Sub-periodo pre-07/1989 com 1.4289x.
- **Detalhes**: Responsavel Joao Batista (15/03/2003). Marcado "NAO REMOVER (HISTORICO)". Indicador 'V' era setado em IND-CORRIGIDO.
- **Conclusao**: **EGG-001 ENCONTRADO** — politica economica dos anos 90 = Plano Verao.

### MYS-036: EGG-002 — Backdoor VALDOCS (CHECK-DOC-ESPECIAL)

- **Arquivo**: `legacy/natural-programs/VALDOCS.NSN#L166-L182`
- **O que esperavamos**: validacao completa de documentos.
- **O que o codigo faz**: subrotina CHECK-DOC-ESPECIAL aceita 8 prefixos CPF (000,001,002,010,011,099,100,999) e apaga TODOS erros, forcando resultado VALIDO.
- **Detalhes**: Comentario "GOVERNO/TESTE". Alteracao 2011 Roberto Mendes "AJUSTE CHECK ESPEC" — backdoor mantido conscientemente.
- **Conclusao**: **EGG-002 ENCONTRADO** — backdoor de teste nunca removido.

### MYS-037: DOCUMENTOS-OK nunca setado

- **Arquivo**: `legacy/natural-programs/VALDOCS.NSN#L18` + `VALELEG.NSN#L178`
- **O que esperavamos**: VALDOCS setar DOCUMENTOS-OK='S' apos validacao.
- **O que o codigo faz**: campo declarado na VIEW mas nunca atualizado. VALELEG depende dele para tipo A.
- **Risco se ignorarmos**: programas assistenciais podem rejeitar beneficiarios sistematicamente.

### MYS-052: Bug mascara CPF conhecido (CONSBENF)

- **Arquivo**: `legacy/natural-programs/CONSBENF.NSN#L149-L168`
- **O que esperavamos**: mascara uniforme ocultando dados sensiveis.
- **O que o codigo faz**: CPFs com menos de 11 digitos (zeros a esquerda) mostram primeiros 3 digitos em vez dos ultimos.
- **Detalhes**: Comentario explicito "INCONSISTENCIA CONHECIDA — NAO CORRIGIR SEM APROVACAO DA AUDITORIA". Existe desde 2003.
- **Risco se ignorarmos**: vazamento de dados sensiveis CPF.

### MYS-056: Colisao semantica codigo 'CO' (RELAUDIT vs DDM)

- **Arquivo**: `legacy/natural-programs/RELAUDIT.NSN#L132-L133` vs `legacy/adabas-ddms/AUDITORIA.ddm`
- **O que esperavamos**: significado unico por codigo.
- **O que o codigo faz**: DDM define CO=CONSULTA, RELAUDIT e BATCHCON usam CO=CONCILIACAO.
- **Detalhes**: DDM nota que acoes CO (consulta) nao gravadas desde 2010. Registros CO pos-2010 sao conciliacoes.
- **Risco se ignorarmos**: analise de auditoria conta conciliacoes como consultas ou vice-versa.

### MYS-058: Exclusoes invisiveis na auditoria (RELAUDIT)

- **Arquivo**: `legacy/natural-programs/RELAUDIT.NSN#L97-L100` + `legacy/adabas-ddms/AUDITORIA.ddm#L89-L91`
- **O que esperavamos**: trilha de auditoria completa.
- **O que o codigo faz**: filtra TODAS acoes 'EX' (exclusao) ANTES dos outros filtros. Unico acesso via SYSAOS (Adabas Online).
- **Detalhes**: DDM confirma deliberacao. Nao ha outro relatorio que exiba exclusoes.
- **Risco se ignorarmos**: lacuna de compliance. Possivel violacao IN-TCU 63/2010.

## Easter Eggs

> Existem **3 easter eggs** escondidos no codigo legado:

1. [x] **EGG-001: Plano Verao** — `legacy/natural-programs/CALCCORR.NSN#L39-L50`. Bloco comentado referencia politica economica Plano Verao (1989-1991), transicao moeda Cruzado→Cruzeiro com multiplicador 2.75x. Marcado "NAO REMOVER (HISTORICO)". Responsavel Joao Batista, 15/03/2003.
2. [x] **EGG-002: Backdoor VALDOCS** — `legacy/natural-programs/VALDOCS.NSN#L166-L182`. Subrotina CHECK-DOC-ESPECIAL aceita 8 prefixos CPF especiais e apaga todos erros de validacao. Comentario "GOVERNO/TESTE". Nunca removido — mantido conscientemente desde alteracao 2011.
3. [x] **EGG-003: Banco Real** — `legacy/natural-programs/BATCHCON.NSN#L200-L230`. Bloco comentado do Banco Real (codigo 356), absorvido pelo Santander em 2007. Dead code desde 2005.

## Resumo

- Total de misterios encontrados: **61** (Par 1: 10, Par 2: 15, Par 3: 10, Par 4: 16, Par 5: 10)
- Confianca alta: 39
- Confianca media: 20
- Confianca baixa: 2
- Easter eggs encontrados: **3 / 3**
- Misterios mais criticos:
  - **MYS-011** — cabecalho BATCHPGT mente sobre CALLNAT
  - **MYS-028** — tabela IPCA congelada desde 2014
  - **MYS-036** — backdoor de teste em producao (EGG-002)
  - **MYS-058** — exclusoes invisiveis na auditoria
