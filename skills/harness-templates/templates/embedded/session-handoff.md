# 会话交接

> 本文件是跨会话的上下文桥梁。每次会话结束前必须更新，下次会话开始时首先读取。

## 本轮完成

- 按 `AGENTS.md` 顺序完成会话启动检查：
  - 执行 `pwd` 确认当前目录
  - 读取 `feature_list.json`，确认当前 active 任务
  - 读取本文档了解上次进度
  - 执行 `git log --oneline -5` 查看最近提交
  - 执行 `git status --short` 确认工作区状态
  - 执行 `./init.sh`，结果：_（记录通过/失败）_
- _（逐条记录本轮实际完成的工作）_

## 当前结论

- _（当前 active 任务的状态与进度摘要）_
- 下一步：_（下一轮从哪开始）_

## 风险与限制

- _（记录当前工作区脏改动、环境问题、阻塞项）_
- _（记录工具链版本兼容性问题）_
- _（记录硬件相关风险：开发板可用性、烧录工具、调试器连接）_
- _（记录已验证但未在真实硬件上测试的点）_
- _（记录内存/Flash 使用情况，栈深度估计）_

## 下一步

- _（下一轮会话的具体行动项，按优先级排列）_
- _（需要先执行的检查或前置条件）_

## 参考命令

- `./init.sh`
- 编译：`make` / `cmake --build build` / `west build`
- 烧录：`make flash` / `openocd -f board.cfg` / `west flash`
- 调试：`make debug` / `arm-none-eabi-gdb` / `west debug`
- 串口监视：`minicom -D /dev/ttyUSB0` / `screen /dev/ttyACM0 115200`
