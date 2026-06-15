#!/usr/bin/env sh
set -eu

echo "============================================"
echo "  Linux C/C++ 项目初始化检查"
echo "============================================"

echo ""
echo "== [1/7] 当前目录 =="
pwd

echo ""
echo "== [2/7] Git 最近提交 =="
git log --oneline -5 2>/dev/null || echo "(尚无提交记录)"

echo ""
echo "== [3/7] 工作区状态 =="
git status --short 2>/dev/null || echo "(非 git 仓库或 git 不可用)"

echo ""
echo "== [4/7] 编译器版本 =="
if command -v gcc >/dev/null 2>&1; then
  echo "GCC: $(gcc --version | head -1)"
else
  echo "GCC: 未安装"
fi

if command -v g++ >/dev/null 2>&1; then
  echo "G++: $(g++ --version | head -1)"
else
  echo "G++: 未安装"
fi

if command -v clang >/dev/null 2>&1; then
  echo "Clang: $(clang --version | head -1)"
else
  echo "Clang: 未安装"
fi

echo ""
echo "== [5/7] 构建系统 =="
if command -v cmake >/dev/null 2>&1; then
  echo "CMake: $(cmake --version | head -1)"
else
  echo "CMake: 未安装"
fi

if command -v make >/dev/null 2>&1; then
  echo "make: $(make --version | head -1)"
else
  echo "make: 未安装"
fi

echo ""
echo "== [6/7] 分析工具 =="
if command -v valgrind >/dev/null 2>&1; then
  echo "Valgrind: $(valgrind --version 2>/dev/null || echo '已安装')"
else
  echo "Valgrind: 未安装（建议安装: apt install valgrind）"
fi

if command -v clang-tidy >/dev/null 2>&1; then
  echo "clang-tidy: 已安装"
else
  echo "clang-tidy: 未安装"
fi

if command -v cppcheck >/dev/null 2>&1; then
  echo "cppcheck: $(cppcheck --version 2>/dev/null || echo '已安装')"
else
  echo "cppcheck: 未安装（建议安装: apt install cppcheck）"
fi

if command -v gdb >/dev/null 2>&1; then
  echo "GDB: $(gdb --version | head -1)"
else
  echo "GDB: 未安装"
fi

echo ""
echo "== [7/7] 编译与测试 =="
if [ -f "CMakeLists.txt" ]; then
  echo "--- CMake 配置 ---"
  mkdir -p build
  if cd build && cmake .. -DCMAKE_BUILD_TYPE=Debug -DCMAKE_CXX_FLAGS="-Wall -Wextra" 2>/dev/null && cd ..; then
    echo "cmake configure: ✓ 通过"
  else
    echo "cmake configure: ✗ 失败"
    exit 1
  fi

  echo ""
  echo "--- 编译 ---"
  if cmake --build build -j$(nproc 2>/dev/null || echo 4) 2>/dev/null; then
    echo "build: ✓ 通过"
  else
    echo "build: ✗ 失败"
    exit 1
  fi

  echo ""
  echo "--- 单元测试 ---"
  if [ -f "build/CTestTestfile.cmake" ]; then
    if cd build && ctest --output-on-failure 2>/dev/null && cd ..; then
      echo "ctest: ✓ 通过"
    else
      echo "ctest: ✗ 失败"
    fi
  else
    echo "ctest: 未配置"
  fi
elif [ -f "Makefile" ]; then
  echo "--- make 编译 ---"
  if make -j$(nproc 2>/dev/null || echo 4) 2>/dev/null; then
    echo "make: ✓ 通过"
  else
    echo "make: ✗ 失败"
    exit 1
  fi

  echo ""
  echo "--- 单元测试 ---"
  if make test 2>/dev/null; then
    echo "make test: ✓ 通过"
  else
    echo "make test: ✗ 失败或未配置"
  fi
else
  echo "(未检测到 CMakeLists.txt/Makefile，跳过编译验证)"
fi

echo ""
echo "============================================"
echo "  初始化完成"
echo "============================================"
echo "若所有检查通过，请继续当前 active 任务。"
echo "提示："
echo "  - 运行 valgrind: valgrind --leak-check=full --show-leak-kinds=all ./build/<binary>"
echo "  - 运行静态分析: clang-tidy src/**/*.cpp -p build/"
echo "  - 启用 ASan: 编译时加 -fsanitize=address -fno-omit-frame-pointer"
