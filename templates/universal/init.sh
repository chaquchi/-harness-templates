#!/usr/bin/env sh
set -eu

echo "============================================"
echo "  项目初始化检查"
echo "============================================"

echo ""
echo "== [1/4] 当前目录 =="
pwd

echo ""
echo "== [2/4] Git 最近提交 =="
git log --oneline -5 2>/dev/null || echo "(尚无提交记录)"

echo ""
echo "== [3/4] 工作区状态 =="
git status --short 2>/dev/null || echo "(非 git 仓库或 git 不可用)"

echo ""
echo "== [4/4] 关键文件完整性 =="
FILES_OK=0
for f in "AGENTS.md" "feature_list.json" "docs/agent/session-handoff.md"; do
  if [ -f "$f" ]; then
    echo "  [✓] $f"
    FILES_OK=$((FILES_OK + 1))
  else
    echo "  [✗] $f 不存在"
  fi
done
echo "  完整性: $FILES_OK/3"

echo ""
echo "============================================"
echo "  初始化完成"
echo "============================================"
echo "若所有检查通过，请继续当前 active 任务。"
