// RUN: %vta-opt %s --vta-check-ucode | %FileCheck %s

module {
  vta.func @valid() {
    vta.ucode {Records = [[0, 0, 0]]}
    vta.gemm reset false, uop 0 to 1, iter 1 x 1, dst 0, 0, src 0, 0, wgt 0, 0
    vta.finish
  }
}
// CHECK: vta.ucode
// CHECK: vta.gemm
// CHECK: vta.finish
