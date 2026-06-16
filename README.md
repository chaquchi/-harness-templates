# Harness Templates — AI Coding 工程化基础设施

一键为新项目搭建 Harness 工程四件套，让 AI Agent 有条理地工作。

```
AI Agent = LLM + Harness
```

## 什么是 Harness 工程

Harness（马鞍）是用来驯服 AI 这匹野马的。一个 AI Coding 项目有了 Harness，Agent 就能：

- **会话启动** → 自动读取 AGENTS.md 和交接文档，知道做到哪了
- **工作中** → 遵守 Work Rules，单任务推进，不乱重构
- **会话结束** → 更新 session-handoff.md 和 feature_list.json，下次无缝继续

## 四件套

| 文件 | 作用 |
|------|------|
| `AGENTS.md` | 行为规则：Session Start → Work Rules → Definition of Done → Session End |
| `feature_list.json` | 任务总账：所有功能的状态、验证条件、证据记录 |
| `docs/agent/session-handoff.md` | 会话交接单：本轮干了什么、卡在哪、下一步 |
| `init.sh` | 一键验证：环境、依赖、编译、测试是否正常 |

## 支持的 6 种项目模板

| 模板 | 适用场景 |
|------|---------|
| `universal` | 不限技术栈，通用规则 |
| `frontend` | React / Vue / Angular 前端项目 |
| `backend` | Spring Boot / Express / FastAPI 后端项目 |
| `desktop` | Electron / Tauri 桌面应用 |
| `embedded` | ARM / RTOS / Bare-metal 嵌入式开发 |
| `linux-cpp` | Linux 环境下 C/C++ 系统开发 |

## 安装

### 方式一：从 .skill 文件安装

下载最新 `harness-templates.skill`，然后：

```bash
# macOS / Linux
./install.sh harness-templates.skill

# Windows PowerShell
.\install.ps1 harness-templates.skill
```

重启 Claude Code 或执行 `/reload-plugins`。

### 方式二：从源码安装

```bash
git clone <repo-url>
cd harness-templates
./install.sh
```

## 使用

安装后在 Claude Code 中输入：

```
帮我配置 Harness 工程
```

或者指定项目类型：

```
给我的前端项目加上 Harness 工程规范
```

Agent 会自动询问项目类型，然后生成对应的四件套。

## 项目结构

```
harness-templates/
├── skills/
│   └── harness-templates/
│       ├── SKILL.md              # Skill 定义
│       └── templates/            # 6 套模板
│           ├── universal/
│           ├── frontend/
│           ├── backend/
│           ├── desktop/
│           ├── embedded/
│           └── linux-cpp/
├── install.sh                    # Linux/macOS 安装脚本
└── install.ps1                   # Windows 安装脚本
```

## 许可

MIT
