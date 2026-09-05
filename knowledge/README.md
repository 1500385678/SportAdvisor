# SportAdvisor · 知识库索引

> 自动化生成 · v1.9 · 2026-09-06
> 数据源:`../_SportLib/01-10/`

## 用途
把张勇整理的 10 大运动主题 md 做成**可查询的结构化索引**,供后续:
- Phase 0 / 任务 2:动作库 `exercises.json` 抽取
- Phase 0 / 任务 3:康复库 `rehab_kb.json` 抽取
- Phase 0 / 任务 4:训练计划表 schema 设计
- Phase 0 / 任务 6:心率/RPE 基线范围表
- LLM 知识检索(RAG 召回单元)

## 文件
| 文件 | 用途 | 版本 | 状态 |
|------|------|------|------|
| `_index.json` | 10 主题元数据(topic_id / name / path / file / lines / bytes / summary / status) | 1.0 | ready |
| `exercises.json` | 训练动作库(name / 肌群 / 器械 / 难度 / 教学要点 / 错误 / 升降阶) | 0.1.0 | skeleton (49 条) |
| `rehab_kb.json` | 伤病/康复库(PEACE&LOVE 原则 / 7 类伤病 / 分级 / 分期康复 / 预防) | 0.1.0 | skeleton (7 条) |
| `plan_schema.json` | 训练计划表 schema(plan / session / set_block / rep_set / load_entry 5 层 + volume_policy 容量规则 + **5 个 4 周示例:增肌 + 减脂 + 力量 + 耐力 + 康复**,roadmap v0.3 5/5 闭环) | 0.6.0 | draft+volume_policy+5/5 模板闭环 |
| `hr_rpe_baseline.json` | 心率/RPE 基线(HRmax 3 公式 / 5 区分布 / Borg CR10 / 9 类人群偏移 / 2 个示例 baseline) | 0.1.0 | skeleton |

## 当前状态
- **主题数**:10 / 10 (全部 ready)
- **主题总行数**:1886
- **主题总字节**:约 76 KB
- **动作库**:49 条骨架(力量 33 / 柔韧 9 / 动态热身 5 / 核心 2)
- **康复库**:7 条骨架(急性 5 / 慢性 2;PEACE&LOVE + 7 项警示信号 + 8 项预防原则)
- **计划表模板**:5/5 闭环(增肌+减脂+力量+耐力+康复 · 0905 v0.6.0 commit `06bf107`)

## 主题列表

| ID | 主题 | 文件 | 行数 | 摘要 |
|----|------|------|------|------|
| 01 | 运动科学 | 运动解剖学与能量系统.md | 188 | 训练学/生理/能量底层 |
| 02 | 力量训练 | 力量训练全指南.md | 181 | 复合动作/渐进超负荷 |
| 03 | 有氧运动 | 有氧运动完全指南.md | 174 | 跑步/骑行/心率区间 |
| 04 | 柔韧与拉伸 | 柔韧性与拉伸完全指南.md | 177 | 动态/PNF/活动度 |
| 05 | 运动营养 | 运动营养完全指南.md | 207 | 宏量/补水/补剂 |
| 06 | 专项运动 | 常见球类与户外运动指南.md | 169 | 球类/户外/格斗 |
| 07 | 运动损伤 | 运动损伤预防与康复指南.md | 201 | 预防/康复/伤病处理 |
| 08 | 训练计划 | 周期化训练与减脂增肌方案.md | 200 | 周期化/分化 |
| 09 | 运动心理 | 运动动机与心理调节.md | 172 | 动机/疲劳/坚持 |
| 10 | 运动装备 | 运动装备选购与维护指南.md | 217 | 选鞋/护具/穿戴 |

## 动作库(exercises.json)概览

按 category / level / pattern / equipment / muscle_group 全部已索引,见 `exercises.json` 顶部 `stats` 块。

- **覆盖来源**:02_力量训练 / 04_柔韧与拉伸 / 06_专项运动
- **schema 版本**:0.1
- **预留 progression refs**:32 个升阶动作尚未入库(待 T2 任务补充)
- **扩展方向**:有氧(03)、康复(07)、训练计划(08) 主题下动作尚未抽取

## 康复库(rehab_kb.json)概览

覆盖 7 类常见伤病,均带分期康复 + 关键动作 + 预防 + 就医判断;PEACE&LOVE 原则单列。

- **覆盖来源**:07_运动损伤
- **schema 版本**:0.1
- **结构**:`principles` (PEACE/LOVE 9 字母) · `warning_signals` (7 项) · `prevention_principles` (8 项) · `injuries` (7 条)
- **伤病分布**:急性 5(肌肉拉伤、踝扭伤、ACL、跑步膝、肩袖) + 慢性 2(跟腱病、ITBS)
- **预留 key_exercises**:与 `exercises.json` id 对接(Phase 1)
- **与 plan_schema 衔接**:rehab_kb 的关键动作可作为 `plan_rehab_4w_demo01` 等康复模板的 set_block 引用源

## Phase 0 进度
- [x] **任务 1**:盘点 10 大主题,建索引 ← 2026-08-24
- [x] **任务 2(部分)**:提取训练动作库 `exercises.json` ← 2026-08-25(骨架 v0.1.0,49 条入库;100+ 目标待 T2 任务扩展)
- [x] **任务 3(部分)**:提取伤病/康复知识 `rehab_kb.json` ← 2026-08-26(骨架 v0.1.0,7 条伤病 + PEACE&LOVE 原则 + 警示信号 + 预防原则;扩展待 T3)
- [x] **任务 4**:设计训练计划表 schema ← 2026-08-27(`plan_schema.json` v0.1.0 / 5 层结构 / 1 个 4 周增肌示例;扩展待 T2 任务)
- [x] **任务 4 增量**:统一容量口径 ← 2026-09-01(`plan_schema.json` v0.2.0 / 新增 `volume_policy` 字段:`counting_basis` / `warmup_policy` / `primary_split_method` / `primary_vs_accessory_ratio` / `weekly_volume_targets_per_muscle_group` / `intensity_floor_pct_1rm` / `rpe_floor`,解决 0831 增量中提到的 capacity 计算口径差异;示例 plan 已落地 4 子字段)
- [x] **任务 4 v0.3 增量**:减脂模板入库 ← 2026-09-02(`plan_schema.json` v0.3.0 / 新增 `plan_fatloss_4w_demo01`,4 练/周 upper_lower + 力量+有氧双轨,落地完整 7 字段 volume_policy + `cardio_summary` + `weekly_energy_expenditure_kcal_min`;roadmap v0.3 进度 1/5 → 2/5,余 力量/耐力/康复)
- [x] **任务 4 v0.4 增量**:力量模板入库 ← 2026-09-03(`plan_schema.json` v0.4.0 / 新增 `plan_strength_4w_demo01`,PPL 3 练/周,大复合为锚(深蹲/卧推/硬拉/划船/推举),强度 75-90% 1RM / RPE 7-9,70/30 主辅比,容量 8-12 working sets/肌群/周,4 周线性加重 + W4 末 1RM 测试;roadmap v0.3 进度 2/5 → 3/5,余 耐力/康复)
- [x] **任务 4 v0.5 增量**:耐力模板入库 ← 2026-09-04(`plan_schema.json` v0.5.0 / 新增 `plan_endurance_4w_demo01`,3 练/周,Z2 慢跑为主项(30min 起步线性递增到 40min,RPE 4 / 60-70% HRmax),徒手力量循环为辅项(深蹲+俯卧撑+平板 3 轮);roadmap v0.3 进度 3/5 → 4/5,余 康复 1 类;新增 `cardio_summary` 字段(有氧主导模板专用:primary_modality / primary_zone / weekly_minutes / rpe_target)与 `weekly_target.cardio_minutes_min` + `constraints.min_cardio_zone` 三件套配套表达有氧容量;per_muscle_targets 降至 0-4 因为力量占比小;W4 末两日做 5km 配速测试作为下一周期起点)
- [x] **任务 4 v0.6 增量**:康复模板入库 · roadmap 5/5 闭环 ← 2026-09-05(`plan_schema.json` v0.6.0 / 新增 `plan_rehab_4w_demo01` 4 周下背痛 LBP 亚急性/慢性期进阶回归,3 练/周 30-45min/练,4 阶段线性递进:激活(W1 死虫+臀桥+猫驼+15min 行走)→ 稳定(W2 加鸟狗+20min 行走)→ 力量回归(W3 罗马尼亚硬拉 5-10kg + 平板 + 25min 行走)→ 整合(W4 单腿臀桥+平板延长+30min 行走);落地完整 7 字段 volume_policy(per_muscle_targets 0-4 + intensity_floor 40% 1RM 适配徒手 + rpe_floor 4)+ **康复四件套** `inclusion_criteria`(5 条准入:急性期 ≥ 72h / 无夜间痛 / 无神经症状 / VAS ≤ 4 / 无红旗征)+ `exclusion_criteria`(5 条禁忌:神经根/马尾/骨折/感染/孕中晚期/严重骨质疏松)+ `red_flags_stop_training`(4 条停训信号:训练中 VAS > 6 / 下肢放射 / 头晕心悸 / 次日晨僵 > 30min)+ `constraints.rehab_constraints`(VAS 疼痛阈值 ≤ 3/10 + 晨僵 ≤ 30min + 进阶门槛"连续 3 次无 VAS > 2 且僵硬 < 15min");`weekly_target.primary_lift_count_min=0`(康复初期无大复合);`load_progression`(linear,康复线性回归非肌肥大)+ `calendar_overview`(4 周布局)+ W4 末 ODI 功能障碍指数 + 5×sit-and-reach 测试作为下一周期/回归正常训练依据;**两类主导模板扩展字段模式已确立**:endurance 用 cardio_summary / rehab 用 rehab_constraints —— v0.4 session 模板库可参考;**roadmap v0.3 进度 4/5 → 5/5 闭环 — Phase 0 任务 4 闭环**;5 个 mock-id 模板与 exercises.json 实际 id 对齐推迟至 v1.0)
- [x] **任务 5**:SQLite → PostgreSQL + InfluxDB 迁移脚本(← 2026-08-29 骨架 v0.1.0:`migrations/001_init_schema.sql` 5 表 DDL + 11 索引 + 触发器 + `influx/line_protocol_example.lp` + README 双轨说明;<br>← 2026-08-31 增量:`migrations/002_seed_demo_data.sql` 就位 — 1 plan + 1 session + 1 block + 4 rep_sets 一键 INSERT,验收 SQL 内置,容量口径差异已标注待 plan_schema.json v0.2 volume_policy 字段统一(0901 闭环);Phase 1 接入 FastAPI 后端到端验收待办)
- [x] **任务 6**:心率/RPE 基线范围表(← 2026-08-28 v0.1.0,9 类人群基线 + 2 个示例 baseline;扩展待 T3)

## 下一项
**任务 2 扩展** —— 把动作库从 49 条扩展到 100+ 条:
- 补全已有 progression 引用
- 从 03_有氧运动 抽取跑步/骑行/游泳动作
- 从 07_运动损伤 抽取康复/预防动作
- 从 08_训练计划 抽取周期化模板对应的代表动作

或并行推进 **Phase 1 启动**(roadmap v0.3 5/5 闭环释放全部条件,数据层 002 fixture + 知识层 5 模板就绪,差 T1 拍板入口形态 FastAPI/React/Docker 3 选 1):
- FastAPI 骨架:`app/main.py` + `app/routers/plan.py` + `requirements.txt`(FastAPI/SQLAlchemy/asyncpg/pydantic/uvicorn),`/plan` 端点读取 002 fixture + 渲染 5 模板 4 周计划 JSON + volume_policy 后端兜底校验

## 计划表 schema(plan_schema.json)概览

- **覆盖来源**:08_训练计划 / 02_力量训练 / 03_有氧运动 / 07_运动损伤(康复)
- **schema 版本**:0.6(v0.6.0 / 2026-09-05)
- **结构**:5 层 — `plan` → `session` → `set_block` → `rep_set` → `load_entry`
- **plan 顶层规则**(5 个):`deload` / `weekly_target` / `load_progression` / `constraints` / `volume_policy`(v0.2 新增)
- **volume_policy 7 字段**:counting_basis / warmup_policy / primary_split_method / primary_vs_accessory_ratio / weekly_volume_targets_per_muscle_group / intensity_floor_pct_1rm / rpe_floor —— 统一"组怎么数、热身算不算、主辅怎么分、每肌群做多少组"
- **v0.5 新增有氧三件套**(endurance 专用):`cardio_summary`(primary_modality / primary_zone / weekly_minutes / rpe_target) + `weekly_target.cardio_minutes_min` + `constraints.min_cardio_zone` —— 表达"练什么有氧/什么强度/每周多少分钟/最低心率区间"
- **v0.6 新增康复四件套**(rehab 专用):`inclusion_criteria`(5 条准入条件:急性期已过 72h / 无夜间痛 / 无神经症状 / VAS ≤ 4 / 无红旗征)+ `exclusion_criteria`(5 条禁忌:神经根受压 / 马尾综合征 / 急性骨折/感染/肿瘤 / 怀孕中晚期 / 严重骨质疏松)+ `red_flags_stop_training`(4 条停训信号:训练中 VAS > 6/10 / 下肢放射痛麻木加重 / 头晕心悸胸痛 / 次日晨僵 > 30min)+ `constraints.rehab_constraints`(VAS 疼痛阈值 ≤ 3/10 + 晨僵 ≤ 30min + 进阶门槛"连续 3 次无 VAS > 2 且僵硬 < 15min")—— 表达"什么情况能进/不能进/什么时候必须停/进阶的门槛是什么";`weekly_target.primary_lift_count_min=0` 标记康复初期无大复合
- **两类主导模板扩展字段模式已确立**:endurance 用 cardio_summary(有氧容量)/ rehab 用 rehab_constraints(康复容量) —— v0.4 session 模板库可参考
- **支持目标**:增肌 / 减脂 / 力量 / 耐力 / 康复 / 混合
- **支持分化**:fullbody / upper_lower / push_pull_legs / bro_split / 自定
- **支持渐进模型**:linear / double_progression / undulating / wave / conjugate
- **示例**(5 个,roadmap v0.3 5/5 闭环):
  - ① 4 周增肌入门(徒手+哑铃,3 练/周,Day A 全身推+腿,4 组哑铃卧推递进 20→25kg) — 已落地 volume_policy(counting_basis=working_sets_only / warmup=exclude_with_separate_log / primary_split=movement_pattern / 60_40)
  - ② 4 周减脂塑形(力量+有氧双轨,4 练/周 upper_lower,Day 1 上肢+核心,3 组俯卧撑) — 落地完整 7 字段 volume_policy(primary_split=movement_pattern / 50_50)、`cardio_summary`(Z2 / 15min)、`weekly_target.weekly_energy_expenditure_kcal_min` = 2000、`constraints.required_cardio_per_week_min` = 90
  - ③ 4 周纯力量周期化(PPL 3 练/周,大复合为锚,典型 Day 1 PUSH = 卧推+推举+臂屈伸 3 blocks) — 落地完整 7 字段 volume_policy(primary_split=movement_pattern / **70_30 主辅比**、intensity_floor=70% 1RM、rpe_floor=7,容量 8-12 working sets/肌群/周)、`load_progression`(linear,W1 75% → W4 85% 1RM)、`calendar_overview`(4 周每日布局概览)、`constraints.max_session_minutes`=75 / `min_rest_between_sessions_hours`=48(PPL 3 练/周,日间至少 48h 恢复)
  - ④ 4 周有氧耐力入门(3 练/周,Day 1 = Z2 慢跑 30min + 徒手循环 3 轮) — 落地完整 7 字段 volume_policy(per_muscle_targets 降至 0-4 因为力量占比小,intensity_floor=40% 1RM,rpe_floor=4)、**有氧三件套**:`cardio_summary`(慢跑/Z2/weekly_minutes 90-150/rpe 4) + `weekly_target.cardio_minutes_min`=90 + `constraints.min_cardio_zone`=Z2;`load_progression`(linear,W1 30min Z2 → W3 35min Z2 + 5min Z3,W4 deload 减量)、`calendar_overview`(4 周布局,W4 末两日 5km 配速测试作为下一周期起点)
  - ⑤ 4 周下背痛康复(LBP 亚急性/慢性期进阶回归,3 练/周 30-45min/练,Day 1 = 死虫 3×8/侧 + 臀桥 3×10 + 猫驼 2×8 + 15min Z1-Z2 行走) — 落地完整 7 字段 volume_policy(per_muscle_targets 0-4,intensity_floor=40% 1RM 适配徒手/轻负重,rpe_floor=4)、**康复四件套**:`inclusion_criteria`(5 条准入)+ `exclusion_criteria`(5 条禁忌)+ `red_flags_stop_training`(4 条停训信号)+ `constraints.rehab_constraints`(VAS 阈值 3/10 + 晨僵 30min + 进阶门槛);`weekly_target.primary_lift_count_min=0`(康复初期无大复合,如深蹲/硬拉/卧推全部 `exclude_exercise_ids`);`load_progression`(linear,康复线性回归非肌肥大)、`calendar_overview`(4 阶段:W1 激活 → W2 稳定 → W3 力量回归 → W4 整合),W4 末 ODI 功能障碍指数 + 5×sit-and-reach 测试作为回归正常训练依据
- **关联库**:exercises.json(动作引用)/ rehab_kb.json(伤病禁忌过滤) / load_baseline(心率区间 + RPE 锚点) / hr_rpe_baseline.json
- **下一步**:roadmap v0.3 5/5 已闭环,Phase 0 任务 4 完成;Phase 1 端到端验收条件全部就绪(数据层 002 fixture + 知识层 5 模板),差 T1 拍板入口形态;4 个 mock-id 模板与 exercises.json 实际 id 对齐在 v1.0 一起做;v0.4 session 模板库(20+)可参考 endurance 的"主项 + 辅项循环"和 rehab 的"4 阶段线性递进"两类主导模板结构
