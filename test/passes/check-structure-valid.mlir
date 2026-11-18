// RUN: %vta-opt %s --vta-check-structure | %FileCheck %s

module {
  vta.func @valid() {
    vta.ucode {Records = [[0, 0, 0]]}
    vta.load_INP sram 0, dram 0, size 1 x 1, stride 1, pad 0, 0, 0, 0
    vta.finish
  }
}
// CHECK: vta.func @valid
// CHECK: vta.load_INP
// CHECK: vta.finish
