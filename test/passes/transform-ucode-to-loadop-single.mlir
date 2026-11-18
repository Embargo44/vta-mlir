// RUN: %vta-opt %s --vta-transform-ucode-to-loadop | %FileCheck %s

module {
  vta.func @single() {
    vta.ucode {Records = [[0, 0, 0], [1, 1, 1]]}
    vta.finish
  }
}
// CHECK: vta.ucode
// CHECK-NEXT: vta.load
// CHECK-NEXT: vta.finish
