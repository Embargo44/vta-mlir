// RUN: not %vta-opt %s 2>&1 | %FileCheck %s

// CHECK: AluOpcode must be 0-4

module {
  vta.func @test() {
  vta.alu reset false, uop 0 to 1, iter 1 x 1, dst 0, 0, src 0, 0, alu 5, imm false, 0
  vta.finish
}
}
