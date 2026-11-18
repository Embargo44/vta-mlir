// RUN: not %vta-opt %s 2>&1 | %FileCheck %s

// CHECK: MUL immediate must fit in 8 bits

module {
  vta.func @test() {
  vta.alu_MUL_imm imm 256, uop 0 to 1
  vta.finish
}
}
