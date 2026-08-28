-- 001_init_schema.sql
-- SportAdvisor 训练计划/记录核心表 5 层结构
-- 版本:v0.1.0  ·  生成日期:2026-08-29
-- 对应:`knowledge/plan_schema.json` v0.1.0 (plan / session / set_block / rep_set / load_entry)
-- 目标:PostgreSQL 14+ (5 张常规表) + InfluxDB 2.x (1 张时序表) 双轨
-- 说明:本文件为骨架,字段类型/索引为初稿,Phase 1 接入 FastAPI 时再细化
--      load_entry 在 PostgreSQL 存聚合(每日一行),InfluxDB 存原始心率/RPE 时序(秒级)

BEGIN;

-- ============================================================
-- 1. plans 训练计划主表
-- ============================================================
CREATE TABLE IF NOT EXISTS plans (
    id                          VARCHAR(64)  PRIMARY KEY,          -- plan_<goal>_<weeks>w_<userId>
    name                        VARCHAR(128) NOT NULL,
    goal                        VARCHAR(16)  NOT NULL,              -- 增肌|减脂|力量|耐力|康复|混合
    level                       VARCHAR(16)  NOT NULL,              -- beginner|intermediate|advanced
    weeks                       INT          NOT NULL CHECK (weeks BETWEEN 1 AND 52),
    sessions_per_week           INT          NOT NULL CHECK (sessions_per_week BETWEEN 1 AND 14),
    split                       VARCHAR(32)  NOT NULL,              -- fullbody|upper_lower|push_pull_legs|bro_split|自定
    progression_model           VARCHAR(32)  NOT NULL,              -- linear|double_progression|undulating|wave|conjugate
    -- deload 内嵌
    deload_every_n_weeks        INT          NOT NULL DEFAULT 4,
    deload_intensity_drop_pct   INT          NOT NULL DEFAULT 40,
    deload_volume_drop_pct      INT          NOT NULL DEFAULT 50,
    -- 元数据
    tags                        JSONB        NOT NULL DEFAULT '[]'::jsonb,
    source_doc                  VARCHAR(256),
    ref_section                 VARCHAR(128),
    owner                       VARCHAR(32)  NOT NULL DEFAULT 'sport_advisor',  -- sport_advisor|user
    created_at                  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at                  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    CONSTRAINT plans_goal_chk   CHECK (goal IN ('增肌','减脂','力量','耐力','康复','混合')),
    CONSTRAINT plans_level_chk  CHECK (level IN ('beginner','intermediate','advanced'))
);

CREATE INDEX IF NOT EXISTS idx_plans_goal        ON plans (goal);
CREATE INDEX IF NOT EXISTS idx_plans_owner       ON plans (owner);
CREATE INDEX IF NOT EXISTS idx_plans_created_at  ON plans (created_at DESC);

COMMENT ON TABLE  plans                   IS '训练计划主表,1 个 plan = 1 个 4/8/12 周周期化方案';
COMMENT ON COLUMN plans.progression_model IS '渐进模型:linear=线性加重 / double_progression=双重渐进 / undulating=波动 / wave=波浪 / conjugate=共轭';


-- ============================================================
-- 2. sessions 单次训练表 (1 plan → N sessions)
-- ============================================================
CREATE TABLE IF NOT EXISTS sessions (
    id                          VARCHAR(64)  PRIMARY KEY,          -- sess_<planId>_w<n>d<m>
    plan_id                     VARCHAR(64)  NOT NULL REFERENCES plans(id) ON DELETE CASCADE,
    week_index                  INT          NOT NULL CHECK (week_index >= 1),
    day_index                   INT          NOT NULL CHECK (day_index  >= 1),
    day_label                   VARCHAR(64)  NOT NULL,              -- "周一 / Day A / 上肢日"
    focus                       VARCHAR(64),                        -- 胸+三头|腿|全身|有氧|混合
    estimated_minutes           INT          NOT NULL CHECK (estimated_minutes > 0),
    warmup_ids                  JSONB        NOT NULL DEFAULT '[]'::jsonb,
    main_blocks                 JSONB        NOT NULL DEFAULT '[]'::jsonb,  -- set_block id 顺序
    cooldown_ids                JSONB        NOT NULL DEFAULT '[]'::jsonb,
    notes                       TEXT,
    intensity_target            VARCHAR(64),                        -- "RPE 7-8 / 心率区间 Z2-Z3"
    -- load_summary 展开(便于 SQL 聚合)
    total_volume_kg             NUMERIC(10,2) NOT NULL DEFAULT 0,
    primary_lift_volume_kg      NUMERIC(10,2) NOT NULL DEFAULT 0,
    accessory_volume_kg         NUMERIC(10,2) NOT NULL DEFAULT 0,
    intensity_avg_rpe           NUMERIC(3,1),
    intensity_avg_pct_1rm       NUMERIC(5,2),
    -- 完成态
    completed_at                TIMESTAMPTZ,
    user_feedback               JSONB,                              -- {difficulty,enjoyment,energy,note}
    created_at                  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    UNIQUE (plan_id, week_index, day_index)
);

CREATE INDEX IF NOT EXISTS idx_sessions_plan_id       ON sessions (plan_id);
CREATE INDEX IF NOT EXISTS idx_sessions_completed_at  ON sessions (completed_at DESC);

COMMENT ON TABLE  sessions                IS '单次训练,1 plan 含 N session(weeks × sessions_per_week)';
COMMENT ON COLUMN sessions.main_blocks    IS '主要训练 block id 列表(执行顺序),引用 set_blocks.id';


-- ============================================================
-- 3. set_blocks 训练组块表 (1 session → N blocks)
-- ============================================================
CREATE TABLE IF NOT EXISTS set_blocks (
    id                          VARCHAR(64)  PRIMARY KEY,          -- block_<sessId>_<n>
    session_id                  VARCHAR(64)  NOT NULL REFERENCES sessions(id) ON DELETE CASCADE,
    "order"                     INT          NOT NULL CHECK ("order" >= 1),
    block_type                  VARCHAR(32)  NOT NULL,              -- compound|isolation|accessory|superset|circuit|emom|amrap|interval
    name                        VARCHAR(128) NOT NULL,
    exercise_id                 VARCHAR(64)  NOT NULL,              -- 引用 knowledge/exercises.json (软外键)
    -- reps 目标
    target_reps_min             INT,
    target_reps_max             INT,
    target_reps_unit            VARCHAR(16)  NOT NULL DEFAULT 'reps',  -- reps|sec|meters|calories
    -- 组/休息
    set_count                   INT          NOT NULL CHECK (set_count > 0),
    set_count_progression       TEXT,                              -- "前 2 周 3 组 → 第 3-4 周 4 组"
    rest_sec_default            INT          NOT NULL DEFAULT 90,
    rest_strategy               VARCHAR(32)  NOT NULL DEFAULT '固定',
    target_rpe_range            VARCHAR(16),                        -- "7-8"
    failure_distance            INT          NOT NULL DEFAULT 0,  -- 0=力竭, 1=差 1 次, 2=差 2 次
    -- 高级
    superset_with_block_id      VARCHAR(64),                        -- 自引用
    drop_set                    BOOLEAN      NOT NULL DEFAULT FALSE,
    rest_pause                  BOOLEAN      NOT NULL DEFAULT FALSE,
    note                        TEXT,
    created_at                  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    CONSTRAINT set_blocks_type_chk CHECK (block_type IN ('compound','isolation','accessory','superset','circuit','emom','amrap','interval'))
);

CREATE INDEX IF NOT EXISTS idx_set_blocks_session_id ON set_blocks (session_id);
CREATE INDEX IF NOT EXISTS idx_set_blocks_exercise   ON set_blocks (exercise_id);
CREATE INDEX IF NOT EXISTS idx_set_blocks_order      ON set_blocks (session_id, "order");

COMMENT ON TABLE  set_blocks IS '训练组块,1 session 拆成 N block(复合/孤立/超级组等)';
COMMENT ON COLUMN set_blocks.exercise_id IS '软外键:对应 knowledge/exercises.json 中的 ex_xxx_id;不在 DB 内强约束,允许 Phase 0 schema 独立演进';


-- ============================================================
-- 4. rep_sets 实际完成组记录 (1 block → N rep_set)
-- ============================================================
CREATE TABLE IF NOT EXISTS rep_sets (
    id                          VARCHAR(64)  PRIMARY KEY,          -- rs_<blockId>_<setNum>
    block_id                    VARCHAR(64)  NOT NULL REFERENCES set_blocks(id) ON DELETE CASCADE,
    set_number                  INT          NOT NULL CHECK (set_number >= 1),
    -- 计划值
    rep_count                   INT          NOT NULL CHECK (rep_count >= 0),
    load_kg                     NUMERIC(6,2) NOT NULL DEFAULT 0,
    load_pct_1rm                INT          CHECK (load_pct_1rm BETWEEN 0 AND 100),
    rpe                         NUMERIC(3,1) CHECK (rpe BETWEEN 0 AND 10),
    rest_sec                    INT          NOT NULL DEFAULT 0,
    tempo                       VARCHAR(16),                        -- "3-1-1-0"
    -- 实际值
    completed                   BOOLEAN      NOT NULL DEFAULT FALSE,
    actual_reps                 INT,
    actual_load                 NUMERIC(6,2),
    logged_at                   TIMESTAMPTZ,
    note                        TEXT,
    created_at                  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    UNIQUE (block_id, set_number)
);

CREATE INDEX IF NOT EXISTS idx_rep_sets_block_id ON rep_sets (block_id);
CREATE INDEX IF NOT EXISTS idx_rep_sets_logged   ON rep_sets (logged_at DESC) WHERE completed = TRUE;

COMMENT ON TABLE  rep_sets                IS '实际完成组记录,1 block 含 N rep_set,completed=false 表示计划/未完成';
COMMENT ON COLUMN rep_sets.load_pct_1rm    IS '相对 1RM 百分比(0-100),用于自动重量换算';


-- ============================================================
-- 5. load_entries 训练负荷聚合表(每日一行 → PostgreSQL)
--    注:秒级心率/RPE 时序写 InfluxDB,见 migrations/README.md
-- ============================================================
CREATE TABLE IF NOT EXISTS load_entries (
    id                          VARCHAR(64)  PRIMARY KEY,          -- load_<userId>_<YYYYMMDD>
    user_id                     VARCHAR(64)  NOT NULL,
    session_id                  VARCHAR(64)  REFERENCES sessions(id) ON DELETE SET NULL,
    date                        DATE         NOT NULL,
    duration_min                INT          NOT NULL CHECK (duration_min > 0),
    -- 心率
    avg_heart_rate_bpm          INT,
    max_heart_rate_bpm          INT,
    hr_zone_distribution        JSONB        NOT NULL DEFAULT '{}'::jsonb,  -- {Z1:5,Z2:15,Z3:30,Z4:8,Z5:2}
    rpe_session_avg             NUMERIC(3,1),
    -- 容量
    total_volume_kg             NUMERIC(10,2) NOT NULL DEFAULT 0,
    -- 负荷指标
    trimp                       NUMERIC(8,2),                        -- Training Impulse
    acute_load_7d               NUMERIC(10,2),                       -- 7 天急性负荷
    chronic_load_28d            NUMERIC(10,2),                       -- 28 天慢性负荷
    acwr                        NUMERIC(4,2),                        -- 急慢性负荷比(7d/28d),理想区间 0.8-1.3
    overtraining_flag           BOOLEAN      NOT NULL DEFAULT FALSE,
    -- 元数据
    source                      VARCHAR(32)  NOT NULL DEFAULT 'manual',  -- manual|apple_watch|garmin|coros|whoop|polar
    logged_at                   TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    note                        TEXT,
    UNIQUE (user_id, date)
);

CREATE INDEX IF NOT EXISTS idx_load_entries_user_id  ON load_entries (user_id);
CREATE INDEX IF NOT EXISTS idx_load_entries_date     ON load_entries (date DESC);
CREATE INDEX IF NOT EXISTS idx_load_entries_user_dt  ON load_entries (user_id, date DESC);
CREATE INDEX IF NOT EXISTS idx_load_entries_overtn   ON load_entries (overtraining_flag) WHERE overtraining_flag = TRUE;

COMMENT ON TABLE  load_entries                IS '每日训练负荷聚合(1 用户 1 日 1 行),高频原始时序存 InfluxDB';
COMMENT ON COLUMN load_entries.acwr           IS 'Acute:Chronic Workload Ratio,理想 0.8-1.3,>1.5 提示过度训练风险';
COMMENT ON COLUMN load_entries.source         IS '数据来源:manual 手动 / apple_watch / garmin / coros / whoop / polar';


-- ============================================================
-- 6. 触发器:plans.updated_at 自动维护
-- ============================================================
CREATE OR REPLACE FUNCTION trg_set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS plans_set_updated_at ON plans;
CREATE TRIGGER plans_set_updated_at
    BEFORE UPDATE ON plans
    FOR EACH ROW EXECUTE FUNCTION trg_set_updated_at();


COMMIT;

-- ============================================================
-- 验收
-- ============================================================
-- 应用后预期:
--   \dt 应列出 4 张表:plans / sessions / set_blocks / rep_sets / load_entries
--   \di 应列出至少 11 个索引(idx_*)
--   plans 表有 trg_set_updated_at 触发器
-- 数据迁移:
--   1) knowledge/plan_schema.json v0.1.0 的 1 个示例(plan_hypertrophy_4w_demo01)
--      直接 INSERT 到 plans / sessions / set_blocks / rep_sets 4 张表
--   2) knowledge/load_baseline / hr_rpe_baseline 单独导出为元数据种子(Phase 1)
-- 时序数据:
--   写入 InfluxDB(见 migrations/influx/line_protocol_example.lp)
--   PostgreSQL load_entries 仅保留每日聚合行
