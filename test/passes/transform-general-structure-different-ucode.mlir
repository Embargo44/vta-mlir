// RUN: not %vta-opt %s --vta-transform-general-structure 2>&1 | %FileCheck %s
// CHECK: different micro: cannot merge ucodes with different Records

module {
  vta.func @different() {
    vta.ucode {Records = [[0, 0, 0]]}
    vta.ucode {Records = [[1, 1, 1]]}
    vta.finish
  }
}
