// RUN: not %vta-opt %s --vta-check-ucode 2>&1 | %FileCheck %s
// CHECK: UopEnd exceeds ucode record count

module {
  vta.func @out_of_range() {
    vta.ucode {Records = [[0, 0, 0]]}
    vta.gemm reset false, uop 0 to 2, iter 1 x 1, dst 0, 0, src 0, 0, wgt 0, 0
    vta.finish
  }
}
