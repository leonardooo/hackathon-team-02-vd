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
| BR-001 | | | | | |
| BR-002 | | | | | |
| BR-003 | | | | | |
| BR-004 | | | | | |
| BR-005 | | | | | |
| BR-006 | | | | | |
| BR-007 | | | | | |
| BR-008 | | | | | |
| BR-009 | | | | | |
| BR-010 | | | | | |
| BR-011 | | | | | |
| BR-012 | | | | | |
| BR-013 | | | | | |
| BR-014 | | | | | |
| BR-015 | | | | | |

> Adicione mais linhas conforme necessario. Lembre-se: existem **10 regras escondidas** no codigo!

## Regras por Categoria

### Calculos Financeiros
<!-- Liste aqui as regras relacionadas a calculos de valores, beneficios, etc. -->

### Validacoes de Status
<!-- Liste aqui as regras de transicao de status (A, S, C, I, D) -->

### Regras de Autorizacao
<!-- Liste aqui as regras de quem pode fazer o que -->

### Regras de Negocio Temporais
<!-- Liste aqui regras com prazos, datas-limite, periodos -->

## Resumo Estatistico

- Total de regras encontradas: ___
- Regras criticas: ___
- Regras com duplicacao: ___
- Regras sem documentacao (escondidas): ___
