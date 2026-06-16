#!/usr/bin/env sh
# Harness Templates Skill — 一键安装脚本
# 用法: ./install.sh                       从源码安装（git clone 后执行）
#       ./install.sh harness-templates.skill   从 .skill 文件安装

set -eu

PLUGIN_NAME="harness-templates"
PLUGINS_DIR="${HOME}/.claude/plugins"
CACHE_DIR="${PLUGINS_DIR}/cache/claude-plugins-official/${PLUGIN_NAME}"
INSTALLED_JSON="${PLUGINS_DIR}/installed_plugins.json"
TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%S.000Z)"
SKILL_FILE="${1:-}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "== Harness Templates Skill 安装 =="
echo ""

# 判断安装模式
if [ -n "$SKILL_FILE" ]; then
  # === 模式 A：从 .skill 文件安装 ===
  if [ ! -f "$SKILL_FILE" ]; then
    echo "[✗] 找不到 ${SKILL_FILE}"
    echo "    用法: $0 <harness-templates.skill 路径>"
    exit 1
  fi
  echo "[✓] 从 .skill 文件安装: ${SKILL_FILE}"
  SOURCE_DIR=""
  NEED_UNZIP=true
else
  # === 模式 B：从源码安装（git clone 后） ===
  if [ -f "${SCRIPT_DIR}/skills/harness-templates/SKILL.md" ]; then
    echo "[✓] 从源码安装: ${SCRIPT_DIR}"
    SOURCE_DIR="$SCRIPT_DIR"
    NEED_UNZIP=false
  else
    echo "[✗] 找不到 skills/harness-templates/SKILL.md"
    echo "    请在仓库根目录运行此脚本，或指定 .skill 文件路径"
    exit 1
  fi
fi

# 创建插件目录
mkdir -p "$CACHE_DIR"
echo "[✓] 创建目录 ${CACHE_DIR}"

# 复制 / 解压文件
if $NEED_UNZIP; then
  unzip -o "$SKILL_FILE" -d "$CACHE_DIR" > /dev/null
  echo "[✓] 解压完成"
  # 处理嵌套目录
  if [ -d "${CACHE_DIR}/${PLUGIN_NAME}" ]; then
    mv "${CACHE_DIR}/${PLUGIN_NAME}/"* "$CACHE_DIR/" 2>/dev/null || true
    rmdir "${CACHE_DIR}/${PLUGIN_NAME}" 2>/dev/null || true
    echo "[✓] 修正目录结构"
  fi
else
  cp -r "${SOURCE_DIR}/skills" "$CACHE_DIR/"
  cp -r "${SOURCE_DIR}/templates" "$CACHE_DIR/"
  cp "${SOURCE_DIR}/install.sh" "$CACHE_DIR/" 2>/dev/null || true
  cp "${SOURCE_DIR}/install.ps1" "$CACHE_DIR/" 2>/dev/null || true
  echo "[✓] 复制完成"
fi

# 注册到 installed_plugins.json
if [ -f "$INSTALLED_JSON" ]; then
  if grep -q "\"${PLUGIN_NAME}@" "$INSTALLED_JSON" 2>/dev/null; then
    echo "[!] ${PLUGIN_NAME} 已注册，跳过"
  else
    python3 -c "
import json
with open('${INSTALLED_JSON}', 'r') as f:
    data = json.load(f)
data['plugins']['${PLUGIN_NAME}@claude-plugins-official'] = [{
    'scope': 'user',
    'installPath': '${CACHE_DIR}',
    'version': '1.0.0',
    'installedAt': '${TIMESTAMP}',
    'lastUpdated': '${TIMESTAMP}'
}]
with open('${INSTALLED_JSON}', 'w') as f:
    json.dump(data, f, indent=2)
print('已注册')
" 2>/dev/null || echo "[!] 自动注册失败，请手动编辑 ${INSTALLED_JSON}"
    echo "[✓] 注册完成"
  fi
else
  echo "[!] ${INSTALLED_JSON} 不存在，请先安装 Claude Code"
fi

echo ""
echo "========================================"
echo "  安装完成！"
echo "========================================"
echo ""
echo "下一步："
echo "  1. 重启 Claude Code 或执行 /reload-plugins"
echo "  2. 在项目中输入 \"帮我配置 Harness 工程\" 即可触发"
