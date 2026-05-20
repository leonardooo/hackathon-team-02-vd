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

## Easter Eggs

> Dica: existem **3 easter eggs** escondidos no codigo legado. Registre aqui os que encontrar:

1. [x] Easter Egg 1: busca realizada nos 3 programas do Par 1; nao identificado ate o momento.
2. [x] Easter Egg 2: busca realizada por comentarios e blocos inativos; sem evidencias conclusivas.
3. [ ] Easter Egg 3: pendente de validacao cruzada com programas de outros pares.

## Resumo

- Total de misterios encontrados: 10
- Confianca alta: 6
- Confianca media: 4
- Confianca baixa: 0
- Easter eggs encontrados: 0 / 3
