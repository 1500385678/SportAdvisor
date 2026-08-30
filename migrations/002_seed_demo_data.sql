-- 002_seed_demo_data.sql
-- SportAdvisor 训练计划示例种子数据
-- 版本:v0.1.0  ·  生成日期:2026-08-31
-- 对应:`knowledge/plan_schema.json` v0.1.0 examples[0] (plan_hypertrophy_4w_demo01)
-- 目标:PostgreSQL 14+  ·  依赖:`001_init_schema.sql` 已应用
-- 用途:Phase 1 端到端验收 — 验证 plans / sessions / set_blocks / rep_sets 4 表
--      联合 INSERT 后能从 plans 一路 JOIN 到底,无 FK 断裂
-- 范围:1 个 plan + 1 个 session(w1d1) + 1 个 set_block + 4 个 rep_set
--      其余 11 个 session(4 周 × 3 次/周 - 1)暂不写入,留给 Phase 1 计划引擎实例化
-- 注意:exercise_id / warmup_ids / cooldown_ids 引用 knowledge/exercises.json,
--      是软外键,DB 不强约束;Phase 1 引入 exercises 表后改为强外键

BEGIN;

-- ============================================================
-- 1. plans — 1 个 4 周增肌入门计划(徒手+哑铃)
-- ============================================================
INSERT INTO plans (
    id, name, goal, level, weeks, sessions_per_week,
    split, progression_model,
    deload_every_n_weeks, deload_intensity_drop_pct, deload_volume_drop_pct,
    tags, source_doc, ref_section, owner, created_at, updated_at
) VALUES (
    'plan_hypertrophy_4w_demo01',
    '4 周增肌入门(徒手+哑铃)',
    '增肌',
    'beginner',
    4,
    3,
    'fullbody',
    'double_progression',
    4, 40, 50,
    '["增肌", "入门", "徒手", "哑铃", "4 周"]'::jsonb,
    '08_训练计划/周期化训练与减脂增肌方案.md',
    '三、增肌 4 周周期化方案',
    'sport_advisor',
    '2026-08-27T03:10:00+08:00',
    '2026-08-27T03:10:00+08:00'
)
ON CONFLICT (id) DO NOTHING;


-- ============================================================
-- 2. sessions — 第 1 周第 1 天(全身推+腿)
-- ============================================================
INSERT INTO sessions (
    id, plan_id, week_index, day_index, day_label, focus,
    estimated_minutes, warmup_ids, main_blocks, cooldown_ids,
    notes, intensity_target,
    total_volume_kg, primary_lift_volume_kg, accessory_volume_kg,
    intensity_avg_rpe, intensity_avg_pct_1rm,
    completed_at, user_feedback
) VALUES (
    'sess_plan_hypertrophy_4w_demo01_w1d1',
    'plan_hypertrophy_4w_demo01',
    1, 1,
    '周一 / Day A / 全身推+腿',
    '胸+三头+股四头',
    60,
    '["ex_mobility_warmup_001", "ex_warmup_dynamic_arm"]'::jsonb,
    '["block_w1d1_01"]'::jsonb,
    '["ex_stretch_chest", "ex_stretch_quad"]'::jsonb,
    '复合动作先做,孤立后做;组间休息严格 90s',
    'RPE 7-8 / 心率区间 Z2-Z3',
    775, 775, 0,
    7.25, 66,
    NULL,
    NULL
)
ON CONFLICT (id) DO NOTHING;


-- ============================================================
-- 3. set_blocks — 1 个哑铃卧推组块(复合动作)
-- ============================================================
INSERT INTO set_blocks (
    id, session_id, "order", block_type, name, exercise_id,
    target_reps_min, target_reps_max, target_reps_unit,
    set_count, set_count_progression, rest_sec_default, rest_strategy,
    target_rpe_range, failure_distance,
    superset_with_block_id, drop_set, rest_pause, note
) VALUES (
    'block_w1d1_01',
    'sess_plan_hypertrophy_4w_demo01_w1d1',
    1,
    'compound',
    '哑铃卧推',
    'ex_strength_push_db_bench_press',
    8, 12, 'reps',
    4,
    '前 2 周 3 组 → 第 3-4 周 4 组',
    90,
    '固定',
    '7-8',
    1,
    NULL, FALSE, FALSE,
    '前 2 组热身,后 2 组工作'
)
ON CONFLICT (id) DO NOTHING;


-- ============================================================
-- 4. rep_sets — 4 个实际组记录(热身/工作/工作/工作)
-- ============================================================
INSERT INTO rep_sets (
    id, block_id, set_number,
    rep_count, load_kg, load_pct_1rm, rpe, rest_sec, tempo,
    completed, actual_reps, actual_load, logged_at, note
) VALUES
    -- 第 1 组:热身组 60% 1RM
    ('rs_w1d1_01_1', 'block_w1d1_01', 1, 10, 20.00, 60, 6.0, 90, '3-1-1-0', FALSE, NULL, NULL, NULL, '热身组'),
    -- 第 2 组:工作过渡 65% 1RM
    ('rs_w1d1_01_2', 'block_w1d1_01', 2, 10, 22.50, 65, 7.0, 90, '3-1-1-0', FALSE, NULL, NULL, NULL, NULL),
    -- 第 3 组:工作 70% 1RM RPE 8
    ('rs_w1d1_01_3', 'block_w1d1_01', 3, 10, 25.00, 70, 8.0, 90, '3-1-1-0', FALSE, NULL, NULL, NULL, NULL),
    -- 第 4 组:工作 70% 1RM RPE 8 留 1 次余量
    ('rs_w1d1_01_4', 'block_w1d1_01', 4, 10, 25.00, 70, 8.0, 90, '3-1-1-0', FALSE, NULL, NULL, NULL, '最后 1 次卡')
ON CONFLICT (id) DO NOTHING;


COMMIT;

-- ============================================================
-- 验收查询(应用后跑一下)
-- ============================================================
-- 1) 计数
--   SELECT COUNT(*) FROM plans;                      -- 期望:1
--   SELECT COUNT(*) FROM sessions;                   -- 期望:1
--   SELECT COUNT(*) FROM set_blocks;                 -- 期望:1
--   SELECT COUNT(*) FROM rep_sets;                   -- 期望:4
--
-- 2) JOIN 验证 5 层关系不断
--   SELECT p.id AS plan, s.id AS session, b.id AS block, COUNT(r.id) AS sets
--   FROM plans p
--   JOIN sessions s ON s.plan_id = p.id
--   JOIN set_blocks b ON b.session_id = s.id
--   JOIN rep_sets r ON r.block_id = b.id
--   WHERE p.id = 'plan_hypertrophy_4w_demo01'
--   GROUP BY p.id, s.id, b.id;
--   -- 期望:plan_hypertrophy_4w_demo01 | sess_plan_hypertrophy_4w_demo01_w1d1 | block_w1d1_01 | 4
--
-- 3) main_blocks JSONB 反查一致性
--   SELECT id, main_blocks FROM sessions WHERE id = 'sess_plan_hypertrophy_4w_demo01_w1d1';
--   -- 期望:main_blocks = ["block_w1d1_01"]
--
-- 4) 总容量核对 ⚠ 已知口径差异(需 T3 决策,不阻塞本次入库)
--   SELECT s.id, s.total_volume_kg AS declared,
--          SUM(r.rep_count * r.load_kg) AS computed
--   FROM sessions s
--   JOIN set_blocks b ON b.session_id = s.id
--   JOIN rep_sets r ON r.block_id = b.id
--   WHERE s.id = 'sess_plan_hypertrophy_4w_demo01_w1d1'
--   GROUP BY s.id, s.total_volume_kg;
--   -- 当前:declared=775.00, computed=925.00 (20×10+22.5×10+25×10+25×10)
--   -- 差 150 kg,推测口径:热身组(20kg)不计入工作容量,或仅取后 3 组
--   -- → 200+225+250+250=925; 225+250+250=725; 与 775 仍差 50
--   -- 临时方案:以 computed 为准,等 T3 在 plan_schema.json v0.2 加 volume_policy 字段统一
--   -- 不在本 seed 中改 session.total_volume_kg,保留 plan_schema.json 原值供溯源
