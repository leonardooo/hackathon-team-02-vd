-- =============================================================================
-- Migration : V1__create_beneficiario_schema.sql
-- Origem    : DDM BENEFICIARIO (ARQUIVO 150, SIFAP/Adabas, DBID 57)
-- Destino   : PostgreSQL 16
-- Autor     : PAR 4 - DBA/QA
-- Data      : 2026-05-20
-- Decisão   : GRP-DEPENDENTE (PE, max 10) → tabela separada
--             Justificativa: cpf_dependente e ind_deficiencia são consultados
--             individualmente no ciclo mensal; sit_dependente tem ciclo de vida
--             próprio; JSONB inviabilizaria indexes e auditoria por dependente.
-- =============================================================================

-- ---------------------------------------------------------------------------
-- SCHEMA
-- ---------------------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS sifap;

-- ---------------------------------------------------------------------------
-- TIPOS ENUMERADOS  (evitam strings mágicas e garantem integridade)
-- ---------------------------------------------------------------------------

-- AG: M=Masculino F=Feminino I=Indefinido
CREATE TYPE sifap.sexo_tipo AS ENUM ('M', 'F', 'I');

-- AH: S=Solteiro C=Casado D=Divorciado V=Viúvo U=União Estável
CREATE TYPE sifap.estado_civil_tipo AS ENUM ('S', 'C', 'D', 'V', 'U');

-- CE: A=Ativo S=Suspenso C=Cancelado I=Inativo D=Desligado
CREATE TYPE sifap.situacao_beneficiario_tipo AS ENUM ('A', 'S', 'C', 'I', 'D');

-- DE: FI=Filho CJ=Cônjuge NT=Neto TU=Tutelado
CREATE TYPE sifap.parentesco_tipo AS ENUM ('FI', 'CJ', 'NT', 'TU');

-- DF: A=Ativo I=Inativo D=Desligado
CREATE TYPE sifap.situacao_dependente_tipo AS ENUM ('A', 'I', 'D');

-- FA: S=Sim N=Não P=Pendente
CREATE TYPE sifap.biometria_tipo AS ENUM ('S', 'N', 'P');

-- ---------------------------------------------------------------------------
-- TABELA PRINCIPAL: beneficiario
-- Mapeia campos AA..GG do DDM (exceto grupo PE DA..DG → tabela separada)
-- ---------------------------------------------------------------------------
CREATE TABLE sifap.beneficiario (

    -- Chave surrogate (não existia no Adabas; ISN era a chave física)
    id                      BIGSERIAL           PRIMARY KEY,

    -- Identificação  (AA, AB)
    num_inscricao           NUMERIC(11)         NOT NULL,   -- AA: matrícula/ISN alternativo
    cpf                     CHAR(11)            NOT NULL,   -- AB: DESCRIPTOR S1

    -- Dados pessoais (AC..AL)
    nome_completo           VARCHAR(60)         NOT NULL,   -- AC
    nome_mae                VARCHAR(60)         NOT NULL,   -- AD: obrigatório no legado
    nome_pai                VARCHAR(60),                    -- AE: opcional
    dt_nascimento           DATE                NOT NULL,   -- AF: era AAAAMMDD
    sexo                    sifap.sexo_tipo     NOT NULL,   -- AG
    estado_civil            sifap.estado_civil_tipo,        -- AH
    rg_numero               VARCHAR(15),                    -- AI
    rg_orgao                VARCHAR(10),                    -- AJ
    rg_uf                   CHAR(2),                        -- AK
    rg_dt_expedicao         DATE,                           -- AL

    -- Grupo Endereço BA (grupo simples — embedded, sem tabela separada)
    end_logradouro          VARCHAR(60),                    -- BB
    end_numero              VARCHAR(10),                    -- BC: alfanum para "S/N"
    end_complemento         VARCHAR(30),                    -- BD
    end_bairro              VARCHAR(40),                    -- BE
    end_municipio           VARCHAR(40),                    -- BF
    end_uf                  CHAR(2),                        -- BG: DESCRIPTOR via superdescriptor S2
    end_cep                 CHAR(8),                        -- BH: sem hífen
    end_cod_ibge            CHAR(7),                        -- BI
    end_cod_regiao          CHAR(2),                        -- BJ: 01-05 ou 99 (especial)

    -- Dados do Benefício (CA..CJ)
    cod_programa            CHAR(4)             NOT NULL,   -- CA: DESCRIPTOR via S3
    dt_cadastro             DATE                NOT NULL,   -- CB: DESCRIPTOR
    dt_inicio_benef         DATE                NOT NULL,   -- CC
    dt_fim_benef            DATE,                           -- CD: NULL = sem prazo (era 0 no Adabas)
    situacao                sifap.situacao_beneficiario_tipo NOT NULL DEFAULT 'A', -- CE: via S2 e S3
    mot_situacao            CHAR(3),                        -- CF: cód. tabela interna
    dt_ult_situacao         DATE,                           -- CG
    vlr_renda_familiar      NUMERIC(9, 2),                  -- CH
    qtd_membros_familia     SMALLINT,                       -- CI
    ind_renda_percap        NUMERIC(7, 2),                  -- CJ: calculado

    -- Contato (EA..EC — adicionado 2015)
    tel_fixo                VARCHAR(14),                    -- EA
    tel_celular             VARCHAR(15),                    -- EB
    email                   VARCHAR(80),                    -- EC

    -- Biometria (FA..FD — adicionado 2005)
    ind_biometria           sifap.biometria_tipo NOT NULL DEFAULT 'N', -- FA
    dt_coleta_bio           DATE,                           -- FB
    cod_posto_bio           CHAR(6),                        -- FC
    hash_digital            CHAR(64),                       -- FD: SHA-256 (campo nunca implementado no legado)

    -- Controle interno / auditoria (GA..GG)
    dt_inclusao             DATE                NOT NULL,   -- GA: DESCRIPTOR
    hr_inclusao             TIME                NOT NULL,   -- GB
    usr_inclusao            VARCHAR(8)          NOT NULL,   -- GC: login Natural
    dt_ult_alteracao        DATE,                           -- GD
    hr_ult_alteracao        TIME,                           -- GE
    usr_ult_alteracao       VARCHAR(8),                     -- GF
    num_versao              INTEGER             NOT NULL DEFAULT 1, -- GG: optimistic lock

    -- Constraints de unicidade
    CONSTRAINT uq_beneficiario_num_inscricao UNIQUE (num_inscricao),
    CONSTRAINT uq_beneficiario_cpf           UNIQUE (cpf),

    -- Integridade de datas
    CONSTRAINT ck_beneficiario_dt_fim CHECK (dt_fim_benef IS NULL OR dt_fim_benef >= dt_inicio_benef),
    CONSTRAINT ck_beneficiario_renda  CHECK (vlr_renda_familiar IS NULL OR vlr_renda_familiar >= 0),
    CONSTRAINT ck_beneficiario_membros CHECK (qtd_membros_familia IS NULL OR qtd_membros_familia > 0)
);

COMMENT ON TABLE  sifap.beneficiario                IS 'DDM BENEFICIARIO – Arquivo 150. Base principal SIFAP (~4,2M registros).';
COMMENT ON COLUMN sifap.beneficiario.cpf            IS 'DESCRIPTOR S1 no Adabas. Armazenado sem formatação (11 dígitos).';
COMMENT ON COLUMN sifap.beneficiario.end_uf         IS 'Parte do superdescriptor S2 (UF + situação) no Adabas.';
COMMENT ON COLUMN sifap.beneficiario.cod_programa   IS 'Parte do superdescriptor S3 (programa + situação) no Adabas.';
COMMENT ON COLUMN sifap.beneficiario.dt_fim_benef   IS 'NULL equivale ao valor 0 do Adabas (sem prazo definido).';
COMMENT ON COLUMN sifap.beneficiario.num_versao     IS 'Optimistic locking. Substitui o controle de concorrência via ISN do Adabas.';
COMMENT ON COLUMN sifap.beneficiario.hash_digital   IS 'Campo FD declarado no DDM mas nunca implementado no legado. Mantido para compatibilidade futura.';

-- ---------------------------------------------------------------------------
-- TABELA DEPENDENTES: beneficiario_dependente
-- Origem: GRP-DEPENDENTE (DA) — Periodic Group (PE), max 10 ocorrências
--
-- DECISÃO ARQUITETURAL — tabela separada (não JSONB):
--   1. cpf_dependente é consultado individualmente (é a pessoa quem recebe?)
--   2. ind_deficiencia afeta o cálculo do valor do benefício (needs index)
--   3. sit_dependente muda de forma independente e precisa de auditoria própria
--   4. parentesco determina elegibilidade — regra de negócio crítica
--   5. JSONB inviabilizaria partial indexes e queries do ciclo mensal (3,8M pag)
-- ---------------------------------------------------------------------------
CREATE TABLE sifap.beneficiario_dependente (

    id                      BIGSERIAL           PRIMARY KEY,
    beneficiario_id         BIGINT              NOT NULL
                                REFERENCES sifap.beneficiario (id)
                                ON DELETE CASCADE,          -- dependente não existe sem beneficiário

    -- Posição original no PE (1..10) — preserva a ordem do Adabas
    ordem                   SMALLINT            NOT NULL,

    -- Campos do grupo DA (DB..DG)
    cpf_dependente          CHAR(11),                       -- DB: CPF real ou '00000000000'
    nome_dependente         VARCHAR(60)         NOT NULL,   -- DC
    dt_nascimento           DATE                NOT NULL,   -- DD
    parentesco              sifap.parentesco_tipo NOT NULL, -- DE
    situacao                sifap.situacao_dependente_tipo NOT NULL DEFAULT 'A', -- DF
    ind_deficiencia         BOOLEAN             NOT NULL DEFAULT FALSE, -- DG: S→TRUE, N→FALSE

    -- Constraints
    CONSTRAINT uq_dependente_beneficiario_ordem UNIQUE (beneficiario_id, ordem),
    CONSTRAINT ck_dependente_ordem CHECK (ordem BETWEEN 1 AND 10),
    CONSTRAINT ck_dependente_cpf   CHECK (
        cpf_dependente IS NULL
        OR cpf_dependente ~ '^\d{11}$'   -- 11 dígitos numéricos
    )
);

COMMENT ON TABLE  sifap.beneficiario_dependente              IS 'DDM BENEFICIARIO – GRP-DEPENDENTE (DA), PE max 10. Tabela separada para permitir queries individuais por CPF, deficiência e parentesco.';
COMMENT ON COLUMN sifap.beneficiario_dependente.ordem        IS 'Posição original da ocorrência no Periodic Group do Adabas (1-10).';
COMMENT ON COLUMN sifap.beneficiario_dependente.cpf_dependente IS '00000000000 no legado indica ausência de CPF. Armazenado como NULL aqui.';
COMMENT ON COLUMN sifap.beneficiario_dependente.ind_deficiencia IS 'Campo DG. TRUE = deficiente. Afeta o valor calculado do benefício — precisa ser indexado.';

-- ---------------------------------------------------------------------------
-- INDEXES
-- Mapeamento dos DESCRIPTORs e superdescriptors do Adabas
-- ---------------------------------------------------------------------------

-- S1: AB (CPF) — já coberto pela UNIQUE constraint

-- S2: BG + CE  (UF + situação) — superdescriptor Adabas → index composto
CREATE INDEX idx_beneficiario_uf_situacao
    ON sifap.beneficiario (end_uf, situacao);

-- S3: CA + CE  (programa + situação) — superdescriptor Adabas → index composto
CREATE INDEX idx_beneficiario_programa_situacao
    ON sifap.beneficiario (cod_programa, situacao);

-- CB: dt_cadastro — DESCRIPTOR individual
CREATE INDEX idx_beneficiario_dt_cadastro
    ON sifap.beneficiario (dt_cadastro);

-- Ciclo mensal: buscar ativos por programa (query mais frequente)
CREATE INDEX idx_beneficiario_programa_ativo
    ON sifap.beneficiario (cod_programa)
    WHERE situacao = 'A';

-- Dependentes: FK + busca por beneficiário (todo acesso começa aqui)
CREATE INDEX idx_dependente_beneficiario_id
    ON sifap.beneficiario_dependente (beneficiario_id);

-- Dependentes: CPF real (exclui '00000000000' → partial index menor e mais rápido)
CREATE INDEX idx_dependente_cpf
    ON sifap.beneficiario_dependente (cpf_dependente)
    WHERE cpf_dependente IS NOT NULL;

-- Dependentes: deficiência (relatórios e cálculo de benefício diferenciado)
CREATE INDEX idx_dependente_deficiencia
    ON sifap.beneficiario_dependente (beneficiario_id)
    WHERE ind_deficiencia = TRUE;

-- Dependentes: ativos por beneficiário (ciclo mensal)
CREATE INDEX idx_dependente_ativo
    ON sifap.beneficiario_dependente (beneficiario_id)
    WHERE situacao = 'A';

-- =============================================================================
-- FIM DA MIGRATION V1
-- =============================================================================
