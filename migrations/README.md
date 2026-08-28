# SportAdvisor · 迁移脚本

> 数据层骨架 · Phase 0 任务 5 收尾
> 版本:v0.1.0  ·  生成日期:2026-08-29
> 对应:`knowledge/plan_schema.json` v0.1.0(5 层 plan / session / set_block / rep_set / load_entry)

---

## 一、设计概览

```
┌──────────────────────────────────────────────────────────────┐
│                      SportAdvisor 数据层                      │
├──────────────────────────┬───────────────────────────────────┤
│   PostgreSQL 14+         │   InfluxDB 2.x                    │
│   (5 张常规表)            │   (1 个时序 measurement)           │
│                          │                                   │
│  plans                   │   measurement = training_load     │
│   └─ sessions            │   tags: user_id, session_id,      │
│        └─ set_blocks     │         source, exercise_id       │
│             └─ rep_sets  │   fields: heart_rate, rpe,        │
│  load_entries (聚合/日)   │           load_kg, reps           │
│                          │   粒度:秒级原始数据                │
└──────────────────────────┴───────────────────────────────────┘
              ↑                              ↑
              │ 计划/记录(低频,事务性强)        │ 训练负荷(高频,append-only)
              │                              │
        ┌─────┴──────────────────────────────┴─────┐
        │       FastAPI /load/ingest 等端点         │
        └───────────────────────────────────────────┘
```

**双轨原因**:
- 计划/记录 → 强关系、强事务、需 JOIN 查询(plan / session / rep_set)→ PostgreSQL
- 心率/RPE/容量 → 高频写入(每组 1-3 条)、append-only、时序聚合 → InfluxDB
- 每日聚合(acute_load_7d / chronic_load_28d / acwr)→ 双写 PostgreSQL(load_entries)+ InfluxDB(Flux 实时算)

---

## 二、文件清单

| 文件 | 用途 | 状态 |
|------|------|------|
| `001_init_schema.sql` | PostgreSQL 5 表 DDL + 索引 + 触发器 | ✅ v0.1.0 |
| `influx/line_protocol_example.lp` | InfluxDB Line Protocol 样本(训练负荷) | ✅ v0.1.0 |
| `README.md` | 本文档 | ✅ v0.1.0 |
| `002_seed_demo_data.sql` | plan_schema.json 示例(plan_hypertrophy_4w_demo01)入库脚本 | 📋 Phase 1 |
| `003_*.sql` | 其他 seed(增肌/减脂/力量/耐力/康复 5 模板) | 📋 Phase 1 |

---

## 三、5 张表对应 plan_schema.json 字段

| 表 | 数量级 | PK 模式 | 引用 |
|----|--------|---------|------|
| `plans` | 10²-10³ 用户计划 | `plan_<goal>_<weeks>w_<userId>` | — |
| `sessions` | 10⁴-10⁵(周×日) | `sess_<planId>_w<n>d<m>` | plans(id) |
| `set_blocks` | 10⁵-10⁶(组块) | `block_<sessId>_<n>` | sessions(id) |
| `rep_sets` | 10⁶-10⁷(组记录) | `rs_<blockId>_<setNum>` | set_blocks(id) |
| `load_entries` | 10⁴-10⁵(用户×日) | `load_<userId>_<YYYYMMDD>` | sessions(id), NULL allowed |

**软外键说明**:
- `set_blocks.exercise_id` 不强外键到 `exercises` 表(Phase 0 还在 `knowledge/exercises.json` 文件层),Phase 1 引入 `exercises` 表后,改为强外键 + JSONB 兼容期
- `sessions.main_blocks` 是 JSONB 数组(存 set_block id 列表),而不是新建 `session_blocks` 中间表 — 因执行顺序本身是稳定列表,且一个 block 只属于一个 session,无多对多

---

## 四、实施步骤(Phase 1 启动期)

### 4.1 PostgreSQL 部署

```bash
# 1. 创建数据库与用户
createdb sport_advisor
createuser -P sport_app  # 密码:见部署 .env

# 2. 应用 DDL
psql -d sport_advisor -U sport_app -f migrations/001_init_schema.sql

# 3. 验证
psql -d sport_advisor -U sport_app -c "\dt"
psql -d sport_advisor -U sport_app -c "\di"
psql -d sport_advisor -U sport_app -c "\d plans"
```

### 4.2 InfluxDB 部署

```bash
# 1. 启动(本地或 Docker)
docker run -d --name influxdb \
  -p 8086:8086 \
  -v influxdb-data:/var/lib/influxdb2 \
  -e DOCKER_INFLUXDB_INIT_MODE=setup \
  -e DOCKER_INFLUXDB_INIT_USERNAME=sportadmin \
  -e DOCKER_INFLUXDB_INIT_PASSWORD=<secret> \
  -e DOCKER_INFLUXDB_INIT_ORG=sportadvisor \
  -e DOCKER_INFLUXDB_INIT_BUCKET=sport_metrics \
  influxdb:2.7

# 2. 灌入样本数据(测试连接)
influx write --bucket sport_metrics \
  --file migrations/influx/line_protocol_example.lp \
  --org sportadvisor

# 3. 验证
influx query 'from(bucket:"sport_metrics") |> range(start:-1h) |> limit(n:5)'
```

### 4.3 应用层接入(Phase 1)

- FastAPI 端点:
  - `POST /plan` 创建计划 → 写 `plans` + 嵌套 `sessions` / `set_blocks` / `rep_sets`
  - `POST /load/ingest` 摄入可穿戴数据 → 写 InfluxDB(秒级) + 异步汇总写 `load_entries`
  - `GET /load/acwr?user_id=xxx` 查询急慢性负荷比 → InfluxDB Flux 实时算
- 引入 `app/models/` SQLAlchemy ORM 与 `app/schemas/` Pydantic 模型,与 DDL 一一对应

---

## 五、验收标准

- [x] PostgreSQL 5 表 DDL 完整,所有 NOT NULL / CHECK 约束就位
- [x] 至少 11 个索引(goal / owner / created_at / plan_id / session_id / exercise_id / user_id / date / overtraining_flag 等)
- [x] `plans.updated_at` 触发器自动维护
- [x] InfluxDB Line Protocol 样本覆盖训练负荷主路径(热身/工作/组间休息)
- [x] README 解释双轨设计 + 软外键决策
- [ ] Phase 1 接入 FastAPI 后,端到端写入 1 个示例计划(plan_hypertrophy_4w_demo01)→ 4 张表完整落库
- [ ] Phase 1 接入 FastAPI 后,可穿戴模拟器推 1 小时心率 → InfluxDB + `load_entries` 双写一致
- [ ] ACWR Flux 查询在 200ms 内返回(< 1 年数据量)

---

## 六、变更记录

| 日期 | 版本 | 变更 | 关联 |
|------|------|------|------|
| 2026-08-29 | v0.1.0 | 初版:5 表 DDL + InfluxDB .lp 样本 + README | Phase 0 任务 5 收尾 |
