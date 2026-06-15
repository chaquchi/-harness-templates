---
name: harness-templates
description: >
  为项目搭建 Harness 工程基础设施（AGENTS.md、feature_list.json、session-handoff.md、init.sh）。
  当用户提到 Harness 工程、AGENTS.md、feature_list、session-handoff、init.sh、项目规则配置、
  Agent 行为规范、AI Coding 工作流、会话交接、任务总账 时触发。即使用户只是说
  "帮我给项目加上 AI 编码规范" 或 "我想让 AI 更有条理地工作"，也应使用此 Skill。
---

# Harness Templates — AI Coding 工程化基础设施

这个 Skill 为项目一键生成 Harness 工程四件套，让 AI Agent 在任何项目中都能有条理地工作。

## 核心理念

```
AI Agent = LLM + Harness

Harness 四大组件：
  Memory（上下文记忆）    → session-handoff.md + feature_list.json
  Tools/Action（执行能力） → init.sh
  Planning（规划编排）    → AGENTS.md（Definition of Done）
  Guardrails（护栏）      → AGENTS.md（Work Rules）
```

## 第一步：确认项目类型

如果用户没有明确指定项目类型，先询问：

> 你想为哪种类型的项目配置 Harness 工程？
> 1. **通用** — 不限技术栈，通用规则
> 2. **前端** — React / Vue / Angular 等前端项目
> 3. **后端** — Spring Boot / Express / FastAPI 等服务端项目
> 4. **桌面应用** — Electron / Tauri 等桌面客户端
> 5. **嵌入式** — ARM / RTOS / Bare-metal 嵌入式开发
> 6. **Linux C/C++** — Linux 环境下 C/C++ 系统/服务开发

根据回答选择对应的模板变体：

| 项目类型 | 模板目录 |
|---------|---------|
| 通用 | `templates/universal/` |
| 前端 | `templates/frontend/` |
| 后端 | `templates/backend/` |
| 桌面应用 | `templates/desktop/` |
| 嵌入式 | `templates/embedded/` |
| Linux C/C++ | `templates/linux-cpp/` |

## 第二步：确认项目路径

如果用户没有指定目标路径，默认为当前工作目录（`pwd`）。询问确认：

> 将把 Harness 文件生成到 `<path>`，可以吗？

## 第三步：生成文件

从对应的模板目录中，将以下文件复制/生成到目标项目根目录：

```
<project-root>/
├── AGENTS.md                        # Agent 行为规则
├── feature_list.json                # 功能任务总账
├── init.sh                          # 初始化验证脚本（chmod +x）
└── docs/
    └── agent/
        └── session-handoff.md       # 会话交接单
```

### 生成规则

1. **AGENTS.md** — 直接复制模板文件。如果项目中已有 `AGENTS.md`，询问是覆盖还是合并。
2. **feature_list.json** — 直接复制模板骨架（所有 feature 为 `not_started`）。如果已存在，只询问是否追加新 feature 条目。
3. **docs/agent/session-handoff.md** — 直接复制空白模板。
4. **init.sh** — 直接复制模板文件，然后执行 `chmod +x init.sh`。

## 第四步：配置 sessionStart Hook

在项目的 `.claude/settings.json` 中添加 sessionStart hook，让每次新会话自动加载 `AGENTS.md`：

如果 `.claude/settings.json` 不存在，创建：
```json
{
  "hooks": {
    "sessionStart": [
      {
        "type": "command",
        "command": "cat AGENTS.md"
      }
    ]
  }
}
```

如果已存在，将 `sessionStart` hook 合并进去（去重）。

## 第五步：初始化验证

生成完成后，执行 `./init.sh` 验证基础环境。如果 init.sh 执行失败：

- 判断是环境问题（缺少工具链）还是脚本问题（路径不对）
- 环境问题：记录到 `session-handoff.md` 的"风险与限制"
- 脚本问题：修正 init.sh 直到通过

## 第六步：完成报告

向用户汇报生成结果：

```
✅ Harness 工程已就绪

已生成文件：
  - AGENTS.md              → Agent 行为规则
  - feature_list.json       → 功能任务总账
  - docs/agent/session-handoff.md → 会话交接单
  - init.sh                 → 初始化验证脚本
  - .claude/settings.json   → sessionStart 自动加载 AGENTS.md

验证结果：init.sh 通过 / 部分失败（<具体说明>）

下一步：运行 ./init.sh 确认环境，然后开始第一个 feature。
```

---

## 模板变体差异

各项目类型的核心差异在 `init.sh` 的验证命令：

| 项目类型 | init.sh 核心检查 |
|---------|-----------------|
| universal | pwd + git + 基础环境 |
| frontend | node -v + npm -v + npm install + lint/test/build |
| backend | java -v/npm/pip + mvn/npm/pip install + compile/test |
| desktop | node -v + npm -v + Electron 依赖检查 |
| embedded | arm-none-eabi-gcc + make/cmake + 交叉编译工具链 |
| linux-cpp | gcc/g++ + cmake/make + 编译 + ctest/valgrind |

---

## 注意事项

- 所有模板默认不覆盖用户已有文件，必须先询问。
- `feature_list.json` 的 features 是骨架示例，需要根据实际项目调整。
- `init.sh` 中 `set -eu` 表示遇错即停，是刻意设计——不要在坏环境上工作。
- 会话结束时务必更新 `session-handoff.md` 和 `feature_list.json`，这是跨会话记忆的命脉。
