// RUN: %vta-opt %s --vta-transform-ucode-to-loadop | %FileCheck %s

module {
  vta.func @multiple() {
    vta.ucode {Records = [[0, 0, 0]]}
    vta.ucode {Records = [[1, 1, 1]]}
    vta.finish
  }
}
// CHECK: vta.ucode
// CHECK-NEXT: vta.load
// CHECK: vta.ucode
// CHECK-NEXT: vta.load
// CHECK: vta.finish
