# InfluxDB Line Protocol 示例 · SportAdvisor 时序数据
# 文件名:line_protocol_example.lp
# 版本:v0.1.0  ·  生成:2026-08-29
# 对应:`knowledge/plan_schema.json` v0.1.0 · load_entry schema
# 目标:InfluxDB 2.x · bucket=sport_metrics · measurement=training_load
# 写入方式:Phase 1 接入 FastAPI 后,通过 /load/ingest 端点批量写入
# 注:本文件是 .lp 格式的样本,可直接 `influx write` 灌入测试库

# ============================================================
# Measurement: training_load
# 字段:
#   tags:   user_id, session_id, source, exercise_id
#   fields: heart_rate(int), rpe(float), load_kg(float), reps(int), set_number(int)
#   time:   秒级时间戳
# ============================================================

# --- 1) 用户 aaron_001 在 2026-08-29 09:00 完成 4 周增肌计划 w1d1 哑铃卧推第 1 组热身 ---
training_load,user_id=aaron_001,session_id=sess_plan_hypertrophy_4w_demo01_w1d1,source=apple_watch,exercise_id=ex_strength_push_db_bench_press heart_rate=88i,rpe=4.0,load_kg=20.0,reps=10i,set_number=1i 1756425600000000000

# --- 2) 同 session 第 2 组,心率上升,RPE=7 ---
training_load,user_id=aaron_001,session_id=sess_plan_hypertrophy_4w_demo01_w1d1,source=apple_watch,exercise_id=ex_strength_push_db_bench_press heart_rate=128i,rpe=7.0,load_kg=22.5,reps=10i,set_number=2i 1756425660000000000

# --- 3) 同 session 第 3 组工作组,RPE=8 ---
training_load,user_id=aaron_001,session_id=sess_plan_hypertrophy_4w_demo01_w1d1,source=apple_watch,exercise_id=ex_strength_push_db_bench_press heart_rate=142i,rpe=8.0,load_kg=25.0,reps=10i,set_number=3i 1756425720000000000

# --- 4) 同 session 第 4 组,RPE=8,卡 1 次 ---
training_load,user_id=aaron_001,session_id=sess_plan_hypertrophy_4w_demo01_w1d1,source=apple_watch,exercise_id=ex_strength_push_db_bench_press heart_rate=148i,rpe=8.0,load_kg=25.0,reps=10i,set_number=4i 1756425780000000000

# --- 5) 组间休息 90s,心率下降(可选记录) ---
training_load,user_id=aaron_001,session_id=sess_plan_hypertrophy_4w_demo01_w1d1,source=apple_watch,exercise_id=rest heart_rate=105i,rpe=0i,load_kg=0.0,reps=0i,set_number=0i 1756425870000000000

# ============================================================
# 字段语义:
#   heart_rate (int)   - 实时心率 bpm,可选(没戴表就 null,本字段缺失)
#   rpe        (float) - 0-10,Borg CR10 量表,可 0.5 步进
#   load_kg    (float) - 实际完成重量(kg)
#   reps       (int)   - 实际完成次数
#   set_number (int)   - 组序号(0=休息/组间)
#
# 写入命令(示例):
#   influx write --bucket sport_metrics \
#     --file migrations/influx/line_protocol_example.lp \
#     --org sportadvisor
#
# 读取 ACWR(7d/28d)示例 Flux:
#   from(bucket:"sport_metrics")
#     |> range(start:-28d)
#     |> filter(fn:(r) => r._measurement == "training_load" and r.user_id == "aaron_001")
#     |> aggregateWindow(every:1d, fn:sum, createEmpty:false)
#     |> map(fn:(r) => ({ r with _value: r._value }))
# ============================================================
