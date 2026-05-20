---
title: "Checklist de Misterios - Quanto seu time descobriu?"
description: "Lista dos misterios plantados no codigo legado SIFAP. Encontre todos para pontuar!"
---

# Checklist de Misterios do SIFAP

> Ha **10 regras de negocio escondidas** e **3 easter eggs** plantados no codigo legado. Quanto mais seu time encontrar, melhor a nota na rubrica (dimensao A1).

## Como funciona

- Cada misterio vale 1-3 pontos dependendo da dificuldade
- Total possivel: **32 pontos**
- Os misterios estao distribuidos nos 15 programas .NSN e nos 4 DDMs
- Nenhum misterio esta documentado nos legacy-docs (os docs estao desatualizados de proposito!)

## Regras de Negocio Escondidas (10)

Marque [x] quando encontrar:

- [x] **MYS-001** (★★): CADBENEF.NSN#L156-L169 — idade > 75 muda status para 'S' (suspenso) automaticamente, sem documentacao funcional. Criterio demografico: idade.
- [x] **MYS-002** (★): CADDEPEND.NSN#L63-L66 — limite de 5 dependentes hardcoded no codigo, mas DDM BENEFICIARIO define PE com ate 10 ocorrencias.
- [x] **MYS-003** (★★★): CADPROG.NSN#L87-L88 — constante magica `0.347215` usada em FATOR-K = 1 + (FATOR-REAJ × 0.347215). Sem justificativa funcional.
- [x] **MYS-004** (★★★): BATCHPGT.NSN#L291-L303 — em DEZEMBRO: 13o salario usa formula simplificada (sem fator familiar/renda), e abono de 15% para programas tipo 'A'.
- [x] **MYS-005** (★★★): BATCHPGT.NSN#L284-L285 usa TRUNCAMENTO (mult×100, int, div÷100) enquanto BATCHREL.NSN#L135-L139 usa ROUND (+0.005). Perda sistematica de centavos no truncamento.
- [x] **MYS-006** (★★): BATCHPGT.NSN#L306-L312 — desconto simplificado de 3% flat (acima de R$500), ignora os 8 tipos de desconto do CALCDSCT (IR, judicial, consignacoes com cap 30%).
- [x] **MYS-007** (★): CADDEPEND.NSN#L96-L101 — CPF de dependente = 0 passa na validacao de duplicidade (ignorado quando CPF=0). Permite dependentes sem identificador real.
- [ ] **MYS-008** (★): Beneficiarios de uma regiao especifica pulam TODAS as verificacoes de elegibilidade. Qual regiao?
- [x] **MYS-009** (★★): BATCHPGT.NSN#L178-L192 — processamento ordenado por CPF ascendente (comentario de 1999: "SISTEMAS DOWNSTREAM DEPENDEM DESTA ORDENACAO"). Ordem nao e por programa/regiao mas por CPF.
- [x] **MYS-010** (★★★): BATCHPGT.NSN#L340-L345 — alteracao de 2015 "INC AUDITORIA" mas NENHUM codigo de auditoria existe. Eventos de geracao de pagamento nao sao auditados. RELAUDIT so le o que BATCHCON grava.

## Easter Eggs (3)

- [ ] **EGG-001** (★): Um bloco de codigo comentado referencia uma politica economica dos anos 90 que nunca foi removida. Qual politica?
- [ ] **EGG-002** (★): Um programa tem uma funcao de validacao especial que aceita certos documentos sem verificacao. Parece um backdoor de teste. Onde?
- [x] **EGG-003** (★): BATCHCON.NSN#L200-L230 — bloco comentado do **Banco Real** (codigo 356), absorvido pelo Santander em 2007. Dead code desde 2005.

## Inconsistencias entre Documentacao e Codigo (bonus)

- [x] **INC-001**: Limite de dependentes: DDM permite 10 (PE), codigo limita a 5 (CADDEPEND#L63-L66)
- [ ] **INC-002**: O documento de arquitetura original nao menciona uma estrutura de dados que foi adicionada depois
- [x] **INC-003**: Formula de 4 fatores (BATCHPGT#L279-L281), constante 0.347215 (CADPROG#L87), 13o simplificado — nenhum em documentacao
- [x] **INC-004**: BATCHPGT trunca valores monetarios; BATCHREL arredonda (+0.005) — mesmo VLR-BRUTO, metodos diferentes

## Pontuacao

| Faixa | Classificacao |
|-------|--------------|
| 26-32 pontos | Excelente - arqueologia completa! |
| 18-25 pontos | Solido - bom trabalho de investigacao |
| 10-17 pontos | Satisfatorio - encontrou o basico |
| 0-9 pontos | Precisa melhorar - explore mais a fundo |

## Dicas

- Use **Copilot Chat** para perguntar sobre cada programa: "Tem alguma logica escondida neste codigo?"
- Compare o que a **documentacao diz** com o que o **codigo faz** - as inconsistencias sao intencionais
- Os DDMs tambem contem pistas em seus comentarios
- Se travar, levante a mao - o facilitador pode dar uma dica calibrada apos 90 minutos
