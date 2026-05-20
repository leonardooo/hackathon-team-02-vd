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
