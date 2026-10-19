// RUN: not %vta-opt %s 2>&1 | %FileCheck %s

// CHECK: UopEnd must be > UopBgn when ResetReg is false

vta.func @test() {
  vta.ucode {Records = [[0, 0, 0]]}
  vta.gemm reset false, uop 0 to 0, iter 1 x 1,
           dst 0, 0, src 0, 0, wgt 0, 0
  vta.finish
  
}
