# AGENTS.md

本仓库使用 Harness 工程规范管理 Linux C/C++ 项目的 AI Coding 工作流。
目标不是尽快堆代码，而是保证每一轮会话结束后，下一轮会话仍能基于仓库状态无缝继续。

## Session Start

每次开始修改代码前，严格按此顺序执行：

1. 执行 `pwd` 确认当前在项目根目录。
2. 读取 `feature_list.json`，确认当前唯一的 `active` 任务；若没有 `active`，选择优先级最高且状态为 `not_started` 的任务激活。
3. 读取 `docs/agent/session-handoff.md`，了解上次会话的已完成内容、未完成内容、风险和下一步。
4. 执行 `git log --oneline -5`，查看最近提交记录。
5. 执行 `git status --short`，确认当前工作区干净程度。
6. 执行 `./init.sh`，完成初始化和基础验证。
7. 若基础验证失败，**必须先修复基础状态**，严禁在坏状态上继续叠加新功能。

## Work Rules

- 一次只允许一个功能处于 `active` 状态。
- 不要因为"代码已经写了"就把任务标记为完成。
- 只有在消除当前 blocker 所必需时，才允许做窄范围的旁路修复。
- 不要为了让结果看起来通过而弱化验证规则。
- 优先依赖仓库中的持久化文件（`feature_list.json`、`session-handoff.md`），不要依赖聊天记录作为事实来源。
- 除非当前任务明确要求，否则不要顺手重构其他模块。
- 代码注释要求中文，简洁、通俗易懂。函数注释说明关键作用、参数约束和返回值含义，头文件中的公开 API 必须有完整文档注释。
- 不要自行提交代码，提交由用户决定。
- **C/C++ 规范**：
  - 所有 `malloc` 必须有对应的 `free`，所有 `new` 必须有对应的 `delete`。优先使用 RAII 和智能指针。
  - 指针参数必须做空检查，数组访问必须做边界检查。
  - 头文件必须包含 `#pragma once` 或 include guard。
  - `.h` 文件只放公开接口声明，实现细节放 `.c`/`.cpp` 中。
  - 全局变量必须加 `static` 限制作用域，或使用明确的命名空间前缀。
  - 编译必须通过 `-Wall -Wextra -Werror`，零 warning。
  - POSIX 系统调用返回值必须检查，`errno` 必须处理或记录。
  - 信号处理函数中只能使用 async-signal-safe 函数。

## Source of Truth

以下文件是 Agent 的主要工作依据：

- `feature_list.json`：功能状态的唯一事实来源。
- `docs/agent/session-handoff.md`：会话交接记录，包含当前进度、验证状态、风险和下一步。
- `init.sh`：工具链检查、编译、静态分析、测试验证入口。
- `AGENTS.md`：会话启动顺序、工作规则和完成定义。

## Definition of Done

一个功能只有在以下条件**全部满足**时，才可以从 `active` 变成 `passing`：

- 目标行为已经实现。
- 编译通过，零 warning（`-Wall -Wextra -Werror`）。
- 静态分析通过（`clang-tidy` / `cppcheck`，如有配置）。
- 单元测试通过，且新增代码覆盖率不低于 80%。
- 验证结果和证据已记录在 `feature_list.json` 的 `evidence` 字段中。
- 当前改动没有破坏 `./init.sh` 的标准启动路径。
- Valgrind / AddressSanitizer 检查无内存泄漏和越界访问（如适用）。
- 头文件变更（如有）已确认不破坏 ABI 兼容性。

## Session End

每次会话结束前必须完成：

1. 更新 `docs/agent/session-handoff.md`，记录本轮完成、当前结论、风险与限制、下一步。
2. 更新 `feature_list.json`，回填当前 active 任务的状态与 evidence。
3. 记录未解决的风险、限制和 blocker。
4. 清理临时调试痕迹（`printf`/`std::cout` 调试输出、注释掉的试验代码、`#if 0` 块）。
5. 执行 `./init.sh` 确认仓库仍可进入可继续状态。
6. 只有在工作状态安全、可恢复时，才提示用户可以提交代码。
