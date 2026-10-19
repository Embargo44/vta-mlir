// RUN: not %vta-opt %s 2>&1 | %FileCheck %s

// CHECK: UopBgn must be <= UopEnd

vta.func @test() {
  vta.ucode {Records = [[0, 0, 0], [1, 1, 1], [2, 2, 2]]}
  vta.gemm reset false, uop 3 to 1, iter 1 x 1,
           dst 0, 0, src 0, 0, wgt 0, 0
  vta.finish
  
}
