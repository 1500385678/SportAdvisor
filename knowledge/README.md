# SportAdvisor · 知识库索引

> 自动化生成 · v1.5 · 2026-09-01
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
| `plan_schema.json` | 训练计划表 schema(plan / session / set_block / rep_set / load_entry 5 层 + volume_policy 容量规则 + 1 个 4 周增肌示例) | 0.2.0 | draft+volume_policy |
| `hr_rpe_baseline.json` | 心率/RPE 基线(HRmax 3 公式 / 5 区分布 / Borg CR10 / 9 类人群偏移 / 2 个示例 baseline) | 0.1.0 | skeleton |

## 当前状态
- **主题数**:10 / 10 (全部 ready)
- **主题总行数**:1886
- **主题总字节**:约 76 KB
- **动作库**:49 条骨架(力量 33 / 柔韧 9 / 动态热身 5 / 核心 2)
- **康复库**:7 条骨架(急性 5 / 慢性 2;PEACE&LOVE + 7 项警示信号 + 8 项预防原则)

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

## Phase 0 进度
- [x] **任务 1**:盘点 10 大主题,建索引 ← 2026-08-24
- [x] **任务 2(部分)**:提取训练动作库 `exercises.json` ← 2026-08-25(骨架 v0.1.0,49 条入库;100+ 目标待 T2 任务扩展)
- [x] **任务 3(部分)**:提取伤病/康复知识 `rehab_kb.json` ← 2026-08-26(骨架 v0.1.0,7 条伤病 + PEACE&LOVE 原则 + 警示信号 + 预防原则;扩展待 T3)
- [x] **任务 4**:设计训练计划表 schema ← 2026-08-27(`plan_schema.json` v0.1.0 / 5 层结构 / 1 个 4 周增肌示例;扩展待 T2 任务)
- [x] **任务 4 增量**:统一容量口径 ← 2026-09-01(`plan_schema.json` v0.2.0 / 新增 `volume_policy` 字段:`counting_basis` / `warmup_policy` / `primary_split_method` / `primary_vs_accessory_ratio` / `weekly_volume_targets_per_muscle_group` / `intensity_floor_pct_1rm` / `rpe_floor`,解决 0831 增量中提到的 capacity 计算口径差异;示例 plan 已落地 4 子字段)
- [ ] 任务 5:SQLite → PostgreSQL + InfluxDB 迁移脚本
- [ ] 任务 6:心率/RPE 基线范围表

## 下一项
**任务 2 扩展** —— 把动作库从 49 条扩展到 100+ 条:
- 补全已有 progression 引用
- 从 03_有氧运动 抽取跑步/骑行/游泳动作
- 从 07_运动损伤 抽取康复/预防动作
- 从 08_训练计划 抽取周期化模板对应的代表动作

或并行推进 **任务 5**:SQLite → PostgreSQL + InfluxDB 迁移脚本(对齐 `plan_schema.json` 的 plan / session / rep_set / load_entry 4 表)。

## 计划表 schema(plan_schema.json)概览

- **覆盖来源**:08_训练计划 / 02_力量训练 / 03_有氧运动
- **schema 版本**:0.2(v0.2.0 / 2026-09-01)
- **结构**:5 层 — `plan` → `session` → `set_block` → `rep_set` → `load_entry`
- **plan 顶层规则**(5 个):`deload` / `weekly_target` / `load_progression` / `constraints` / `volume_policy`(v0.2 新增)
- **volume_policy 7 字段**:counting_basis / warmup_policy / primary_split_method / primary_vs_accessory_ratio / weekly_volume_targets_per_muscle_group / intensity_floor_pct_1rm / rpe_floor —— 统一"组怎么数、热身算不算、主辅怎么分、每肌群做多少组"
- **支持目标**:增肌 / 减脂 / 力量 / 耐力 / 康复 / 混合
- **支持分化**:fullbody / upper_lower / push_pull_legs / bro_split / 自定
- **支持渐进模型**:linear / double_progression / undulating / wave / conjugate
- **示例**:1 个 4 周增肌入门计划(徒手+哑铃,3 练/周,Day A 全身推+腿,4 组哑铃卧推递进 20→25kg) — 已落地 volume_policy(counting_basis=working_sets_only / warmup=exclude_with_separate_log / primary_split=movement_pattern / 60_40)
- **关联库**:exercises.json(动作引用)/ rehab_kb.json(伤病禁忌过滤) / load_baseline(心率区间 + RPE 锚点) / hr_rpe_baseline.json
- **下一步**:Phase 0 任务 5 落库(002_seed_demo_data.sql 0831 已就位)→ FastAPI /plan 端点对接,volume_policy 容量校验在 API 层兜底
