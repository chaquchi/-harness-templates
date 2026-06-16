#!/usr/bin/env sh
set -eu

echo "============================================"
echo "  嵌入式项目初始化检查"
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
echo "== [4/6] 交叉编译工具链 =="
# ARM GCC
if command -v arm-none-eabi-gcc >/dev/null 2>&1; then
  echo "ARM GCC: $(arm-none-eabi-gcc --version | head -1)"
else
  echo "ARM GCC: 未安装（如非 ARM 平台可忽略）"
fi

# RISC-V GCC
if command -v riscv64-unknown-elf-gcc >/dev/null 2>&1; then
  echo "RISC-V GCC: $(riscv64-unknown-elf-gcc --version | head -1)"
else
  echo "RISC-V GCC: 未安装（如非 RISC-V 平台可忽略）"
fi

# AVR GCC
if command -v avr-gcc >/dev/null 2>&1; then
  echo "AVR GCC: $(avr-gcc --version | head -1)"
else
  echo "AVR GCC: 未安装（如非 AVR 平台可忽略）"
fi

# ESP32 (xtensa)
if command -v xtensa-esp32-elf-gcc >/dev/null 2>&1; then
  echo "ESP32 GCC: $(xtensa-esp32-elf-gcc --version | head -1)"
else
  echo "ESP32 GCC: 未安装（如非 ESP32 平台可忽略）"
fi

echo ""
echo "== [5/6] 构建工具 =="
if command -v make >/dev/null 2>&1; then
  echo "make: $(make --version | head -1)"
else
  echo "make: 未安装"
fi

if command -v cmake >/dev/null 2>&1; then
  echo "cmake: $(cmake --version | head -1)"
else
  echo "cmake: 未安装"
fi

if command -v west >/dev/null 2>&1; then
  echo "west: $(west --version 2>/dev/null || echo '已安装')"
fi

echo ""
echo "== [6/7] 编译验证 =="
BUILD_OK=0
if [ -f "Makefile" ]; then
  echo "--- make 编译 ---"
  if make -j$(nproc 2>/dev/null || echo 4) 2>/dev/null; then
    echo "make: ✓ 通过"
    BUILD_OK=1
  else
    echo "make: ✗ 失败（可能是工具链或目标平台未配置）"
  fi
elif [ -f "CMakeLists.txt" ]; then
  echo "--- cmake 编译 ---"
  # 使用 subshell 防止 cwd 泄漏
  (
    if [ ! -d "build" ]; then
      mkdir -p build
    fi
    cd build && cmake .. 2>/dev/null && cmake --build . -j$(nproc 2>/dev/null || echo 4) 2>/dev/null
  ) && { echo "cmake build: ✓ 通过"; BUILD_OK=1; } || echo "cmake build: ✗ 失败"
elif [ -f "west.yml" ]; then
  echo "--- west 编译 ---"
  if west build -d build 2>/dev/null; then
    echo "west build: ✓ 通过"
    BUILD_OK=1
  else
    echo "west build: ✗ 失败"
  fi
else
  echo "(未检测到 Makefile/CMakeLists.txt/west.yml，跳过编译验证)"
fi

echo ""
echo "== [7/7] 单元测试 =="
if [ "$BUILD_OK" -eq 1 ]; then
  if [ -f "CMakeLists.txt" ] && [ -f "build/CTestTestfile.cmake" ]; then
    if (cd build && ctest --output-on-failure 2>/dev/null); then
      echo "ctest: ✓ 通过"
    else
      echo "ctest: ✗ 失败或未配置"
    fi
  elif make test 2>/dev/null; then
    echo "make test: ✓ 通过"
  else
    echo "单元测试: ✗ 失败或未配置（请在目标硬件上验证）"
  fi
else
  echo "编译未通过，跳过单元测试"
fi

echo ""
echo "============================================"
echo "  初始化完成"
echo "============================================"
echo "若所有检查通过，请继续当前 active 任务。"
echo "注意：硬件验证需连接开发板并正确配置烧录工具。"
