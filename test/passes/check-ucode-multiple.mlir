// RUN: not %vta-opt %s --vta-check-ucode 2>&1 | %FileCheck %s
// CHECK: expected exactly one vta.ucode, found 2

module {
  vta.func @multiple() {
    vta.ucode {Records = [[0, 0, 0]]}
    vta.ucode {Records = [[1, 1, 1]]}
    vta.finish
  }
}
