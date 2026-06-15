#!/usr/bin/env sh
# Harness Templates Skill — 一键安装脚本
# 用法: ./install.sh [harness-templates.skill 路径]
#      默认查找当前目录下的 harness-templates.skill

set -eu

SKILL_FILE="${1:-harness-templates.skill}"
PLUGIN_NAME="harness-templates"
PLUGINS_DIR="${HOME}/.claude/plugins"
CACHE_DIR="${PLUGINS_DIR}/cache/claude-plugins-official/${PLUGIN_NAME}"
INSTALLED_JSON="${PLUGINS_DIR}/installed_plugins.json"
TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%S.000Z)"

echo "== Harness Templates Skill 安装 =="
echo ""

# 1. 检查 .skill 文件
if [ ! -f "$SKILL_FILE" ]; then
  echo "[✗] 找不到 ${SKILL_FILE}"
  echo "    请将 .skill 文件放在当前目录，或: $0 <路径>"
  exit 1
fi
echo "[✓] 找到 ${SKILL_FILE}"

# 2. 创建插件目录
mkdir -p "$CACHE_DIR"
echo "[✓] 创建目录 ${CACHE_DIR}"

# 3. 解压
unzip -o "$SKILL_FILE" -d "$CACHE_DIR" > /dev/null
echo "[✓] 解压完成"

# 4. 处理嵌套目录（.skill 包可能多一层）
if [ -d "${CACHE_DIR}/${PLUGIN_NAME}" ]; then
  mv "${CACHE_DIR}/${PLUGIN_NAME}/"* "$CACHE_DIR/" 2>/dev/null || true
  rmdir "${CACHE_DIR}/${PLUGIN_NAME}" 2>/dev/null || true
  echo "[✓] 修正目录结构"
fi

# 5. 注册到 installed_plugins.json
if [ -f "$INSTALLED_JSON" ]; then
  # 检查是否已注册
  if grep -q "\"${PLUGIN_NAME}@" "$INSTALLED_JSON" 2>/dev/null; then
    echo "[!] ${PLUGIN_NAME} 已注册，跳过"
  else
    # 用 Python 处理 JSON（更可靠）
    python3 -c "
import json, sys
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
echo "  2. 在项目中输入 /harness-templates 或"
echo "     \"帮我配置 Harness 工程\" 即可触发"
