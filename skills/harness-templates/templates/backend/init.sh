#!/usr/bin/env sh
set -eu

echo "============================================"
echo "  后端项目初始化检查"
echo "============================================"

echo ""
echo "== [1/6] 当前目录 =="
pwd

echo ""
echo "== [2/6] Git 最近提交 =="
git log --oneline -5 2>/dev/null || echo "(尚无提交记录)"

echo ""
echo "== [3/6] 工作区状态 =="
git status --short 2>/dev/null || echo "(非 git 仓库或 git 不可用)"

echo ""
echo "== [4/6] 运行时与构建工具 =="
# Java / Maven
if [ -f "pom.xml" ] || [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
  echo "Java 版本:"
  java -version 2>&1 | head -1 || echo "(java 不可用)"
  if command -v mvn >/dev/null 2>&1; then
    echo "Maven: $(mvn -v 2>/dev/null | head -1 || echo '未知')"
  fi
  if command -v gradle >/dev/null 2>&1; then
    echo "Gradle: $(gradle -v 2>/dev/null | head -2 | tail -1 || echo '未知')"
  fi
fi

# Node.js / npm
if [ -f "package.json" ]; then
  echo "Node.js: $(node -v 2>/dev/null || echo '不可用')"
  echo "npm: $(npm -v 2>/dev/null || echo '不可用')"
fi

# Python
if [ -f "requirements.txt" ] || [ -f "setup.py" ] || [ -f "pyproject.toml" ]; then
  echo "Python: $(python3 --version 2>/dev/null || python --version 2>/dev/null || echo '不可用')"
  echo "pip: $(pip3 --version 2>/dev/null | head -1 || pip --version 2>/dev/null | head -1 || echo '不可用')"
fi

echo ""
echo "== [5/6] 依赖安装 =="
if [ -f "pom.xml" ]; then
  echo "Maven 依赖解析..."
  mvn -q dependency:resolve 2>/dev/null || echo "Maven 依赖解析失败（可忽略，编译时会再次尝试）"
elif [ -f "package.json" ]; then
  echo "npm 依赖安装..."
  npm install --silent 2>/dev/null || echo "npm install 失败"
elif [ -f "requirements.txt" ]; then
  echo "pip 依赖安装..."
  pip3 install -r requirements.txt -q 2>/dev/null || pip install -r requirements.txt -q 2>/dev/null || echo "pip install 失败"
elif [ -f "pyproject.toml" ]; then
  echo "pip 依赖安装 (pyproject)..."
  pip3 install -e . -q 2>/dev/null || pip install -e . -q 2>/dev/null || echo "pip install 失败"
else
  echo "(未检测到构建配置文件，跳过依赖安装)"
fi

echo ""
echo "== [6/6] 编译与测试 =="
if [ -f "pom.xml" ]; then
  echo "--- Maven 编译 ---"
  if mvn -q -DskipTests compile 2>/dev/null; then
    echo "compile: ✓ 通过"
  else
    echo "compile: ✗ 失败"
  fi
  echo ""
  echo "--- 单元测试 ---"
  if mvn -q test 2>/dev/null; then
    echo "test: ✓ 通过"
  else
    echo "test: ✗ 失败或未配置"
  fi
elif [ -f "package.json" ]; then
  echo "--- 编译 ---"
  if npm run build --silent 2>/dev/null; then
    echo "build: ✓ 通过"
  else
    echo "build: ✗ 失败或未配置"
  fi
  echo ""
  echo "--- 单元测试 ---"
  if npm test --silent 2>/dev/null; then
    echo "test: ✓ 通过"
  else
    echo "test: ✗ 失败或未配置"
  fi
elif [ -f "pyproject.toml" ] || [ -f "setup.py" ] || [ -f "requirements.txt" ]; then
  echo "--- 语法检查 ---"
  if python3 -m py_compile *.py 2>/dev/null || python -m py_compile *.py 2>/dev/null; then
    echo "syntax: ✓ 通过"
  else
    echo "syntax: ✗ 失败"
  fi
  echo ""
  echo "--- 单元测试 ---"
  if python3 -m pytest -q 2>/dev/null || python -m pytest -q 2>/dev/null; then
    echo "pytest: ✓ 通过"
  else
    echo "pytest: ✗ 失败或未配置"
  fi
else
  echo "(未检测到构建配置文件，跳过验证)"
fi

echo ""
echo "============================================"
echo "  初始化完成"
echo "============================================"
echo "若所有检查通过，请继续当前 active 任务。"
