// RUN: %vta-opt %s --vta-transform-general-structure | %FileCheck %s

module {
  vta.func @merge() {
    vta.ucode {Records = [[0, 0, 0]]}
    vta.ucode {Records = [[0, 0, 0]]}
    vta.finish
  }
}
// CHECK: vta.ucode
// CHECK-NEXT: vta.load
// CHECK-NOT: vta.ucode
// CHECK: vta.finish
