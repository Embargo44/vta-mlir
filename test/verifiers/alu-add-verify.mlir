// RUN: not %vta-opt %s 2>&1 | %FileCheck %s

// CHECK: DstFactorOut must be 0-127

module {
  vta.func @test() {
  vta.alu_ADD uop 0 to 1 {DstFactorOut = 128 : i8}
  vta.finish
}
}
