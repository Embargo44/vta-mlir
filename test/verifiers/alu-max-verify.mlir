// RUN: not %vta-opt %s 2>&1 | %FileCheck %s

// CHECK: IterOut must be >= 1

module {
  vta.func @test() {
  vta.alu_MAX uop 0 to 1 {IterOut = 0 : i16}
  vta.finish
}
}
