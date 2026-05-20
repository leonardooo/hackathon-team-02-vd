-- =============================================================================
-- Migration : V4__create_auditoria_schema.sql
-- Origem    : DDM AUDITORIA (ARQUIVO 153, SIFAP/Adabas, DBID 57)
-- Destino   : PostgreSQL 16
-- Autor     : PAR 4 - DBA/QA
-- Data      : 2026-05-20
--
-- REGRAS INVIOLÁVEIS (obrigatoriedade legal: IN-TCU 63/2010 + Art.14 Lei 8159):
--   1. APPEND-ONLY: nenhum UPDATE ou DELETE jamais (trigger de bloqueio abaixo).
--   2. RETENÇÃO MÍNIMA: 10 anos — partições antigas NÃO devem ser dropadas.
--   3. CONSULTAS PESADAS: usar superdescriptors S2 (entidade+data) e S3 (user+data).
--
-- DECISÕES ARQUITETURAIS:
--   1. Particionamento por dt_evento (RANGE anual) — 25M registros crescendo.
--      Cada partição anual pode ser arquivada em tablespace de baixo custo após
--      o período ativo, sem violar a retenção legal.
--
--   2. MU grupos DA/DD (GRP-ANTES + GRP-DEPOIS, max 20 ocorrências cada) →
--      TABELA SEPARADA auditoria_campo_alterado:
--      Os MU DB/DC/DE/DF são paralelos: DB[i]=DE[i] (mesmo campo, antes e depois).
--      Tabela separada permite queries de compliance:
--      "todas as alterações do campo SITUACAO para o beneficiário X"
--      JSONB bloquearia esse tipo de query de auditoria exigida pelo TCU.
-- =============================================================================

-- ---------------------------------------------------------------------------
-- TIPOS ENUMERADOS
-- ---------------------------------------------------------------------------

-- BA: tipo de ação
CREATE TYPE sifap.cod_acao_tipo AS ENUM (
    'IN',  -- Inclusão
    'AL',  -- Alteração
    'EX',  -- Exclusão
    'CO',  -- Consulta (não gravado desde 2010 - Port. 213/2010)
    'LG',  -- Login
    'LO',  -- Logout
    'BT',  -- Batch
    'ER',  -- Erro
    'AU',  -- Autorização
    'RE'   -- Rejeição
);

-- CA: tipo de entidade afetada
CREATE TYPE sifap.tipo_entidade_tipo AS ENUM (
    'BENF',  -- Beneficiário
    'PGTO',  -- Pagamento
    'PROG',  -- Programa Social
    'ADMN',  -- Administração
    'SIST'   -- Sistema
);

-- FD: situação do processamento batch
CREATE TYPE sifap.sit_batch_tipo AS ENUM (
    'S',  -- Sucesso
    'E',  -- Erro
    'W'   -- Warning
);

-- ---------------------------------------------------------------------------
-- TABELA PRINCIPAL: auditoria  (APPEND-ONLY + PARTICIONADA por dt_evento)
-- ---------------------------------------------------------------------------
CREATE TABLE sifap.auditoria (

    -- Identificação do evento
    id                      BIGSERIAL           NOT NULL,   -- surrogate key
    num_auditoria           NUMERIC(15)         NOT NULL,   -- AA: sequencial único Adabas (DESCRIPTOR)
    dt_evento               DATE                NOT NULL,   -- AB: DESCRIPTOR / chave de partição
    hr_evento               TIME                NOT NULL,   -- AC
    ts_evento               TIMESTAMP           NOT NULL,   -- AD: AAAAMMDDHHMMSS — precisão completa

    -- Ação (BA..BC)
    cod_acao                sifap.cod_acao_tipo NOT NULL,   -- BA: DESCRIPTOR / parte de S1
    cod_modulo              VARCHAR(8)          NOT NULL,   -- BB: nome do programa Natural
    des_acao                VARCHAR(80),                    -- BC: descrição livre

    -- Entidade afetada (CA..CC)
    tipo_entidade           sifap.tipo_entidade_tipo NOT NULL, -- CA: parte de S2
    id_entidade             VARCHAR(15)         NOT NULL,   -- CB: chave da entidade / parte de S2 (DESCRIPTOR)
    cpf_afetado             CHAR(11),                       -- CC: CPF se aplicável (DESCRIPTOR)

    -- Usuário e origem (EA..EF)
    usr_evento              VARCHAR(8)          NOT NULL,   -- EA: login Natural / DESCRIPTOR / parte de S3
    nome_usuario            VARCHAR(40),                    -- EB
    cod_perfil              CHAR(3),                        -- EC: ADM/OPR/CON/AUD/SUP
    cod_lotacao             VARCHAR(10),                    -- ED: cód. unidade organizacional
    ip_origem               VARCHAR(45),                    -- EE: IPv4 ou IPv6 (adicionado 2012; VARCHAR(45) suporta IPv6)
    id_sessao               VARCHAR(20),                    -- EF

    -- Contexto batch — preenchido apenas quando cod_acao = 'BT' (FA..FE)
    num_ciclo_batch         NUMERIC(6),                     -- FA
    num_seq_batch           NUMERIC(10),                    -- FB
    nom_job_batch           VARCHAR(16),                    -- FC: nome do JOB JES2/JCL
    sit_batch               sifap.sit_batch_tipo,           -- FD
    des_erro_batch          VARCHAR(120),                   -- FE

    -- Correlação de operações compostas (GA..GB)
    id_correlacao           UUID,                           -- GA: era CHAR(36) no Adabas
    num_seq_correlacao      SMALLINT,                       -- GB: sequencial dentro da operação

    -- ⚠ APPEND-ONLY: as constraints abaixo reforçam a imutabilidade no DDL.
    -- O trigger fn_auditoria_bloquear_mutacao abaixo é a guarda principal.
    CONSTRAINT ck_auditoria_batch CHECK (
        cod_acao != 'BT' OR num_ciclo_batch IS NOT NULL  -- batch deve ter ciclo
    ),
    CONSTRAINT ck_auditoria_ts CHECK (
        ts_evento::DATE = dt_evento                      -- timestamp deve ser coerente com a data
    ),

    PRIMARY KEY (id, dt_evento)  -- PK composta obrigatória em tabelas particionadas

) PARTITION BY RANGE (dt_evento);

COMMENT ON TABLE  sifap.auditoria               IS 'DDM AUDITORIA – Arquivo 153. Trilha imutável de auditoria do SIFAP. APPEND-ONLY por IN-TCU 63/2010. Retenção mínima 10 anos (Art.14 Lei 8159).';
COMMENT ON COLUMN sifap.auditoria.ts_evento     IS 'AD: timestamp completo AAAAMMDDHHMMSS. Armazenado como TIMESTAMP para precisão. dt_evento + hr_evento mantidos por compatibilidade com superdescriptors do Adabas.';
COMMENT ON COLUMN sifap.auditoria.ip_origem     IS 'EE: adicionado em 2012. VARCHAR(45) suporta tanto IPv4 quanto IPv6 (máx 39 chars).';
COMMENT ON COLUMN sifap.auditoria.id_correlacao IS 'GA: era CHAR(36) no Adabas. Convertido para UUID nativo do PostgreSQL.';

-- ---------------------------------------------------------------------------
-- PARTIÇÕES ANUAIS (1997–2030)
-- ⚠ NUNCA FAZER DROP nestas partições — retenção legal mínima de 10 anos.
-- Arquivar em tablespace de baixo custo após período ativo.
-- ---------------------------------------------------------------------------
CREATE TABLE sifap.auditoria_1997 PARTITION OF sifap.auditoria FOR VALUES FROM ('1997-01-01') TO ('1998-01-01');
CREATE TABLE sifap.auditoria_1998 PARTITION OF sifap.auditoria FOR VALUES FROM ('1998-01-01') TO ('1999-01-01');
CREATE TABLE sifap.auditoria_1999 PARTITION OF sifap.auditoria FOR VALUES FROM ('1999-01-01') TO ('2000-01-01');
CREATE TABLE sifap.auditoria_2000 PARTITION OF sifap.auditoria FOR VALUES FROM ('2000-01-01') TO ('2001-01-01');
CREATE TABLE sifap.auditoria_2001 PARTITION OF sifap.auditoria FOR VALUES FROM ('2001-01-01') TO ('2002-01-01');
CREATE TABLE sifap.auditoria_2002 PARTITION OF sifap.auditoria FOR VALUES FROM ('2002-01-01') TO ('2003-01-01');
CREATE TABLE sifap.auditoria_2003 PARTITION OF sifap.auditoria FOR VALUES FROM ('2003-01-01') TO ('2004-01-01');
CREATE TABLE sifap.auditoria_2004 PARTITION OF sifap.auditoria FOR VALUES FROM ('2004-01-01') TO ('2005-01-01');
CREATE TABLE sifap.auditoria_2005 PARTITION OF sifap.auditoria FOR VALUES FROM ('2005-01-01') TO ('2006-01-01');
CREATE TABLE sifap.auditoria_2006 PARTITION OF sifap.auditoria FOR VALUES FROM ('2006-01-01') TO ('2007-01-01');
CREATE TABLE sifap.auditoria_2007 PARTITION OF sifap.auditoria FOR VALUES FROM ('2007-01-01') TO ('2008-01-01');
CREATE TABLE sifap.auditoria_2008 PARTITION OF sifap.auditoria FOR VALUES FROM ('2008-01-01') TO ('2009-01-01');
CREATE TABLE sifap.auditoria_2009 PARTITION OF sifap.auditoria FOR VALUES FROM ('2009-01-01') TO ('2010-01-01');
CREATE TABLE sifap.auditoria_2010 PARTITION OF sifap.auditoria FOR VALUES FROM ('2010-01-01') TO ('2011-01-01');
CREATE TABLE sifap.auditoria_2011 PARTITION OF sifap.auditoria FOR VALUES FROM ('2011-01-01') TO ('2012-01-01');
CREATE TABLE sifap.auditoria_2012 PARTITION OF sifap.auditoria FOR VALUES FROM ('2012-01-01') TO ('2013-01-01');
CREATE TABLE sifap.auditoria_2013 PARTITION OF sifap.auditoria FOR VALUES FROM ('2013-01-01') TO ('2014-01-01');
CREATE TABLE sifap.auditoria_2014 PARTITION OF sifap.auditoria FOR VALUES FROM ('2014-01-01') TO ('2015-01-01');
CREATE TABLE sifap.auditoria_2015 PARTITION OF sifap.auditoria FOR VALUES FROM ('2015-01-01') TO ('2016-01-01');
CREATE TABLE sifap.auditoria_2016 PARTITION OF sifap.auditoria FOR VALUES FROM ('2016-01-01') TO ('2017-01-01');
CREATE TABLE sifap.auditoria_2017 PARTITION OF sifap.auditoria FOR VALUES FROM ('2017-01-01') TO ('2018-01-01');
CREATE TABLE sifap.auditoria_2018 PARTITION OF sifap.auditoria FOR VALUES FROM ('2018-01-01') TO ('2019-01-01');
CREATE TABLE sifap.auditoria_2019 PARTITION OF sifap.auditoria FOR VALUES FROM ('2019-01-01') TO ('2020-01-01');
CREATE TABLE sifap.auditoria_2020 PARTITION OF sifap.auditoria FOR VALUES FROM ('2020-01-01') TO ('2021-01-01');
CREATE TABLE sifap.auditoria_2021 PARTITION OF sifap.auditoria FOR VALUES FROM ('2021-01-01') TO ('2022-01-01');
CREATE TABLE sifap.auditoria_2022 PARTITION OF sifap.auditoria FOR VALUES FROM ('2022-01-01') TO ('2023-01-01');
CREATE TABLE sifap.auditoria_2023 PARTITION OF sifap.auditoria FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');
CREATE TABLE sifap.auditoria_2024 PARTITION OF sifap.auditoria FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');
CREATE TABLE sifap.auditoria_2025 PARTITION OF sifap.auditoria FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');
CREATE TABLE sifap.auditoria_2026 PARTITION OF sifap.auditoria FOR VALUES FROM ('2026-01-01') TO ('2027-01-01');
CREATE TABLE sifap.auditoria_2027 PARTITION OF sifap.auditoria FOR VALUES FROM ('2027-01-01') TO ('2028-01-01');
CREATE TABLE sifap.auditoria_2028 PARTITION OF sifap.auditoria FOR VALUES FROM ('2028-01-01') TO ('2029-01-01');
CREATE TABLE sifap.auditoria_2029 PARTITION OF sifap.auditoria FOR VALUES FROM ('2029-01-01') TO ('2030-01-01');
CREATE TABLE sifap.auditoria_2030 PARTITION OF sifap.auditoria FOR VALUES FROM ('2030-01-01') TO ('2031-01-01');

-- ---------------------------------------------------------------------------
-- TRIGGER APPEND-ONLY — guarda principal da imutabilidade legal
-- Bloqueia qualquer tentativa de UPDATE ou DELETE em tempo de execução.
-- Complementa as permissões de banco (REVOKE DELETE, UPDATE do usuário app).
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION sifap.fn_auditoria_bloquear_mutacao()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE EXCEPTION
        'VIOLAÇÃO DE INTEGRIDADE: registros de auditoria são imutáveis por exigência legal (IN-TCU 63/2010 / Art.14 Lei 8159). Operação: %, tabela: %',
        TG_OP, TG_TABLE_NAME;
END;
$$;

COMMENT ON FUNCTION sifap.fn_auditoria_bloquear_mutacao()
    IS 'Trigger de bloqueio APPEND-ONLY. Impede UPDATE e DELETE na tabela auditoria conforme IN-TCU 63/2010.';

-- O trigger é criado na tabela pai — propaga automaticamente para todas as partições
CREATE TRIGGER trg_auditoria_bloquear_update
    BEFORE UPDATE ON sifap.auditoria
    FOR EACH ROW EXECUTE FUNCTION sifap.fn_auditoria_bloquear_mutacao();

CREATE TRIGGER trg_auditoria_bloquear_delete
    BEFORE DELETE ON sifap.auditoria
    FOR EACH ROW EXECUTE FUNCTION sifap.fn_auditoria_bloquear_mutacao();

-- ---------------------------------------------------------------------------
-- TABELA CAMPOS ALTERADOS: auditoria_campo_alterado
-- Origem: GRP-ANTES (DA) + GRP-DEPOIS (DD) — MU paralelos, max 20 cada
--
-- Mapeamento: DB[i]+DC[i]+DE[i]+DF[i] → 1 linha por campo alterado
--   DB[i] = campo_nome (nome do campo antes — igual a DE[i])
--   DC[i] = valor_antes
--   DF[i] = valor_depois
--
-- DECISÃO: tabela separada (não JSONB):
--   Queries de compliance TCU precisam de: "todos os registros onde
--   o campo SITUACAO do beneficiário X foi alterado entre datas D1 e D2".
--   JSONB exigiria JSON path frágil e não seria indexável com eficiência.
-- ---------------------------------------------------------------------------
CREATE TABLE sifap.auditoria_campo_alterado (

    id                      BIGSERIAL           PRIMARY KEY,
    auditoria_id            BIGINT              NOT NULL,   -- FK lógica (sem REFERENCES: tabela pai é particionada)
    auditoria_dt_evento     DATE                NOT NULL,   -- replica partição para joins eficientes

    -- Posição no MU (1..20)
    ordem                   SMALLINT            NOT NULL,

    -- Par antes/depois (DB[i]/DC[i] + DE[i]/DF[i])
    campo_nome              VARCHAR(30)         NOT NULL,   -- DB=DE: nome do campo alterado
    valor_antes             VARCHAR(80),                    -- DC: NULL se ação = IN (inclusão)
    valor_depois            VARCHAR(80),                    -- DF: NULL se ação = EX (exclusão)

    -- Constraints
    CONSTRAINT uq_campo_alterado_auditoria_ordem UNIQUE (auditoria_id, ordem),
    CONSTRAINT ck_campo_alterado_ordem CHECK (ordem BETWEEN 1 AND 20)
);

COMMENT ON TABLE  sifap.auditoria_campo_alterado              IS 'DDM AUDITORIA – GRP-ANTES (DA) + GRP-DEPOIS (DD), MU paralelos max 20. Uma linha por campo alterado em cada evento.';
COMMENT ON COLUMN sifap.auditoria_campo_alterado.auditoria_id IS 'FK lógica para auditoria.id. Sem REFERENCES declarado porque auditoria é particionada (limitação PostgreSQL).';
COMMENT ON COLUMN sifap.auditoria_campo_alterado.valor_antes  IS 'DC: NULL quando cod_acao = IN (não havia valor anterior).';
COMMENT ON COLUMN sifap.auditoria_campo_alterado.valor_depois IS 'DF: NULL quando cod_acao = EX (não há valor posterior).';

-- ---------------------------------------------------------------------------
-- INDEXES — mapeamento dos superdescriptors do Adabas
-- ⚠ Todos os indexes devem suportar partition pruning (incluir dt_evento)
-- ---------------------------------------------------------------------------

-- AA: num_auditoria DESCRIPTOR — busca por número único
CREATE INDEX idx_auditoria_num_auditoria
    ON sifap.auditoria (num_auditoria);

-- S1: AB + BA (data + ação) — timeline de ações
CREATE INDEX idx_auditoria_data_acao
    ON sifap.auditoria (dt_evento, cod_acao);

-- S2: CA + CB + AB (entidade + id + data) — trilha por entidade (mais usada pelo TCU)
CREATE INDEX idx_auditoria_entidade_data
    ON sifap.auditoria (tipo_entidade, id_entidade, dt_evento);

-- S3: EA + AB (usuário + data) — trilha por usuário
CREATE INDEX idx_auditoria_usuario_data
    ON sifap.auditoria (usr_evento, dt_evento);

-- CC: CPF afetado DESCRIPTOR — consulta "o que aconteceu com este CPF?"
CREATE INDEX idx_auditoria_cpf_afetado
    ON sifap.auditoria (cpf_afetado, dt_evento)
    WHERE cpf_afetado IS NOT NULL;

-- Correlação: rastreamento de operações compostas
CREATE INDEX idx_auditoria_correlacao
    ON sifap.auditoria (id_correlacao)
    WHERE id_correlacao IS NOT NULL;

-- Campos alterados: busca por nome do campo (compliance TCU)
CREATE INDEX idx_campo_alterado_nome
    ON sifap.auditoria_campo_alterado (campo_nome, auditoria_id);

-- Campos alterados: FK para joins
CREATE INDEX idx_campo_alterado_auditoria_id
    ON sifap.auditoria_campo_alterado (auditoria_id);

-- =============================================================================
-- FIM DA MIGRATION V4
-- =============================================================================
