// RUN: not %vta-opt %s --vta-check-ucode 2>&1 | %FileCheck %s
// CHECK: first VTA op must be vta.ucode

module {
  vta.func @not_first() {
    vta.load_INP sram 0, dram 0, size 1 x 1, stride 1, pad 0, 0, 0, 0
    vta.ucode {Records = [[0, 0, 0]]}
    vta.finish
  }
}
