// RUN: %vta-opt %s --vta-transform-general-structure | %FileCheck %s

module {
  vta.func @move() {
    vta.load_INP sram 0, dram 0, size 1 x 1, stride 1, pad 0, 0, 0, 0
    vta.ucode {Records = [[0, 0, 0]]}
    vta.finish
  }
}
// CHECK: vta.ucode
// CHECK-NEXT: vta.load
// CHECK-NEXT: vta.load_INP
// CHECK-NEXT: vta.finish
