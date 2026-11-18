// RUN: not %vta-opt %s 2>&1 | %FileCheck %s

// CHECK: DstFactorOut must be 0-127

module {
  vta.func @test() {
  vta.gemm_NoOp {ResetReg = true, DstFactorOut = 128 : i8}
  vta.finish
}
}
