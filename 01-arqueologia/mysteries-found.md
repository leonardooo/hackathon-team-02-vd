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

## Easter Eggs

> Dica: existem **3 easter eggs** escondidos no codigo legado. Registre aqui os que encontrar:

1. [x] Easter Egg 1: busca realizada nos 3 programas do Par 1; nao identificado ate o momento.
2. [x] Easter Egg 2: busca realizada por comentarios e blocos inativos; sem evidencias conclusivas.
3. [ ] Easter Egg 3: pendente de validacao cruzada com programas de outros pares.

## Resumo

- Total de misterios encontrados: 25 (Par 1: 10, Par 2: 15)
- Confianca alta: 15
- Confianca media: 9
- Confianca baixa: 1
- Easter eggs encontrados: 0 / 3
- Misterio mais critico: **MYS-011** (cabecalho BATCHPGT mente sobre CALLNAT — divergencia de calculo)
