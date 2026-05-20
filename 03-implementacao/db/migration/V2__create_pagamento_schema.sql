-- =============================================================================
-- Migration : V2__create_pagamento_schema.sql
-- Origem    : DDM PAGAMENTO (ARQUIVO 152, SIFAP/Adabas, DBID 57)
-- Destino   : PostgreSQL 16
-- Autor     : PAR 4 - DBA/QA
-- Data      : 2026-05-20
--
-- DECISÕES ARQUITETURAIS:
--   1. PARTICIONAMENTO por ano_mes_ref (RANGE):
--      Tabela com 180M registros crescendo 3,8M/mês. Sem particionamento,
--      o ciclo mensal (full scan + joins) ultrapassaria a janela de 2h.
--      Cada partição anual isola ~45,6M linhas e permite partition pruning.
--
--   2. GRP-DESCONTO (CA) → TABELA SEPARADA (não JSONB):
--      - TIPO-DESCONTO é consultado individualmente (relatórios por tipo IR/JD/CS...)
--      - NUM-PROCESSO (judicial) precisa ser buscável sem varrer o pagamento inteiro
--      - VLR-DESCONTO é somado/agregado por tipo no ciclo de reconciliação
--      - JSONB inviabilizaria os indexes e as agregações do ciclo mensal
-- =============================================================================

-- ---------------------------------------------------------------------------
-- TIPOS ENUMERADOS
-- ---------------------------------------------------------------------------

-- DA: situação do pagamento
CREATE TYPE sifap.situacao_pagamento_tipo AS ENUM (
    'P',  -- Pendente
    'G',  -- Gerado
    'E',  -- Emitido
    'C',  -- Confirmado
    'D',  -- Devolvido
    'X',  -- Cancelado
    'R'   -- Reprocessado
);

-- ED: tipo de conta bancária
CREATE TYPE sifap.tipo_conta_tipo AS ENUM ('C', 'P');  -- C=Corrente P=Poupança

-- CB: tipo de desconto
CREATE TYPE sifap.tipo_desconto_tipo AS ENUM (
    'IR',  -- Imposto de Renda
    'JD',  -- Judicial
    'CS',  -- Contribuição Social
    'PA',  -- Parcelamento Administrativo
    'EM',  -- Empréstimo Consignado
    'TX',  -- Taxa
    'OU',  -- Outros
    'EX'   -- Extraordinário
);

-- FE: situação integração SIAFI
CREATE TYPE sifap.situacao_siafi_tipo AS ENUM ('I', 'P', 'E');  -- Integrado/Pendente/Erro

-- GB: situação de conciliação bancária
CREATE TYPE sifap.situacao_conciliacao_tipo AS ENUM (
    'C',  -- Conciliado
    'D',  -- Divergente
    'P',  -- Pendente
    'N'   -- Não Aplicável
);

-- ---------------------------------------------------------------------------
-- TABELA PRINCIPAL: pagamento  (PARTICIONADA por ano_mes_ref)
-- 180M registros — crescimento 3,8M/mês — sem partição, ciclo estoura 2h
-- ---------------------------------------------------------------------------
CREATE TABLE sifap.pagamento (

    -- Surrogate key + chave natural do Adabas
    id                      BIGSERIAL           NOT NULL,   -- gerado no PostgreSQL
    num_pagamento           NUMERIC(15)         NOT NULL,   -- AA: sequencial único Adabas (DESCRIPTOR)
    cpf_beneficiario        CHAR(11)            NOT NULL,   -- AB: DESCRIPTOR / parte de S1
    num_inscricao           NUMERIC(11)         NOT NULL,   -- AC: FK lógica p/ beneficiario.num_inscricao
    cod_programa            CHAR(4)             NOT NULL,   -- AD: DESCRIPTOR / parte de S2
    ano_mes_ref             DATE                NOT NULL,   -- AE: AAAAMM → primeiro dia do mês (DESCRIPTOR S1/S2/S3)
    num_ciclo               NUMERIC(6)          NOT NULL,   -- AF: ciclo de processamento / parte de S3

    -- Valores (BA..BC)
    vlr_bruto               NUMERIC(9, 2)       NOT NULL,   -- BA
    vlr_liquido             NUMERIC(9, 2)       NOT NULL,   -- BB
    vlr_desconto_total      NUMERIC(7, 2)       NOT NULL DEFAULT 0, -- BC

    -- Status e processamento (DA..DG)
    situacao                sifap.situacao_pagamento_tipo NOT NULL DEFAULT 'P', -- DA / parte de S2 e S3
    dt_geracao              DATE                NOT NULL,   -- DB: DESCRIPTOR
    hr_geracao              TIME                NOT NULL,   -- DC
    dt_emissao              DATE,                           -- DD
    dt_confirmacao          DATE,                           -- DE
    dt_cancelamento         DATE,                           -- DF
    mot_cancelamento        CHAR(3),                        -- DG

    -- Dados bancários (EA..EE)
    cod_banco               CHAR(3),                        -- EA: código FEBRABAN
    cod_agencia             VARCHAR(6),                     -- EB
    num_conta               VARCHAR(13),                    -- EC
    tipo_conta              sifap.tipo_conta_tipo,          -- ED
    cod_operacao            CHAR(3),                        -- EE: operação Caixa

    -- Integração SIAFI (FA..FE — adicionado 2002)
    num_ob_siafi            VARCHAR(12),                    -- FA: Ordem Bancária
    num_ne_siafi            VARCHAR(12),                    -- FB: Nota de Empenho
    cod_ug_emitente         CHAR(6),                        -- FC: Unidade Gestora
    cod_gestao              CHAR(5),                        -- FD
    sit_integ_siafi         sifap.situacao_siafi_tipo,      -- FE

    -- Conciliação bancária (GA..GE)
    dt_conciliacao          DATE,                           -- GA
    sit_conciliacao         sifap.situacao_conciliacao_tipo, -- GB
    vlr_conciliado          NUMERIC(9, 2),                  -- GC
    cod_retorno_banco       CHAR(2),                        -- GD: código CNAB 240
    des_retorno_banco       VARCHAR(40),                    -- GE

    -- Hash de arquivo (HA..HB — adicionado 2015)
    hash_arq_remessa        CHAR(64),                       -- HA: SHA-256
    hash_arq_retorno        CHAR(64),                       -- HB: SHA-256

    -- Controle interno (IA..IF)
    dt_inclusao             DATE                NOT NULL,   -- IA
    hr_inclusao             TIME                NOT NULL,   -- IB
    usr_inclusao            VARCHAR(8)          NOT NULL DEFAULT 'BATCH', -- IC
    dt_ult_alteracao        DATE,                           -- ID
    hr_ult_alteracao        TIME,                           -- IE
    usr_ult_alteracao       VARCHAR(8),                     -- IF

    -- Constraints
    CONSTRAINT ck_pagamento_vlr_bruto   CHECK (vlr_bruto >= 0),
    CONSTRAINT ck_pagamento_vlr_liq     CHECK (vlr_liquido >= 0),
    CONSTRAINT ck_pagamento_vlr_dsct    CHECK (vlr_desconto_total >= 0),
    CONSTRAINT ck_pagamento_vlr_balance CHECK (vlr_liquido <= vlr_bruto),
    CONSTRAINT ck_pagamento_dt_cancel   CHECK (
        dt_cancelamento IS NULL OR situacao IN ('X', 'D', 'R')
    ),

    PRIMARY KEY (id, ano_mes_ref)  -- PK composta inclui a chave de partição (obrigatório no PostgreSQL)

) PARTITION BY RANGE (ano_mes_ref);

COMMENT ON TABLE  sifap.pagamento                     IS 'DDM PAGAMENTO – Arquivo 152. Tabela transacional principal (~180M registros). Particionada por ano_mes_ref (RANGE anual).';
COMMENT ON COLUMN sifap.pagamento.num_pagamento       IS 'AA: DESCRIPTOR no Adabas. Sequencial único do sistema legado.';
COMMENT ON COLUMN sifap.pagamento.ano_mes_ref         IS 'AE: era NUMERIC(6) AAAAMM no Adabas. Convertido para DATE (primeiro dia do mês). Chave de partição.';
COMMENT ON COLUMN sifap.pagamento.num_ciclo           IS 'AF: parte do superdescriptor S3 (ciclo + situação).';
COMMENT ON COLUMN sifap.pagamento.vlr_desconto_total  IS 'BC: deve ser igual à soma de pagamento_desconto.vlr_desconto para o mesmo id.';
COMMENT ON COLUMN sifap.pagamento.hash_arq_remessa    IS 'HA: SHA-256 do arquivo de remessa CNAB 240. Campo adicionado em 2015.';

-- ---------------------------------------------------------------------------
-- PARTIÇÕES ANUAIS (1997–2030)
-- Criar antecipadamente evita bloqueio em produção durante o ciclo mensal.
-- Partições futuras além de 2030 devem ser criadas via migration incremental.
-- ---------------------------------------------------------------------------
CREATE TABLE sifap.pagamento_1997 PARTITION OF sifap.pagamento
    FOR VALUES FROM ('1997-01-01') TO ('1998-01-01');

CREATE TABLE sifap.pagamento_1998 PARTITION OF sifap.pagamento
    FOR VALUES FROM ('1998-01-01') TO ('1999-01-01');

CREATE TABLE sifap.pagamento_1999 PARTITION OF sifap.pagamento
    FOR VALUES FROM ('1999-01-01') TO ('2000-01-01');

CREATE TABLE sifap.pagamento_2000 PARTITION OF sifap.pagamento
    FOR VALUES FROM ('2000-01-01') TO ('2001-01-01');

CREATE TABLE sifap.pagamento_2001 PARTITION OF sifap.pagamento
    FOR VALUES FROM ('2001-01-01') TO ('2002-01-01');

CREATE TABLE sifap.pagamento_2002 PARTITION OF sifap.pagamento
    FOR VALUES FROM ('2002-01-01') TO ('2003-01-01');

CREATE TABLE sifap.pagamento_2003 PARTITION OF sifap.pagamento
    FOR VALUES FROM ('2003-01-01') TO ('2004-01-01');

CREATE TABLE sifap.pagamento_2004 PARTITION OF sifap.pagamento
    FOR VALUES FROM ('2004-01-01') TO ('2005-01-01');

CREATE TABLE sifap.pagamento_2005 PARTITION OF sifap.pagamento
    FOR VALUES FROM ('2005-01-01') TO ('2006-01-01');

CREATE TABLE sifap.pagamento_2006 PARTITION OF sifap.pagamento
    FOR VALUES FROM ('2006-01-01') TO ('2007-01-01');

CREATE TABLE sifap.pagamento_2007 PARTITION OF sifap.pagamento
    FOR VALUES FROM ('2007-01-01') TO ('2008-01-01');

CREATE TABLE sifap.pagamento_2008 PARTITION OF sifap.pagamento
    FOR VALUES FROM ('2008-01-01') TO ('2009-01-01');

CREATE TABLE sifap.pagamento_2009 PARTITION OF sifap.pagamento
    FOR VALUES FROM ('2009-01-01') TO ('2010-01-01');

CREATE TABLE sifap.pagamento_2010 PARTITION OF sifap.pagamento
    FOR VALUES FROM ('2010-01-01') TO ('2011-01-01');

CREATE TABLE sifap.pagamento_2011 PARTITION OF sifap.pagamento
    FOR VALUES FROM ('2011-01-01') TO ('2012-01-01');

CREATE TABLE sifap.pagamento_2012 PARTITION OF sifap.pagamento
    FOR VALUES FROM ('2012-01-01') TO ('2013-01-01');

CREATE TABLE sifap.pagamento_2013 PARTITION OF sifap.pagamento
    FOR VALUES FROM ('2013-01-01') TO ('2014-01-01');

CREATE TABLE sifap.pagamento_2014 PARTITION OF sifap.pagamento
    FOR VALUES FROM ('2014-01-01') TO ('2015-01-01');

CREATE TABLE sifap.pagamento_2015 PARTITION OF sifap.pagamento
    FOR VALUES FROM ('2015-01-01') TO ('2016-01-01');

CREATE TABLE sifap.pagamento_2016 PARTITION OF sifap.pagamento
    FOR VALUES FROM ('2016-01-01') TO ('2017-01-01');

CREATE TABLE sifap.pagamento_2017 PARTITION OF sifap.pagamento
    FOR VALUES FROM ('2017-01-01') TO ('2018-01-01');

CREATE TABLE sifap.pagamento_2018 PARTITION OF sifap.pagamento
    FOR VALUES FROM ('2018-01-01') TO ('2019-01-01');

CREATE TABLE sifap.pagamento_2019 PARTITION OF sifap.pagamento
    FOR VALUES FROM ('2019-01-01') TO ('2020-01-01');

CREATE TABLE sifap.pagamento_2020 PARTITION OF sifap.pagamento
    FOR VALUES FROM ('2020-01-01') TO ('2021-01-01');

CREATE TABLE sifap.pagamento_2021 PARTITION OF sifap.pagamento
    FOR VALUES FROM ('2021-01-01') TO ('2022-01-01');

CREATE TABLE sifap.pagamento_2022 PARTITION OF sifap.pagamento
    FOR VALUES FROM ('2022-01-01') TO ('2023-01-01');

CREATE TABLE sifap.pagamento_2023 PARTITION OF sifap.pagamento
    FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');

CREATE TABLE sifap.pagamento_2024 PARTITION OF sifap.pagamento
    FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

CREATE TABLE sifap.pagamento_2025 PARTITION OF sifap.pagamento
    FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');

CREATE TABLE sifap.pagamento_2026 PARTITION OF sifap.pagamento
    FOR VALUES FROM ('2026-01-01') TO ('2027-01-01');

CREATE TABLE sifap.pagamento_2027 PARTITION OF sifap.pagamento
    FOR VALUES FROM ('2027-01-01') TO ('2028-01-01');

CREATE TABLE sifap.pagamento_2028 PARTITION OF sifap.pagamento
    FOR VALUES FROM ('2028-01-01') TO ('2029-01-01');

CREATE TABLE sifap.pagamento_2029 PARTITION OF sifap.pagamento
    FOR VALUES FROM ('2029-01-01') TO ('2030-01-01');

CREATE TABLE sifap.pagamento_2030 PARTITION OF sifap.pagamento
    FOR VALUES FROM ('2030-01-01') TO ('2031-01-01');

-- ---------------------------------------------------------------------------
-- TABELA DESCONTOS: pagamento_desconto
-- Origem: GRP-DESCONTO (CA) — Periodic Group (PE), max 8 ocorrências
--
-- DECISÃO: tabela separada (não JSONB):
--   1. TIPO-DESCONTO é consultado por tipo (relatório IR, JD com NUM-PROCESSO...)
--   2. NUM-PROCESSO judicial precisa ser buscável individualmente
--   3. VLR-DESCONTO é agregado/somado no ciclo de reconciliação por tipo
--   4. DT-INICIO/FIM é usado em regras de vigência — precisa de range query
-- ---------------------------------------------------------------------------
CREATE TABLE sifap.pagamento_desconto (

    id                      BIGSERIAL           PRIMARY KEY,
    pagamento_id            BIGINT              NOT NULL,   -- FK → pagamento.id (sem REFERENCES por ser particionada)
    pagamento_ano_mes_ref   DATE                NOT NULL,   -- replica a chave de partição para joins eficientes

    -- Posição no PE (1..8)
    ordem                   SMALLINT            NOT NULL,

    -- Campos do grupo CA (CB..CG)
    tipo_desconto           sifap.tipo_desconto_tipo NOT NULL, -- CB
    vlr_desconto            NUMERIC(7, 2)       NOT NULL,   -- CC
    pct_desconto            NUMERIC(3, 2),                  -- CD: percentual aplicado
    num_processo            VARCHAR(20),                    -- CE: número judicial (só para tipo JD)
    dt_inicio_dsct          DATE                NOT NULL,   -- CF
    dt_fim_dsct             DATE,                           -- CG: NULL = indefinido (era 0 no Adabas)

    -- Constraints
    CONSTRAINT uq_desconto_pagamento_ordem UNIQUE (pagamento_id, ordem),
    CONSTRAINT ck_desconto_ordem           CHECK (ordem BETWEEN 1 AND 8),
    CONSTRAINT ck_desconto_vlr             CHECK (vlr_desconto >= 0),
    CONSTRAINT ck_desconto_pct             CHECK (pct_desconto IS NULL OR pct_desconto BETWEEN 0 AND 100),
    CONSTRAINT ck_desconto_processo        CHECK (
        num_processo IS NULL OR tipo_desconto = 'JD'   -- processo judicial só para tipo JD
    ),
    CONSTRAINT ck_desconto_dt_fim          CHECK (
        dt_fim_dsct IS NULL OR dt_fim_dsct >= dt_inicio_dsct
    )
);

COMMENT ON TABLE  sifap.pagamento_desconto                  IS 'DDM PAGAMENTO – GRP-DESCONTO (CA), PE max 8. Tabela separada para permitir queries e agregações por tipo de desconto.';
COMMENT ON COLUMN sifap.pagamento_desconto.pagamento_id     IS 'FK lógica para pagamento.id. Sem FK declarada pois pagamento é particionada (limitação do PostgreSQL).';
COMMENT ON COLUMN sifap.pagamento_desconto.pagamento_ano_mes_ref IS 'Replica a chave de partição de pagamento para permitir joins diretos na partição correta.';
COMMENT ON COLUMN sifap.pagamento_desconto.num_processo      IS 'CE: número do processo judicial. Preenchido APENAS quando tipo_desconto = JD.';
COMMENT ON COLUMN sifap.pagamento_desconto.dt_fim_dsct       IS 'CG: NULL equivale ao valor 0 do Adabas (vigência indefinida).';

-- ---------------------------------------------------------------------------
-- INDEXES — mapeamento dos superdescriptors do Adabas
-- ---------------------------------------------------------------------------

-- S1: AB + AE (CPF + competência) → ciclo mensal por beneficiário
CREATE INDEX idx_pagamento_cpf_competencia
    ON sifap.pagamento (cpf_beneficiario, ano_mes_ref);

-- S2: AD + AE + DA (programa + competência + situação) → processamento batch
CREATE INDEX idx_pagamento_programa_competencia_situacao
    ON sifap.pagamento (cod_programa, ano_mes_ref, situacao);

-- S3: AF + DA (ciclo + situação) → consulta de ciclo em andamento
CREATE INDEX idx_pagamento_ciclo_situacao
    ON sifap.pagamento (num_ciclo, situacao);

-- DB: dt_geracao DESCRIPTOR — rastreamento de geração
CREATE INDEX idx_pagamento_dt_geracao
    ON sifap.pagamento (dt_geracao);

-- Ciclo mensal: pagamentos pendentes/gerados do mês corrente (partial index)
CREATE INDEX idx_pagamento_pendentes
    ON sifap.pagamento (cod_programa, ano_mes_ref)
    WHERE situacao IN ('P', 'G');

-- SIAFI: busca por ordem bancária (frequente em reconciliação)
CREATE INDEX idx_pagamento_ob_siafi
    ON sifap.pagamento (num_ob_siafi)
    WHERE num_ob_siafi IS NOT NULL;

-- Descontos: FK + tipo (queries mais frequentes)
CREATE INDEX idx_desconto_pagamento_id
    ON sifap.pagamento_desconto (pagamento_id);

CREATE INDEX idx_desconto_tipo
    ON sifap.pagamento_desconto (tipo_desconto, pagamento_id);

-- Descontos: processo judicial (busca individual por número de processo)
CREATE INDEX idx_desconto_processo_judicial
    ON sifap.pagamento_desconto (num_processo)
    WHERE num_processo IS NOT NULL;

-- =============================================================================
-- FIM DA MIGRATION V2
-- =============================================================================
