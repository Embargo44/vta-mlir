#!/usr/bin/env bash
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
g++ -std=c++17 -O2 "$HERE/run_sim.cpp" -o "$HERE/run_sim" \
  -I"$HERE/3rdparty/tvm/3rdparty/vta-hw/include" \
  -I"$HERE/3rdparty/tvm/3rdparty/vta-hw/src" \
  -I"$HERE/3rdparty/tvm/include" \
  -I"$HERE/include" \
  -L"$HERE/3rdparty/tvm/build" -lvta_fsim -ltvm_runtime \
  -Wl,-rpath,"$HERE/3rdparty/tvm/build"
echo "built: $HERE/run_sim"
