// RUN: not %vta-opt %s 2>&1 | %FileCheck %s

// CHECK: AluOpcode must be 0-4

module {
  vta.func @test() {
  vta.alu_NoOp {ResetReg = true, AluOpcode = 5 : i8}
  vta.finish
}
}
