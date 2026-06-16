#!/usr/bin/env sh
set -eu

echo "============================================"
echo "  桌面应用项目初始化检查"
echo "============================================"

echo ""
echo "== [1/8] 当前目录 =="
pwd

echo ""
echo "== [2/8] Git 最近提交 =="
git log --oneline -5 2>/dev/null || echo "(尚无提交记录)"

echo ""
echo "== [3/8] 工作区状态 =="
git status --short 2>/dev/null || echo "(非 git 仓库或 git 不可用)"

echo ""
echo "== [4/8] Node.js 版本 =="
node -v

echo ""
echo "== [5/8] 包管理器版本 =="
if command -v npm >/dev/null 2>&1; then
  echo "npm: $(npm -v)"
elif command -v pnpm >/dev/null 2>&1; then
  echo "pnpm: $(pnpm -v)"
elif command -v yarn >/dev/null 2>&1; then
  echo "yarn: $(yarn --version 2>/dev/null || yarn -v)"
else
  echo "(未检测到 npm/pnpm/yarn)"
fi

echo ""
echo "== [6/8] 系统信息 =="
echo "OS: $(uname -s 2>/dev/null || echo 'Windows')"
echo "Arch: $(uname -m 2>/dev/null || echo 'x64')"

echo ""
echo "== [7/8] 依赖安装 =="
if [ -f "package.json" ]; then
  if command -v pnpm >/dev/null 2>&1; then
    pnpm install --silent 2>/dev/null || npm install --silent 2>/dev/null
  else
    npm install --silent 2>/dev/null
  fi || echo "依赖安装失败（部分原生模块可能需要额外配置）"
  echo "依赖安装完成"
else
  echo "(package.json 尚未创建，跳过依赖安装)"
fi

echo ""
echo "== [8/8] Lint / 测试 / 构建 =="
if [ -f "package.json" ]; then
  echo ""
  echo "--- Lint 检查 ---"
  if npm run lint --silent 2>/dev/null; then
    echo "lint: ✓ 通过"
  else
    echo "lint: ✗ 失败或未配置"
  fi
  echo ""
  echo "--- 单元测试 ---"
  if npm run test:unit --silent 2>/dev/null; then
    echo "test:unit: ✓ 通过"
  elif npm test --silent 2>/dev/null; then
    echo "test: ✓ 通过"
  else
    echo "test: ✗ 失败或未配置"
  fi
  echo ""
  echo "--- 生产构建 ---"
  if npm run build --silent 2>/dev/null; then
    echo "build: ✓ 通过"
  else
    echo "build: ✗ 失败或未配置"
  fi
else
  echo "(package.json 尚未创建，跳过验证)"
fi

echo ""
echo "============================================"
echo "  初始化完成"
echo "============================================"
echo "若所有检查通过，请继续当前 active 任务。"
echo "提示：首次运行可能需执行 npx @electron/rebuild 编译原生模块。"
