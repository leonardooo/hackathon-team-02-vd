# Mapa de Dependencias - SIFAP Legado

> Use diagramas Mermaid para mapear as dependencias entre programas Natural e DDMs Adabas.
> O objetivo e visualizar "quem chama quem" e "quem le/escreve o que".

## Diagrama de Dependencias entre Programas

> Substitua o exemplo abaixo pelo mapa real do seu time.
> Dica: use `CALLNAT` e `PERFORM` no codigo para encontrar chamadas entre programas.

```mermaid
flowchart TD
 subgraph "Programas Online"
 CADBENF["CADBENF.NSN<br/>Cadastro de Beneficiarios"]
 CONBENF["CONBENF.NSN<br/>Consulta de Beneficiarios"]
 REGPGTO["REGPGTO.NSN<br/>Registro de Pagamentos"]
 end

 subgraph "Programas Batch"
 BATCHPGT["BATCHPGT.NSN<br/>Processamento em Lote"]
 end

 subgraph "Subprogramas"
 CALCBENF["CALCBENF.NSN<br/>Calculo de Beneficios"]
 VALCPF["VALCPF.NSN<br/>Validacao de CPF"]
 end

 subgraph "DDMs Adabas"
 DDM_BENEF[("DDM: BENEFICIARIO")]
 DDM_PGTO[("DDM: PAGAMENTO")]
 end

 CADBENF -->|CALLNAT| VALCPF
 CADBENF -->|CALLNAT| CALCBENF
 CADBENF -->|READ/STORE| DDM_BENEF

 REGPGTO -->|CALLNAT| CALCBENF
 REGPGTO -->|READ/STORE| DDM_PGTO

 CONBENF -->|READ| DDM_BENEF

 BATCHPGT -->|CALLNAT| CALCBENF
 BATCHPGT -->|READ/UPDATE| DDM_PGTO
 BATCHPGT -->|READ| DDM_BENEF
```

> **Instrucao**: Este e apenas um exemplo inicial com 6 programas.
> Seu time deve mapear **todos os 15 programas** e **4 DDMs**.

## Diagrama de Fluxo de Dados (DDMs)

```mermaid
flowchart LR
 subgraph "Entrada de Dados"
 UI["Terminal 3270"]
 BATCH["Arquivos Batch"]
 end

 subgraph "Processamento"
 PROG["Programas Natural"]
 end

 subgraph "Armazenamento (Adabas)"
 DDM1[("BENEFICIARIO")]
 DDM2[("PAGAMENTO")]
 DDM3[("DDM 3: ???")]
 DDM4[("DDM 4: ???")]
 end

 UI --> PROG
 BATCH --> PROG
 PROG <--> DDM1
 PROG <--> DDM2
 PROG <--> DDM3
 PROG <--> DDM4
```

> Substitua "DDM 3: ???" e "DDM 4: ???" pelos nomes reais encontrados.

## Tabela de Dependencias

| Programa | Chama (CALLNAT) | Le (READ) DDMs | Escreve (STORE/UPDATE) DDMs | Observacoes |
|----------|----------------|----------------|----------------------------|-------------|
| CADBENF.NSN | | | | |
| CONBENF.NSN | | | | |
| REGPGTO.NSN | | | | |
| BATCHPGT.NSN | | | | |
| CALCBENF.NSN | | | | |
| VALCPF.NSN | | | | |
| | | | | |
| | | | | |
| | | | | |
| | | | | |
| | | | | |
| | | | | |
| | | | | |
| | | | | |
| | | | | |

## Dependencias Circulares

> Liste aqui qualquer dependencia circular encontrada (programa A chama B que chama A):

- Nenhuma encontrada ate agora.

## Programas Orfaos

> Programas que nao sao chamados por nenhum outro (possiveis pontos de entrada ou codigo morto):

- A investigar.
