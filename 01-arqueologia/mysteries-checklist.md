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

- [ ] **MYS-001** (★★): Um programa modifica silenciosamente o status do beneficiario baseado em um criterio demografico. Onde? Por que?
- [ ] **MYS-002** (★): Um limite numerico esta hardcoded no codigo mas contradiz a capacidade definida no DDM. Qual e o limite? Em qual programa?
- [ ] **MYS-003** (★★★): Uma variavel misteriosa e usada em calculos mas nunca foi documentada - ninguem sabe de onde veio a constante. Qual variavel?
- [ ] **MYS-004** (★★★): Em um mes especifico do ano, o calculo de beneficio muda completamente. Qual mes? O que muda?
- [ ] **MYS-005** (★★★): O sistema usa uma tecnica de arredondamento que causa perda sistematica de centavos. Qual tecnica? Onde?
- [ ] **MYS-006** (★★): Um tipo de desconto ignora uma regra de limite que se aplica a todos os outros. Qual tipo? Por que?
- [ ] **MYS-007** (★): Certos CPFs sao aceitos sem validacao real. Quais? Isso e um bug ou feature?
- [ ] **MYS-008** (★): Beneficiarios de uma regiao especifica pulam TODAS as verificacoes de elegibilidade. Qual regiao?
- [ ] **MYS-009** (★★): O processamento batch segue uma ordem que nao e a mais logica, mas que virou dependencia de outros sistemas. Qual ordem?
- [ ] **MYS-010** (★★★): Um tipo de evento de auditoria e sistematicamente ocultado dos relatorios. Qual tipo? Isso e intencional ou bug?

## Easter Eggs (3)

- [ ] **EGG-001** (★): Um bloco de codigo comentado referencia uma politica economica dos anos 90 que nunca foi removida. Qual politica?
- [ ] **EGG-002** (★): Um programa tem uma funcao de validacao especial que aceita certos documentos sem verificacao. Parece um backdoor de teste. Onde?
- [ ] **EGG-003** (★): Codigo morto referencia uma integracao com uma empresa que nao existe mais. Qual empresa?

## Inconsistencias entre Documentacao e Codigo (bonus)

- [ ] **INC-001**: Um limite documentado diverge do que o codigo permite
- [ ] **INC-002**: O documento de arquitetura original nao menciona uma estrutura de dados que foi adicionada depois
- [ ] **INC-003**: Regras criticas de calculo nao aparecem em nenhum documento
- [ ] **INC-004**: Dois programas usam metodos de arredondamento diferentes para o mesmo tipo de valor

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
