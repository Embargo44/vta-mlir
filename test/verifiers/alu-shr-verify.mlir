// RUN: not %vta-opt %s 2>&1 | %FileCheck %s

// CHECK: SrcFactorIn must be 0-127

module {
  vta.func @test() {
  vta.alu_SHR uop 0 to 1 {SrcFactorIn = 128 : i8}
  vta.finish
}
}
