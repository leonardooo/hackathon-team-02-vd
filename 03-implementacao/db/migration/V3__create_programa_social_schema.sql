-- =============================================================================
-- Migration : V3__create_programa_social_schema.sql
-- Origem    : DDM PROGRAMA-SOCIAL (ARQUIVO 151, SIFAP/Adabas, DBID 57)
-- Destino   : PostgreSQL 16
-- Autor     : PAR 4 - DBA/QA
-- Data      : 2026-05-20
--
-- DECISÕES ARQUITETURAIS:
--   1. GRP-FAIXA-CALCULO (DA, PE max 5) → TABELA SEPARADA:
--      Faixas de renda determinam o cálculo do benefício. São consultadas
--      individualmente (qual faixa se aplica a esta renda per capita?).
--      Mudam por ato normativo e precisam de histórico.
--
--   2. GRP-PARAM-REGIONAL (FA, PE max 6) → TABELA SEPARADA:
--      Parâmetros regionais são consultados por cod_regiao no cálculo.
--      Máx 6 regiões por programa — tabela separada é trivial e muito mais
--      legível do que JSONB para queries de cálculo.
--
--   3. TIPO-DSCT-APLIC (EA, MU max 8) → TABELA DE JUNÇÃO:
--      Lista de tipos de desconto válidos por programa. Normalizada para
--      responder: "quais programas aceitam desconto judicial (JD)?"
--
--   4. FATOR-K (BG) → CAMPO PRESERVADO COM WARNING:
--      Campo declarado no DDM como ">>> NAO DOCUMENTADO <<<".
--      Inserido em ago/2008 a pedido da SENARC sem documentação de regra.
--      AÇÃO REQUERIDA: arqueologia de código Natural p/ entender o uso.
--      Ver mysteries-found.md / mysteries-checklist.md do Stage 1.
-- =============================================================================

-- ---------------------------------------------------------------------------
-- TIPOS ENUMERADOS
-- ---------------------------------------------------------------------------

-- AD: tipo do programa social
CREATE TYPE sifap.tipo_programa_tipo AS ENUM (
    'A',  -- Assistencial
    'T',  -- Trabalho
    'P'   -- Previdenciário
);

-- AI: situação do programa
CREATE TYPE sifap.situacao_programa_tipo AS ENUM (
    'A',  -- Ativo
    'I',  -- Inativo
    'E'   -- Encerrado
);

-- ---------------------------------------------------------------------------
-- TABELA PRINCIPAL: programa_social
-- Tabela paramétrica — apenas ~45 registros. NÃO particionar.
-- ---------------------------------------------------------------------------
CREATE TABLE sifap.programa_social (

    -- AA: chave natural (4 chars) — mantida como PK (pequena, estável, usada em joins)
    cod_programa            CHAR(4)             PRIMARY KEY,   -- AA: DESCRIPTOR S1

    -- Identificação (AB..AI)
    nome_programa           VARCHAR(60)         NOT NULL,   -- AB
    sigla_programa          VARCHAR(10)         NOT NULL,   -- AC: ex: PBF, BPC, PETI
    tipo_programa           sifap.tipo_programa_tipo NOT NULL, -- AD: parte de S2
    orgao_responsavel       VARCHAR(10),                    -- AE: cód. órgão MDS/MDAS
    lei_criacao             VARCHAR(20),                    -- AF: número da lei/decreto
    dt_criacao              DATE                NOT NULL,   -- AG
    dt_encerramento         DATE,                           -- AH: NULL = vigente (era 0 no Adabas)
    situacao                sifap.situacao_programa_tipo NOT NULL DEFAULT 'A', -- AI: parte de S2

    -- Valores base (BA..BG)
    vlr_base_individual     NUMERIC(7, 2),                  -- BA: valor mensal base por pessoa
    vlr_base_familiar       NUMERIC(7, 2),                  -- BB: valor mensal base por família
    vlr_teto_benef          NUMERIC(9, 2),                  -- BC: valor máximo do benefício
    vlr_piso_benef          NUMERIC(7, 2),                  -- BD: valor mínimo do benefício
    pct_reajuste_anual      NUMERIC(3, 2),                  -- BE: percentual de reajuste anual
    dt_ult_reajuste         DATE,                           -- BF
    fator_k                 NUMERIC(5, 4),                  -- BG: ⚠ CAMPO NÃO DOCUMENTADO

    -- Critérios de elegibilidade (CA..CI)
    renda_max_percap        NUMERIC(7, 2),                  -- CA: renda per capita máxima
    idade_min               SMALLINT            NOT NULL DEFAULT 0, -- CB: 0 = sem limite
    idade_max               SMALLINT            NOT NULL DEFAULT 0, -- CC: 0 = sem limite
    ind_exige_filhos        BOOLEAN             NOT NULL DEFAULT FALSE, -- CD
    qtd_min_filhos          SMALLINT            NOT NULL DEFAULT 0,     -- CE: só relevante se ind_exige_filhos
    ind_exige_escola        BOOLEAN             NOT NULL DEFAULT FALSE, -- CF: frequência escolar
    ind_exige_vacina        BOOLEAN             NOT NULL DEFAULT FALSE, -- CG: carteira de vacinação
    ind_exige_prenatal      BOOLEAN             NOT NULL DEFAULT FALSE, -- CH
    ind_exige_biometria     BOOLEAN             NOT NULL DEFAULT FALSE, -- CI: obrigatório desde 2005

    -- Controle interno (GA..GD)
    dt_inclusao             DATE                NOT NULL,   -- GA
    usr_inclusao            VARCHAR(8)          NOT NULL,   -- GB
    dt_ult_alteracao        DATE,                           -- GC
    usr_ult_alteracao       VARCHAR(8),                     -- GD

    -- Constraints
    CONSTRAINT ck_programa_dt_encerramento CHECK (
        dt_encerramento IS NULL OR dt_encerramento >= dt_criacao
    ),
    CONSTRAINT ck_programa_vlr_piso_teto CHECK (
        vlr_piso_benef IS NULL OR vlr_teto_benef IS NULL
        OR vlr_piso_benef <= vlr_teto_benef
    ),
    CONSTRAINT ck_programa_idade CHECK (
        idade_max = 0 OR idade_min = 0 OR idade_max >= idade_min
    ),
    CONSTRAINT ck_programa_filhos CHECK (
        NOT ind_exige_filhos OR qtd_min_filhos > 0
    )
);

COMMENT ON TABLE  sifap.programa_social              IS 'DDM PROGRAMA-SOCIAL – Arquivo 151. Tabela paramétrica (~45 programas). Regras de elegibilidade e valores base.';
COMMENT ON COLUMN sifap.programa_social.fator_k      IS 'BG: ⚠ CAMPO NÃO DOCUMENTADO NO DDM. Inserido em ago/2008 a pedido da SENARC. Investigar uso nos programas Natural (PGMCALC, PGMBENEF). Ver mysteries-found.md.';
COMMENT ON COLUMN sifap.programa_social.dt_encerramento IS 'AH: NULL equivale ao valor 0 do Adabas (programa vigente sem prazo).';
COMMENT ON COLUMN sifap.programa_social.idade_min    IS 'CB: 0 = sem limite de idade mínima.';
COMMENT ON COLUMN sifap.programa_social.idade_max    IS 'CC: 0 = sem limite de idade máxima.';

-- ---------------------------------------------------------------------------
-- TABELA FAIXAS DE CÁLCULO: programa_social_faixa_calculo
-- Origem: GRP-FAIXA-CALCULO (DA) — PE max 5
-- Consulta crítica: dada a renda_per_cap do beneficiário, qual faixa aplica?
-- ---------------------------------------------------------------------------
CREATE TABLE sifap.programa_social_faixa_calculo (

    id                      BIGSERIAL           PRIMARY KEY,
    cod_programa            CHAR(4)             NOT NULL
                                REFERENCES sifap.programa_social (cod_programa)
                                ON DELETE CASCADE,

    -- Posição no PE (1..5) — preserva a ordem das faixas do Adabas
    ordem                   SMALLINT            NOT NULL,

    -- Campos do grupo DA (DB..DF)
    renda_inicio            NUMERIC(7, 2)       NOT NULL,   -- DB: início da faixa de renda
    renda_fim               NUMERIC(7, 2)       NOT NULL,   -- DC: fim da faixa de renda
    fator_multiplicador     NUMERIC(3, 4)       NOT NULL,   -- DD: fator sobre o valor base
    vlr_adicional           NUMERIC(7, 2)       NOT NULL DEFAULT 0, -- DE: valor fixo adicional
    ind_acumulativo         BOOLEAN             NOT NULL DEFAULT FALSE, -- DF: S=acumula com faixa anterior

    -- Constraints
    CONSTRAINT uq_faixa_programa_ordem UNIQUE (cod_programa, ordem),
    CONSTRAINT ck_faixa_ordem          CHECK (ordem BETWEEN 1 AND 5),
    CONSTRAINT ck_faixa_renda          CHECK (renda_fim > renda_inicio),
    CONSTRAINT ck_faixa_fator          CHECK (fator_multiplicador >= 0),
    CONSTRAINT ck_faixa_adicional      CHECK (vlr_adicional >= 0)
);

COMMENT ON TABLE  sifap.programa_social_faixa_calculo                  IS 'DDM PROGRAMA-SOCIAL – GRP-FAIXA-CALCULO (DA), PE max 5. Define as faixas de renda e fatores para cálculo do benefício.';
COMMENT ON COLUMN sifap.programa_social_faixa_calculo.fator_multiplicador IS 'DD: multiplicado sobre vlr_base_individual ou vlr_base_familiar do programa.';
COMMENT ON COLUMN sifap.programa_social_faixa_calculo.ind_acumulativo  IS 'DF: quando TRUE, o valor desta faixa se soma ao da faixa anterior (regra de progressividade).';

-- ---------------------------------------------------------------------------
-- TABELA PARÂMETROS REGIONAIS: programa_social_param_regional
-- Origem: GRP-PARAM-REGIONAL (FA) — PE max 6 (regiões 01-05 + 99=Especial)
-- ---------------------------------------------------------------------------
CREATE TABLE sifap.programa_social_param_regional (

    id                      BIGSERIAL           PRIMARY KEY,
    cod_programa            CHAR(4)             NOT NULL
                                REFERENCES sifap.programa_social (cod_programa)
                                ON DELETE CASCADE,

    -- Campos do grupo FA (FB..FE)
    cod_regiao              CHAR(2)             NOT NULL,   -- FB: 01=N 02=NE 03=CO 04=SE 05=S 99=Especial
    fator_regional          NUMERIC(3, 4)       NOT NULL DEFAULT 1.0, -- FC: multiplicador regional
    vlr_complemento_reg     NUMERIC(7, 2)       NOT NULL DEFAULT 0,   -- FD: complemento fixo regional
    ativo                   BOOLEAN             NOT NULL DEFAULT TRUE, -- FE: S/N

    -- Constraints
    CONSTRAINT uq_param_reg_programa_regiao UNIQUE (cod_programa, cod_regiao),
    CONSTRAINT ck_param_reg_cod_regiao CHECK (
        cod_regiao IN ('01', '02', '03', '04', '05', '99')
    ),
    CONSTRAINT ck_param_reg_fator CHECK (fator_regional > 0),
    CONSTRAINT ck_param_reg_complemento CHECK (vlr_complemento_reg >= 0)
);

COMMENT ON TABLE  sifap.programa_social_param_regional              IS 'DDM PROGRAMA-SOCIAL – GRP-PARAM-REGIONAL (FA), PE max 6. Ajustes regionais sobre o valor base do benefício.';
COMMENT ON COLUMN sifap.programa_social_param_regional.cod_regiao   IS 'FB: 01=Norte 02=Nordeste 03=Centro-Oeste 04=Sudeste 05=Sul 99=Especial.';

-- ---------------------------------------------------------------------------
-- TABELA TIPOS DE DESCONTO APLICÁVEIS: programa_social_tipo_desconto
-- Origem: TIPO-DSCT-APLIC (EA) — Multiple Value (MU), max 8
--
-- DECISÃO: join table (não array CHAR(3)[]):
--   Permite responder "quais programas aceitam desconto JD?" com index simples.
--   Array precisaria de GIN index e operador @> para a mesma query.
-- ---------------------------------------------------------------------------
CREATE TABLE sifap.programa_social_tipo_desconto (

    cod_programa            CHAR(4)             NOT NULL
                                REFERENCES sifap.programa_social (cod_programa)
                                ON DELETE CASCADE,
    tipo_desconto           sifap.tipo_desconto_tipo NOT NULL,  -- EA: reutiliza o tipo do V2

    CONSTRAINT pk_prog_tipo_desconto PRIMARY KEY (cod_programa, tipo_desconto)
);

COMMENT ON TABLE  sifap.programa_social_tipo_desconto IS 'DDM PROGRAMA-SOCIAL – TIPO-DSCT-APLIC (EA), MU max 8. Lista de tipos de desconto permitidos para cada programa.';

-- ---------------------------------------------------------------------------
-- INDEXES
-- ---------------------------------------------------------------------------

-- S2: tipo + situação (filtro por tipo de programa e status)
CREATE INDEX idx_programa_tipo_situacao
    ON sifap.programa_social (tipo_programa, situacao);

-- Programas ativos (consulta mais frequente — referenciada por beneficiario e pagamento)
CREATE INDEX idx_programa_ativo
    ON sifap.programa_social (cod_programa)
    WHERE situacao = 'A';

-- Faixas: lookup por programa + renda (query do ciclo de cálculo)
CREATE INDEX idx_faixa_programa_renda
    ON sifap.programa_social_faixa_calculo (cod_programa, renda_inicio, renda_fim);

-- Parâmetros regionais: lookup por programa + região
CREATE INDEX idx_param_reg_programa_regiao
    ON sifap.programa_social_param_regional (cod_programa, cod_regiao)
    WHERE ativo = TRUE;

-- Tipos de desconto: busca inversa (quais programas aceitam tipo X?)
CREATE INDEX idx_tipo_desconto_tipo
    ON sifap.programa_social_tipo_desconto (tipo_desconto);

-- =============================================================================
-- FIM DA MIGRATION V3
-- =============================================================================
