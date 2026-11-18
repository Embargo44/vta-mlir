// RUN: not %vta-opt %s 2>&1 | %FileCheck %s

// CHECK: UopEnd must be > UopBgn when ResetReg is false

module {
  vta.func @test() {
  vta.gemm_NoReset uop 1 to 1
  vta.finish
}
}
